	.file	"m.c"
	.text
.Ltext0:
	.file 0 "/home/davea/dwarf/regressiontests/macroendfileIssue343" "m.c"
	.globl	main
	.type	main, @function
main:
.LFB0:
	.file 1 "m.c"
	.loc 1 4 15
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	.loc 1 4 23
	movl	$3, %eax
	.loc 1 4 27
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE0:
	.size	main, .-main
.Letext0:
	.section	.debug_info,"",@progbits
.Ldebug_info0:
	.long	0x75
	.value	0x5
	.byte	0x1
	.byte	0x8
	.long	.Ldebug_abbrev0
	.uleb128 0x2
	.long	.LASF480
	.byte	0x1d
	.byte	0x3
	.long	0x31647
	.long	.LASF0
	.long	.LASF1
	.quad	.Ltext0
	.quad	.Letext0-.Ltext0
	.long	.Ldebug_line0
	.long	.Ldebug_macro0
	.uleb128 0x1
	.byte	0x8
	.byte	0x5
	.long	.LASF476
	.uleb128 0x1
	.byte	0x8
	.byte	0x7
	.long	.LASF477
	.uleb128 0x3
	.byte	0x4
	.byte	0x5
	.string	"int"
	.uleb128 0x1
	.byte	0x8
	.byte	0x5
	.long	.LASF478
	.uleb128 0x1
	.byte	0x10
	.byte	0x4
	.long	.LASF479
	.uleb128 0x4
	.long	.LASF481
	.byte	0x1
	.byte	0x4
	.byte	0x5
	.long	0x45
	.quad	.LFB0
	.quad	.LFE0-.LFB0
	.uleb128 0x1
	.byte	0x9c
	.byte	0
	.section	.debug_abbrev,"",@progbits
.Ldebug_abbrev0:
	.uleb128 0x1
	.uleb128 0x24
	.byte	0
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x3e
	.uleb128 0xb
	.uleb128 0x3
	.uleb128 0xe
	.byte	0
	.byte	0
	.uleb128 0x2
	.uleb128 0x11
	.byte	0x1
	.uleb128 0x25
	.uleb128 0xe
	.uleb128 0x13
	.uleb128 0xb
	.uleb128 0x90
	.uleb128 0xb
	.uleb128 0x91
	.uleb128 0x6
	.uleb128 0x3
	.uleb128 0x1f
	.uleb128 0x1b
	.uleb128 0x1f
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x7
	.uleb128 0x10
	.uleb128 0x17
	.uleb128 0x79
	.uleb128 0x17
	.byte	0
	.byte	0
	.uleb128 0x3
	.uleb128 0x24
	.byte	0
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x3e
	.uleb128 0xb
	.uleb128 0x3
	.uleb128 0x8
	.byte	0
	.byte	0
	.uleb128 0x4
	.uleb128 0x2e
	.byte	0
	.uleb128 0x3f
	.uleb128 0x19
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x27
	.uleb128 0x19
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x7
	.uleb128 0x40
	.uleb128 0x18
	.uleb128 0x7a
	.uleb128 0x19
	.byte	0
	.byte	0
	.byte	0
	.section	.debug_aranges,"",@progbits
	.long	0x2c
	.value	0x2
	.long	.Ldebug_info0
	.byte	0x8
	.byte	0
	.value	0
	.value	0
	.quad	.Ltext0
	.quad	.Letext0-.Ltext0
	.quad	0
	.quad	0
	.section	.debug_macro,"",@progbits
.Ldebug_macro0:
	.value	0x5
	.byte	0x2
	.long	.Ldebug_line0
	.byte	0x7
	.long	.Ldebug_macro2
	.byte	0x3
	.uleb128 0
	.uleb128 0x1
	.file 2 "/usr/include/stdc-predef.h"
	.byte	0x3
	.uleb128 0
	.uleb128 0x2
	.byte	0x7
	.long	.Ldebug_macro3
	.byte	0x4
	.byte	0x1
	.uleb128 0x1
	.string	"A 1"
	.byte	0x1
	.uleb128 0x2
	.string	"B 2"
	.file 3 "/usr/lib/gcc/x86_64-linux-gnu/15/include/stddef.h"
	.byte	0x3
	.uleb128 0x3
	.uleb128 0x3
	.byte	0x7
	.long	.Ldebug_macro4
	.byte	0x4
	.byte	0x4
	.byte	0x4
	.byte	0x4
	.byte	0
	.section	.debug_macro,"G",@progbits,wm4.0.266f34e6189184e0ef8d66523ffd0315,comdat
.Ldebug_macro2:
	.value	0x5
	.byte	0
	.byte	0x5
	.uleb128 0
	.long	.LASF2
	.byte	0x5
	.uleb128 0
	.long	.LASF3
	.byte	0x5
	.uleb128 0
	.long	.LASF4
	.byte	0x5
	.uleb128 0
	.long	.LASF5
	.byte	0x5
        .uleb128 0
	.long	.LASF6
	.byte	0x5
	.uleb128 0
	.long	.LASF7
	.byte	0x5
	.uleb128 0
	.long	.LASF8
	.byte	0x5
	.uleb128 0
	.long	.LASF9
	.byte	0x5
	.uleb128 0
	.long	.LASF10
	.byte	0x5
	.uleb128 0
	.long	.LASF11
	.byte	0x5
	.uleb128 0
	.long	.LASF12
	.byte	0x5
	.uleb128 0
	.long	.LASF13
	.byte	0x5
	.uleb128 0
	.long	.LASF14
	.byte	0x5
	.uleb128 0
	.long	.LASF15
	.byte	0x5
	.uleb128 0
	.long	.LASF16
	.byte	0x5
	.uleb128 0
	.long	.LASF17
	.byte	0x5
	.uleb128 0
	.long	.LASF18
	.byte	0x5
	.uleb128 0
	.long	.LASF19
	.byte	0x5
	.uleb128 0
	.long	.LASF20
	.byte	0x5
	.uleb128 0
	.long	.LASF21
	.byte	0x5
	.uleb128 0
	.long	.LASF22
	.byte	0x5
	.uleb128 0
	.long	.LASF23
	.byte	0x5
	.uleb128 0
	.long	.LASF24
	.byte	0x5
	.uleb128 0
	.long	.LASF25
	.byte	0x5
	.uleb128 0
	.long	.LASF26
	.byte	0x5
	.uleb128 0
	.long	.LASF27
	.byte	0x5
	.uleb128 0
	.long	.LASF28
	.byte	0x5
	.uleb128 0
	.long	.LASF29
	.byte	0x5
	.uleb128 0
	.long	.LASF30
	.byte	0x5
	.uleb128 0
	.long	.LASF31
	.byte	0x5
	.uleb128 0
	.long	.LASF32
	.byte	0x5
	.uleb128 0
	.long	.LASF33
	.byte	0x5
	.uleb128 0
	.long	.LASF34
	.byte	0x5
	.uleb128 0
	.long	.LASF35
	.byte	0x5
	.uleb128 0
	.long	.LASF36
	.byte	0x5
	.uleb128 0
	.long	.LASF37
	.byte	0x5
	.uleb128 0
	.long	.LASF38
	.byte	0x5
	.uleb128 0
	.long	.LASF39
	.byte	0x5
	.uleb128 0
	.long	.LASF40
	.byte	0x5
	.uleb128 0
	.long	.LASF41
	.byte	0x5
	.uleb128 0
	.long	.LASF42
	.byte	0x5
	.uleb128 0
	.long	.LASF43
	.byte	0x5
	.uleb128 0
	.long	.LASF44
	.byte	0x5
	.uleb128 0
	.long	.LASF45
	.byte	0x5
	.uleb128 0
	.long	.LASF46
	.byte	0x5
	.uleb128 0
	.long	.LASF47
	.byte	0x5
	.uleb128 0
	.long	.LASF48
	.byte	0x5
	.uleb128 0
	.long	.LASF49
	.byte	0x5
	.uleb128 0
	.long	.LASF50
	.byte	0x5
	.uleb128 0
	.long	.LASF51
	.byte	0x5
	.uleb128 0
	.long	.LASF52
	.byte	0x5
	.uleb128 0
	.long	.LASF53
	.byte	0x5
	.uleb128 0
	.long	.LASF54
	.byte	0x5
	.uleb128 0
	.long	.LASF55
	.byte	0x5
	.uleb128 0
	.long	.LASF56
	.byte	0x5
	.uleb128 0
	.long	.LASF57
	.byte	0x5
	.uleb128 0
	.long	.LASF58
	.byte	0x5
	.uleb128 0
	.long	.LASF59
	.byte	0x5
	.uleb128 0
	.long	.LASF60
	.byte	0x5
	.uleb128 0
	.long	.LASF61
	.byte	0x5
	.uleb128 0
	.long	.LASF62
	.byte	0x5
	.uleb128 0
	.long	.LASF63
	.byte	0x5
	.uleb128 0
	.long	.LASF64
	.byte	0x5
	.uleb128 0
	.long	.LASF65
	.byte	0x5
	.uleb128 0
	.long	.LASF66
	.byte	0x5
	.uleb128 0
	.long	.LASF67
	.byte	0x5
	.uleb128 0
	.long	.LASF68
	.byte	0x5
	.uleb128 0
	.long	.LASF69
	.byte	0x5
	.uleb128 0
	.long	.LASF70
	.byte	0x5
	.uleb128 0
	.long	.LASF71
	.byte	0x5
	.uleb128 0
	.long	.LASF72
	.byte	0x5
	.uleb128 0
	.long	.LASF73
	.byte	0x5
	.uleb128 0
	.long	.LASF74
	.byte	0x5
	.uleb128 0
	.long	.LASF75
	.byte	0x5
	.uleb128 0
	.long	.LASF76
	.byte	0x5
	.uleb128 0
	.long	.LASF77
	.byte	0x5
	.uleb128 0
	.long	.LASF78
	.byte	0x5
	.uleb128 0
	.long	.LASF79
	.byte	0x5
	.uleb128 0
	.long	.LASF80
	.byte	0x5
	.uleb128 0
	.long	.LASF81
	.byte	0x5
	.uleb128 0
	.long	.LASF82
	.byte	0x5
	.uleb128 0
	.long	.LASF83
	.byte	0x5
	.uleb128 0
	.long	.LASF84
	.byte	0x5
	.uleb128 0
	.long	.LASF85
	.byte	0x5
	.uleb128 0
	.long	.LASF86
	.byte	0x5
	.uleb128 0
	.long	.LASF87
	.byte	0x5
	.uleb128 0
	.long	.LASF88
	.byte	0x5
	.uleb128 0
	.long	.LASF89
	.byte	0x5
	.uleb128 0
	.long	.LASF90
	.byte	0x5
	.uleb128 0
	.long	.LASF91
	.byte	0x5
	.uleb128 0
	.long	.LASF92
	.byte	0x5
	.uleb128 0
	.long	.LASF93
	.byte	0x5
	.uleb128 0
	.long	.LASF94
	.byte	0x5
	.uleb128 0
	.long	.LASF95
	.byte	0x5
	.uleb128 0
	.long	.LASF96
	.byte	0x5
	.uleb128 0
	.long	.LASF97
	.byte	0x5
	.uleb128 0
	.long	.LASF98
	.byte	0x5
	.uleb128 0
	.long	.LASF99
	.byte	0x5
	.uleb128 0
	.long	.LASF100
	.byte	0x5
	.uleb128 0
	.long	.LASF101
	.byte	0x5
	.uleb128 0
	.long	.LASF102
	.byte	0x5
	.uleb128 0
	.long	.LASF103
	.byte	0x5
	.uleb128 0
	.long	.LASF104
	.byte	0x5
	.uleb128 0
	.long	.LASF105
	.byte	0x5
	.uleb128 0
	.long	.LASF106
	.byte	0x5
	.uleb128 0
	.long	.LASF107
	.byte	0x5
	.uleb128 0
	.long	.LASF108
	.byte	0x5
	.uleb128 0
	.long	.LASF109
	.byte	0x5
	.uleb128 0
	.long	.LASF110
	.byte	0x5
	.uleb128 0
	.long	.LASF111
	.byte	0x5
	.uleb128 0
	.long	.LASF112
	.byte	0x5
	.uleb128 0
	.long	.LASF113
	.byte	0x5
	.uleb128 0
	.long	.LASF114
	.byte	0x5
	.uleb128 0
	.long	.LASF115
	.byte	0x5
	.uleb128 0
	.long	.LASF116
	.byte	0x5
	.uleb128 0
	.long	.LASF117
	.byte	0x5
	.uleb128 0
	.long	.LASF118
	.byte	0x5
	.uleb128 0
	.long	.LASF119
	.byte	0x5
	.uleb128 0
	.long	.LASF120
	.byte	0x5
	.uleb128 0
	.long	.LASF121
	.byte	0x5
	.uleb128 0
	.long	.LASF122
	.byte	0x5
	.uleb128 0
	.long	.LASF123
	.byte	0x5
	.uleb128 0
	.long	.LASF124
	.byte	0x5
	.uleb128 0
	.long	.LASF125
	.byte	0x5
	.uleb128 0
	.long	.LASF126
	.byte	0x5
	.uleb128 0
	.long	.LASF127
	.byte	0x5
	.uleb128 0
	.long	.LASF128
	.byte	0x5
	.uleb128 0
	.long	.LASF129
	.byte	0x5
	.uleb128 0
	.long	.LASF130
	.byte	0x5
	.uleb128 0
	.long	.LASF131
	.byte	0x5
	.uleb128 0
	.long	.LASF132
	.byte	0x5
	.uleb128 0
	.long	.LASF133
	.byte	0x5
	.uleb128 0
	.long	.LASF134
	.byte	0x5
	.uleb128 0
	.long	.LASF135
	.byte	0x5
	.uleb128 0
	.long	.LASF136
	.byte	0x5
	.uleb128 0
	.long	.LASF137
	.byte	0x5
	.uleb128 0
	.long	.LASF138
	.byte	0x5
	.uleb128 0
	.long	.LASF139
	.byte	0x5
	.uleb128 0
	.long	.LASF140
	.byte	0x5
	.uleb128 0
	.long	.LASF141
	.byte	0x5
	.uleb128 0
	.long	.LASF142
	.byte	0x5
	.uleb128 0
	.long	.LASF143
	.byte	0x5
	.uleb128 0
	.long	.LASF144
	.byte	0x5
	.uleb128 0
	.long	.LASF145
	.byte	0x5
	.uleb128 0
	.long	.LASF146
	.byte	0x5
	.uleb128 0
	.long	.LASF147
	.byte	0x5
	.uleb128 0
	.long	.LASF148
	.byte	0x5
	.uleb128 0
	.long	.LASF149
	.byte	0x5
	.uleb128 0
	.long	.LASF150
	.byte	0x5
	.uleb128 0
	.long	.LASF151
	.byte	0x5
	.uleb128 0
	.long	.LASF152
	.byte	0x5
	.uleb128 0
	.long	.LASF153
	.byte	0x5
	.uleb128 0
	.long	.LASF154
	.byte	0x5
	.uleb128 0
	.long	.LASF155
	.byte	0x5
	.uleb128 0
	.long	.LASF156
	.byte	0x5
	.uleb128 0
	.long	.LASF157
	.byte	0x5
	.uleb128 0
	.long	.LASF158
	.byte	0x5
	.uleb128 0
	.long	.LASF159
	.byte	0x5
	.uleb128 0
	.long	.LASF160
	.byte	0x5
	.uleb128 0
	.long	.LASF161
	.byte	0x5
	.uleb128 0
	.long	.LASF162
	.byte	0x5
	.uleb128 0
	.long	.LASF163
	.byte	0x5
	.uleb128 0
	.long	.LASF164
	.byte	0x5
	.uleb128 0
	.long	.LASF165
	.byte	0x5
	.uleb128 0
	.long	.LASF166
	.byte	0x5
	.uleb128 0
	.long	.LASF167
	.byte	0x5
	.uleb128 0
	.long	.LASF168
	.byte	0x5
	.uleb128 0
	.long	.LASF169
	.byte	0x5
	.uleb128 0
	.long	.LASF170
	.byte	0x5
	.uleb128 0
	.long	.LASF171
	.byte	0x5
	.uleb128 0
	.long	.LASF172
	.byte	0x5
	.uleb128 0
	.long	.LASF173
	.byte	0x5
	.uleb128 0
	.long	.LASF174
	.byte	0x5
	.uleb128 0
	.long	.LASF175
	.byte	0x5
	.uleb128 0
	.long	.LASF176
	.byte	0x5
	.uleb128 0
	.long	.LASF177
	.byte	0x5
	.uleb128 0
	.long	.LASF178
	.byte	0x5
	.uleb128 0
	.long	.LASF179
	.byte	0x5
	.uleb128 0
	.long	.LASF180
	.byte	0x5
	.uleb128 0
	.long	.LASF181
	.byte	0x5
	.uleb128 0
	.long	.LASF182
	.byte	0x5
	.uleb128 0
	.long	.LASF183
	.byte	0x5
	.uleb128 0
	.long	.LASF184
	.byte	0x5
	.uleb128 0
	.long	.LASF185
	.byte	0x5
	.uleb128 0
	.long	.LASF186
	.byte	0x5
	.uleb128 0
	.long	.LASF187
	.byte	0x5
	.uleb128 0
	.long	.LASF188
	.byte	0x5
	.uleb128 0
	.long	.LASF189
	.byte	0x5
	.uleb128 0
	.long	.LASF190
	.byte	0x5
	.uleb128 0
	.long	.LASF191
	.byte	0x5
	.uleb128 0
	.long	.LASF192
	.byte	0x5
	.uleb128 0
	.long	.LASF193
	.byte	0x5
	.uleb128 0
	.long	.LASF194
	.byte	0x5
	.uleb128 0
	.long	.LASF195
	.byte	0x5
	.uleb128 0
	.long	.LASF196
	.byte	0x5
	.uleb128 0
	.long	.LASF197
	.byte	0x5
	.uleb128 0
	.long	.LASF198
	.byte	0x5
	.uleb128 0
	.long	.LASF199
	.byte	0x5
	.uleb128 0
	.long	.LASF200
	.byte	0x5
	.uleb128 0
	.long	.LASF201
	.byte	0x5
	.uleb128 0
	.long	.LASF202
	.byte	0x5
	.uleb128 0
	.long	.LASF203
	.byte	0x5
	.uleb128 0
	.long	.LASF204
	.byte	0x5
	.uleb128 0
	.long	.LASF205
	.byte	0x5
	.uleb128 0
	.long	.LASF206
	.byte	0x5
	.uleb128 0
	.long	.LASF207
	.byte	0x5
	.uleb128 0
	.long	.LASF208
	.byte	0x5
	.uleb128 0
	.long	.LASF209
	.byte	0x5
	.uleb128 0
	.long	.LASF210
	.byte	0x5
	.uleb128 0
	.long	.LASF211
	.byte	0x5
	.uleb128 0
	.long	.LASF212
	.byte	0x5
	.uleb128 0
	.long	.LASF213
	.byte	0x5
	.uleb128 0
	.long	.LASF214
	.byte	0x5
	.uleb128 0
	.long	.LASF215
	.byte	0x5
	.uleb128 0
	.long	.LASF216
	.byte	0x5
	.uleb128 0
	.long	.LASF217
	.byte	0x5
	.uleb128 0
	.long	.LASF218
	.byte	0x5
	.uleb128 0
	.long	.LASF219
	.byte	0x5
	.uleb128 0
	.long	.LASF220
	.byte	0x5
	.uleb128 0
	.long	.LASF221
	.byte	0x5
	.uleb128 0
	.long	.LASF222
	.byte	0x5
	.uleb128 0
	.long	.LASF223
	.byte	0x5
	.uleb128 0
	.long	.LASF224
	.byte	0x5
	.uleb128 0
	.long	.LASF225
	.byte	0x5
	.uleb128 0
	.long	.LASF226
	.byte	0x5
	.uleb128 0
	.long	.LASF227
	.byte	0x5
	.uleb128 0
	.long	.LASF228
	.byte	0x5
	.uleb128 0
	.long	.LASF229
	.byte	0x5
	.uleb128 0
	.long	.LASF230
	.byte	0x5
	.uleb128 0
	.long	.LASF231
	.byte	0x5
	.uleb128 0
	.long	.LASF232
	.byte	0x5
	.uleb128 0
	.long	.LASF233
	.byte	0x5
	.uleb128 0
	.long	.LASF234
	.byte	0x5
	.uleb128 0
	.long	.LASF235
	.byte	0x5
	.uleb128 0
	.long	.LASF236
	.byte	0x5
	.uleb128 0
	.long	.LASF237
	.byte	0x5
	.uleb128 0
	.long	.LASF238
	.byte	0x5
	.uleb128 0
	.long	.LASF239
	.byte	0x5
	.uleb128 0
	.long	.LASF240
	.byte	0x5
	.uleb128 0
	.long	.LASF241
	.byte	0x5
	.uleb128 0
	.long	.LASF242
	.byte	0x5
	.uleb128 0
	.long	.LASF243
	.byte	0x5
	.uleb128 0
	.long	.LASF244
	.byte	0x5
	.uleb128 0
	.long	.LASF245
	.byte	0x5
	.uleb128 0
	.long	.LASF246
	.byte	0x5
	.uleb128 0
	.long	.LASF247
	.byte	0x5
	.uleb128 0
	.long	.LASF248
	.byte	0x5
	.uleb128 0
	.long	.LASF249
	.byte	0x5
	.uleb128 0
	.long	.LASF250
	.byte	0x5
	.uleb128 0
	.long	.LASF251
	.byte	0x5
	.uleb128 0
	.long	.LASF252
	.byte	0x5
	.uleb128 0
	.long	.LASF253
	.byte	0x5
	.uleb128 0
	.long	.LASF254
	.byte	0x5
	.uleb128 0
	.long	.LASF255
	.byte	0x5
	.uleb128 0
	.long	.LASF256
	.byte	0x5
	.uleb128 0
	.long	.LASF257
	.byte	0x5
	.uleb128 0
	.long	.LASF258
	.byte	0x5
	.uleb128 0
	.long	.LASF259
	.byte	0x5
	.uleb128 0
	.long	.LASF260
	.byte	0x5
	.uleb128 0
	.long	.LASF261
	.byte	0x5
	.uleb128 0
	.long	.LASF262
	.byte	0x5
	.uleb128 0
	.long	.LASF263
	.byte	0x5
	.uleb128 0
	.long	.LASF264
	.byte	0x5
	.uleb128 0
	.long	.LASF265
	.byte	0x5
	.uleb128 0
	.long	.LASF266
	.byte	0x5
	.uleb128 0
	.long	.LASF267
	.byte	0x5
	.uleb128 0
	.long	.LASF268
	.byte	0x5
	.uleb128 0
	.long	.LASF269
	.byte	0x5
	.uleb128 0
	.long	.LASF270
	.byte	0x5
	.uleb128 0
	.long	.LASF271
	.byte	0x5
	.uleb128 0
	.long	.LASF272
	.byte	0x5
	.uleb128 0
	.long	.LASF273
	.byte	0x5
	.uleb128 0
	.long	.LASF274
	.byte	0x5
	.uleb128 0
	.long	.LASF275
	.byte	0x5
	.uleb128 0
	.long	.LASF276
	.byte	0x5
	.uleb128 0
	.long	.LASF277
	.byte	0x5
	.uleb128 0
	.long	.LASF278
	.byte	0x5
	.uleb128 0
	.long	.LASF279
	.byte	0x5
	.uleb128 0
	.long	.LASF280
	.byte	0x5
	.uleb128 0
	.long	.LASF281
	.byte	0x5
	.uleb128 0
	.long	.LASF282
	.byte	0x5
	.uleb128 0
	.long	.LASF283
	.byte	0x5
	.uleb128 0
	.long	.LASF284
	.byte	0x5
	.uleb128 0
	.long	.LASF285
	.byte	0x5
	.uleb128 0
	.long	.LASF286
	.byte	0x5
	.uleb128 0
	.long	.LASF287
	.byte	0x5
	.uleb128 0
	.long	.LASF288
	.byte	0x5
	.uleb128 0
	.long	.LASF289
	.byte	0x5
	.uleb128 0
	.long	.LASF290
	.byte	0x5
	.uleb128 0
	.long	.LASF291
	.byte	0x5
	.uleb128 0
	.long	.LASF292
	.byte	0x5
	.uleb128 0
	.long	.LASF293
	.byte	0x5
	.uleb128 0
	.long	.LASF294
	.byte	0x5
	.uleb128 0
	.long	.LASF295
	.byte	0x5
	.uleb128 0
	.long	.LASF296
	.byte	0x5
	.uleb128 0
	.long	.LASF297
	.byte	0x5
	.uleb128 0
	.long	.LASF298
	.byte	0x5
	.uleb128 0
	.long	.LASF299
	.byte	0x5
	.uleb128 0
	.long	.LASF300
	.byte	0x5
	.uleb128 0
	.long	.LASF301
	.byte	0x5
	.uleb128 0
	.long	.LASF302
	.byte	0x5
	.uleb128 0
	.long	.LASF303
	.byte	0x5
	.uleb128 0
	.long	.LASF304
	.byte	0x5
	.uleb128 0
	.long	.LASF305
	.byte	0x5
	.uleb128 0
	.long	.LASF306
	.byte	0x5
	.uleb128 0
	.long	.LASF307
	.byte	0x5
	.uleb128 0
	.long	.LASF308
	.byte	0x5
	.uleb128 0
	.long	.LASF309
	.byte	0x5
	.uleb128 0
	.long	.LASF310
	.byte	0x5
	.uleb128 0
	.long	.LASF311
	.byte	0x5
	.uleb128 0
	.long	.LASF312
	.byte	0x5
	.uleb128 0
	.long	.LASF313
	.byte	0x5
	.uleb128 0
	.long	.LASF314
	.byte	0x5
	.uleb128 0
	.long	.LASF315
	.byte	0x5
	.uleb128 0
	.long	.LASF316
	.byte	0x5
	.uleb128 0
	.long	.LASF317
	.byte	0x5
	.uleb128 0
	.long	.LASF318
	.byte	0x5
	.uleb128 0
	.long	.LASF319
	.byte	0x5
	.uleb128 0
	.long	.LASF320
	.byte	0x5
	.uleb128 0
	.long	.LASF321
	.byte	0x5
	.uleb128 0
	.long	.LASF322
	.byte	0x5
	.uleb128 0
	.long	.LASF323
	.byte	0x5
	.uleb128 0
	.long	.LASF324
	.byte	0x5
	.uleb128 0
	.long	.LASF325
	.byte	0x5
	.uleb128 0
	.long	.LASF326
	.byte	0x5
	.uleb128 0
	.long	.LASF327
	.byte	0x5
	.uleb128 0
	.long	.LASF328
	.byte	0x5
	.uleb128 0
	.long	.LASF329
	.byte	0x5
	.uleb128 0
	.long	.LASF330
	.byte	0x5
	.uleb128 0
	.long	.LASF331
	.byte	0x5
	.uleb128 0
	.long	.LASF332
	.byte	0x5
	.uleb128 0
	.long	.LASF333
	.byte	0x5
	.uleb128 0
	.long	.LASF334
	.byte	0x5
	.uleb128 0
	.long	.LASF335
	.byte	0x5
	.uleb128 0
	.long	.LASF336
	.byte	0x5
	.uleb128 0
	.long	.LASF337
	.byte	0x5
	.uleb128 0
	.long	.LASF338
	.byte	0x5
	.uleb128 0
	.long	.LASF339
	.byte	0x5
	.uleb128 0
	.long	.LASF340
	.byte	0x5
	.uleb128 0
	.long	.LASF341
	.byte	0x5
	.uleb128 0
	.long	.LASF342
	.byte	0x5
	.uleb128 0
	.long	.LASF343
	.byte	0x5
	.uleb128 0
	.long	.LASF344
	.byte	0x5
	.uleb128 0
	.long	.LASF345
	.byte	0x5
	.uleb128 0
	.long	.LASF346
	.byte	0x5
	.uleb128 0
	.long	.LASF347
	.byte	0x5
	.uleb128 0
	.long	.LASF348
	.byte	0x5
	.uleb128 0
	.long	.LASF349
	.byte	0x5
	.uleb128 0
	.long	.LASF350
	.byte	0x5
	.uleb128 0
	.long	.LASF351
	.byte	0x5
	.uleb128 0
	.long	.LASF352
	.byte	0x5
	.uleb128 0
	.long	.LASF353
	.byte	0x5
	.uleb128 0
	.long	.LASF354
	.byte	0x5
	.uleb128 0
	.long	.LASF355
	.byte	0x5
	.uleb128 0
	.long	.LASF356
	.byte	0x5
	.uleb128 0
	.long	.LASF357
	.byte	0x5
	.uleb128 0
	.long	.LASF358
	.byte	0x5
	.uleb128 0
	.long	.LASF359
	.byte	0x5
	.uleb128 0
	.long	.LASF360
	.byte	0x5
	.uleb128 0
	.long	.LASF361
	.byte	0x5
	.uleb128 0
	.long	.LASF362
	.byte	0x5
	.uleb128 0
	.long	.LASF363
	.byte	0x5
	.uleb128 0
	.long	.LASF364
	.byte	0x5
	.uleb128 0
	.long	.LASF365
	.byte	0x5
	.uleb128 0
	.long	.LASF366
	.byte	0x5
	.uleb128 0
	.long	.LASF367
	.byte	0x5
	.uleb128 0
	.long	.LASF368
	.byte	0x5
	.uleb128 0
	.long	.LASF369
	.byte	0x5
	.uleb128 0
	.long	.LASF370
	.byte	0x5
	.uleb128 0
	.long	.LASF371
	.byte	0x5
	.uleb128 0
	.long	.LASF372
	.byte	0x5
	.uleb128 0
	.long	.LASF373
	.byte	0x5
	.uleb128 0
	.long	.LASF374
	.byte	0x5
	.uleb128 0
	.long	.LASF375
	.byte	0x5
	.uleb128 0
	.long	.LASF376
	.byte	0x5
	.uleb128 0
	.long	.LASF377
	.byte	0x5
	.uleb128 0
	.long	.LASF378
	.byte	0x5
	.uleb128 0
	.long	.LASF379
	.byte	0x5
	.uleb128 0
	.long	.LASF380
	.byte	0x5
	.uleb128 0
	.long	.LASF381
	.byte	0x5
	.uleb128 0
	.long	.LASF382
	.byte	0x5
	.uleb128 0
	.long	.LASF383
	.byte	0x5
	.uleb128 0
	.long	.LASF384
	.byte	0x5
	.uleb128 0
	.long	.LASF385
	.byte	0x5
	.uleb128 0
	.long	.LASF386
	.byte	0x5
	.uleb128 0
	.long	.LASF387
	.byte	0x5
	.uleb128 0
	.long	.LASF388
	.byte	0x5
	.uleb128 0
	.long	.LASF389
	.byte	0x5
	.uleb128 0
	.long	.LASF390
	.byte	0x5
	.uleb128 0
	.long	.LASF391
	.byte	0x5
	.uleb128 0
	.long	.LASF392
	.byte	0x5
	.uleb128 0
	.long	.LASF393
	.byte	0x5
	.uleb128 0
	.long	.LASF394
	.byte	0x5
	.uleb128 0
	.long	.LASF395
	.byte	0x5
	.uleb128 0
	.long	.LASF396
	.byte	0x5
	.uleb128 0
	.long	.LASF397
	.byte	0x5
	.uleb128 0
	.long	.LASF398
	.byte	0x5
	.uleb128 0
	.long	.LASF399
	.byte	0x5
	.uleb128 0
	.long	.LASF400
	.byte	0x5
	.uleb128 0
	.long	.LASF401
	.byte	0x5
	.uleb128 0
	.long	.LASF402
	.byte	0x5
	.uleb128 0
	.long	.LASF403
	.byte	0x5
	.uleb128 0
	.long	.LASF404
	.byte	0x5
	.uleb128 0
	.long	.LASF405
	.byte	0x5
	.uleb128 0
	.long	.LASF406
	.byte	0x5
	.uleb128 0
	.long	.LASF407
	.byte	0x5
	.uleb128 0
	.long	.LASF408
	.byte	0x5
	.uleb128 0
	.long	.LASF409
	.byte	0
	.section	.debug_macro,"G",@progbits,wm4.stdcpredef.h.19.88fdbfd5cf6f83ed579effc3e425f09b,comdat
.Ldebug_macro3:
	.value	0x5
	.byte	0
	.byte	0x5
	.uleb128 0x13
	.long	.LASF410
	.byte	0x5
	.uleb128 0x26
	.long	.LASF411
	.byte	0x5
	.uleb128 0x27
	.long	.LASF412
	.byte	0x5
	.uleb128 0x30
	.long	.LASF413
	.byte	0x5
	.uleb128 0x31
	.long	.LASF414
	.byte	0x5
	.uleb128 0x3e
	.long	.LASF415
	.byte	0
	.section	.debug_macro,"G",@progbits,wm4.stddef.h.39.01f6ae7e0b0e6a37bd33b8645cad6e11,comdat
.Ldebug_macro4:
	.value	0x5
	.byte	0
	.byte	0x5
	.uleb128 0x27
	.long	.LASF416
	.byte	0x5
	.uleb128 0x28
	.long	.LASF417
	.byte	0x5
	.uleb128 0x2a
	.long	.LASF418
	.byte	0x5
	.uleb128 0x93
	.long	.LASF419
	.byte	0x5
	.uleb128 0x94
	.long	.LASF420
	.byte	0x5
	.uleb128 0x95
	.long	.LASF421
	.byte	0x5
	.uleb128 0x96
	.long	.LASF422
	.byte	0x5
	.uleb128 0x97
	.long	.LASF423
	.byte	0x5
	.uleb128 0x98
	.long	.LASF424
	.byte	0x5
	.uleb128 0x99
	.long	.LASF425
	.byte	0x5
	.uleb128 0x9a
	.long	.LASF426
	.byte	0x5
	.uleb128 0x9b
	.long	.LASF427
	.byte	0x5
	.uleb128 0x9c
	.long	.LASF428
	.byte	0x6
	.uleb128 0xad
	.long	.LASF429
	.byte	0x5
	.uleb128 0xc8
	.long	.LASF430
	.byte	0x5
	.uleb128 0xc9
	.long	.LASF431
	.byte	0x5
	.uleb128 0xca
	.long	.LASF432
	.byte	0x5
	.uleb128 0xcb
	.long	.LASF433
	.byte	0x5
	.uleb128 0xcc
	.long	.LASF434
	.byte	0x5
	.uleb128 0xcd
	.long	.LASF435
	.byte	0x5
	.uleb128 0xce
	.long	.LASF436
	.byte	0x5
	.uleb128 0xcf
	.long	.LASF437
	.byte	0x5
	.uleb128 0xd0
	.long	.LASF438
	.byte	0x5
	.uleb128 0xd1
	.long	.LASF439
	.byte	0x5
	.uleb128 0xd2
	.long	.LASF440
	.byte	0x5
	.uleb128 0xd3
	.long	.LASF441
	.byte	0x5
	.uleb128 0xd4
	.long	.LASF442
	.byte	0x5
	.uleb128 0xd5
	.long	.LASF443
	.byte	0x5
	.uleb128 0xd6
	.long	.LASF444
	.byte	0x5
	.uleb128 0xd7
	.long	.LASF445
	.byte	0x5
	.uleb128 0xd8
	.long	.LASF446
	.byte	0x5
	.uleb128 0xdf
	.long	.LASF447
	.byte	0x6
	.uleb128 0xfc
	.long	.LASF448
	.byte	0x5
	.uleb128 0x11a
	.long	.LASF449
	.byte	0x5
	.uleb128 0x11b
	.long	.LASF450
	.byte	0x5
	.uleb128 0x11c
	.long	.LASF451
	.byte	0x5
	.uleb128 0x11d
	.long	.LASF452
	.byte	0x5
	.uleb128 0x11e
	.long	.LASF453
	.byte	0x5
	.uleb128 0x11f
	.long	.LASF454
	.byte	0x5
	.uleb128 0x120
	.long	.LASF455
	.byte	0x5
	.uleb128 0x121
	.long	.LASF456
	.byte	0x5
	.uleb128 0x122
	.long	.LASF457
	.byte	0x5
	.uleb128 0x123
	.long	.LASF458
	.byte	0x5
	.uleb128 0x124
	.long	.LASF459
	.byte	0x5
	.uleb128 0x125
	.long	.LASF460
	.byte	0x5
	.uleb128 0x126
	.long	.LASF461
	.byte	0x5
	.uleb128 0x127
	.long	.LASF462
	.byte	0x5
	.uleb128 0x128
	.long	.LASF463
	.byte	0x5
	.uleb128 0x129
	.long	.LASF464
	.byte	0x6
	.uleb128 0x136
	.long	.LASF465
	.byte	0x6
	.uleb128 0x16c
	.long	.LASF466
	.byte	0x6
	.uleb128 0x19e
	.long	.LASF467
	.byte	0x5
	.uleb128 0x1a3
	.long	.LASF468
	.byte	0x6
	.uleb128 0x1a9
	.long	.LASF469
	.byte	0x6
	.uleb128 0x1ae
	.long	.LASF470
	.byte	0x5
	.uleb128 0x1af
	.long	.LASF471
	.byte	0x5
	.uleb128 0x1b4
	.long	.LASF472
	.byte	0x5
	.uleb128 0x1d0
	.long	.LASF473
	.byte	0x5
	.uleb128 0x1d4
	.long	.LASF474
	.byte	0x5
	.uleb128 0x1d5
	.long	.LASF475
	.byte	0
	.section	.debug_line,"",@progbits
.Ldebug_line0:
	.section	.debug_str,"MS",@progbits,1
.LASF217:
	.string	"__FLT16_NORM_MAX__ 6.55040000000000000000000000000000000e+4F16"
.LASF437:
	.string	"_SIZE_T_ "
.LASF108:
	.string	"__SIG_ATOMIC_MAX__ 0x7fffffff"
.LASF255:
	.string	"__FLT64_HAS_QUIET_NAN__ 1"
.LASF334:
	.string	"__DEC64_SUBNORMAL_MIN__ 0.000000000000001E-383DD"
.LASF212:
	.string	"__FLT16_MIN_10_EXP__ (-4)"
.LASF238:
	.string	"__FLT32_HAS_INFINITY__ 1"
.LASF461:
	.string	"__INT_WCHAR_T_H "
.LASF245:
	.string	"__FLT64_MAX_EXP__ 1024"
.LASF163:
	.string	"__FLT_MIN_10_EXP__ (-37)"
.LASF299:
	.string	"__FLT64X_EPSILON__ 1.08420217248550443400745280086994171e-19F64x"
.LASF277:
	.string	"__FLT32X_MAX_EXP__ 1024"
.LASF367:
	.string	"__GCC_ATOMIC_TEST_AND_SET_TRUEVAL 1"
.LASF333:
	.string	"__DEC64_EPSILON__ 1E-15DD"
.LASF187:
	.string	"__DBL_DENORM_MIN__ ((double)4.94065645841246544176568792868221372e-324L)"
.LASF379:
	.string	"__amd64 1"
.LASF151:
	.string	"__INTPTR_MAX__ 0x7fffffffffffffffL"
.LASF225:
	.string	"__FLT32_MANT_DIG__ 24"
.LASF459:
	.string	"_WCHAR_T_H "
.LASF356:
	.string	"__GCC_HAVE_SYNC_COMPARE_AND_SWAP_8 1"
.LASF480:
	.string	"GNU C23 15.2.0 -mtune=generic -march=x86-64 -g3 -gdwarf-5 -O0 -fasynchronous-unwind-tables -fstack-protector-strong -fstack-clash-protection -fcf-protection -fzero-init-padding-bits=all"
.LASF17:
	.string	"__ATOMIC_RELEASE 3"
.LASF409:
	.string	"__DECIMAL_BID_FORMAT__ 1"
.LASF279:
	.string	"__FLT32X_DECIMAL_DIG__ 17"
.LASF389:
	.string	"__k8__ 1"
.LASF178:
	.string	"__DBL_MIN_EXP__ (-1021)"
.LASF360:
	.string	"__GCC_ATOMIC_CHAR16_T_LOCK_FREE 2"
.LASF280:
	.string	"__FLT32X_MAX__ 1.79769313486231570814527423731704357e+308F32x"
.LASF377:
	.string	"__SIZEOF_WINT_T__ 4"
.LASF265:
	.string	"__FLT128_NORM_MAX__ 1.18973149535723176508575932662800702e+4932F128"
.LASF432:
	.string	"_SIZE_T "
.LASF11:
	.string	"__GNUC_MINOR__ 2"
.LASF233:
	.string	"__FLT32_NORM_MAX__ 3.40282346638528859811704183484516925e+38F32"
.LASF445:
	.string	"_GCC_SIZE_T "
.LASF118:
	.string	"__UINT64_MAX__ 0xffffffffffffffffUL"
.LASF385:
	.string	"__ATOMIC_HLE_ACQUIRE 65536"
.LASF250:
	.string	"__FLT64_MIN__ 2.22507385850720138309023271733240406e-308F64"
.LASF97:
	.string	"__LONG_LONG_WIDTH__ 64"
.LASF429:
	.string	"__need_ptrdiff_t"
.LASF171:
	.string	"__FLT_DENORM_MIN__ 1.40129846432481707092372958328991613e-45F"
.LASF307:
	.string	"__BFLT16_MIN_EXP__ (-125)"
.LASF34:
	.string	"__SIZEOF_SIZE_T__ 8"
.LASF38:
	.string	"__ORDER_BIG_ENDIAN__ 4321"
.LASF369:
	.string	"__GCC_CONSTRUCTIVE_SIZE 64"
.LASF436:
	.string	"__SIZE_T "
.LASF138:
	.string	"__UINT64_C(c) c ## UL"
.LASF176:
	.string	"__DBL_MANT_DIG__ 53"
.LASF174:
	.string	"__FLT_HAS_QUIET_NAN__ 1"
.LASF84:
	.string	"__INT_MAX__ 0x7fffffff"
.LASF175:
	.string	"__FLT_IS_IEC_60559__ 1"
.LASF210:
	.string	"__FLT16_DIG__ 3"
.LASF56:
	.string	"__INT16_TYPE__ short int"
.LASF224:
	.string	"__FLT16_IS_IEC_60559__ 1"
.LASF326:
	.string	"__DEC32_EPSILON__ 1E-6DF"
.LASF316:
	.string	"__BFLT16_DENORM_MIN__ 9.18354961579912115600575419704879436e-41BF16"
.LASF193:
	.string	"__LDBL_DIG__ 18"
.LASF293:
	.string	"__FLT64X_MAX_EXP__ 16384"
.LASF15:
	.string	"__ATOMIC_SEQ_CST 5"
.LASF30:
	.string	"__SIZEOF_SHORT__ 2"
.LASF62:
	.string	"__UINT64_TYPE__ long unsigned int"
.LASF143:
	.string	"__INT_FAST32_MAX__ 0x7fffffffffffffffL"
.LASF63:
	.string	"__INT_LEAST8_TYPE__ signed char"
.LASF241:
	.string	"__FLT64_MANT_DIG__ 53"
.LASF465:
	.string	"_BSD_WCHAR_T_"
.LASF69:
	.string	"__UINT_LEAST32_TYPE__ unsigned int"
.LASF77:
	.string	"__UINT_FAST32_TYPE__ long unsigned int"
.LASF40:
	.string	"__BYTE_ORDER__ __ORDER_LITTLE_ENDIAN__"
.LASF202:
	.string	"__LDBL_MIN__ 3.36210314311209350626267781732175260e-4932L"
.LASF404:
	.string	"linux 1"
.LASF228:
	.string	"__FLT32_MIN_10_EXP__ (-37)"
.LASF188:
	.string	"__DBL_HAS_DENORM__ 1"
.LASF359:
	.string	"__GCC_ATOMIC_CHAR8_T_LOCK_FREE 2"
.LASF88:
	.string	"__WCHAR_MIN__ (-__WCHAR_MAX__ - 1)"
.LASF5:
	.string	"__STDC_UTF_32__ 1"
.LASF122:
	.string	"__INT_LEAST16_MAX__ 0x7fff"
.LASF82:
	.string	"__SCHAR_MAX__ 0x7f"
.LASF43:
	.string	"__GNUC_EXECUTION_CHARSET_NAME \"UTF-8\""
.LASF242:
	.string	"__FLT64_DIG__ 15"
.LASF71:
	.string	"__INT_FAST8_TYPE__ signed char"
.LASF23:
	.string	"__PIE__ 2"
.LASF208:
	.string	"__LDBL_IS_IEC_60559__ 1"
.LASF286:
	.string	"__FLT32X_HAS_INFINITY__ 1"
.LASF270:
	.string	"__FLT128_HAS_INFINITY__ 1"
.LASF474:
	.string	"unreachable() (__builtin_unreachable ())"
.LASF397:
	.string	"__MMX_WITH_SSE__ 1"
.LASF67:
	.string	"__UINT_LEAST8_TYPE__ unsigned char"
.LASF375:
	.string	"__SIZEOF_INT128__ 16"
.LASF271:
	.string	"__FLT128_HAS_QUIET_NAN__ 1"
.LASF435:
	.string	"_T_SIZE "
.LASF264:
	.string	"__FLT128_MAX__ 1.18973149535723176508575932662800702e+4932F128"
.LASF105:
	.string	"__UINTMAX_MAX__ 0xffffffffffffffffUL"
.LASF65:
	.string	"__INT_LEAST32_TYPE__ int"
.LASF124:
	.string	"__INT_LEAST16_WIDTH__ 16"
.LASF348:
	.string	"__DEC64X_SUBNORMAL_MIN__ 0.000000000000000000000000000000001E-6143D64x"
.LASF434:
	.string	"_T_SIZE_ "
.LASF3:
	.string	"__STDC_VERSION__ 202311L"
.LASF343:
	.string	"__DEC64X_MIN_EXP__ (-6142)"
.LASF457:
	.string	"_WCHAR_T_DEFINED_ "
.LASF256:
	.string	"__FLT64_IS_IEC_60559__ 1"
.LASF237:
	.string	"__FLT32_HAS_DENORM__ 1"
.LASF406:
	.string	"__unix__ 1"
.LASF353:
	.string	"__GCC_HAVE_SYNC_COMPARE_AND_SWAP_1 1"
.LASF291:
	.string	"__FLT64X_MIN_EXP__ (-16381)"
.LASF438:
	.string	"_BSD_SIZE_T_ "
.LASF462:
	.string	"_GCC_WCHAR_T "
.LASF161:
	.string	"__FLT_DIG__ 6"
.LASF142:
	.string	"__INT_FAST16_WIDTH__ 64"
.LASF22:
	.string	"__pie__ 2"
.LASF209:
	.string	"__FLT16_MANT_DIG__ 11"
.LASF312:
	.string	"__BFLT16_MAX__ 3.38953138925153547590470800371487867e+38BF16"
.LASF153:
	.string	"__UINTPTR_MAX__ 0xffffffffffffffffUL"
.LASF414:
	.string	"__STDC_IEC_60559_COMPLEX__ 201404L"
.LASF154:
	.string	"__GCC_IEC_559 2"
.LASF259:
	.string	"__FLT128_MIN_EXP__ (-16381)"
.LASF239:
	.string	"__FLT32_HAS_QUIET_NAN__ 1"
.LASF441:
	.string	"_BSD_SIZE_T_DEFINED_ "
.LASF133:
	.string	"__UINT_LEAST16_MAX__ 0xffff"
.LASF150:
	.string	"__UINT_FAST64_MAX__ 0xffffffffffffffffUL"
.LASF201:
	.string	"__LDBL_NORM_MAX__ 1.18973149535723176502126385303097021e+4932L"
.LASF10:
	.string	"__GNUC__ 15"
.LASF131:
	.string	"__UINT_LEAST8_MAX__ 0xff"
.LASF336:
	.string	"__DEC128_MIN_EXP__ (-6142)"
.LASF47:
	.string	"__WCHAR_TYPE__ int"
.LASF111:
	.string	"__INT8_MAX__ 0x7f"
.LASF340:
	.string	"__DEC128_EPSILON__ 1E-33DL"
.LASF469:
	.string	"__need_NULL"
.LASF400:
	.string	"__CET__ 3"
.LASF320:
	.string	"__BFLT16_IS_IEC_60559__ 0"
.LASF261:
	.string	"__FLT128_MAX_EXP__ 16384"
.LASF159:
	.string	"__FLT_RADIX__ 2"
.LASF284:
	.string	"__FLT32X_DENORM_MIN__ 4.94065645841246544176568792868221372e-324F32x"
.LASF311:
	.string	"__BFLT16_DECIMAL_DIG__ 4"
.LASF33:
	.string	"__SIZEOF_LONG_DOUBLE__ 16"
.LASF190:
	.string	"__DBL_HAS_QUIET_NAN__ 1"
.LASF304:
	.string	"__FLT64X_IS_IEC_60559__ 1"
.LASF204:
	.string	"__LDBL_DENORM_MIN__ 3.64519953188247460252840593361941982e-4951L"
.LASF254:
	.string	"__FLT64_HAS_INFINITY__ 1"
.LASF147:
	.string	"__UINT_FAST8_MAX__ 0xff"
.LASF386:
	.string	"__ATOMIC_HLE_RELEASE 131072"
.LASF196:
	.string	"__LDBL_MAX_EXP__ 16384"
.LASF407:
	.string	"unix 1"
.LASF79:
	.string	"__INTPTR_TYPE__ long int"
.LASF332:
	.string	"__DEC64_MAX__ 9.999999999999999E384DD"
.LASF364:
	.string	"__GCC_ATOMIC_INT_LOCK_FREE 2"
.LASF391:
	.string	"__MMX__ 1"
.LASF290:
	.string	"__FLT64X_DIG__ 18"
.LASF130:
	.string	"__INT_LEAST64_WIDTH__ 64"
.LASF257:
	.string	"__FLT128_MANT_DIG__ 113"
.LASF37:
	.string	"__ORDER_LITTLE_ENDIAN__ 1234"
.LASF450:
	.string	"__WCHAR_T__ "
.LASF378:
	.string	"__SIZEOF_PTRDIFF_T__ 8"
.LASF335:
	.string	"__DEC128_MANT_DIG__ 34"
.LASF422:
	.string	"__PTRDIFF_T "
.LASF57:
	.string	"__INT32_TYPE__ int"
.LASF390:
	.string	"__code_model_small__ 1"
.LASF301:
	.string	"__FLT64X_HAS_DENORM__ 1"
.LASF323:
	.string	"__DEC32_MAX_EXP__ 97"
.LASF220:
	.string	"__FLT16_DENORM_MIN__ 5.96046447753906250000000000000000000e-8F16"
.LASF2:
	.string	"__STDC__ 1"
.LASF306:
	.string	"__BFLT16_DIG__ 2"
.LASF413:
	.string	"__STDC_IEC_559_COMPLEX__ 1"
.LASF475:
	.string	"__STDC_VERSION_STDDEF_H__ 202311L"
.LASF292:
	.string	"__FLT64X_MIN_10_EXP__ (-4931)"
.LASF415:
	.string	"__STDC_ISO_10646__ 201706L"
.LASF315:
	.string	"__BFLT16_EPSILON__ 7.81250000000000000000000000000000000e-3BF16"
.LASF371:
	.string	"__HAVE_SPECULATION_SAFE_VALUE 1"
.LASF467:
	.string	"NULL"
.LASF262:
	.string	"__FLT128_MAX_10_EXP__ 4932"
.LASF266:
	.string	"__FLT128_MIN__ 3.36210314311209350626267781732175260e-4932F128"
.LASF140:
	.string	"__INT_FAST8_WIDTH__ 8"
.LASF244:
	.string	"__FLT64_MIN_10_EXP__ (-307)"
.LASF347:
	.string	"__DEC64X_EPSILON__ 1E-33D64x"
.LASF380:
	.string	"__amd64__ 1"
.LASF211:
	.string	"__FLT16_MIN_EXP__ (-13)"
.LASF231:
	.string	"__FLT32_DECIMAL_DIG__ 9"
.LASF258:
	.string	"__FLT128_DIG__ 33"
.LASF60:
	.string	"__UINT16_TYPE__ short unsigned int"
.LASF98:
	.string	"__WCHAR_WIDTH__ 32"
.LASF358:
	.string	"__GCC_ATOMIC_CHAR_LOCK_FREE 2"
.LASF86:
	.string	"__LONG_LONG_MAX__ 0x7fffffffffffffffLL"
.LASF68:
	.string	"__UINT_LEAST16_TYPE__ short unsigned int"
.LASF165:
	.string	"__FLT_MAX_10_EXP__ 38"
.LASF85:
	.string	"__LONG_MAX__ 0x7fffffffffffffffL"
.LASF283:
	.string	"__FLT32X_EPSILON__ 2.22044604925031308084726333618164062e-16F32x"
.LASF213:
	.string	"__FLT16_MAX_EXP__ 16"
.LASF352:
	.string	"__NO_INLINE__ 1"
.LASF440:
	.string	"_SIZE_T_DEFINED "
.LASF103:
	.string	"__INTMAX_MAX__ 0x7fffffffffffffffL"
.LASF183:
	.string	"__DBL_MAX__ ((double)1.79769313486231570814527423731704357e+308L)"
.LASF247:
	.string	"__FLT64_DECIMAL_DIG__ 17"
.LASF355:
	.string	"__GCC_HAVE_SYNC_COMPARE_AND_SWAP_4 1"
.LASF455:
	.string	"_WCHAR_T_ "
.LASF45:
	.string	"__SIZE_TYPE__ long unsigned int"
.LASF200:
	.string	"__LDBL_MAX__ 1.18973149535723176502126385303097021e+4932L"
.LASF158:
	.string	"__DEC_EVAL_METHOD__ 2"
.LASF167:
	.string	"__FLT_MAX__ 3.40282346638528859811704183484516925e+38F"
.LASF179:
	.string	"__DBL_MIN_10_EXP__ (-307)"
.LASF227:
	.string	"__FLT32_MIN_EXP__ (-125)"
.LASF195:
	.string	"__LDBL_MIN_10_EXP__ (-4931)"
.LASF226:
	.string	"__FLT32_DIG__ 6"
.LASF253:
	.string	"__FLT64_HAS_DENORM__ 1"
.LASF156:
	.string	"__FLT_EVAL_METHOD__ 0"
.LASF297:
	.string	"__FLT64X_NORM_MAX__ 1.18973149535723176502126385303097021e+4932F64x"
.LASF285:
	.string	"__FLT32X_HAS_DENORM__ 1"
.LASF382:
	.string	"__x86_64__ 1"
.LASF104:
	.string	"__INTMAX_C(c) c ## L"
.LASF296:
	.string	"__FLT64X_MAX__ 1.18973149535723176502126385303097021e+4932F64x"
.LASF362:
	.string	"__GCC_ATOMIC_WCHAR_T_LOCK_FREE 2"
.LASF13:
	.string	"__VERSION__ \"15.2.0\""
.LASF431:
	.string	"__SIZE_T__ "
.LASF128:
	.string	"__INT_LEAST64_MAX__ 0x7fffffffffffffffL"
.LASF121:
	.string	"__INT_LEAST8_WIDTH__ 8"
.LASF115:
	.string	"__UINT8_MAX__ 0xff"
.LASF116:
	.string	"__UINT16_MAX__ 0xffff"
.LASF446:
	.string	"_SIZET_ "
.LASF74:
	.string	"__INT_FAST64_TYPE__ long int"
.LASF218:
	.string	"__FLT16_MIN__ 6.10351562500000000000000000000000000e-5F16"
.LASF117:
	.string	"__UINT32_MAX__ 0xffffffffU"
.LASF107:
	.string	"__INTMAX_WIDTH__ 64"
.LASF325:
	.string	"__DEC32_MAX__ 9.999999E96DF"
.LASF191:
	.string	"__DBL_IS_IEC_60559__ 1"
.LASF91:
	.string	"__PTRDIFF_MAX__ 0x7fffffffffffffffL"
.LASF64:
	.string	"__INT_LEAST16_TYPE__ short int"
.LASF229:
	.string	"__FLT32_MAX_EXP__ 128"
.LASF401:
	.string	"__gnu_linux__ 1"
.LASF466:
	.string	"__need_wchar_t"
.LASF384:
	.string	"__SIZEOF_FLOAT128__ 16"
.LASF120:
	.string	"__INT8_C(c) c"
.LASF464:
	.string	"__DEFINED_wchar_t "
.LASF119:
	.string	"__INT_LEAST8_MAX__ 0x7f"
.LASF81:
	.string	"__GXX_ABI_VERSION 1020"
.LASF26:
	.string	"__LP64__ 1"
.LASF365:
	.string	"__GCC_ATOMIC_LONG_LOCK_FREE 2"
.LASF274:
	.string	"__FLT32X_DIG__ 15"
.LASF273:
	.string	"__FLT32X_MANT_DIG__ 53"
.LASF25:
	.string	"_LP64 1"
.LASF344:
	.string	"__DEC64X_MAX_EXP__ 6145"
.LASF451:
	.string	"_WCHAR_T "
.LASF454:
	.string	"__WCHAR_T "
.LASF478:
	.string	"long long int"
.LASF294:
	.string	"__FLT64X_MAX_10_EXP__ 4932"
.LASF185:
	.string	"__DBL_MIN__ ((double)2.22507385850720138309023271733240406e-308L)"
.LASF357:
	.string	"__GCC_ATOMIC_BOOL_LOCK_FREE 2"
.LASF149:
	.string	"__UINT_FAST32_MAX__ 0xffffffffffffffffUL"
.LASF24:
	.string	"__FINITE_MATH_ONLY__ 0"
.LASF248:
	.string	"__FLT64_MAX__ 1.79769313486231570814527423731704357e+308F64"
.LASF387:
	.string	"__GCC_ASM_FLAG_OUTPUTS__ 1"
.LASF137:
	.string	"__UINT_LEAST64_MAX__ 0xffffffffffffffffUL"
.LASF416:
	.string	"_STDDEF_H "
.LASF408:
	.string	"__ELF__ 1"
.LASF282:
	.string	"__FLT32X_MIN__ 2.22507385850720138309023271733240406e-308F32x"
.LASF80:
	.string	"__UINTPTR_TYPE__ long unsigned int"
.LASF123:
	.string	"__INT16_C(c) c"
.LASF372:
	.string	"__GCC_HAVE_DWARF2_CFI_ASM 1"
.LASF31:
	.string	"__SIZEOF_FLOAT__ 4"
.LASF327:
	.string	"__DEC32_SUBNORMAL_MIN__ 0.000001E-95DF"
.LASF303:
	.string	"__FLT64X_HAS_QUIET_NAN__ 1"
.LASF173:
	.string	"__FLT_HAS_INFINITY__ 1"
.LASF310:
	.string	"__BFLT16_MAX_10_EXP__ 38"
.LASF222:
	.string	"__FLT16_HAS_INFINITY__ 1"
.LASF216:
	.string	"__FLT16_MAX__ 6.55040000000000000000000000000000000e+4F16"
.LASF393:
	.string	"__SSE2__ 1"
.LASF249:
	.string	"__FLT64_NORM_MAX__ 1.79769313486231570814527423731704357e+308F64"
.LASF180:
	.string	"__DBL_MAX_EXP__ 1024"
.LASF28:
	.string	"__SIZEOF_LONG__ 8"
.LASF19:
	.string	"__ATOMIC_CONSUME 1"
.LASF342:
	.string	"__DEC64X_MANT_DIG__ 34"
.LASF234:
	.string	"__FLT32_MIN__ 1.17549435082228750796873653722224568e-38F32"
.LASF48:
	.string	"__WINT_TYPE__ unsigned int"
.LASF473:
	.string	"_GCC_NULLPTR_T "
.LASF112:
	.string	"__INT16_MAX__ 0x7fff"
.LASF93:
	.string	"__SCHAR_WIDTH__ 8"
.LASF136:
	.string	"__UINT32_C(c) c ## U"
.LASF73:
	.string	"__INT_FAST32_TYPE__ long int"
.LASF313:
	.string	"__BFLT16_NORM_MAX__ 3.38953138925153547590470800371487867e+38BF16"
.LASF32:
	.string	"__SIZEOF_DOUBLE__ 8"
.LASF12:
	.string	"__GNUC_PATCHLEVEL__ 0"
.LASF132:
	.string	"__UINT8_C(c) c"
.LASF319:
	.string	"__BFLT16_HAS_QUIET_NAN__ 1"
.LASF215:
	.string	"__FLT16_DECIMAL_DIG__ 5"
.LASF458:
	.string	"_WCHAR_T_DEFINED "
.LASF427:
	.string	"_PTRDIFF_T_DECLARED "
.LASF90:
	.string	"__WINT_MIN__ 0U"
.LASF192:
	.string	"__LDBL_MANT_DIG__ 64"
.LASF240:
	.string	"__FLT32_IS_IEC_60559__ 1"
.LASF168:
	.string	"__FLT_NORM_MAX__ 3.40282346638528859811704183484516925e+38F"
.LASF4:
	.string	"__STDC_UTF_16__ 1"
.LASF203:
	.string	"__LDBL_EPSILON__ 1.08420217248550443400745280086994171e-19L"
.LASF419:
	.string	"_PTRDIFF_T "
.LASF424:
	.string	"_BSD_PTRDIFF_T_ "
.LASF206:
	.string	"__LDBL_HAS_INFINITY__ 1"
.LASF155:
	.string	"__GCC_IEC_559_COMPLEX 2"
.LASF109:
	.string	"__SIG_ATOMIC_MIN__ (-__SIG_ATOMIC_MAX__ - 1)"
.LASF376:
	.string	"__SIZEOF_WCHAR_T__ 4"
.LASF260:
	.string	"__FLT128_MIN_10_EXP__ (-4931)"
.LASF41:
	.string	"__FLOAT_WORD_ORDER__ __ORDER_LITTLE_ENDIAN__"
.LASF354:
	.string	"__GCC_HAVE_SYNC_COMPARE_AND_SWAP_2 1"
.LASF321:
	.string	"__DEC32_MANT_DIG__ 7"
.LASF236:
	.string	"__FLT32_DENORM_MIN__ 1.40129846432481707092372958328991613e-45F32"
.LASF329:
	.string	"__DEC64_MIN_EXP__ (-382)"
.LASF148:
	.string	"__UINT_FAST16_MAX__ 0xffffffffffffffffUL"
.LASF113:
	.string	"__INT32_MAX__ 0x7fffffff"
.LASF444:
	.string	"___int_size_t_h "
.LASF16:
	.string	"__ATOMIC_ACQUIRE 2"
.LASF134:
	.string	"__UINT16_C(c) c"
.LASF114:
	.string	"__INT64_MAX__ 0x7fffffffffffffffL"
.LASF479:
	.string	"long double"
.LASF399:
	.string	"__SEG_GS 1"
.LASF395:
	.string	"__SSE_MATH__ 1"
.LASF50:
	.string	"__UINTMAX_TYPE__ long unsigned int"
.LASF221:
	.string	"__FLT16_HAS_DENORM__ 1"
.LASF448:
	.string	"__need_size_t"
.LASF346:
	.string	"__DEC64X_MAX__ 9.999999999999999999999999999999999E6144D64x"
.LASF337:
	.string	"__DEC128_MAX_EXP__ 6145"
.LASF460:
	.string	"___int_wchar_t_h "
.LASF452:
	.string	"_T_WCHAR_ "
.LASF110:
	.string	"__SIG_ATOMIC_WIDTH__ 32"
.LASF83:
	.string	"__SHRT_MAX__ 0x7fff"
.LASF305:
	.string	"__BFLT16_MANT_DIG__ 8"
.LASF39:
	.string	"__ORDER_PDP_ENDIAN__ 3412"
.LASF166:
	.string	"__FLT_DECIMAL_DIG__ 9"
.LASF246:
	.string	"__FLT64_MAX_10_EXP__ 308"
.LASF194:
	.string	"__LDBL_MIN_EXP__ (-16381)"
.LASF99:
	.string	"__WINT_WIDTH__ 32"
.LASF298:
	.string	"__FLT64X_MIN__ 3.36210314311209350626267781732175260e-4932F64x"
.LASF439:
	.string	"_SIZE_T_DEFINED_ "
.LASF139:
	.string	"__INT_FAST8_MAX__ 0x7f"
.LASF27:
	.string	"__SIZEOF_INT__ 4"
.LASF235:
	.string	"__FLT32_EPSILON__ 1.19209289550781250000000000000000000e-7F32"
.LASF381:
	.string	"__x86_64 1"
.LASF463:
	.string	"_WCHAR_T_DECLARED "
.LASF145:
	.string	"__INT_FAST64_MAX__ 0x7fffffffffffffffL"
.LASF330:
	.string	"__DEC64_MAX_EXP__ 385"
.LASF276:
	.string	"__FLT32X_MIN_10_EXP__ (-307)"
.LASF476:
	.string	"long int"
.LASF106:
	.string	"__UINTMAX_C(c) c ## UL"
.LASF53:
	.string	"__CHAR32_TYPE__ unsigned int"
.LASF443:
	.string	"__DEFINED_size_t "
.LASF314:
	.string	"__BFLT16_MIN__ 1.17549435082228750796873653722224568e-38BF16"
.LASF302:
	.string	"__FLT64X_HAS_INFINITY__ 1"
.LASF338:
	.string	"__DEC128_MIN__ 1E-6143DL"
.LASF275:
	.string	"__FLT32X_MIN_EXP__ (-1021)"
.LASF152:
	.string	"__INTPTR_WIDTH__ 64"
.LASF368:
	.string	"__GCC_DESTRUCTIVE_SIZE 64"
.LASF309:
	.string	"__BFLT16_MAX_EXP__ 128"
.LASF75:
	.string	"__UINT_FAST8_TYPE__ unsigned char"
.LASF126:
	.string	"__INT32_C(c) c"
.LASF207:
	.string	"__LDBL_HAS_QUIET_NAN__ 1"
.LASF55:
	.string	"__INT8_TYPE__ signed char"
.LASF89:
	.string	"__WINT_MAX__ 0xffffffffU"
.LASF51:
	.string	"__CHAR8_TYPE__ unsigned char"
.LASF402:
	.string	"__linux 1"
.LASF423:
	.string	"_PTRDIFF_T_ "
.LASF426:
	.string	"_GCC_PTRDIFF_T "
.LASF61:
	.string	"__UINT32_TYPE__ unsigned int"
.LASF324:
	.string	"__DEC32_MIN__ 1E-95DF"
.LASF267:
	.string	"__FLT128_EPSILON__ 1.92592994438723585305597794258492732e-34F128"
.LASF29:
	.string	"__SIZEOF_LONG_LONG__ 8"
.LASF219:
	.string	"__FLT16_EPSILON__ 9.76562500000000000000000000000000000e-4F16"
.LASF59:
	.string	"__UINT8_TYPE__ unsigned char"
.LASF94:
	.string	"__SHRT_WIDTH__ 16"
.LASF396:
	.string	"__SSE2_MATH__ 1"
.LASF411:
	.string	"__STDC_IEC_559__ 1"
.LASF7:
	.string	"__STDC_EMBED_NOT_FOUND__ 0"
.LASF144:
	.string	"__INT_FAST32_WIDTH__ 64"
.LASF308:
	.string	"__BFLT16_MIN_10_EXP__ (-37)"
.LASF470:
	.string	"offsetof"
.LASF42:
	.string	"__SIZEOF_POINTER__ 8"
.LASF251:
	.string	"__FLT64_EPSILON__ 2.22044604925031308084726333618164062e-16F64"
.LASF289:
	.string	"__FLT64X_MANT_DIG__ 64"
.LASF87:
	.string	"__WCHAR_MAX__ 0x7fffffff"
.LASF160:
	.string	"__FLT_MANT_DIG__ 24"
.LASF95:
	.string	"__INT_WIDTH__ 32"
.LASF199:
	.string	"__LDBL_DECIMAL_DIG__ 21"
.LASF370:
	.string	"__GCC_ATOMIC_POINTER_LOCK_FREE 2"
.LASF449:
	.string	"__wchar_t__ "
.LASF481:
	.string	"main"
.LASF398:
	.string	"__SEG_FS 1"
.LASF76:
	.string	"__UINT_FAST16_TYPE__ long unsigned int"
.LASF8:
	.string	"__STDC_EMBED_FOUND__ 1"
.LASF350:
	.string	"__USER_LABEL_PREFIX__ "
.LASF477:
	.string	"long unsigned int"
.LASF361:
	.string	"__GCC_ATOMIC_CHAR32_T_LOCK_FREE 2"
.LASF405:
	.string	"__unix 1"
.LASF35:
	.string	"__CHAR_BIT__ 8"
.LASF14:
	.string	"__ATOMIC_RELAXED 0"
.LASF6:
	.string	"__STDC_HOSTED__ 1"
.LASF101:
	.string	"__SIZE_WIDTH__ 64"
.LASF425:
	.string	"___int_ptrdiff_t_h "
.LASF453:
	.string	"_T_WCHAR "
.LASF412:
	.string	"__STDC_IEC_60559_BFP__ 201404L"
.LASF223:
	.string	"__FLT16_HAS_QUIET_NAN__ 1"
.LASF96:
	.string	"__LONG_WIDTH__ 64"
.LASF388:
	.string	"__k8 1"
.LASF52:
	.string	"__CHAR16_TYPE__ short unsigned int"
.LASF366:
	.string	"__GCC_ATOMIC_LLONG_LOCK_FREE 2"
.LASF164:
	.string	"__FLT_MAX_EXP__ 128"
.LASF18:
	.string	"__ATOMIC_ACQ_REL 4"
.LASF322:
	.string	"__DEC32_MIN_EXP__ (-94)"
.LASF58:
	.string	"__INT64_TYPE__ long int"
.LASF169:
	.string	"__FLT_MIN__ 1.17549435082228750796873653722224568e-38F"
.LASF102:
	.string	"__BITINT_MAXWIDTH__ 65535"
.LASF394:
	.string	"__FXSR__ 1"
.LASF468:
	.string	"NULL ((void *)0)"
.LASF127:
	.string	"__INT_LEAST32_WIDTH__ 32"
.LASF44:
	.string	"__GNUC_WIDE_EXECUTION_CHARSET_NAME \"UTF-32LE\""
.LASF66:
	.string	"__INT_LEAST64_TYPE__ long int"
.LASF345:
	.string	"__DEC64X_MIN__ 1E-6143D64x"
.LASF403:
	.string	"__linux__ 1"
.LASF21:
	.string	"__PIC__ 2"
.LASF456:
	.string	"_BSD_WCHAR_T_ "
.LASF70:
	.string	"__UINT_LEAST64_TYPE__ long unsigned int"
.LASF420:
	.string	"_T_PTRDIFF_ "
.LASF92:
	.string	"__SIZE_MAX__ 0xffffffffffffffffUL"
.LASF417:
	.string	"_STDDEF_H_ "
.LASF363:
	.string	"__GCC_ATOMIC_SHORT_LOCK_FREE 2"
.LASF295:
	.string	"__FLT64X_DECIMAL_DIG__ 21"
.LASF141:
	.string	"__INT_FAST16_MAX__ 0x7fffffffffffffffL"
.LASF288:
	.string	"__FLT32X_IS_IEC_60559__ 1"
.LASF170:
	.string	"__FLT_EPSILON__ 1.19209289550781250000000000000000000e-7F"
.LASF317:
	.string	"__BFLT16_HAS_DENORM__ 1"
.LASF157:
	.string	"__FLT_EVAL_METHOD_TS_18661_3__ 0"
.LASF189:
	.string	"__DBL_HAS_INFINITY__ 1"
.LASF129:
	.string	"__INT64_C(c) c ## L"
.LASF243:
	.string	"__FLT64_MIN_EXP__ (-1021)"
.LASF46:
	.string	"__PTRDIFF_TYPE__ long int"
.LASF72:
	.string	"__INT_FAST16_TYPE__ long int"
.LASF184:
	.string	"__DBL_NORM_MAX__ ((double)1.79769313486231570814527423731704357e+308L)"
.LASF341:
	.string	"__DEC128_SUBNORMAL_MIN__ 0.000000000000000000000000000000001E-6143DL"
.LASF410:
	.string	"_STDC_PREDEF_H 1"
.LASF471:
	.string	"offsetof(TYPE,MEMBER) __builtin_offsetof (TYPE, MEMBER)"
.LASF442:
	.string	"_SIZE_T_DECLARED "
.LASF383:
	.string	"__SIZEOF_FLOAT80__ 16"
.LASF287:
	.string	"__FLT32X_HAS_QUIET_NAN__ 1"
.LASF181:
	.string	"__DBL_MAX_10_EXP__ 308"
.LASF421:
	.string	"_T_PTRDIFF "
.LASF9:
	.string	"__STDC_EMBED_EMPTY__ 2"
.LASF20:
	.string	"__pic__ 2"
.LASF351:
	.string	"__GNUC_STDC_INLINE__ 1"
.LASF392:
	.string	"__SSE__ 1"
.LASF36:
	.string	"__BIGGEST_ALIGNMENT__ 16"
.LASF268:
	.string	"__FLT128_DENORM_MIN__ 6.47517511943802511092443895822764655e-4966F128"
.LASF433:
	.string	"_SYS_SIZE_T_H "
.LASF162:
	.string	"__FLT_MIN_EXP__ (-125)"
.LASF374:
	.string	"__SSP_STRONG__ 3"
.LASF318:
	.string	"__BFLT16_HAS_INFINITY__ 1"
.LASF447:
	.string	"__size_t "
.LASF339:
	.string	"__DEC128_MAX__ 9.999999999999999999999999999999999E6144DL"
.LASF349:
	.string	"__REGISTER_PREFIX__ "
.LASF135:
	.string	"__UINT_LEAST32_MAX__ 0xffffffffU"
.LASF278:
	.string	"__FLT32X_MAX_10_EXP__ 308"
.LASF428:
	.string	"__DEFINED_ptrdiff_t "
.LASF49:
	.string	"__INTMAX_TYPE__ long int"
.LASF214:
	.string	"__FLT16_MAX_10_EXP__ 4"
.LASF281:
	.string	"__FLT32X_NORM_MAX__ 1.79769313486231570814527423731704357e+308F32x"
.LASF472:
	.string	"_GCC_MAX_ALIGN_T "
.LASF252:
	.string	"__FLT64_DENORM_MIN__ 4.94065645841246544176568792868221372e-324F64"
.LASF230:
	.string	"__FLT32_MAX_10_EXP__ 38"
.LASF263:
	.string	"__FLT128_DECIMAL_DIG__ 36"
.LASF100:
	.string	"__PTRDIFF_WIDTH__ 64"
.LASF125:
	.string	"__INT_LEAST32_MAX__ 0x7fffffff"
.LASF78:
	.string	"__UINT_FAST64_TYPE__ long unsigned int"
.LASF418:
	.string	"_ANSI_STDDEF_H "
.LASF197:
	.string	"__LDBL_MAX_10_EXP__ 4932"
.LASF331:
	.string	"__DEC64_MIN__ 1E-383DD"
.LASF232:
	.string	"__FLT32_MAX__ 3.40282346638528859811704183484516925e+38F32"
.LASF186:
	.string	"__DBL_EPSILON__ ((double)2.22044604925031308084726333618164062e-16L)"
.LASF373:
	.string	"__PRAGMA_REDEFINE_EXTNAME 1"
.LASF54:
	.string	"__SIG_ATOMIC_TYPE__ int"
.LASF300:
	.string	"__FLT64X_DENORM_MIN__ 3.64519953188247460252840593361941982e-4951F64x"
.LASF269:
	.string	"__FLT128_HAS_DENORM__ 1"
.LASF272:
	.string	"__FLT128_IS_IEC_60559__ 1"
.LASF182:
	.string	"__DBL_DECIMAL_DIG__ 17"
.LASF205:
	.string	"__LDBL_HAS_DENORM__ 1"
.LASF430:
	.string	"__size_t__ "
.LASF177:
	.string	"__DBL_DIG__ 15"
.LASF328:
	.string	"__DEC64_MANT_DIG__ 16"
.LASF172:
	.string	"__FLT_HAS_DENORM__ 1"
.LASF146:
	.string	"__INT_FAST64_WIDTH__ 64"
.LASF198:
	.string	"__DECIMAL_DIG__ 21"
	.section	.debug_line_str,"MS",@progbits,1
.LASF0:
	.string	"m.c"
.LASF1:
	.string	"/home/davea/dwarf/regressiontests/macroendfileIssue343"
	.ident	"GCC: (Ubuntu 15.2.0-16ubuntu1) 15.2.0"
	.section	.note.GNU-stack,"",@progbits
	.section	.note.gnu.property,"a"
	.align 8
	.long	1f - 0f
	.long	4f - 1f
	.long	5
0:
	.string	"GNU"
1:
	.align 8
	.long	0xc0000002
	.long	3f - 2f
2:
	.long	0x3
3:
	.align 8
4:
