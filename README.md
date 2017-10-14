# Using LLVM to check for pointer arithmetic done on non-array variables

We are trying to do an analysis on pointer arithmetic on non-array objects. This is the [link](https://www.securecoding.cert.org/confluence/display/c/ARR37-C.+Do+not+add+or+subtract+an+integer+to+a+pointer+to+a+non-array+object) for the SEI CERT C standard. 

This is related to software security because C struct members are not guaranteed to be contiguous. Hence, there might be an exploit where a program iterating through a struct of function pointers (via pointer arithmetic) and executing them ends up executing the an attacker’s injected functions.

# Rough algorithm sketch

**Perform 1st pass through the LLVM IR, map all virtual registers to their types**
* Data structure: an unordered map 
  * Key will be virtual register name, Value will be its LLVM type
* Keep a look out for struct pointers
* Keep a lookout for getelementptr: it doesn’t actually “get” the element pointer, but rather it adds to the address of the pointer
  * One exception where it really is used for “getting” pointers is when you supply an addition argument of 0 (so you don’t actually add anything to the address)

**Perform 2nd pass through LLVM IR**
* Keep a look out for getelementptr (because that’s the only way LLVM IR does pointer arithmetic)
* Check the arguments’ type against our hashmap
* If it’s an array, ignore it
  * If it’s non-array, we found ourselves a bug
    * Structs
    * And basically every single other type that’s not an array 
  * When we encounter a bug, print out to the screen. Or print all of them at the end, whichever way works.
