; ModuleID = 'char_pointer.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@.str = private unnamed_addr constant [6 x i8] c"abcde\00", align 1

; Function Attrs: nounwind uwtable
define void @func() #0 {
entry:
  %string = alloca i8*, align 8
  %second_string = alloca i8, align 1
  call void @llvm.dbg.declare(metadata !{i8** %string}, metadata !11), !dbg !14
  store i8* getelementptr inbounds ([6 x i8]* @.str, i32 0, i32 0), i8** %string, align 8, !dbg !14
  call void @llvm.dbg.declare(metadata !{i8* %second_string}, metadata !15), !dbg !16
  %0 = load i8** %string, align 8, !dbg !16
  %add.ptr = getelementptr inbounds i8* %0, i64 1, !dbg !16
  %1 = load i8* %add.ptr, align 1, !dbg !16
  store i8 %1, i8* %second_string, align 1, !dbg !16
  ret void, !dbg !17
}

; Function Attrs: nounwind readnone
declare void @llvm.dbg.declare(metadata, metadata) #1

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!8, !9}
!llvm.ident = !{!10}

!0 = metadata !{i32 786449, metadata !1, i32 12, metadata !"clang version 3.4.2 (tags/RELEASE_34/dot2-final)", i1 false, metadata !"", i32 0, metadata !2, metadata !2, metadata !3, metadata !2, metadata !2, metadata !""} ; [ DW_TAG_compile_unit ] [/media/sf_shared_cs4239/cs4239_assignment2/pass/char_pointer.c] [DW_LANG_C99]
!1 = metadata !{metadata !"char_pointer.c", metadata !"/media/sf_shared_cs4239/cs4239_assignment2/pass"}
!2 = metadata !{i32 0}
!3 = metadata !{metadata !4}
!4 = metadata !{i32 786478, metadata !1, metadata !5, metadata !"func", metadata !"func", metadata !"", i32 1, metadata !6, i1 false, i1 true, i32 0, i32 0, null, i32 0, i1 false, void ()* @func, null, null, metadata !2, i32 2} ; [ DW_TAG_subprogram ] [line 1] [def] [scope 2] [func]
!5 = metadata !{i32 786473, metadata !1}          ; [ DW_TAG_file_type ] [/media/sf_shared_cs4239/cs4239_assignment2/pass/char_pointer.c]
!6 = metadata !{i32 786453, i32 0, null, metadata !"", i32 0, i64 0, i64 0, i64 0, i32 0, null, metadata !7, i32 0, null, null, null} ; [ DW_TAG_subroutine_type ] [line 0, size 0, align 0, offset 0] [from ]
!7 = metadata !{null}
!8 = metadata !{i32 2, metadata !"Dwarf Version", i32 4}
!9 = metadata !{i32 1, metadata !"Debug Info Version", i32 1}
!10 = metadata !{metadata !"clang version 3.4.2 (tags/RELEASE_34/dot2-final)"}
!11 = metadata !{i32 786688, metadata !4, metadata !"string", metadata !5, i32 3, metadata !12, i32 0, i32 0} ; [ DW_TAG_auto_variable ] [string] [line 3]
!12 = metadata !{i32 786447, null, null, metadata !"", i32 0, i64 64, i64 64, i64 0, i32 0, metadata !13} ; [ DW_TAG_pointer_type ] [line 0, size 64, align 64, offset 0] [from char]
!13 = metadata !{i32 786468, null, null, metadata !"char", i32 0, i64 8, i64 8, i64 0, i32 0, i32 6} ; [ DW_TAG_base_type ] [char] [line 0, size 8, align 8, offset 0, enc DW_ATE_signed_char]
!14 = metadata !{i32 3, i32 0, metadata !4, null}
!15 = metadata !{i32 786688, metadata !4, metadata !"second_string", metadata !5, i32 4, metadata !13, i32 0, i32 0} ; [ DW_TAG_auto_variable ] [second_string] [line 4]
!16 = metadata !{i32 4, i32 0, metadata !4, null}
!17 = metadata !{i32 5, i32 0, metadata !4, null}
