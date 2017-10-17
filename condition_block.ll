; ModuleID = 'condition_block.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@func.b = private unnamed_addr constant [4 x i32] [i32 1, i32 2, i32 3, i32 4], align 16

; Function Attrs: nounwind uwtable
define void @func() #0 {
entry:
  %a = alloca i32, align 4
  %b = alloca [4 x i32], align 16
  %c = alloca i32*, align 8
  call void @llvm.dbg.declare(metadata !{i32* %a}, metadata !11), !dbg !13
  store i32 1, i32* %a, align 4, !dbg !13
  call void @llvm.dbg.declare(metadata !{[4 x i32]* %b}, metadata !14), !dbg !18
  %0 = bitcast [4 x i32]* %b to i8*, !dbg !18
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* %0, i8* bitcast ([4 x i32]* @func.b to i8*), i64 16, i32 16, i1 false), !dbg !18
  call void @llvm.dbg.declare(metadata !{i32** %c}, metadata !19), !dbg !21
  %1 = load i32* %a, align 4, !dbg !22
  %cmp = icmp eq i32 %1, 1, !dbg !22
  br i1 %cmp, label %if.then, label %if.else, !dbg !22

if.then:                                          ; preds = %entry
  store i32* %a, i32** %c, align 8, !dbg !24
  %2 = load i32** %c, align 8, !dbg !26
  %incdec.ptr = getelementptr inbounds i32* %2, i32 1, !dbg !26
  store i32* %incdec.ptr, i32** %c, align 8, !dbg !26
  br label %if.end, !dbg !27

if.else:                                          ; preds = %entry
  %arrayidx = getelementptr inbounds [4 x i32]* %b, i32 0, i64 1, !dbg !28
  store i32* %arrayidx, i32** %c, align 8, !dbg !28
  %3 = load i32** %c, align 8, !dbg !30
  %incdec.ptr1 = getelementptr inbounds i32* %3, i32 1, !dbg !30
  store i32* %incdec.ptr1, i32** %c, align 8, !dbg !30
  br label %if.end

if.end:                                           ; preds = %if.else, %if.then
  ret void, !dbg !31
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

!0 = metadata !{i32 786449, metadata !1, i32 12, metadata !"clang version 3.4.2 (tags/RELEASE_34/dot2-final)", i1 false, metadata !"", i32 0, metadata !2, metadata !2, metadata !3, metadata !2, metadata !2, metadata !""} ; [ DW_TAG_compile_unit ] [/home/student/assign2/proper/condition_block.c] [DW_LANG_C99]
!1 = metadata !{metadata !"condition_block.c", metadata !"/home/student/assign2/proper"}
!2 = metadata !{i32 0}
!3 = metadata !{metadata !4}
!4 = metadata !{i32 786478, metadata !1, metadata !5, metadata !"func", metadata !"func", metadata !"", i32 1, metadata !6, i1 false, i1 true, i32 0, i32 0, null, i32 0, i1 false, void ()* @func, null, null, metadata !2, i32 2} ; [ DW_TAG_subprogram ] [line 1] [def] [scope 2] [func]
!5 = metadata !{i32 786473, metadata !1}          ; [ DW_TAG_file_type ] [/home/student/assign2/proper/condition_block.c]
!6 = metadata !{i32 786453, i32 0, null, metadata !"", i32 0, i64 0, i64 0, i64 0, i32 0, null, metadata !7, i32 0, null, null, null} ; [ DW_TAG_subroutine_type ] [line 0, size 0, align 0, offset 0] [from ]
!7 = metadata !{null}
!8 = metadata !{i32 2, metadata !"Dwarf Version", i32 4}
!9 = metadata !{i32 1, metadata !"Debug Info Version", i32 1}
!10 = metadata !{metadata !"clang version 3.4.2 (tags/RELEASE_34/dot2-final)"}
!11 = metadata !{i32 786688, metadata !4, metadata !"a", metadata !5, i32 3, metadata !12, i32 0, i32 0} ; [ DW_TAG_auto_variable ] [a] [line 3]
!12 = metadata !{i32 786468, null, null, metadata !"int", i32 0, i64 32, i64 32, i64 0, i32 0, i32 5} ; [ DW_TAG_base_type ] [int] [line 0, size 32, align 32, offset 0, enc DW_ATE_signed]
!13 = metadata !{i32 3, i32 0, metadata !4, null}
!14 = metadata !{i32 786688, metadata !4, metadata !"b", metadata !5, i32 4, metadata !15, i32 0, i32 0} ; [ DW_TAG_auto_variable ] [b] [line 4]
!15 = metadata !{i32 786433, null, null, metadata !"", i32 0, i64 128, i64 32, i32 0, i32 0, metadata !12, metadata !16, i32 0, null, null, null} ; [ DW_TAG_array_type ] [line 0, size 128, align 32, offset 0] [from int]
!16 = metadata !{metadata !17}
!17 = metadata !{i32 786465, i64 0, i64 4}        ; [ DW_TAG_subrange_type ] [0, 3]
!18 = metadata !{i32 4, i32 0, metadata !4, null}
!19 = metadata !{i32 786688, metadata !4, metadata !"c", metadata !5, i32 5, metadata !20, i32 0, i32 0} ; [ DW_TAG_auto_variable ] [c] [line 5]
!20 = metadata !{i32 786447, null, null, metadata !"", i32 0, i64 64, i64 64, i64 0, i32 0, metadata !12} ; [ DW_TAG_pointer_type ] [line 0, size 64, align 64, offset 0] [from int]
!21 = metadata !{i32 5, i32 0, metadata !4, null}
!22 = metadata !{i32 6, i32 0, metadata !23, null}
!23 = metadata !{i32 786443, metadata !1, metadata !4, i32 6, i32 0, i32 0} ; [ DW_TAG_lexical_block ] [/home/student/assign2/proper/condition_block.c]
!24 = metadata !{i32 8, i32 0, metadata !25, null} ; [ DW_TAG_imported_declaration ]
!25 = metadata !{i32 786443, metadata !1, metadata !23, i32 7, i32 0, i32 1} ; [ DW_TAG_lexical_block ] [/home/student/assign2/proper/condition_block.c]
!26 = metadata !{i32 9, i32 0, metadata !25, null}
!27 = metadata !{i32 10, i32 0, metadata !25, null}
!28 = metadata !{i32 11, i32 0, metadata !29, null}
!29 = metadata !{i32 786443, metadata !1, metadata !23, i32 10, i32 0, i32 2} ; [ DW_TAG_lexical_block ] [/home/student/assign2/proper/condition_block.c]
!30 = metadata !{i32 12, i32 0, metadata !29, null}
!31 = metadata !{i32 14, i32 0, metadata !4, null}
