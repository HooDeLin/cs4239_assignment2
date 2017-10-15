#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/Instruction.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/Support/SourceMgr.h"

#include <iostream>
#include "llvm/Support/Debug.h"

#include <cstdio>
#include <map>
#include <set>

using namespace llvm;
using namespace std;

/*
 * Test if a pointer is interesting (for the bonus).
 * I.e. is it a global or argument?
 */
static bool isPointerInteresting(Value *Ptr, map<Value *, bool> &info)
{
  auto i = info.find(Ptr);
  if (i != info.end())
    return i->second;
  info.insert(make_pair(Ptr, false));

  bool interesting = false;
  if (GetElementPtrInst *GEP = dyn_cast<GetElementPtrInst>(Ptr))
    interesting = isPointerInteresting(GEP->getPointerOperand(), info);
  else if (BitCastInst *Cast = dyn_cast<BitCastInst>(Ptr))
    interesting = isPointerInteresting(Cast->getOperand(0), info);
  else if (SelectInst *Select = dyn_cast<SelectInst>(Ptr))
  {
    interesting =
      (isPointerInteresting(Select->getOperand(1), info) ||
       isPointerInteresting(Select->getOperand(2), info));
  }
  else if (PHINode *PHI = dyn_cast<PHINode>(Ptr))
  {
    size_t numValues = PHI->getNumIncomingValues();
    for (size_t i = 0; i < numValues; i++)
    {
      interesting = isPointerInteresting(PHI->getIncomingValue(i), info);
      if (interesting)
        break;
    }
  }
  else if (isa<Argument>(Ptr) ||
      isa<GlobalVariable>(Ptr))
    interesting = true;

  if (interesting) {
    info.erase(Ptr);
    info.insert(make_pair(Ptr, true));
  }
  return interesting;
}

/*
 * Traverse the IR (backwards) to find escaping allocas.
 */
static void addEscapingAllocas(Value *Ptr, set<Value *> &seen, set<Value *> &escaping)
{
  if (seen.find(Ptr) != seen.end())
    return;
  seen.insert(Ptr);

  if (GetElementPtrInst *GEP = dyn_cast<GetElementPtrInst>(Ptr))
    addEscapingAllocas(GEP->getPointerOperand(), seen, escaping);
  else if (BitCastInst *Cast = dyn_cast<BitCastInst>(Ptr))
    addEscapingAllocas(Cast->getOperand(0), seen, escaping);
  else if (SelectInst *Select = dyn_cast<SelectInst>(Ptr))
  {
    addEscapingAllocas(Select->getOperand(1), seen, escaping);
    addEscapingAllocas(Select->getOperand(2), seen, escaping);
  }
  else if (PHINode *PHI = dyn_cast<PHINode>(Ptr))
  {
    size_t numValues = PHI->getNumIncomingValues();
    for (size_t i = 0; i < numValues; i++)
      addEscapingAllocas(PHI->getIncomingValue(i), seen, escaping);
  }
  else if (isa<AllocaInst>(Ptr))
    escaping.insert(Ptr);
}

/*
 * Prints all escaping allocas.
 */
static void escapeAnalysis(const char *name, Module *M)
{
  set<Value *> seen, escaping;
  map<Value *, bool> interesting;
  for (auto &F: *M)
  {
    for (auto &BB: F)
    {
      for (auto &I: BB)
      {
        // Check if is an escaping instruction:
        Value *Ptr = nullptr;       // Escaping pointer
        if (ReturnInst *Ret = dyn_cast<ReturnInst>(&I))
          Ptr = Ret->getReturnValue();
        else if (StoreInst *Store = dyn_cast<StoreInst>(&I))
        {
          // For the bonus:
          Ptr = Store->getPointerOperand();
          if (!isPointerInteresting(Ptr, interesting))
            continue;
          Ptr = Store->getValueOperand();
        }
        if (Ptr == nullptr || !isa<PointerType>(Ptr->getType()))
          continue;
        addEscapingAllocas(Ptr, seen, escaping);
      }
    }
  }

  // Print the results:
  printf("%s:\n", name);
  for (auto &V: escaping)
    V->dump();
}

int validateName(std::string name) {
  // Checks if the name is prefixed with %
  // Used to filter out non-virtual-register names, which can happen in
  // instructions like `store i32 0, ...`
  // TODO: this function might be buggy since I'm trying to filter out names
  // that don't have %, and for now the only ones that don't seem to have % in
  // them are '0', so name[0] won't even work because it's like a null string?
  return name.length() > 0;
  //return name[0] == '%';
}

/*
 * First Pass of the algorithm
 * Runs through the LLVM instructions and maps all seen Virtual
 * Registers to their LLVM types
 */
static void mapRegsToType(const char *name, Module *M) {
  // Probably don't need this, just ignore it first I guess
  set<Value *> seen, escaping;

  // What is a Value *?
  // I know it's a pointer to Value, but what is Value?
  map<Value *, bool> interesting;
  map<std::string, Type *> name_type_map;
 
  // `auto` keyword in C++11 means automatic type inference
  // Prior to C++11, it meant automatic lifetime, which was implicitly declared
  // C++11 Ranged-based for loop
  for (auto &F : *M) {
    // To catch types of parameters
    // Might include values we don't need, since LLVM auto-generated functions
    // would be here too, not just the source code declared functions
    for (auto &A : F.getArgumentList()) {
      std::string arg_name = A.getName().str();
      //errs() << "arg name: " << arg_name << "\n";
      if (validateName(arg_name))
        name_type_map.insert(make_pair(A.getName().str(), A.getType()));
    }

    for (auto &BB : F) {
      for (auto &I : BB) {
        // Variables
        Value *val_ptr = nullptr; // not sure what this is needed for atm
        PointerType *ptr_type = nullptr;
        std::string name = "";
 
        if (isa<llvm::BinaryOperator>(&I)) {
          errs() << "==================" << "\n";
          I.dump();
          errs() << "==================" << "\n";
          errs() << "OMG I FOUND A BINARRYYY OPERAAAATORRRR" << "\n";
        }


        // Check if I is AllocaInst
        if (AllocaInst *AI = dyn_cast<AllocaInst>(&I)) {
          // getType() returns pointer to PointerType
          ptr_type = AI->getType();
          name = AI->getName().str();

          errs() << "==================" << "\n";
          I.dump();
          errs() << "==================" << "\n";
          errs() << name << " has type: ";
          ptr_type->dump(); 
          errs() << "\n";

          // Insert into map
          name_type_map.insert(make_pair(name, ptr_type));
        }

        // Check if I is GetElementPtrInst
        if (GetElementPtrInst *GEPI = dyn_cast<GetElementPtrInst>(&I)) {
          errs() << "==================" << "\n";
          I.dump();
          errs() << "==================" << "\n";
          Type *ptr_operand_type = GEPI->getPointerOperandType();
          errs() << "Pointer Operand Type of GEP: ";
          ptr_operand_type->dump();
          errs() << "\n";
          name = GEPI->getName().str();
          errs() << "Name of lvalue: " << name << "\n";
          name_type_map.insert(make_pair(name, ptr_operand_type));
        }

        // Check if I is load
        if (LoadInst *LI = dyn_cast<LoadInst>(&I)) {
          errs() << "==================" << "\n";
          I.dump();
          errs() << "==================" << "\n";
          // Extract the operands 
          val_ptr = LI->getPointerOperand();
          errs() << "Pointer Operand: ";
          val_ptr->dump();
          errs() << "xxxxxxxxxxxxxxxx" << "\n";

          Type *ptr_operand_type = LI->getPointerOperand()->getType();
          errs() << "Pointer Operand Type of LI: ";
          ptr_operand_type->dump();
          errs() << "\n";

          // Load instructions apparently don't have explicit names...
          if ((name = LI->getName()) != NULL) {
            // Manually extract the name
          }
          //name_type_map.insert(make_pair(name, ptr_operand_type));
        }

        // Check if I is store
        //if (StoreInst *SI = dyn_cast<StoreInst>(&I)) {
        //  errs() << "==================" << "\n";
        //  I.dump();
        //  errs() << "==================" << "\n";
        //  // Extract the operands 
        //  Value *val_operand = SI->getValueOperand();
        //  Value *ptr_operand = SI->getPointerOperand();
        //  errs() << "Value Operand of Store: " << val_operand->getName().str() << "\n";
        //  errs() << "Pointer Operand of Store: " << ptr_operand->getName().str() << "\n";

        //  // Add PointerOperand to name_type_map with type of ValueOperand
        //  std::string val_operand_name = val_operand->getName().str();
        //  if (validateName(val_operand_name)) {
        //    llvm::Type *val_operand_type = name_type_map.at(val_operand->getName().str());
        //    std::string ptr_operand_name = ptr_operand->getName().str();
        //    name_type_map.insert(make_pair(ptr_operand_name, val_operand_type));
        //  }

        //}
      }
    }
  }
  // Print the map
  errs() << "===== Types of the names =====\n";
  for (auto &x : name_type_map) {
    errs() << x.first << " has type: ";
    x.second->dump();
    errs() << "\n";
  }

  // Print the results:
  printf("%s:\n", name);
  for (auto &V: escaping)
    V->dump();
}

/*
 * Main.
 */
int main(int argc, char **argv)
{
  printf("Pointer Arithmetic on Non-Array Object Analysis:\n\n");

  for (int i = 1; i < argc; i++)
  {
    LLVMContext &Context = getGlobalContext();
    SMDiagnostic Err;
    Module *M = ParseIRFile(argv[i], Err, Context);
    if (M == nullptr) {
      fprintf(stderr, "ERROR: failed to load %s\n", argv[i]);
      continue;
    }
    // our analysis function
    mapRegsToType(argv[i], M);
  }
  return 0;
}

