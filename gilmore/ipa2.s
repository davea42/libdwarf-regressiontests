	#  /home/dgilmore/open64_pp1/bg1287a82/local/lib/gcc-lib/x86_64-open64-linux/5.0/be::5.0

	#-----------------------------------------------------------
	# Compiling ipa2.c (ipa2.B)
	#-----------------------------------------------------------

	#-----------------------------------------------------------
	# Options:
	#-----------------------------------------------------------
	#  Target:Core, ISA:ISA_1, Endian:little, Pointer Size:64
	#  -O0	(Optimization level)
	#  -g2	(Debug level)
	#  -m2	(Report advisories)
	#-----------------------------------------------------------

	.file	1	"/home/dgilmore/tests/TENX-41392/ipa2.c"


	.text
	.align	2
	.section .text
	.p2align 5,,

	# Program Unit: foo
.globl	foo
	.type	foo, @function
foo:	# 0x0
	# .frame	%rbp, 16, %rbp
	# .result_decl_1877 = -12
	# _temp_reserved_spill0 = -8
	.loc	1	1	0
 #   1  int foo(void) { return 0; }
.LBB1_foo:
.LEH_pushbp_foo:
	.loc	1	1	0
	pushq %rbp                    	# 
.LEH_movespbp_foo:
	movq %rsp,%rbp                	# 
.LEH_adjustsp_foo:
	addq $-16,%rsp                	# 
	.loc	1	1	0
	movq $0,%rax                  	# 
	leave                         	# 
	ret                           	# 
.LDWend_foo:
	.size foo, .LDWend_foo-foo
	.section .text
	.align	4

	.section .debug_info, "",@progbits
	.byte	0x8c, 0x00, 0x00, 0x00, 0x02, 0x00
	.4byte	.debug_abbrev
	.4byte	0x70690108, 0x632e3261, 0x6e657400, 0x652d7773
	.4byte	0x33316578, 0x6461632e, 0x65636e65, 0x6d6f632e
	.4byte	0x6f682f3a, 0x642f656d, 0x6d6c6967, 0x2f65726f
	.4byte	0x74736574, 0x45542f73, 0x342d584e, 0x32393331
	.byte	0x00, 0x6f, 0x70, 0x65, 0x6e, 0x63, 0x63, 0x20
	.byte	0x35, 0x2e, 0x30, 0x00, 0x01, 0x00
	.quad	.LBB1_foo
	.quad	.LDWend_foo
	.4byte	.debug_line
	.4byte	0x746e6902, 0x03040500, 0x6f660101, 0x0101006f
	.byte	0x01, 0x56
	.quad	.LBB1_foo
	.quad	.LDWend_foo
	.byte	0x00, 0x00

	.section .debug_frame, "",@progbits
.LCIE:
	.4byte 0x10
	.4byte 0xffffffff
	.byte	0x01, 0x00, 0x01, 0x78, 0x10, 0x0c, 0x07, 0x08
	.byte	0x90, 0x01, 0x00, 0x00
	.4byte 0x28
	.4byte	.LCIE
	.quad	.LBB1_foo
	.quad	.LDWend_foo - .LBB1_foo
	.byte	0x04
	.4byte	.LEH_movespbp_foo - .LBB1_foo
	.byte	0x0e, 0x10, 0x86, 0x02, 0x04
	.4byte	.LEH_adjustsp_foo - .LEH_movespbp_foo
	.byte	0x0d, 0x06, 0x00, 0x00, 0x00, 0x00

	.section .debug_aranges, "",@progbits
	.byte	0x2c, 0x00, 0x00, 0x00, 0x02, 0x00
	.4byte	.debug_info
	.byte	0x08, 0x00, 0x00, 0x00, 0x00, 0x00
	.quad	.LBB1_foo
	.quad	.LDWend_foo - .LBB1_foo
	.4byte	0x00000000, 0x00000000, 0x00000000, 0x00000000

	.section .debug_pubnames, "",@progbits
	.byte	0x16, 0x00, 0x00, 0x00, 0x02, 0x00
	.4byte	.debug_info
	.4byte	0x00000090, 0x00000073, 0x006f6f66, 0x00000000

	.section .eh_frame, "a",@progbits
.LEHCIE:
	.4byte	.LEHCIE_end - .LEHCIE_begin
.LEHCIE_begin:
	.4byte 0x0
	.byte	0x01, 0x00, 0x01, 0x78, 0x10, 0x0c, 0x07, 0x08
	.byte	0x90, 0x01
	.align 8
.LEHCIE_end:
	.4byte	.LFDE1_end - .LFDE1_begin
.LFDE1_begin:
	.4byte	.LFDE1_begin - .LEHCIE
	.quad	.LBB1_foo
	.quad	.LDWend_foo - .LBB1_foo
	.byte	0x04
	.4byte	.LEH_movespbp_foo - .LBB1_foo
	.byte	0x0e, 0x10, 0x86, 0x02, 0x04
	.4byte	.LEH_adjustsp_foo - .LEH_movespbp_foo
	.byte	0x0d, 0x06
	.align 8
.LFDE1_end:

	.section .debug_line, ""

	.section .debug_abbrev, "",@progbits
	.4byte	0x03011101, 0x25081b08, 0x420b1308, 0x1201110b
	.4byte	0x00061001, 0x00240200, 0x0b3e0803, 0x00000b0b
	.4byte	0x3a002e03, 0x030b3b0b, 0x340c3f08, 0x110a400c
	.byte	0x01, 0x12, 0x01, 0x00, 0x00, 0x00, 0x00
	.section	.note.GNU-stack,"",@progbits
	.ident	"#Open64 Compiler Version 5.0 : ipa2.c compiled with : -O0 -g2 -march=core -msse2 -msse3 -mno-3dnow -mno-sse4a -mno-ssse3 -mno-sse41 -mno-sse42 -mno-aes -mno-pclmul -mno-avx -mno-xop -mno-fma -mno-fma4 -m64"

