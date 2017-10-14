echo "Compiling PtrArith.cpp..."

clang++ -std=c++11 PtrArith.cpp -o ptrarith `llvm-config --cxxflags` `llvm-config --ldflags` `llvm-config --libs` -lpthread -lncurses -ldl

echo "Running PtrArith with input test01.ll"
./ptrarith test01.ll
