; ModuleID = 'global_int_point_arith.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@c = global i32 1, align 4

; Function Attrs: nounwind uwtable
define void @func() #0 {
entry:
  %b = alloca i32*, align 8
  call void @llvm.dbg.declare(metadata !{i32** %b}, metadata !14), !dbg !16
  store i32* @c, i32** %b, align 8, !dbg !17
  %0 = load i32** %b, align 8, !dbg !18
  %incdec.ptr = getelementptr inbounds i32* %0, i32 1, !dbg !18
  store i32* %incdec.ptr, i32** %b, align 8, !dbg !18
  ret void, !dbg !19
}

; Function Attrs: nounwind readnone
declare void @llvm.dbg.declare(metadata, metadata) #1

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!11, !12}
!llvm.ident = !{!13}

!0 = metadata !{i32 786449, metadata !1, i32 12, metadata !"clang version 3.4.2 (tags/RELEASE_34/dot2-final)", i1 false, metadata !"", i32 0, metadata !2, metadata !2, metadata !3, metadata !8, metadata !2, metadata !""} ; [ DW_TAG_compile_unit ] [/home/student/assign2/proper/global_int_point_arith.c] [DW_LANG_C99]
!1 = metadata !{metadata !"global_int_point_arith.c", metadata !"/home/student/assign2/proper"}
!2 = metadata !{i32 0}
!3 = metadata !{metadata !4}
!4 = metadata !{i32 786478, metadata !1, metadata !5, metadata !"func", metadata !"func", metadata !"", i32 3, metadata !6, i1 false, i1 true, i32 0, i32 0, null, i32 0, i1 false, void ()* @func, null, null, metadata !2, i32 4} ; [ DW_TAG_subprogram ] [line 3] [def] [scope 4] [func]
!5 = metadata !{i32 786473, metadata !1}          ; [ DW_TAG_file_type ] [/home/student/assign2/proper/global_int_point_arith.c]
!6 = metadata !{i32 786453, i32 0, null, metadata !"", i32 0, i64 0, i64 0, i64 0, i32 0, null, metadata !7, i32 0, null, null, null} ; [ DW_TAG_subroutine_type ] [line 0, size 0, align 0, offset 0] [from ]
!7 = metadata !{null}
!8 = metadata !{metadata !9}
!9 = metadata !{i32 786484, i32 0, null, metadata !"c", metadata !"c", metadata !"", metadata !5, i32 1, metadata !10, i32 0, i32 1, i32* @c, null} ; [ DW_TAG_variable ] [c] [line 1] [def]
!10 = metadata !{i32 786468, null, null, metadata !"int", i32 0, i64 32, i64 32, i64 0, i32 0, i32 5} ; [ DW_TAG_base_type ] [int] [line 0, size 32, align 32, offset 0, enc DW_ATE_signed]
!11 = metadata !{i32 2, metadata !"Dwarf Version", i32 4}
!12 = metadata !{i32 1, metadata !"Debug Info Version", i32 1}
!13 = metadata !{metadata !"clang version 3.4.2 (tags/RELEASE_34/dot2-final)"}
!14 = metadata !{i32 786688, metadata !4, metadata !"b", metadata !5, i32 5, metadata !15, i32 0, i32 0} ; [ DW_TAG_auto_variable ] [b] [line 5]
!15 = metadata !{i32 786447, null, null, metadata !"", i32 0, i64 64, i64 64, i64 0, i32 0, metadata !10} ; [ DW_TAG_pointer_type ] [line 0, size 64, align 64, offset 0] [from int]
!16 = metadata !{i32 5, i32 0, metadata !4, null}
!17 = metadata !{i32 6, i32 0, metadata !4, null}
!18 = metadata !{i32 7, i32 0, metadata !4, null}
!19 = metadata !{i32 8, i32 0, metadata !4, null} ; [ DW_TAG_imported_declaration ]
