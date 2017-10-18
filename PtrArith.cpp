#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/Instruction.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/Support/SourceMgr.h"

#include "llvm/IR/GlobalVariable.h"
#include "llvm/IR/Constants.h"
#include "llvm/ADT/Twine.h"
// #include "llvm/IR/DerivedUser.h"
#include "llvm/IR/Operator.h"
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

std::string getOperandFromInstStringManually(std::string instruction) {
  std::stringstream ss(instruction);
  std::string item;
  vector<std::string> tokens;
  while(std::getline(ss, item, '=')) {
    tokens.push_back(item);
  }
  return trimWhitespace(tokens.at(0)).erase(0,1);
}

/* Functions to get std::string representation from LLVM classes */

std::string getStringFromValuePtr(Value * val) {
  // Returns the virtual register name from a Value *
  if (val->hasName()) {
    return val->getName().str();
  }
  std::string instruction, val_str;
  raw_string_ostream rso(instruction);
  val->print(rso);
  return getOperandFromInstStringManually(instruction);
}

std::string getStringFromTypePtr(Type *type) {
  std::string type_string;
  raw_string_ostream rso(type_string);
  type->print(rso);
  return rso.str();
}

std::string getStringFromInstPtr(Instruction *inst) {
  std::string instruction;
  raw_string_ostream rso(instruction);
  inst->print(rso);
  return instruction;
}

/* End of Functions to get std::string representation from LLVM classes */


/* Functions to get std::string operands from Instructions */

std::string getOperandFromInst(Instruction *instruction) {
  if (instruction->hasName()) {
    return instruction->getName().str();
  }
  std::string instruction_string = getStringFromInstPtr(instruction);
  return getOperandFromInstStringManually(instruction_string);
}

std::string getPointerOperandFromInst(Instruction *instruction, Value *pointerOperand) {
  if (pointerOperand->hasName()) {
    return pointerOperand->getName().str();
  } else {
    std::string type = getStringFromTypePtr(pointerOperand->getType());
    std::string instruction_string = getStringFromInstPtr(instruction);
    size_t pos = instruction_string.find(type);
    instruction_string.erase(0, pos + type.length());
    pos = instruction_string.find(',');
    std::string pointerOperand = trimWhitespace(instruction_string.substr(0, pos));
    return pointerOperand.erase(0,1);
  }
}

/* End of Functions to get std::string operands from Instructions */

/* Helper functions */
bool isDoingPtrArith(GetElementPtrInst *GEPI) {
  // We can know if GetElementPtrInst is doing pointer arithmetic if some indices are non zero
  // and the register value looks like %incdec.ptr, %incdec.ptr1, %incdec.ptr2 ...
  return !GEPI->hasAllZeroIndices() && !getOperandFromInst(GEPI).substr(0,10).compare("incdec.ptr");
}

bool isValueNameEmpty(Value * val) { // A value can be %a, %1 or 0
  if (val->hasName()) { // No need for more checks
    return true;
  }
  std::string instruction, val_str;
  raw_string_ostream rso(instruction);
  val->print(rso);
  std::stringstream ss(instruction);
  std::string item;
  vector<std::string> tokens;
  while(std::getline(ss, item, '=')) {
    tokens.push_back(item);
  }
  return trimWhitespace(tokens.at(0)).at(0) == '%';
}
/* End of Helper functions */

/* Function to print warnings */

void printDetectedAnalysis(GetElementPtrInst *GEPI, std::string functionName) {
  if (MDNode *n = GEPI->getMetadata("dbg")) {
    DILocation loc(n);
    unsigned line = loc.getLineNumber();
    StringRef file = loc.getFilename();
    StringRef dir = loc.getDirectory();
    errs() << "Line " << line << " of " << dir.str() << "/"
           << file.str() << ": Possible pointer arithmetic on non-array objects\n";
  } else {
    errs() << "Write into string literal in function "
           << functionName << "\n";
  }
}

/* End of Function to print warnings */

/* Main Analyse and Instruction Loop */
static void analyse(const char *name, Module *M) {
  map<std::string, Type *> name_type_map;
  map<std::string, std::string> reg_relation_map;

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
        // errs() << "==================" << "\n";
        // I.dump();
        // errs() << "\n";
        // errs() << "==================" << "\n";
        // Variables
        Value *val_ptr = nullptr;
        PointerType *ptr_type = nullptr;
        std::string name = "";

        if (isa<llvm::BinaryOperator>(&I)) {
          Value *op1 = I.getOperand(0);
          Value *op2 = I.getOperand(1);
          Type *op1_type = op1->getType();

          // Get the string representation of the virtual register
          std::string op1_str = getStringFromValuePtr(op1);
          std::string op2_str = getStringFromValuePtr(op2);

          // Extract the lvalue's name
          name = getOperandFromInst(&I);

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

        if (AllocaInst *AI = dyn_cast<AllocaInst>(&I)) {
          ptr_type = AI->getType();
          name = AI->getName().str();
          // errs() << name << " has type: ";
          // ptr_type->dump();
          // errs() << "\n";
          name_type_map.insert(make_pair(name, ptr_type));
        }

        if (GetElementPtrInst *GEPI = dyn_cast<GetElementPtrInst>(&I)) {
          Type *ptr_operand_type = GEPI->getPointerOperandType();
          // errs() << "Pointer Operand Type of GEP: ";
          // ptr_operand_type->dump();
          // errs() << "\n";
          name = getOperandFromInst(GEPI);
          // errs() << "Name of lvalue: " << name << "\n";
          std::string ptr_operand = getPointerOperandFromInst(GEPI, GEPI->getPointerOperand());
          name_type_map.insert(make_pair(name, ptr_operand_type));
          reg_relation_map.insert(make_pair(name, ptr_operand));

          // Analyse and report non-array pointer arithmetic
          if (isDoingPtrArith(GEPI)) {
            // Backtrack at most 2 levels to check if it is an array
            std::string current = ptr_operand;
            if (reg_relation_map.find(current) != reg_relation_map.end()) {
              current = reg_relation_map.at(current);
              if (reg_relation_map.find(current) != reg_relation_map.end()) {
                current = reg_relation_map.at(current);
              }
            }
            if (!name_type_map.at(current)->getArrayElementType()->isArrayTy()) {
              printDetectedAnalysis(GEPI, F.getName().str());
            }
          }
        }

        // Check if I is load
        if (LoadInst *LI = dyn_cast<LoadInst>(&I)) {
          Type *ptr_operand_type = LI->getPointerOperand()->getType();
          // errs() << "Pointer Operand Type of LI: ";
          // ptr_operand_type->dump();
          // errs() << "\n";

          // Extract the lvalue's name
          name = getOperandFromInst(LI);
          std::string pointerOperand = getPointerOperandFromInst(LI, LI->getPointerOperand());
          reg_relation_map.insert(make_pair(name, pointerOperand));
          name_type_map.insert(make_pair(name, ptr_operand_type));
        }

        // Check if I is store
        if (StoreInst *SI = dyn_cast<StoreInst>(&I)) {
          // Extract the operands
          Value *val_operand = SI->getValueOperand();
          Value *ptr_operand = SI->getPointerOperand();
          std::string val_operand_string = getStringFromValuePtr(val_operand);
          std::string ptr_operand_string = getStringFromValuePtr(ptr_operand);
          // errs() << "Value Operand of Store: " << val_operand->getName().str() << "\n";
          // errs() << "Pointer Operand of Store: " << ptr_operand->getName().str() << "\n";

          // This happens whenever it is a global array or global structs
          // Example: store i32* getelementptr inbounds ([4 x i32]* @a, i32 0, i32 0), i32** %b, align 8
          // Example: store i32* getelementptr inbounds (%struct.numbers* @mynumber, i32 0, i32 0), i32** %b, align 8
          if (ConstantExpr *expr = dyn_cast<ConstantExpr>(val_operand)) {
            if (GetElementPtrInst *GEPI = dyn_cast<GetElementPtrInst>(expr->getAsInstruction())) {
                if (GEPI->getPointerOperandType()->getArrayElementType()->isArrayTy()) {
                  // We need to update the newest type
                  name_type_map.erase(ptr_operand_string);
                  name_type_map.insert(make_pair(ptr_operand_string, GEPI->getPointerOperandType()));
                }
            }
          } else if (isValueNameEmpty(val_operand)) {
            reg_relation_map.insert(make_pair(ptr_operand_string, val_operand_string));
            name_type_map.insert(make_pair(val_operand_string, val_operand->getType()));
            name_type_map.insert(make_pair(ptr_operand_string, val_operand->getType()));
          }
        }
      }
    }
  }
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
    analyse(argv[i], M);
  }
  return 0;
}
