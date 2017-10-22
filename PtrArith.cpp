#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/Instruction.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/IR/GlobalVariable.h"
#include "llvm/IR/Constants.h"
#include "llvm/DebugInfo.h"
#include "llvm/Support/Debug.h"

#include <sstream>
#include <cstdio>
#include <map>
#include <set>

using namespace llvm;
using namespace std;

/*
 * Function prototypes
 */
string trimWhitespace(string);
bool isDoingPtrArith(GetElementPtrInst *);
bool isValueNameEmpty(Value *);
string getStringFromValuePtr(Value *);
string getStringFromTypePtr(Type *);
string getStringFromInstPtr(Instruction *);
string getOperandFromInst(Instruction *);
string getPointerOperandFromInst(Instruction *, Value *);
string getOperandFromInstStringManually(string) ;
void printDetectedAnalysis(GetElementPtrInst *, string);
void printEndAnalysis();
string getObjectThatIsBeingDereferenced(string, Type*, map<string, string>, map<string, string>);
/*
 * Helper functions
 */

string trimWhitespace(string input) {
  // Remove whitespaces surrounding the input
  string output = input;
  output.erase(output.begin(), find_if(output.begin(), output.end(), [](int ch) {
        return !isspace(ch);
  }));
  output.erase(find_if(output.rbegin(), output.rend(), [](int ch) {
        return !isspace(ch);
    }).base(), output.end());
  return output;
}

bool isDoingPtrArith(GetElementPtrInst *GEPI) {
  // We can know if GetElementPtrInst is doing pointer arithmetic if some
  // indices are non zero and the register value looks like
  //%<some name>.ptr
  return !GEPI->hasAllZeroIndices() &&
         getOperandFromInst(GEPI)
         .find(".ptr") != string::npos;
}

bool isValueNameEmpty(Value *val) {
  // A value can be %a, %1 or 0
  if (val->hasName()) {
    // No need for more checks
    return true;
  }
  string instruction, val_str;
  raw_string_ostream rso(instruction);
  val->print(rso);
  stringstream ss(instruction);
  string item;
  vector<string> tokens;
  while(getline(ss, item, '=')) {
    tokens.push_back(item);
  }
  return trimWhitespace(tokens.at(0)).at(0) == '%';
}

// getParent gets the named value parent that are n-levels from current parent
// We do not return unnamed register (%0, %1)
string getParent(string current, map<string, string> reg_relation_map, int level) {
  if (level == 0) {
    return current;
  } else if (reg_relation_map.find(current) != reg_relation_map.end()) {
   char * p ;
   string parent = reg_relation_map.at(current);
   strtol(parent.c_str(), &p, 10) ;
   if (*p == 0) { // This is an unnamed register
     // Run the function again, without decreasing the level
     return getParent(parent, reg_relation_map, level);
   } else {
     return getParent(reg_relation_map.at(current), reg_relation_map, level - 1);
   }
  } else {
    // You have no parent
    return getParent(current, reg_relation_map, 0);
  }
}

// First, we get the parent that the type of its direct parent
// Then, we use getParent to find the object address that is being used
string getObjectThatIsBeingDereferenced(string current, Type *ptr_operand_type, map<string, string>reg_relation_map, map<string, Type*>name_type_map) {
  string direct_parent = getParent(current, reg_relation_map, 1);
  string current_type = getStringFromTypePtr(name_type_map.at(getParent(current, reg_relation_map, 1)));
  string ptr_operand_type_string = getStringFromTypePtr(ptr_operand_type);
  size_t succ = count(ptr_operand_type_string.begin(), ptr_operand_type_string.end(), '*');
  size_t pred = count(current_type.begin(), current_type.end(), '*');
  return getParent(direct_parent, reg_relation_map, (int)pred-succ + 1);
}

/*
 * Functions to get std::string representation from LLVM classes
 */

string getStringFromValuePtr(Value *val) {
  // Returns the virtual register name from a Value *
  if (val->hasName()) {
    return val->getName().str();
  }
  string instruction, val_str;
  raw_string_ostream rso(instruction);
  val->print(rso);
  return getOperandFromInstStringManually(instruction);
}

string getStringFromTypePtr(Type *type) {
  string type_string;
  raw_string_ostream rso(type_string);
  type->print(rso);
  return rso.str();
}

string getStringFromInstPtr(Instruction *inst) {
  string instruction;
  raw_string_ostream rso(instruction);
  inst->print(rso);
  return instruction;
}

/*
 * Functions to get std::string operands from llvm::Instructions
 */

string getOperandFromInst(Instruction *instruction) {
  if (instruction->hasName()) {
    return instruction->getName().str();
  }
  string instruction_string = getStringFromInstPtr(instruction);
  return getOperandFromInstStringManually(instruction_string);
}

string getPointerOperandFromInst(Instruction *instruction, Value *pointerOperand) {
  if (pointerOperand->hasName()) {
    return pointerOperand->getName().str();
  } else {
    string type = getStringFromTypePtr(pointerOperand->getType());
    string instruction_string = getStringFromInstPtr(instruction);
    size_t pos = instruction_string.find(type);
    instruction_string.erase(0, pos + type.length());
    pos = instruction_string.find(',');
    string pointerOperand = trimWhitespace(instruction_string.substr(0, pos));
    return pointerOperand.erase(0,1);
  }
}

string getOperandFromInstStringManually(string instruction) {
  stringstream ss(instruction);
  string item;
  vector<string> tokens;
  while(getline(ss, item, '=')) {
    tokens.push_back(item);
  }
  return trimWhitespace(tokens.at(0)).erase(0,1);
}

/*
 * Function to print warnings
 */
void printDetectedAnalysis(GetElementPtrInst *GEPI, string functionName) {
  if (MDNode *n = GEPI->getMetadata("dbg")) {
    DILocation loc(n);
    unsigned line = loc.getLineNumber();
    StringRef file = loc.getFilename();
    StringRef dir = loc.getDirectory();
    errs() << "Line " << line << " of " << dir.str() << "/"
           << file.str() << ": Possible pointer arithmetic on non-array objects\n";
  } else {
    errs() << "Possible pointer arithmetic on non-array objects in function "
           << functionName << "\n";
  }
}

void printEndAnalysis() {
  errs() << "========= End of analysis =========\n";
}

/*
 * Main analysis and Instruction Loop
 */
static void analyse(const char *name, Module *M) {
  map<string, Type *> name_type_map;
  map<string, string> reg_relation_map;

  for (auto &F : *M) {
    // To catch types of parameters
    // Might include values we don't need, since LLVM auto-generated functions
    // would be here too, not just the source code declared functions
    for (auto &A : F.getArgumentList()) {
      if (A.hasName())
        name_type_map.erase(getStringFromValuePtr(&A));
        name_type_map.insert(make_pair(getStringFromValuePtr(&A), A.getType()));
    }

    for (auto &BB : F) {
      for (auto &I : BB) {
        Value *val_ptr = nullptr;
        PointerType *ptr_type = nullptr;
        string name = "";

        if (isa<BinaryOperator>(&I)) {
          Value *op1 = I.getOperand(0);
          Value *op2 = I.getOperand(1);
          Type *op1_type = op1->getType();

          // Get the string representation of the virtual register
          string op1_str = getStringFromValuePtr(op1);
          string op2_str = getStringFromValuePtr(op2);
          name = getOperandFromInst(&I);

          // Type of both operands and result will be that of op1
          name_type_map.erase(op1_str);
          name_type_map.erase(op2_str);
          name_type_map.erase(name);
          reg_relation_map.erase(name);
          name_type_map.insert(make_pair(op1_str, op1_type));
          name_type_map.insert(make_pair(op2_str, op1_type));
          name_type_map.insert(make_pair(name, op1_type));
          reg_relation_map.insert(make_pair(name, op1_str));
        }

        if (AllocaInst *AI = dyn_cast<AllocaInst>(&I)) {
          ptr_type = AI->getType();
          name = AI->getName().str();
          name_type_map.erase(name); // Shouldn't happen, but just in case
          name_type_map.insert(make_pair(name, ptr_type));
        }

        if (GetElementPtrInst *GEPI = dyn_cast<GetElementPtrInst>(&I)) {
          Type *ptr_operand_type = GEPI->getPointerOperandType();
          name = getOperandFromInst(GEPI);
          string ptr_operand = getPointerOperandFromInst(GEPI, GEPI->getPointerOperand());
          name_type_map.erase(name);
          reg_relation_map.erase(name);
          name_type_map.insert(make_pair(name, ptr_operand_type));
          reg_relation_map.insert(make_pair(name, ptr_operand));

          // Analyse and report non-array pointer arithmetic
          if (isDoingPtrArith(GEPI)) {
            // We check if the address that is being used for pointer arithmetic
            // is an address corresponds to an array
            // Go to the function for more explanation on how this is done
            string object = getObjectThatIsBeingDereferenced(name, ptr_operand_type, reg_relation_map, name_type_map);
            if (!name_type_map.at(object)->getArrayElementType()->isArrayTy()) {
              printDetectedAnalysis(GEPI, F.getName().str());
            }
          }
        }

        // Check if I is load
        if (LoadInst *LI = dyn_cast<LoadInst>(&I)) {
          Type *ptr_operand_type = LI->getPointerOperand()->getType();
          name = getOperandFromInst(LI);
          string pointerOperand = getPointerOperandFromInst(LI, LI->getPointerOperand());
          reg_relation_map.erase(name);
          name_type_map.erase(name);
          reg_relation_map.insert(make_pair(name, pointerOperand));
          name_type_map.insert(make_pair(name, ptr_operand_type));
        }

        // Check if I is store
        if (StoreInst *SI = dyn_cast<StoreInst>(&I)) {
          // Extract the operands
          Value *val_operand = SI->getValueOperand();
          Value *ptr_operand = SI->getPointerOperand();
          string val_operand_string = getStringFromValuePtr(val_operand);
          string ptr_operand_string = getStringFromValuePtr(ptr_operand);

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
            // We need to check if the value is in our name_type_map,
            // this happens whenever there is a global variable
            if (name_type_map.find(val_operand_string) == name_type_map.end()) {
              name_type_map.insert(make_pair(val_operand_string, val_operand->getType()));
            }
            // We check if the value is just the updated value
            // e.g. If we don't check this, we would create a cycle in reg_relation_map
            string parent = val_operand_string;
            while(reg_relation_map.find(parent) != reg_relation_map.end() && parent != ptr_operand_string) {
              parent = reg_relation_map.at(parent);
            }
            if (parent != ptr_operand_string) { // Only add new mapping if there is no cycles
              reg_relation_map.erase(ptr_operand_string);
              name_type_map.erase(ptr_operand_string);
              reg_relation_map.insert(make_pair(ptr_operand_string, val_operand_string));
              name_type_map.insert(make_pair(ptr_operand_string, val_operand->getType()));
            }
          }
        }
      }
    }
  }
  printEndAnalysis();
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
    // Run our analysis function
    analyse(argv[i], M);
  }
  return 0;
}
