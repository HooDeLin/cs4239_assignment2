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
  call void @llvm.dbg.declare(metadata !{%struct.numbers** %numb.addr}, metadata !23), !dbg !24
  call void @llvm.dbg.declare(metadata !{i32* %total}, metadata !25), !dbg !26
  store i32 0, i32* %total, align 4, !dbg !26
  call void @llvm.dbg.declare(metadata !{i16** %numb_ptr}, metadata !27), !dbg !30
  %0 = load %struct.numbers** %numb.addr, align 8, !dbg !31
  %num_a = getelementptr inbounds %struct.numbers* %0, i32 0, i32 0, !dbg !31
  store i16* %num_a, i16** %numb_ptr, align 8, !dbg !31
  br label %for.cond, !dbg !31

for.cond:                                         ; preds = %for.inc, %entry
  %1 = load i16** %numb_ptr, align 8, !dbg !31
  %2 = load %struct.numbers** %numb.addr, align 8, !dbg !31
  %num_c = getelementptr inbounds %struct.numbers* %2, i32 0, i32 2, !dbg !31
  %cmp = icmp ule i16* %1, %num_c, !dbg !31
  br i1 %cmp, label %for.body, label %for.end, !dbg !31

for.body:                                         ; preds = %for.cond
  %3 = load i16** %numb_ptr, align 8, !dbg !33
  %4 = load i16* %3, align 2, !dbg !33
  %conv = sext i16 %4 to i32, !dbg !33
  %5 = load i32* %total, align 4, !dbg !33
  %add = add nsw i32 %5, %conv, !dbg !33
  store i32 %add, i32* %total, align 4, !dbg !33
  br label %for.inc, !dbg !35

for.inc:                                          ; preds = %for.body
  %6 = load i16** %numb_ptr, align 8, !dbg !36
  %incdec.ptr = getelementptr inbounds i16* %6, i32 1, !dbg !36
  store i16* %incdec.ptr, i16** %numb_ptr, align 8, !dbg !36
  br label %for.cond, !dbg !36

for.end:                                          ; preds = %for.cond
  %7 = load i32* %total, align 4, !dbg !37
  ret i32 %7, !dbg !37
}

; Function Attrs: nounwind readnone
declare void @llvm.dbg.declare(metadata, metadata) #1

; Function Attrs: nounwind uwtable
define i32 @main() #0 {
entry:
  %retval = alloca i32, align 4
  %my_numbers = alloca %struct.numbers, align 2
  store i32 0, i32* %retval
  call void @llvm.dbg.declare(metadata !{%struct.numbers* %my_numbers}, metadata !38), !dbg !39
  %0 = bitcast %struct.numbers* %my_numbers to i8*, !dbg !39
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* %0, i8* bitcast (%struct.numbers* @main.my_numbers to i8*), i64 6, i32 2, i1 false), !dbg !39
  %call = call i32 @sum_numbers(%struct.numbers* %my_numbers), !dbg !40
  ret i32 0, !dbg !41
}

; Function Attrs: nounwind
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* nocapture, i8* nocapture readonly, i64, i32, i1) #2

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone }
attributes #2 = { nounwind }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!20, !21}
!llvm.ident = !{!22}

!0 = metadata !{i32 786449, metadata !1, i32 12, metadata !"clang version 3.4.2 (tags/RELEASE_34/dot2-final)", i1 false, metadata !"", i32 0, metadata !2, metadata !2, metadata !3, metadata !2, metadata !2, metadata !""} ; [ DW_TAG_compile_unit ] [/media/sf_shared_cs4239/cs4239_assignment2/test01.c] [DW_LANG_C99]
!1 = metadata !{metadata !"test01.c", metadata !"/media/sf_shared_cs4239/cs4239_assignment2"}
!2 = metadata !{i32 0}
!3 = metadata !{metadata !4, metadata !17}
!4 = metadata !{i32 786478, metadata !1, metadata !5, metadata !"sum_numbers", metadata !"sum_numbers", metadata !"", i32 7, metadata !6, i1 false, i1 true, i32 0, i32 0, null, i32 256, i1 false, i32 (%struct.numbers*)* @sum_numbers, null, null, metadata !2, i32 7} ; [ DW_TAG_subprogram ] [line 7] [def] [sum_numbers]
!5 = metadata !{i32 786473, metadata !1}          ; [ DW_TAG_file_type ] [/media/sf_shared_cs4239/cs4239_assignment2/test01.c]
!6 = metadata !{i32 786453, i32 0, null, metadata !"", i32 0, i64 0, i64 0, i64 0, i32 0, null, metadata !7, i32 0, null, null, null} ; [ DW_TAG_subroutine_type ] [line 0, size 0, align 0, offset 0] [from ]
!7 = metadata !{metadata !8, metadata !9}
!8 = metadata !{i32 786468, null, null, metadata !"int", i32 0, i64 32, i64 32, i64 0, i32 0, i32 5} ; [ DW_TAG_base_type ] [int] [line 0, size 32, align 32, offset 0, enc DW_ATE_signed]
!9 = metadata !{i32 786447, null, null, metadata !"", i32 0, i64 64, i64 64, i64 0, i32 0, metadata !10} ; [ DW_TAG_pointer_type ] [line 0, size 64, align 64, offset 0] [from ]
!10 = metadata !{i32 786470, null, null, metadata !"", i32 0, i64 0, i64 0, i64 0, i32 0, metadata !11} ; [ DW_TAG_const_type ] [line 0, size 0, align 0, offset 0] [from numbers]
!11 = metadata !{i32 786451, metadata !1, null, metadata !"numbers", i32 3, i64 48, i64 16, i32 0, i32 0, null, metadata !12, i32 0, null, null, null} ; [ DW_TAG_structure_type ] [numbers] [line 3, size 48, align 16, offset 0] [def] [from ]
!12 = metadata !{metadata !13, metadata !15, metadata !16}
!13 = metadata !{i32 786445, metadata !1, metadata !11, metadata !"num_a", i32 4, i64 16, i64 16, i64 0, i32 0, metadata !14} ; [ DW_TAG_member ] [num_a] [line 4, size 16, align 16, offset 0] [from short]
!14 = metadata !{i32 786468, null, null, metadata !"short", i32 0, i64 16, i64 16, i64 0, i32 0, i32 5} ; [ DW_TAG_base_type ] [short] [line 0, size 16, align 16, offset 0, enc DW_ATE_signed]
!15 = metadata !{i32 786445, metadata !1, metadata !11, metadata !"num_b", i32 4, i64 16, i64 16, i64 16, i32 0, metadata !14} ; [ DW_TAG_member ] [num_b] [line 4, size 16, align 16, offset 16] [from short]
!16 = metadata !{i32 786445, metadata !1, metadata !11, metadata !"num_c", i32 4, i64 16, i64 16, i64 32, i32 0, metadata !14} ; [ DW_TAG_member ] [num_c] [line 4, size 16, align 16, offset 32] [from short]
!17 = metadata !{i32 786478, metadata !1, metadata !5, metadata !"main", metadata !"main", metadata !"", i32 21, metadata !18, i1 false, i1 true, i32 0, i32 0, null, i32 0, i1 false, i32 ()* @main, null, null, metadata !2, i32 21} ; [ DW_TAG_subprogram ] [line 21] [def] [main]
!18 = metadata !{i32 786453, i32 0, null, metadata !"", i32 0, i64 0, i64 0, i64 0, i32 0, null, metadata !19, i32 0, null, null, null} ; [ DW_TAG_subroutine_type ] [line 0, size 0, align 0, offset 0] [from ]
!19 = metadata !{metadata !8}
!20 = metadata !{i32 2, metadata !"Dwarf Version", i32 4}
!21 = metadata !{i32 1, metadata !"Debug Info Version", i32 1}
!22 = metadata !{metadata !"clang version 3.4.2 (tags/RELEASE_34/dot2-final)"}
!23 = metadata !{i32 786689, metadata !4, metadata !"numb", metadata !5, i32 16777223, metadata !9, i32 0, i32 0} ; [ DW_TAG_arg_variable ] [numb] [line 7]
!24 = metadata !{i32 7, i32 0, metadata !4, null}
!25 = metadata !{i32 786688, metadata !4, metadata !"total", metadata !5, i32 8, metadata !8, i32 0, i32 0} ; [ DW_TAG_auto_variable ] [total] [line 8]
!26 = metadata !{i32 8, i32 0, metadata !4, null} ; [ DW_TAG_imported_declaration ]
!27 = metadata !{i32 786688, metadata !4, metadata !"numb_ptr", metadata !5, i32 9, metadata !28, i32 0, i32 0} ; [ DW_TAG_auto_variable ] [numb_ptr] [line 9]
!28 = metadata !{i32 786447, null, null, metadata !"", i32 0, i64 64, i64 64, i64 0, i32 0, metadata !29} ; [ DW_TAG_pointer_type ] [line 0, size 64, align 64, offset 0] [from ]
!29 = metadata !{i32 786470, null, null, metadata !"", i32 0, i64 0, i64 0, i64 0, i32 0, metadata !14} ; [ DW_TAG_const_type ] [line 0, size 0, align 0, offset 0] [from short]
!30 = metadata !{i32 9, i32 0, metadata !4, null}
!31 = metadata !{i32 12, i32 0, metadata !32, null}
!32 = metadata !{i32 786443, metadata !1, metadata !4, i32 12, i32 0, i32 0} ; [ DW_TAG_lexical_block ] [/media/sf_shared_cs4239/cs4239_assignment2/test01.c]
!33 = metadata !{i32 15, i32 0, metadata !34, null}
!34 = metadata !{i32 786443, metadata !1, metadata !32, i32 14, i32 0, i32 1} ; [ DW_TAG_lexical_block ] [/media/sf_shared_cs4239/cs4239_assignment2/test01.c]
!35 = metadata !{i32 16, i32 0, metadata !34, null}
!36 = metadata !{i32 14, i32 0, metadata !32, null}
!37 = metadata !{i32 18, i32 0, metadata !4, null}
!38 = metadata !{i32 786688, metadata !17, metadata !"my_numbers", metadata !5, i32 22, metadata !11, i32 0, i32 0} ; [ DW_TAG_auto_variable ] [my_numbers] [line 22]
!39 = metadata !{i32 22, i32 0, metadata !17, null}
!40 = metadata !{i32 23, i32 0, metadata !17, null}
!41 = metadata !{i32 24, i32 0, metadata !17, null}
