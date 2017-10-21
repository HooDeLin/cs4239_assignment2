build:
	echo "Compiling PtrArith.cpp..."
	clang++ -std=c++11 PtrArith.cpp -o ptrarith `llvm-config --cxxflags` `llvm-config --ldflags` `llvm-config --libs` -lpthread -lncurses -ldl

clean:
	rm ptrarith

.PHONY: clean
