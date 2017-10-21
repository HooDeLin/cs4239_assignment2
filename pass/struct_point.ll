; ModuleID = 'struct_point.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.numbers = type { i32, i32 }

@func.my_numbers = private unnamed_addr constant %struct.numbers { i32 1, i32 2 }, align 4

; Function Attrs: nounwind uwtable
define void @func() #0 {
entry:
  %my_numbers = alloca %struct.numbers, align 4
  %b = alloca i32*, align 8
  call void @llvm.dbg.declare(metadata !{%struct.numbers* %my_numbers}, metadata !11), !dbg !17
  %0 = bitcast %struct.numbers* %my_numbers to i8*, !dbg !17
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* %0, i8* bitcast (%struct.numbers* @func.my_numbers to i8*), i64 8, i32 4, i1 false), !dbg !17
  call void @llvm.dbg.declare(metadata !{i32** %b}, metadata !18), !dbg !20
  %a = getelementptr inbounds %struct.numbers* %my_numbers, i32 0, i32 0, !dbg !21
  store i32* %a, i32** %b, align 8, !dbg !21
  ret void, !dbg !22
}

; Function Attrs: nounwind readnone
declare void @llvm.dbg.declare(metadata, metadata) #1

; Function Attrs: nounwind
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* nocapture, i8* nocapture readonly, i64, i32, i1) #2

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone }
attributes #2 = { nounwind }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!8, !9}
!llvm.ident = !{!10}

!0 = metadata !{i32 786449, metadata !1, i32 12, metadata !"clang version 3.4.2 (tags/RELEASE_34/dot2-final)", i1 false, metadata !"", i32 0, metadata !2, metadata !2, metadata !3, metadata !2, metadata !2, metadata !""} ; [ DW_TAG_compile_unit ] [/home/student/assign2/proper/struct_point.c] [DW_LANG_C99]
!1 = metadata !{metadata !"struct_point.c", metadata !"/home/student/assign2/proper"}
!2 = metadata !{i32 0}
!3 = metadata !{metadata !4}
!4 = metadata !{i32 786478, metadata !1, metadata !5, metadata !"func", metadata !"func", metadata !"", i32 6, metadata !6, i1 false, i1 true, i32 0, i32 0, null, i32 0, i1 false, void ()* @func, null, null, metadata !2, i32 6} ; [ DW_TAG_subprogram ] [line 6] [def] [func]
!5 = metadata !{i32 786473, metadata !1}          ; [ DW_TAG_file_type ] [/home/student/assign2/proper/struct_point.c]
!6 = metadata !{i32 786453, i32 0, null, metadata !"", i32 0, i64 0, i64 0, i64 0, i32 0, null, metadata !7, i32 0, null, null, null} ; [ DW_TAG_subroutine_type ] [line 0, size 0, align 0, offset 0] [from ]
!7 = metadata !{null}
!8 = metadata !{i32 2, metadata !"Dwarf Version", i32 4}
!9 = metadata !{i32 1, metadata !"Debug Info Version", i32 1}
!10 = metadata !{metadata !"clang version 3.4.2 (tags/RELEASE_34/dot2-final)"}
!11 = metadata !{i32 786688, metadata !4, metadata !"my_numbers", metadata !5, i32 7, metadata !12, i32 0, i32 0} ; [ DW_TAG_auto_variable ] [my_numbers] [line 7]
!12 = metadata !{i32 786451, metadata !1, null, metadata !"numbers", i32 1, i64 64, i64 32, i32 0, i32 0, null, metadata !13, i32 0, null, null, null} ; [ DW_TAG_structure_type ] [numbers] [line 1, size 64, align 32, offset 0] [def] [from ]
!13 = metadata !{metadata !14, metadata !16}
!14 = metadata !{i32 786445, metadata !1, metadata !12, metadata !"a", i32 2, i64 32, i64 32, i64 0, i32 0, metadata !15} ; [ DW_TAG_member ] [a] [line 2, size 32, align 32, offset 0] [from int]
!15 = metadata !{i32 786468, null, null, metadata !"int", i32 0, i64 32, i64 32, i64 0, i32 0, i32 5} ; [ DW_TAG_base_type ] [int] [line 0, size 32, align 32, offset 0, enc DW_ATE_signed]
!16 = metadata !{i32 786445, metadata !1, metadata !12, metadata !"b", i32 3, i64 32, i64 32, i64 32, i32 0, metadata !15} ; [ DW_TAG_member ] [b] [line 3, size 32, align 32, offset 32] [from int]
!17 = metadata !{i32 7, i32 0, metadata !4, null}
!18 = metadata !{i32 786688, metadata !4, metadata !"b", metadata !5, i32 8, metadata !19, i32 0, i32 0} ; [ DW_TAG_auto_variable ] [b] [line 8]
!19 = metadata !{i32 786447, null, null, metadata !"", i32 0, i64 64, i64 64, i64 0, i32 0, metadata !15} ; [ DW_TAG_pointer_type ] [line 0, size 64, align 64, offset 0] [from int]
!20 = metadata !{i32 8, i32 0, metadata !4, null} ; [ DW_TAG_imported_declaration ]
!21 = metadata !{i32 9, i32 0, metadata !4, null}
!22 = metadata !{i32 10, i32 0, metadata !4, null}
