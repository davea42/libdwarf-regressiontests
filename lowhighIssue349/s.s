	.file	"s.c"
	.text
.Ltext0:
	.file 1 "s.c"
	.p2align 4
	.globl	f
	.type	f, @function
f:
.LVL0:
.LFB0:
	.loc 1 2 21 view -0
	.cfi_startproc
	.loc 1 2 21 is_stmt 0 view .LVU1
	endbr64
	.loc 1 2 23 is_stmt 1 view .LVU2
	.loc 1 2 21 is_stmt 0 view .LVU3
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movl	%esi, %ebp
	pushq	%rbx
	.cfi_def_cfa_offset 24
	.cfi_offset 3, -24
	movl	%edi, %ebx
	.loc 1 2 27 view .LVU4
	leal	(%rdi,%rdi,2), %edi
.LVL1:
	.loc 1 2 36 is_stmt 1 view .LVU5
	.loc 1 2 21 is_stmt 0 view .LVU6
	subq	$8, %rsp
	.cfi_def_cfa_offset 32
	.loc 1 2 40 view .LVU7
	call	g@PLT
.LVL2:
	.loc 1 2 46 is_stmt 1 discriminator 1 view .LVU8
	.loc 1 2 50 is_stmt 0 discriminator 1 view .LVU9
	leal	(%rax,%rbp), %edi
.LVL3:
	.loc 1 2 61 is_stmt 1 discriminator 1 view .LVU10
	.loc 1 2 65 is_stmt 0 discriminator 1 view .LVU11
	call	g@PLT
.LVL4:
	.loc 1 2 71 is_stmt 1 discriminator 2 view .LVU12
	.loc 1 2 85 is_stmt 0 view .LVU13
	addq	$8, %rsp
	.cfi_def_cfa_offset 24
	.loc 1 2 80 discriminator 2 view .LVU14
	addl	%ebx, %eax
.LVL5:
	.loc 1 2 85 view .LVU15
	popq	%rbx
	.cfi_def_cfa_offset 16
.LVL6:
	.loc 1 2 85 view .LVU16
	popq	%rbp
	.cfi_def_cfa_offset 8
.LVL7:
	.loc 1 2 85 view .LVU17
	ret
	.cfi_endproc
.LFE0:
	.size	f, .-f
.Letext0:
	.section	.debug_addr,"",@progbits
.Ldebug_addr0:
	.quad	.LVL1
	.quad	.LVL2
	.quad	.LVL3
	.quad	.LVL4
	.quad	.LVL6
	.quad	.LFB0
	.quad	.LVL2-1
	.quad	.LVL7
	.quad	.LVL0
	.section	.debug_info.dwo,"e",@progbits
.Ldebug_info0:
	.long	0xad
	.value	0x4
	.long	.Ldebug_abbrev0
	.byte	0x8
	.uleb128 0x1
	.uleb128 0x1
	.byte	0xc
	.string	"s.c"
	.uleb128 0
	.byte	0xde
	.byte	0x1e
	.byte	0x46
	.byte	0x27
	.byte	0xb9
	.byte	0xb1
	.byte	0xd5
	.byte	0x6c
	.uleb128 0x2
	.string	"g"
	.byte	0x1
	.byte	0x1
	.byte	0xc
	.long	0x2f
	.long	0x2f
	.uleb128 0x3
	.long	0x2f
	.byte	0
	.uleb128 0x4
	.byte	0x4
	.byte	0x5
	.string	"int"
	.uleb128 0x5
	.string	"f"
	.byte	0x1
	.byte	0x2
	.byte	0x5
	.long	0x2f
	.uleb128 0x5
	.quad	.LFE0-.LFB0
	.uleb128 0x1
	.byte	0x9c
	.uleb128 0x6
	.string	"a"
	.byte	0x1
	.byte	0x2
	.byte	0xb
	.long	0x2f
	.long	.LLST0-.Ldebug_loc0
	.long	.LVUS0-.Ldebug_loc0
	.uleb128 0x6
	.string	"b"
	.byte	0x1
	.byte	0x2
	.byte	0x12
	.long	0x2f
	.long	.LLST1-.Ldebug_loc0
	.long	.LVUS1-.Ldebug_loc0
	.uleb128 0x7
	.string	"x"
	.byte	0x1
	.byte	0x2
	.byte	0x1b
	.long	0x2f
	.long	.LLST2-.Ldebug_loc0
	.long	.LVUS2-.Ldebug_loc0
	.uleb128 0x7
	.string	"y"
	.byte	0x1
	.byte	0x2
	.byte	0x32
	.long	0x2f
	.long	.LLST3-.Ldebug_loc0
	.long	.LVUS3-.Ldebug_loc0
	.uleb128 0x8
	.uleb128 0x1
	.long	0x1b
	.long	0xa9
	.uleb128 0x9
	.uleb128 0x1
	.byte	0x55
	.uleb128 0x7
	.byte	0x73
	.sleb128 0
	.byte	0x31
	.byte	0x24
	.byte	0x73
	.sleb128 0
	.byte	0x22
	.byte	0
	.uleb128 0xa
	.uleb128 0x3
	.long	0x1b
	.byte	0
	.byte	0
	.section	.debug_info,"",@progbits
.Lskeleton_debug_info0:
	.long	0x30
	.value	0x4
	.long	.Lskeleton_debug_abbrev0
	.byte	0x8
	.uleb128 0x1
	.quad	.Ltext0
	.quad	.Letext0-.Ltext0
	.long	.Ldebug_line0
	.long	.LASF0
	.long	.LASF1
	.long	.Ldebug_addr0
	.byte	0xde
	.byte	0x1e
	.byte	0x46
	.byte	0x27
	.byte	0xb9
	.byte	0xb1
	.byte	0xd5
	.byte	0x6c
	.section	.debug_abbrev,"",@progbits
.Lskeleton_debug_abbrev0:
	.uleb128 0x1
	.uleb128 0x11
	.byte	0
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x7
	.uleb128 0x10
	.uleb128 0x17
	.uleb128 0x2130
	.uleb128 0xe
	.uleb128 0x1b
	.uleb128 0xe
	.uleb128 0x2134
	.uleb128 0x19
	.uleb128 0x2133
	.uleb128 0x17
	.uleb128 0x2131
	.uleb128 0x7
	.byte	0
	.byte	0
	.byte	0
	.section	.debug_abbrev.dwo,"e",@progbits
.Ldebug_abbrev0:
	.uleb128 0x1
	.uleb128 0x11
	.byte	0x1
	.uleb128 0x25
	.uleb128 0x1f02
	.uleb128 0x13
	.uleb128 0xb
	.uleb128 0x3
	.uleb128 0x8
	.uleb128 0x1b
	.uleb128 0x1f02
	.uleb128 0x2131
	.uleb128 0x7
	.byte	0
	.byte	0
	.uleb128 0x2
	.uleb128 0x2e
	.byte	0x1
	.uleb128 0x3f
	.uleb128 0x19
	.uleb128 0x3
	.uleb128 0x8
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
	.uleb128 0x3c
	.uleb128 0x19
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x3
	.uleb128 0x5
	.byte	0
	.uleb128 0x49
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x4
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
	.uleb128 0x5
	.uleb128 0x2e
	.byte	0x1
	.uleb128 0x3f
	.uleb128 0x19
	.uleb128 0x3
	.uleb128 0x8
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
	.uleb128 0x1f01
	.uleb128 0x12
	.uleb128 0x7
	.uleb128 0x40
	.uleb128 0x18
	.uleb128 0x2117
	.uleb128 0x19
	.byte	0
	.byte	0
	.uleb128 0x6
	.uleb128 0x5
	.byte	0
	.uleb128 0x3
	.uleb128 0x8
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2
	.uleb128 0x17
	.uleb128 0x2137
	.uleb128 0x17
	.byte	0
	.byte	0
	.uleb128 0x7
	.uleb128 0x34
	.byte	0
	.uleb128 0x3
	.uleb128 0x8
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2
	.uleb128 0x17
	.uleb128 0x2137
	.uleb128 0x17
	.byte	0
	.byte	0
	.uleb128 0x8
	.uleb128 0x4109
	.byte	0x1
	.uleb128 0x11
	.uleb128 0x1f01
	.uleb128 0x31
	.uleb128 0x13
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x9
	.uleb128 0x410a
	.byte	0
	.uleb128 0x2
	.uleb128 0x18
	.uleb128 0x2111
	.uleb128 0x18
	.byte	0
	.byte	0
	.uleb128 0xa
	.uleb128 0x4109
	.byte	0
	.uleb128 0x11
	.uleb128 0x1f01
	.uleb128 0x31
	.uleb128 0x13
	.byte	0
	.byte	0
	.byte	0
	.section	.debug_loc.dwo,"e",@progbits
.Ldebug_loc0:
.LVUS0:
	.uleb128 0
	.uleb128 .LVU5
	.uleb128 .LVU5
	.uleb128 .LVU16
	.uleb128 .LVU16
	.uleb128 0
.LLST0:
	.byte	0x3
	.uleb128 0x8
	.long	.LVL1-.LVL0
	.value	0x1
	.byte	0x55
	.byte	0x3
	.uleb128 0
	.long	.LVL6-.LVL1
	.value	0x1
	.byte	0x53
	.byte	0x3
	.uleb128 0x4
	.long	.LFE0-.LVL6
	.value	0x4
	.byte	0xf3
	.uleb128 0x1
	.byte	0x55
	.byte	0x9f
	.byte	0
.LVUS1:
	.uleb128 0
	.uleb128 .LVU8
	.uleb128 .LVU8
	.uleb128 .LVU17
	.uleb128 .LVU17
	.uleb128 0
.LLST1:
	.byte	0x3
	.uleb128 0x8
	.long	.LVL2-1-.LVL0
	.value	0x1
	.byte	0x54
	.byte	0x3
	.uleb128 0x6
	.long	.LVL7-.LVL2-1
	.value	0x1
	.byte	0x56
	.byte	0x3
	.uleb128 0x7
	.long	.LFE0-.LVL7
	.value	0x4
	.byte	0xf3
	.uleb128 0x1
	.byte	0x54
	.byte	0x9f
	.byte	0
.LVUS2:
	.uleb128 .LVU5
	.uleb128 .LVU8
	.uleb128 .LVU8
	.uleb128 .LVU8
	.uleb128 .LVU8
	.uleb128 .LVU12
.LLST2:
	.byte	0x3
	.uleb128 0
	.long	.LVL2-1-.LVL1
	.value	0x1
	.byte	0x55
	.byte	0x3
	.uleb128 0x6
	.long	.LVL2-.LVL2-1
	.value	0x8
	.byte	0x73
	.sleb128 0
	.byte	0x31
	.byte	0x24
	.byte	0x73
	.sleb128 0
	.byte	0x22
	.byte	0x9f
	.byte	0x3
	.uleb128 0x1
	.long	.LVL4-1-.LVL2
	.value	0x1
	.byte	0x50
	.byte	0
.LVUS3:
	.uleb128 .LVU10
	.uleb128 .LVU12
	.uleb128 .LVU12
	.uleb128 .LVU15
.LLST3:
	.byte	0x3
	.uleb128 0x2
	.long	.LVL4-1-.LVL3
	.value	0x1
	.byte	0x55
	.byte	0x3
	.uleb128 0x3
	.long	.LVL5-.LVL4
	.value	0x1
	.byte	0x50
	.byte	0
	.section	.debug_gnu_pubnames,"",@progbits
	.long	0x15
	.value	0x2
	.long	.Lskeleton_debug_info0
	.long	0xb1
	.long	0x36
	.byte	0x30
	.string	"f"
	.long	0
	.section	.debug_gnu_pubtypes,"",@progbits
	.long	0x17
	.value	0x2
	.long	.Lskeleton_debug_info0
	.long	0xb1
	.long	0x2f
	.byte	0x90
	.string	"int"
	.long	0
	.section	.debug_aranges,"",@progbits
	.long	0x2c
	.value	0x2
	.long	.Lskeleton_debug_info0
	.byte	0x8
	.byte	0
	.value	0
	.value	0
	.quad	.Ltext0
	.quad	.Letext0-.Ltext0
	.quad	0
	.quad	0
	.section	.debug_line,"",@progbits
.Ldebug_line0:
	.section	.debug_line.dwo,"e",@progbits
.Lskeleton_debug_line0:
	.long	.LELT0-.LSLT0
.LSLT0:
	.value	0x4
	.long	.LELTP0-.LASLTP0
.LASLTP0:
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0xf6
	.byte	0xf2
	.byte	0xd
	.byte	0
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0
	.byte	0
	.byte	0
	.byte	0x1
	.byte	0
	.byte	0
	.byte	0x1
	.byte	0
	.string	"s.c"
	.uleb128 0
	.uleb128 0
	.uleb128 0
	.byte	0
.LELTP0:
.LELT0:
	.section	.debug_str,"MS",@progbits,1
.LASF0:
	.string	"s.dwo"
.LASF1:
	.string	"/home/davea/dwarf/regressiontests/lowhighIssue349"
	.section	.debug_str_offsets.dwo,"e",@progbits
	.long	0
	.long	0x32
	.section	.debug_str.dwo,"e",@progbits
	.string	"/home/davea/dwarf/regressiontests/lowhighIssue349"
	.string	"GNU C23 15.2.0 -D_FORTIFY_SOURCE=3 -mtune=generic -march=x86-64 -gdwarf-4 -gsplit-dwarf -O2 -fasynchronous-unwind-tables -fstack-protector-strong -fstack-clash-protection -fcf-protection -fzero-init-padding-bits=all"
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
