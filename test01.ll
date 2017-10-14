; ModuleID = 'test01.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.numbers = type { i16, i16, i16 }

@main.my_numbers = private unnamed_addr constant %struct.numbers { i16 1, i16 2, i16 3 }, align 2

; Function Attrs: nounwind uwtable
define i32 @sum_numbers(%struct.numbers* %numb) #0 {
entry:
  %numb.addr = alloca %struct.numbers*, align 8
  %total = alloca i32, align 4
  %numb_ptr = alloca i16*, align 8
  store %struct.numbers* %numb, %struct.numbers** %numb.addr, align 8
  store i32 0, i32* %total, align 4
  %0 = load %struct.numbers** %numb.addr, align 8
  %num_a = getelementptr inbounds %struct.numbers* %0, i32 0, i32 0
  store i16* %num_a, i16** %numb_ptr, align 8
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %1 = load i16** %numb_ptr, align 8
  %2 = load %struct.numbers** %numb.addr, align 8
  %num_c = getelementptr inbounds %struct.numbers* %2, i32 0, i32 2
  %cmp = icmp ule i16* %1, %num_c
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %3 = load i16** %numb_ptr, align 8
  %4 = load i16* %3, align 2
  %conv = sext i16 %4 to i32
  %5 = load i32* %total, align 4
  %add = add nsw i32 %5, %conv
  store i32 %add, i32* %total, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %6 = load i16** %numb_ptr, align 8
  %incdec.ptr = getelementptr inbounds i16* %6, i32 1
  store i16* %incdec.ptr, i16** %numb_ptr, align 8
  br label %for.cond

for.end:                                          ; preds = %for.cond
  %7 = load i32* %total, align 4
  ret i32 %7
}

; Function Attrs: nounwind uwtable
define i32 @main() #0 {
entry:
  %retval = alloca i32, align 4
  %my_numbers = alloca %struct.numbers, align 2
  store i32 0, i32* %retval
  %0 = bitcast %struct.numbers* %my_numbers to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* %0, i8* bitcast (%struct.numbers* @main.my_numbers to i8*), i64 6, i32 2, i1 false)
  %call = call i32 @sum_numbers(%struct.numbers* %my_numbers)
  ret i32 0
}

; Function Attrs: nounwind
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* nocapture, i8* nocapture readonly, i64, i32, i1) #1

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind }

!llvm.ident = !{!0}

!0 = metadata !{metadata !"clang version 3.4.2 (tags/RELEASE_34/dot2-final)"}
