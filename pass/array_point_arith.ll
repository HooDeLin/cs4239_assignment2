; ModuleID = 'array_point_arith.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind uwtable
define void @func() #0 {
entry:
  %arr = alloca [4 x i32], align 16
  %b = alloca i32*, align 8
  call void @llvm.dbg.declare(metadata !{[4 x i32]* %arr}, metadata !11), !dbg !16
  %0 = bitcast [4 x i32]* %arr to i8*, !dbg !16
  call void @llvm.memset.p0i8.i64(i8* %0, i8 0, i64 16, i32 16, i1 false), !dbg !16
  call void @llvm.dbg.declare(metadata !{i32** %b}, metadata !17), !dbg !19
  %arrayidx = getelementptr inbounds [4 x i32]* %arr, i32 0, i64 1, !dbg !20
  store i32* %arrayidx, i32** %b, align 8, !dbg !20
  %1 = load i32** %b, align 8, !dbg !21
  %incdec.ptr = getelementptr inbounds i32* %1, i32 1, !dbg !21
  store i32* %incdec.ptr, i32** %b, align 8, !dbg !21
  %arraydecay = getelementptr inbounds [4 x i32]* %arr, i32 0, i32 0, !dbg !22
  store i32* %arraydecay, i32** %b, align 8, !dbg !22
  %2 = load i32** %b, align 8, !dbg !23
  %incdec.ptr1 = getelementptr inbounds i32* %2, i32 1, !dbg !23
  store i32* %incdec.ptr1, i32** %b, align 8, !dbg !23
  ret void, !dbg !24
}

; Function Attrs: nounwind readnone
declare void @llvm.dbg.declare(metadata, metadata) #1

; Function Attrs: nounwind
declare void @llvm.memset.p0i8.i64(i8* nocapture, i8, i64, i32, i1) #2

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone }
attributes #2 = { nounwind }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!8, !9}
!llvm.ident = !{!10}

!0 = metadata !{i32 786449, metadata !1, i32 12, metadata !"clang version 3.4.2 (tags/RELEASE_34/dot2-final)", i1 false, metadata !"", i32 0, metadata !2, metadata !2, metadata !3, metadata !2, metadata !2, metadata !""} ; [ DW_TAG_compile_unit ] [/home/student/assign2/proper/array_point_arith.c] [DW_LANG_C99]
!1 = metadata !{metadata !"array_point_arith.c", metadata !"/home/student/assign2/proper"}
!2 = metadata !{i32 0}
!3 = metadata !{metadata !4}
!4 = metadata !{i32 786478, metadata !1, metadata !5, metadata !"func", metadata !"func", metadata !"", i32 1, metadata !6, i1 false, i1 true, i32 0, i32 0, null, i32 0, i1 false, void ()* @func, null, null, metadata !2, i32 1} ; [ DW_TAG_subprogram ] [line 1] [def] [func]
!5 = metadata !{i32 786473, metadata !1}          ; [ DW_TAG_file_type ] [/home/student/assign2/proper/array_point_arith.c]
!6 = metadata !{i32 786453, i32 0, null, metadata !"", i32 0, i64 0, i64 0, i64 0, i32 0, null, metadata !7, i32 0, null, null, null} ; [ DW_TAG_subroutine_type ] [line 0, size 0, align 0, offset 0] [from ]
!7 = metadata !{null}
!8 = metadata !{i32 2, metadata !"Dwarf Version", i32 4}
!9 = metadata !{i32 1, metadata !"Debug Info Version", i32 1}
!10 = metadata !{metadata !"clang version 3.4.2 (tags/RELEASE_34/dot2-final)"}
!11 = metadata !{i32 786688, metadata !4, metadata !"arr", metadata !5, i32 2, metadata !12, i32 0, i32 0} ; [ DW_TAG_auto_variable ] [arr] [line 2]
!12 = metadata !{i32 786433, null, null, metadata !"", i32 0, i64 128, i64 32, i32 0, i32 0, metadata !13, metadata !14, i32 0, null, null, null} ; [ DW_TAG_array_type ] [line 0, size 128, align 32, offset 0] [from int]
!13 = metadata !{i32 786468, null, null, metadata !"int", i32 0, i64 32, i64 32, i64 0, i32 0, i32 5} ; [ DW_TAG_base_type ] [int] [line 0, size 32, align 32, offset 0, enc DW_ATE_signed]
!14 = metadata !{metadata !15}
!15 = metadata !{i32 786465, i64 0, i64 4}        ; [ DW_TAG_subrange_type ] [0, 3]
!16 = metadata !{i32 2, i32 0, metadata !4, null}
!17 = metadata !{i32 786688, metadata !4, metadata !"b", metadata !5, i32 3, metadata !18, i32 0, i32 0} ; [ DW_TAG_auto_variable ] [b] [line 3]
!18 = metadata !{i32 786447, null, null, metadata !"", i32 0, i64 64, i64 64, i64 0, i32 0, metadata !13} ; [ DW_TAG_pointer_type ] [line 0, size 64, align 64, offset 0] [from int]
!19 = metadata !{i32 3, i32 0, metadata !4, null}
!20 = metadata !{i32 4, i32 0, metadata !4, null}
!21 = metadata !{i32 5, i32 0, metadata !4, null}
!22 = metadata !{i32 6, i32 0, metadata !4, null}
!23 = metadata !{i32 7, i32 0, metadata !4, null}
!24 = metadata !{i32 8, i32 0, metadata !4, null} ; [ DW_TAG_imported_declaration ]
