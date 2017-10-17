#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/Instruction.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/Support/SourceMgr.h"

#include "llvm/IR/GlobalVariable.h"
#include "llvm/IR/Constants.h"

#include <iostream>
#include <string>
#include <sstream>
#include <istream>
#include "llvm/DebugInfo.h"
#include "llvm/Support/Debug.h"

#include <cstdio>
#include <map>
#include <set>

using namespace llvm;
using namespace std;

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

std::string trimWhitespace(std::string input) {
  std::string output = input;
  output.erase(output.begin(), std::find_if(output.begin(), output.end(), [](int ch) {
        return !std::isspace(ch);
  }));
  output.erase(std::find_if(output.rbegin(), output.rend(), [](int ch) {
        return !std::isspace(ch);
    }).base(), output.end());
  return output;
}

std::string getOperandFromLoad(std::string instruction) {
  std::stringstream ss(instruction);
  std::string item;
  vector<std::string> tokens;
  while(std::getline(ss, item, '=')) {
    tokens.push_back(item);
  }
  return trimWhitespace(tokens.at(0)).erase(0,1);
}

std::string getStringFromValuePtr(Value * val) {
  // Returns the virtual register name from a Value *
  std::string instruction, val_str;
  raw_string_ostream rso(instruction);
  val->print(rso);
  val_str = getOperandFromLoad(instruction);
  return val_str;
}

std::string getStringFromTypePtr(Type *type) {
  std::string type_string;
  raw_string_ostream rso(type_string);
  type->print(rso);
  type_string = rso.str();
  return type_string;
}

std::string getStringFromInstPtr(Instruction *inst) {
  std::string instruction;
  raw_string_ostream rso(instruction);
  inst->print(rso);
  return instruction;
}

std::string getPointerOperandFromLoadInst(LoadInst *loadInst) {
  if (loadInst->getPointerOperand()->getName().str().compare("")) {
    return loadInst->getPointerOperand()->getName().str();
  } else {
    std::string type = getStringFromTypePtr(loadInst->getPointerOperand()->getType());
    std::string instruction = getStringFromInstPtr(loadInst);
    size_t pos = instruction.find(type);
    instruction.erase(0, pos + type.length());
    pos = instruction.find(',');
    std::string pointerOperand = trimWhitespace(instruction.substr(0, pos));
    return pointerOperand.erase(0,1);
  }
}

std::string getPointerOperandFromGepInst(GetElementPtrInst *GEPI) {
  Type *ptr_operand_type = GEPI->getPointerOperandType();
  std::string type = getStringFromTypePtr(ptr_operand_type);
  std::string instruction = getStringFromInstPtr(GEPI);
  size_t pos = instruction.find(type);
  instruction.erase(0, pos + type.length());
  pos = instruction.find(',');
  std::string pointerOperand = trimWhitespace(instruction.substr(0, pos));
  return pointerOperand.erase(0,1);
}

/*
 * First Pass of the algorithm
 * Runs through the LLVM instructions and maps all seen Virtual
 * Registers to their LLVM types
 */
static void mapRegsToType(const char *name, Module *M) {
  map<std::string, Type *> name_type_map;
  set<std::string> array_reg;
  map<std::string, std::string> reg_relation_map;

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
        Value *val_ptr = nullptr;
        PointerType *ptr_type = nullptr;
        std::string name = "";

        if (isa<llvm::BinaryOperator>(&I)) {
          // errs() << "==================" << "\n";
          // I.dump();
          // errs() << "==================" << "\n";
          Value *op1 = I.getOperand(0);
          Value *op2 = I.getOperand(1);
          Type *op1_type = op1->getType();

          // Get the string representation of the virtual register
          std::string op1_str, op2_str;
          op1_str = getStringFromValuePtr(op1);
          op2_str = getStringFromValuePtr(op2);

          // Extract the lvalue's name
          std::string instruction, name;
          raw_string_ostream rso(instruction);
          I.print(rso);
          name = getOperandFromLoad(instruction);

          // Type of both operands and result will be that of op1
          name_type_map.insert(make_pair(op1_str, op1_type));
          name_type_map.insert(make_pair(op2_str, op1_type));
          name_type_map.insert(make_pair(name, op1_type));
          reg_relation_map.insert(make_pair(name, op1_str));
          // errs() << "Operand 1: " << op1_str << "\n";
          // errs() << "Operand 2: " << op2_str << "\n";
          // errs() << "lvalue's name: " << name << "\n";
          // errs() << "Their types: ";
          // op1_type->dump();
          // errs() << "\n";
        }


        // Check if I is AllocaInst
        if (AllocaInst *AI = dyn_cast<AllocaInst>(&I)) {
          // getType() returns pointer to PointerType
          ptr_type = AI->getType();
          name = AI->getName().str();

          // errs() << "==================" << "\n";
          // I.dump();
          // errs() << "==================" << "\n";
          // errs() << name << " has type: ";
          // ptr_type->dump();
          // errs() << "\n";
          // Insert into map
          name_type_map.insert(make_pair(name, ptr_type));
          // Insert to set if this is an array;
          if (ptr_type->getArrayElementType()->isArrayTy()) {
            array_reg.insert(name);
          }
        }

        // Check if I is GetElementPtrInst
        if (GetElementPtrInst *GEPI = dyn_cast<GetElementPtrInst>(&I)) {
          // errs() << "==================" << "\n";
          // I.dump();
          // errs() << "==================" << "\n";
          Type *ptr_operand_type = GEPI->getPointerOperandType();
          // errs() << "Pointer Operand Type of GEP: ";
          // ptr_operand_type->dump();
          // errs() << "\n";
          name = GEPI->getName().str();
          // errs() << "Name of lvalue: " << name << "\n";
          std::string ptr_operand = getPointerOperandFromGepInst(GEPI);
          name_type_map.insert(make_pair(name, ptr_operand_type));
          if (!GEPI->hasAllZeroIndices() && !name.substr(0,10).compare("incdec.ptr")) {
            // Check if this is from an array (ptr_operand)
            std::string current = ptr_operand;
            while(reg_relation_map.find(current) != reg_relation_map.end()) {
              current = reg_relation_map.at(current);
            }
            if (array_reg.find(current) == array_reg.end()) {
              if (MDNode *n = GEPI->getMetadata("dbg")) {
                DILocation loc(n);
                unsigned line = loc.getLineNumber();
                StringRef file = loc.getFilename();
                StringRef dir = loc.getDirectory();
                errs() << "Line " << line << " of " << dir.str() << "/"
                             << file.str() << ": Possible pointer arithmetic on non-array objects\n";
              } else {
                errs() << "Write into string literal in function "
                             << F.getName().str() << "\n";
              }
            }
          }
          reg_relation_map.insert(make_pair(name, ptr_operand));
        }

        // Check if I is load
        if (LoadInst *LI = dyn_cast<LoadInst>(&I)) {
          // errs() << "==================" << "\n";
          // I.dump();
          // errs() << "==================" << "\n";
          // Extract the operands
          val_ptr = LI->getPointerOperand();
          // errs() << "Pointer Operand: ";
          // val_ptr->dump();

          Type *ptr_operand_type = LI->getPointerOperand()->getType();
          // errs() << "Pointer Operand Type of LI: ";
          // ptr_operand_type->dump();
          // errs() << "\n";

          // Extract the lvalue's name
          std::string instruction;
          raw_string_ostream rso(instruction);
          I.print(rso);
          name = getOperandFromLoad(instruction);
          std::string pointerOperand = getPointerOperandFromLoadInst(LI);
          reg_relation_map.insert(make_pair(name, pointerOperand));
          name_type_map.insert(make_pair(name, ptr_operand_type));
        }

        // Check if I is store
        if (StoreInst *SI = dyn_cast<StoreInst>(&I)) {
          // errs() << "==================" << "\n";
          // I.dump();
          // errs() << "\n";
          // errs() << "==================" << "\n";
          // Extract the operands
          Value *val_operand = SI->getValueOperand();
          Value *ptr_operand = SI->getPointerOperand();
          // errs() << "Value Operand of Store: " << val_operand->getName().str() << "\n";
          // errs() << "Pointer Operand of Store: " << ptr_operand->getName().str() << "\n";

          // Add PointerOperand to name_type_map with type of ValueOperand
          if (ConstantExpr *expr = dyn_cast<ConstantExpr>(val_operand)) { //handle inner instructions
            if (GetElementPtrInst *GEPI = dyn_cast<GetElementPtrInst>(expr->getAsInstruction())) {
                if (GEPI->getPointerOperandType()->getArrayElementType()->isArrayTy()) {
                  array_reg.insert(ptr_operand->getName().str());
                }
            }
          }
          if (val_operand->getName().str().compare("")) {
            reg_relation_map.insert(make_pair(ptr_operand->getName().str(), val_operand->getName().str()));
          }
          std::string val_operand_name = val_operand->getName().str();
          if (validateName(val_operand_name)) {
            auto test = name_type_map.find(val_operand->getName().str());
            if (test != name_type_map.end()) {
              llvm::Type *val_operand_type = name_type_map.at(val_operand->getName().str());
              std::string ptr_operand_name = ptr_operand->getName().str();
              name_type_map.insert(make_pair(ptr_operand_name, val_operand_type));
            } else {
              // errs() << val_operand_name << " is not in the map" << "\n";
            }
          }

        }
      }
    }
  }
  // Print the set
  // errs() << "===== Array registers =====\n";
  // for (std::set<std::string>::iterator it=array_reg.begin(); it!=array_reg.end(); ++it)
	//     errs() << ' ' << *it;
	// errs()<<"\n";
  // Print the relation
  // errs() << "===== Registry relationships =====\n";
  // for (auto &x : reg_relation_map) {
  //   errs() << x.first << " is derived from: " << x.second << "\n";
  //   errs() << "\n";
  // }
  // Print the map
  // errs() << "===== Types of the names =====\n";
  // for (auto &x : name_type_map) {
  //   errs() << x.first << " has type: ";
  //   x.second->dump();
  //   errs() << "\n";
  // }
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
