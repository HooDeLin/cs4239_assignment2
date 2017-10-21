; ModuleID = 'bypass.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.numbers = type { [4 x i32], i32, i32 }

; Function Attrs: nounwind uwtable
define void @func() #0 {
entry:
  %my_numbers = alloca %struct.numbers, align 4
  %b1 = alloca i32*, align 8
  call void @llvm.dbg.declare(metadata !{%struct.numbers* %my_numbers}, metadata !11), !dbg !21
  %a = getelementptr inbounds %struct.numbers* %my_numbers, i32 0, i32 1, !dbg !22
  store i32 123, i32* %a, align 4, !dbg !22
  %b = getelementptr inbounds %struct.numbers* %my_numbers, i32 0, i32 2, !dbg !23
  store i32 456, i32* %b, align 4, !dbg !23
  call void @llvm.dbg.declare(metadata !{i32** %b1}, metadata !24), !dbg !26
  %arr_num = getelementptr inbounds %struct.numbers* %my_numbers, i32 0, i32 0, !dbg !27
  %arrayidx = getelementptr inbounds [4 x i32]* %arr_num, i32 0, i64 3, !dbg !27
  store i32* %arrayidx, i32** %b1, align 8, !dbg !27
  %0 = load i32** %b1, align 8, !dbg !28
  %incdec.ptr = getelementptr inbounds i32* %0, i32 1, !dbg !28
  store i32* %incdec.ptr, i32** %b1, align 8, !dbg !28
  %1 = load i32** %b1, align 8, !dbg !29
  %incdec.ptr2 = getelementptr inbounds i32* %1, i32 1, !dbg !29
  store i32* %incdec.ptr2, i32** %b1, align 8, !dbg !29
  ret void, !dbg !30
}

; Function Attrs: nounwind readnone
declare void @llvm.dbg.declare(metadata, metadata) #1

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!8, !9}
!llvm.ident = !{!10}

!0 = metadata !{i32 786449, metadata !1, i32 12, metadata !"clang version 3.4.2 (tags/RELEASE_34/dot2-final)", i1 false, metadata !"", i32 0, metadata !2, metadata !2, metadata !3, metadata !2, metadata !2, metadata !""} ; [ DW_TAG_compile_unit ] [/media/sf_shared_cs4239/cs4239_assignment2/bypass.c] [DW_LANG_C99]
!1 = metadata !{metadata !"bypass.c", metadata !"/media/sf_shared_cs4239/cs4239_assignment2"}
!2 = metadata !{i32 0}
!3 = metadata !{metadata !4}
!4 = metadata !{i32 786478, metadata !1, metadata !5, metadata !"func", metadata !"func", metadata !"", i32 7, metadata !6, i1 false, i1 true, i32 0, i32 0, null, i32 0, i1 false, void ()* @func, null, null, metadata !2, i32 7} ; [ DW_TAG_subprogram ] [line 7] [def] [func]
!5 = metadata !{i32 786473, metadata !1}          ; [ DW_TAG_file_type ] [/media/sf_shared_cs4239/cs4239_assignment2/bypass.c]
!6 = metadata !{i32 786453, i32 0, null, metadata !"", i32 0, i64 0, i64 0, i64 0, i32 0, null, metadata !7, i32 0, null, null, null} ; [ DW_TAG_subroutine_type ] [line 0, size 0, align 0, offset 0] [from ]
!7 = metadata !{null}
!8 = metadata !{i32 2, metadata !"Dwarf Version", i32 4}
!9 = metadata !{i32 1, metadata !"Debug Info Version", i32 1}
!10 = metadata !{metadata !"clang version 3.4.2 (tags/RELEASE_34/dot2-final)"}
!11 = metadata !{i32 786688, metadata !4, metadata !"my_numbers", metadata !5, i32 8, metadata !12, i32 0, i32 0} ; [ DW_TAG_auto_variable ] [my_numbers] [line 8]
!12 = metadata !{i32 786451, metadata !1, null, metadata !"numbers", i32 1, i64 192, i64 32, i32 0, i32 0, null, metadata !13, i32 0, null, null, null} ; [ DW_TAG_structure_type ] [numbers] [line 1, size 192, align 32, offset 0] [def] [from ]
!13 = metadata !{metadata !14, metadata !19, metadata !20}
!14 = metadata !{i32 786445, metadata !1, metadata !12, metadata !"arr_num", i32 2, i64 128, i64 32, i64 0, i32 0, metadata !15} ; [ DW_TAG_member ] [arr_num] [line 2, size 128, align 32, offset 0] [from ]
!15 = metadata !{i32 786433, null, null, metadata !"", i32 0, i64 128, i64 32, i32 0, i32 0, metadata !16, metadata !17, i32 0, null, null, null} ; [ DW_TAG_array_type ] [line 0, size 128, align 32, offset 0] [from int]
!16 = metadata !{i32 786468, null, null, metadata !"int", i32 0, i64 32, i64 32, i64 0, i32 0, i32 5} ; [ DW_TAG_base_type ] [int] [line 0, size 32, align 32, offset 0, enc DW_ATE_signed]
!17 = metadata !{metadata !18}
!18 = metadata !{i32 786465, i64 0, i64 4}        ; [ DW_TAG_subrange_type ] [0, 3]
!19 = metadata !{i32 786445, metadata !1, metadata !12, metadata !"a", i32 3, i64 32, i64 32, i64 128, i32 0, metadata !16} ; [ DW_TAG_member ] [a] [line 3, size 32, align 32, offset 128] [from int]
!20 = metadata !{i32 786445, metadata !1, metadata !12, metadata !"b", i32 4, i64 32, i64 32, i64 160, i32 0, metadata !16} ; [ DW_TAG_member ] [b] [line 4, size 32, align 32, offset 160] [from int]
!21 = metadata !{i32 8, i32 0, metadata !4, null} ; [ DW_TAG_imported_declaration ]
!22 = metadata !{i32 9, i32 0, metadata !4, null}
!23 = metadata !{i32 10, i32 0, metadata !4, null}
!24 = metadata !{i32 786688, metadata !4, metadata !"b", metadata !5, i32 11, metadata !25, i32 0, i32 0} ; [ DW_TAG_auto_variable ] [b] [line 11]
!25 = metadata !{i32 786447, null, null, metadata !"", i32 0, i64 64, i64 64, i64 0, i32 0, metadata !16} ; [ DW_TAG_pointer_type ] [line 0, size 64, align 64, offset 0] [from int]
!26 = metadata !{i32 11, i32 0, metadata !4, null}
!27 = metadata !{i32 12, i32 0, metadata !4, null}
!28 = metadata !{i32 13, i32 0, metadata !4, null}
!29 = metadata !{i32 14, i32 0, metadata !4, null}
!30 = metadata !{i32 15, i32 0, metadata !4, null}
