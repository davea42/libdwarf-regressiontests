	#  /home/dgilmore/open64_pp1/bg1287a82/local/lib/gcc-lib/x86_64-open64-linux/5.0/be::5.0

	#-----------------------------------------------------------
	# Compiling ipa1.c (ipa1.B)
	#-----------------------------------------------------------

	#-----------------------------------------------------------
	# Options:
	#-----------------------------------------------------------
	#  Target:Core, ISA:ISA_1, Endian:little, Pointer Size:64
	#  -O0	(Optimization level)
	#  -g2	(Debug level)
	#  -m2	(Report advisories)
	#-----------------------------------------------------------

	.file	1	"/home/dgilmore/tests/TENX-41392/ipa1.c"


	.text
	.align	2
	.section .text
	.p2align 5,,

	# Program Unit: main
.globl	main
	.type	main, @function
main:	# 0x0
	# .frame	%rbp, 16, %rbp
	# .result_decl_1878 = -12
	# _temp_reserved_spill0 = -8
	.loc	1	4	0
 #   1  int foo(void);
 #   2  
 #   3  int main()
 #   4  {
.LBB1_main:
.LEH_pushbp_main:
	.loc	1	4	0
	pushq %rbp                    	# [0] 
.LEH_movespbp_main:
	movq %rsp,%rbp                	# [0] 
.LEH_adjustsp_main:
	addq $-16,%rsp                	# [0] 
	addq    $-8,%rsp
	fnstcw  (%rsp)
	andw    $0xfcff,(%rsp)
	orw     $768,(%rsp)
	fldcw   (%rsp)
	addq    $8,%rsp
	.loc	1	5	0
 #   5    return foo();
	.globl	foo
	call foo                      	# [0] foo
.LBB2_main:
	movl %eax,%eax                	# 
	movl %eax,-12(%rbp)           	# .result_decl_1878
	movl -12(%rbp),%eax           	# .result_decl_1878
	leave                         	# 
	ret                           	# 
.LDWend_main:
	.size main, .LDWend_main-main
	.section .text
	.align	4

	.section .debug_info, "",@progbits
	.byte	0x8e, 0x00, 0x00, 0x00, 0x02, 0x00
	.4byte	.debug_abbrev
	.4byte	0x70690108, 0x632e3161, 0x6e657400, 0x652d7773
	.4byte	0x33316578, 0x6461632e, 0x65636e65, 0x6d6f632e
	.4byte	0x6f682f3a, 0x642f656d, 0x6d6c6967, 0x2f65726f
	.4byte	0x74736574, 0x45542f73, 0x342d584e, 0x32393331
	.byte	0x00, 0x6f, 0x70, 0x65, 0x6e, 0x63, 0x63, 0x20
	.byte	0x35, 0x2e, 0x30, 0x00, 0x01, 0x00
	.quad	.LBB1_main
	.quad	.LDWend_main
	.4byte	.debug_line
	.4byte	0x746e6902, 0x03040500, 0x616d0401, 0x01006e69
	.byte	0x01, 0x01, 0x56, 0x02
	.quad	.LBB1_main
	.quad	.LDWend_main
	.byte	0x00, 0x00

	.section .debug_frame, "",@progbits
.LCIE:
	.4byte 0x10
	.4byte 0xffffffff
	.byte	0x01, 0x00, 0x01, 0x78, 0x10, 0x0c, 0x07, 0x08
	.byte	0x90, 0x01, 0x00, 0x00
	.4byte 0x28
	.4byte	.LCIE
	.quad	.LBB1_main
	.quad	.LDWend_main - .LBB1_main
	.byte	0x04
	.4byte	.LEH_movespbp_main - .LBB1_main
	.byte	0x0e, 0x10, 0x86, 0x02, 0x04
	.4byte	.LEH_adjustsp_main - .LEH_movespbp_main
	.byte	0x0d, 0x06, 0x00, 0x00, 0x00, 0x00

	.section .debug_aranges, "",@progbits
	.byte	0x2c, 0x00, 0x00, 0x00, 0x02, 0x00
	.4byte	.debug_info
	.byte	0x08, 0x00, 0x00, 0x00, 0x00, 0x00
	.quad	.LBB1_main
	.quad	.LDWend_main - .LBB1_main
	.4byte	0x00000000, 0x00000000, 0x00000000, 0x00000000

	.section .debug_pubnames, "",@progbits
	.byte	0x17, 0x00, 0x00, 0x00, 0x02, 0x00
	.4byte	.debug_info
	.4byte	0x00000092, 0x00000073, 0x6e69616d, 0x00000000
	.byte	0x00

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
	.quad	.LBB1_main
	.quad	.LDWend_main - .LBB1_main
	.byte	0x04
	.4byte	.LEH_movespbp_main - .LBB1_main
	.byte	0x0e, 0x10, 0x86, 0x02, 0x04
	.4byte	.LEH_adjustsp_main - .LEH_movespbp_main
	.byte	0x0d, 0x06
	.align 8
.LFDE1_end:

	.section .debug_line, ""

	.section .debug_abbrev, "",@progbits
	.4byte	0x03011101, 0x25081b08, 0x420b1308, 0x1201110b
	.4byte	0x00061001, 0x00240200, 0x0b3e0803, 0x00000b0b
	.4byte	0x3a002e03, 0x030b3b0b, 0x340c3f08, 0x360a400c
	.byte	0x0b, 0x11, 0x01, 0x12, 0x01, 0x00, 0x00, 0x00
	.byte	0x00
	.section	.note.GNU-stack,"",@progbits
	.ident	"#Open64 Compiler Version 5.0 : ipa1.c compiled with : -O0 -g2 -march=core -msse2 -msse3 -mno-3dnow -mno-sse4a -mno-ssse3 -mno-sse41 -mno-sse42 -mno-aes -mno-pclmul -mno-avx -mno-xop -mno-fma -mno-fma4 -m64"

