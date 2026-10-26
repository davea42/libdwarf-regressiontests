	.file	"m.c"
	.text
.Ltext0:
	.file 1 "m.c"
	.globl	x
	.type	x, @function
x:
.LFB0:
	.loc 1 2 13
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movl	%edi, -4(%rbp)
	.loc 1 2 22
	movl	-4(%rbp), %eax
	addl	$1, %eax
	.loc 1 2 27
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE0:
	.size	x, .-x
.Letext0:
	.section	.debug_info,"",@progbits
.Ldebug_info0:
	.long	0x63
	.value	0x4
	.long	.Ldebug_abbrev0
	.byte	0x8
	.uleb128 0x1
	.long	.LASF0
	.byte	0xc
	.string	"m.c"
	.long	.LASF1
	.quad	.Ltext0
	.quad	.Letext0-.Ltext0
	.long	.Ldebug_line0
	.long	.Ldebug_macinfo0
	.uleb128 0x2
	.string	"x"
	.byte	0x1
	.byte	0x2
	.byte	0x5
	.long	0x5f
	.quad	.LFB0
	.quad	.LFE0-.LFB0
	.uleb128 0x1
	.byte	0x9c
	.long	0x5f
	.uleb128 0x3
	.string	"a"
	.byte	0x1
	.byte	0x2
	.byte	0xb
	.long	0x5f
	.uleb128 0x2
	.byte	0x91
	.sleb128 -20
	.byte	0
	.uleb128 0x4
	.byte	0x4
	.byte	0x5
	.string	"int"
	.byte	0
	.section	.debug_abbrev,"",@progbits
.Ldebug_abbrev0:
	.uleb128 0x1
	.uleb128 0x11
	.byte	0x1
	.uleb128 0x25
	.uleb128 0xe
	.uleb128 0x13
	.uleb128 0xb
	.uleb128 0x3
	.uleb128 0x8
	.uleb128 0x1b
	.uleb128 0xe
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x7
	.uleb128 0x10
	.uleb128 0x17
	.uleb128 0x43
	.uleb128 0x17
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
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x7
	.uleb128 0x40
	.uleb128 0x18
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x3
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
	.uleb128 0x18
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
	.section	.debug_macinfo,"",@progbits
.Ldebug_macinfo0:
	.byte	0x1
	.uleb128 0
	.string	"__STDC__ 1"
	.byte	0x1
	.uleb128 0
	.string	"__STDC_VERSION__ 202311L"
	.byte	0x1
	.uleb128 0
	.string	"__STDC_UTF_16__ 1"
	.byte	0x1
	.uleb128 0
	.string	"__STDC_UTF_32__ 1"
	.byte	0x1
	.uleb128 0
	.string	"__STDC_HOSTED__ 1"
	.byte	0x1
	.uleb128 0
	.string	"__STDC_EMBED_NOT_FOUND__ 0"
	.byte	0x1
	.uleb128 0
	.string	"__STDC_EMBED_FOUND__ 1"
	.byte	0x1
	.uleb128 0
	.string	"__STDC_EMBED_EMPTY__ 2"
	.byte	0x1
	.uleb128 0
	.string	"__GNUC__ 15"
	.byte	0x1
	.uleb128 0
	.string	"__GNUC_MINOR__ 2"
	.byte	0x1
	.uleb128 0
	.string	"__GNUC_PATCHLEVEL__ 0"
	.byte	0x1
	.uleb128 0
	.string	"__VERSION__ \"15.2.0\""
	.byte	0x1
	.uleb128 0
	.string	"__ATOMIC_RELAXED 0"
	.byte	0x1
	.uleb128 0
	.string	"__ATOMIC_SEQ_CST 5"
	.byte	0x1
	.uleb128 0
	.string	"__ATOMIC_ACQUIRE 2"
	.byte	0x1
	.uleb128 0
	.string	"__ATOMIC_RELEASE 3"
	.byte	0x1
	.uleb128 0
	.string	"__ATOMIC_ACQ_REL 4"
	.byte	0x1
	.uleb128 0
	.string	"__ATOMIC_CONSUME 1"
	.byte	0x1
	.uleb128 0
	.string	"__pic__ 2"
	.byte	0x1
	.uleb128 0
	.string	"__PIC__ 2"
	.byte	0x1
	.uleb128 0
	.string	"__pie__ 2"
	.byte	0x1
	.uleb128 0
	.string	"__PIE__ 2"
	.byte	0x1
	.uleb128 0
	.string	"__FINITE_MATH_ONLY__ 0"
	.byte	0x1
	.uleb128 0
	.string	"_LP64 1"
	.byte	0x1
	.uleb128 0
	.string	"__LP64__ 1"
	.byte	0x1
	.uleb128 0
	.string	"__SIZEOF_INT__ 4"
	.byte	0x1
	.uleb128 0
	.string	"__SIZEOF_LONG__ 8"
	.byte	0x1
	.uleb128 0
	.string	"__SIZEOF_LONG_LONG__ 8"
	.byte	0x1
	.uleb128 0
	.string	"__SIZEOF_SHORT__ 2"
	.byte	0x1
	.uleb128 0
	.string	"__SIZEOF_FLOAT__ 4"
	.byte	0x1
	.uleb128 0
	.string	"__SIZEOF_DOUBLE__ 8"
	.byte	0x1
	.uleb128 0
	.string	"__SIZEOF_LONG_DOUBLE__ 16"
	.byte	0x1
	.uleb128 0
	.string	"__SIZEOF_SIZE_T__ 8"
	.byte	0x1
	.uleb128 0
	.string	"__CHAR_BIT__ 8"
	.byte	0x1
	.uleb128 0
	.string	"__BIGGEST_ALIGNMENT__ 16"
	.byte	0x1
	.uleb128 0
	.string	"__ORDER_LITTLE_ENDIAN__ 1234"
	.byte	0x1
	.uleb128 0
	.string	"__ORDER_BIG_ENDIAN__ 4321"
	.byte	0x1
	.uleb128 0
	.string	"__ORDER_PDP_ENDIAN__ 3412"
	.byte	0x1
	.uleb128 0
	.string	"__BYTE_ORDER__ __ORDER_LITTLE_ENDIAN__"
	.byte	0x1
	.uleb128 0
	.string	"__FLOAT_WORD_ORDER__ __ORDER_LITTLE_ENDIAN__"
	.byte	0x1
	.uleb128 0
	.string	"__SIZEOF_POINTER__ 8"
	.byte	0x1
	.uleb128 0
	.string	"__GNUC_EXECUTION_CHARSET_NAME \"UTF-8\""
	.byte	0x1
	.uleb128 0
	.string	"__GNUC_WIDE_EXECUTION_CHARSET_NAME \"UTF-32LE\""
	.byte	0x1
	.uleb128 0
	.string	"__SIZE_TYPE__ long unsigned int"
	.byte	0x1
	.uleb128 0
	.string	"__PTRDIFF_TYPE__ long int"
	.byte	0x1
	.uleb128 0
	.string	"__WCHAR_TYPE__ int"
	.byte	0x1
	.uleb128 0
	.string	"__WINT_TYPE__ unsigned int"
	.byte	0x1
	.uleb128 0
	.string	"__INTMAX_TYPE__ long int"
	.byte	0x1
	.uleb128 0
	.string	"__UINTMAX_TYPE__ long unsigned int"
	.byte	0x1
	.uleb128 0
	.string	"__CHAR8_TYPE__ unsigned char"
	.byte	0x1
	.uleb128 0
	.string	"__CHAR16_TYPE__ short unsigned int"
	.byte	0x1
	.uleb128 0
	.string	"__CHAR32_TYPE__ unsigned int"
	.byte	0x1
	.uleb128 0
	.string	"__SIG_ATOMIC_TYPE__ int"
	.byte	0x1
	.uleb128 0
	.string	"__INT8_TYPE__ signed char"
	.byte	0x1
	.uleb128 0
	.string	"__INT16_TYPE__ short int"
	.byte	0x1
	.uleb128 0
	.string	"__INT32_TYPE__ int"
	.byte	0x1
	.uleb128 0
	.string	"__INT64_TYPE__ long int"
	.byte	0x1
	.uleb128 0
	.string	"__UINT8_TYPE__ unsigned char"
	.byte	0x1
	.uleb128 0
	.string	"__UINT16_TYPE__ short unsigned int"
	.byte	0x1
	.uleb128 0
	.string	"__UINT32_TYPE__ unsigned int"
	.byte	0x1
	.uleb128 0
	.string	"__UINT64_TYPE__ long unsigned int"
	.byte	0x1
	.uleb128 0
	.string	"__INT_LEAST8_TYPE__ signed char"
	.byte	0x1
	.uleb128 0
	.string	"__INT_LEAST16_TYPE__ short int"
	.byte	0x1
	.uleb128 0
	.string	"__INT_LEAST32_TYPE__ int"
	.byte	0x1
	.uleb128 0
	.string	"__INT_LEAST64_TYPE__ long int"
	.byte	0x1
	.uleb128 0
	.string	"__UINT_LEAST8_TYPE__ unsigned char"
	.byte	0x1
	.uleb128 0
	.string	"__UINT_LEAST16_TYPE__ short unsigned int"
	.byte	0x1
	.uleb128 0
	.string	"__UINT_LEAST32_TYPE__ unsigned int"
	.byte	0x1
	.uleb128 0
	.string	"__UINT_LEAST64_TYPE__ long unsigned int"
	.byte	0x1
	.uleb128 0
	.string	"__INT_FAST8_TYPE__ signed char"
	.byte	0x1
	.uleb128 0
	.string	"__INT_FAST16_TYPE__ long int"
	.byte	0x1
	.uleb128 0
	.string	"__INT_FAST32_TYPE__ long int"
	.byte	0x1
	.uleb128 0
	.string	"__INT_FAST64_TYPE__ long int"
	.byte	0x1
	.uleb128 0
	.string	"__UINT_FAST8_TYPE__ unsigned char"
	.byte	0x1
	.uleb128 0
	.string	"__UINT_FAST16_TYPE__ long unsigned int"
	.byte	0x1
	.uleb128 0
	.string	"__UINT_FAST32_TYPE__ long unsigned int"
	.byte	0x1
	.uleb128 0
	.string	"__UINT_FAST64_TYPE__ long unsigned int"
	.byte	0x1
	.uleb128 0
	.string	"__INTPTR_TYPE__ long int"
	.byte	0x1
	.uleb128 0
	.string	"__UINTPTR_TYPE__ long unsigned int"
	.byte	0x1
	.uleb128 0
	.string	"__GXX_ABI_VERSION 1020"
	.byte	0x1
	.uleb128 0
	.string	"__SCHAR_MAX__ 0x7f"
	.byte	0x1
	.uleb128 0
	.string	"__SHRT_MAX__ 0x7fff"
	.byte	0x1
	.uleb128 0
	.string	"__INT_MAX__ 0x7fffffff"
	.byte	0x1
	.uleb128 0
	.string	"__LONG_MAX__ 0x7fffffffffffffffL"
	.byte	0x1
	.uleb128 0
	.string	"__LONG_LONG_MAX__ 0x7fffffffffffffffLL"
	.byte	0x1
	.uleb128 0
	.string	"__WCHAR_MAX__ 0x7fffffff"
	.byte	0x1
	.uleb128 0
	.string	"__WCHAR_MIN__ (-__WCHAR_MAX__ - 1)"
	.byte	0x1
	.uleb128 0
	.string	"__WINT_MAX__ 0xffffffffU"
	.byte	0x1
	.uleb128 0
	.string	"__WINT_MIN__ 0U"
	.byte	0x1
	.uleb128 0
	.string	"__PTRDIFF_MAX__ 0x7fffffffffffffffL"
	.byte	0x1
	.uleb128 0
	.string	"__SIZE_MAX__ 0xffffffffffffffffUL"
	.byte	0x1
	.uleb128 0
	.string	"__SCHAR_WIDTH__ 8"
	.byte	0x1
	.uleb128 0
	.string	"__SHRT_WIDTH__ 16"
	.byte	0x1
	.uleb128 0
	.string	"__INT_WIDTH__ 32"
	.byte	0x1
	.uleb128 0
	.string	"__LONG_WIDTH__ 64"
	.byte	0x1
	.uleb128 0
	.string	"__LONG_LONG_WIDTH__ 64"
	.byte	0x1
	.uleb128 0
	.string	"__WCHAR_WIDTH__ 32"
	.byte	0x1
	.uleb128 0
	.string	"__WINT_WIDTH__ 32"
	.byte	0x1
	.uleb128 0
	.string	"__PTRDIFF_WIDTH__ 64"
	.byte	0x1
	.uleb128 0
	.string	"__SIZE_WIDTH__ 64"
	.byte	0x1
	.uleb128 0
	.string	"__BITINT_MAXWIDTH__ 65535"
	.byte	0x1
	.uleb128 0
	.string	"__INTMAX_MAX__ 0x7fffffffffffffffL"
	.byte	0x1
	.uleb128 0
	.string	"__INTMAX_C(c) c ## L"
	.byte	0x1
	.uleb128 0
	.string	"__UINTMAX_MAX__ 0xffffffffffffffffUL"
	.byte	0x1
	.uleb128 0
	.string	"__UINTMAX_C(c) c ## UL"
	.byte	0x1
	.uleb128 0
	.string	"__INTMAX_WIDTH__ 64"
	.byte	0x1
	.uleb128 0
	.string	"__SIG_ATOMIC_MAX__ 0x7fffffff"
	.byte	0x1
	.uleb128 0
	.string	"__SIG_ATOMIC_MIN__ (-__SIG_ATOMIC_MAX__ - 1)"
	.byte	0x1
	.uleb128 0
	.string	"__SIG_ATOMIC_WIDTH__ 32"
	.byte	0x1
	.uleb128 0
	.string	"__INT8_MAX__ 0x7f"
	.byte	0x1
	.uleb128 0
	.string	"__INT16_MAX__ 0x7fff"
	.byte	0x1
	.uleb128 0
	.string	"__INT32_MAX__ 0x7fffffff"
	.byte	0x1
	.uleb128 0
	.string	"__INT64_MAX__ 0x7fffffffffffffffL"
	.byte	0x1
	.uleb128 0
	.string	"__UINT8_MAX__ 0xff"
	.byte	0x1
	.uleb128 0
	.string	"__UINT16_MAX__ 0xffff"
	.byte	0x1
	.uleb128 0
	.string	"__UINT32_MAX__ 0xffffffffU"
	.byte	0x1
	.uleb128 0
	.string	"__UINT64_MAX__ 0xffffffffffffffffUL"
	.byte	0x1
	.uleb128 0
	.string	"__INT_LEAST8_MAX__ 0x7f"
	.byte	0x1
	.uleb128 0
	.string	"__INT8_C(c) c"
	.byte	0x1
	.uleb128 0
	.string	"__INT_LEAST8_WIDTH__ 8"
	.byte	0x1
	.uleb128 0
	.string	"__INT_LEAST16_MAX__ 0x7fff"
	.byte	0x1
	.uleb128 0
	.string	"__INT16_C(c) c"
	.byte	0x1
	.uleb128 0
	.string	"__INT_LEAST16_WIDTH__ 16"
	.byte	0x1
	.uleb128 0
	.string	"__INT_LEAST32_MAX__ 0x7fffffff"
	.byte	0x1
	.uleb128 0
	.string	"__INT32_C(c) c"
	.byte	0x1
	.uleb128 0
	.string	"__INT_LEAST32_WIDTH__ 32"
	.byte	0x1
	.uleb128 0
	.string	"__INT_LEAST64_MAX__ 0x7fffffffffffffffL"
	.byte	0x1
	.uleb128 0
	.string	"__INT64_C(c) c ## L"
	.byte	0x1
	.uleb128 0
	.string	"__INT_LEAST64_WIDTH__ 64"
	.byte	0x1
	.uleb128 0
	.string	"__UINT_LEAST8_MAX__ 0xff"
	.byte	0x1
	.uleb128 0
	.string	"__UINT8_C(c) c"
	.byte	0x1
	.uleb128 0
	.string	"__UINT_LEAST16_MAX__ 0xffff"
	.byte	0x1
	.uleb128 0
	.string	"__UINT16_C(c) c"
	.byte	0x1
	.uleb128 0
	.string	"__UINT_LEAST32_MAX__ 0xffffffffU"
	.byte	0x1
	.uleb128 0
	.string	"__UINT32_C(c) c ## U"
	.byte	0x1
	.uleb128 0
	.string	"__UINT_LEAST64_MAX__ 0xffffffffffffffffUL"
	.byte	0x1
	.uleb128 0
	.string	"__UINT64_C(c) c ## UL"
	.byte	0x1
	.uleb128 0
	.string	"__INT_FAST8_MAX__ 0x7f"
	.byte	0x1
	.uleb128 0
	.string	"__INT_FAST8_WIDTH__ 8"
	.byte	0x1
	.uleb128 0
	.string	"__INT_FAST16_MAX__ 0x7fffffffffffffffL"
	.byte	0x1
	.uleb128 0
	.string	"__INT_FAST16_WIDTH__ 64"
	.byte	0x1
	.uleb128 0
	.string	"__INT_FAST32_MAX__ 0x7fffffffffffffffL"
	.byte	0x1
	.uleb128 0
	.string	"__INT_FAST32_WIDTH__ 64"
	.byte	0x1
	.uleb128 0
	.string	"__INT_FAST64_MAX__ 0x7fffffffffffffffL"
	.byte	0x1
	.uleb128 0
	.string	"__INT_FAST64_WIDTH__ 64"
	.byte	0x1
	.uleb128 0
	.string	"__UINT_FAST8_MAX__ 0xff"
	.byte	0x1
	.uleb128 0
	.string	"__UINT_FAST16_MAX__ 0xffffffffffffffffUL"
	.byte	0x1
	.uleb128 0
	.string	"__UINT_FAST32_MAX__ 0xffffffffffffffffUL"
	.byte	0x1
	.uleb128 0
	.string	"__UINT_FAST64_MAX__ 0xffffffffffffffffUL"
	.byte	0x1
	.uleb128 0
	.string	"__INTPTR_MAX__ 0x7fffffffffffffffL"
	.byte	0x1
	.uleb128 0
	.string	"__INTPTR_WIDTH__ 64"
	.byte	0x1
	.uleb128 0
	.string	"__UINTPTR_MAX__ 0xffffffffffffffffUL"
	.byte	0x1
	.uleb128 0
	.string	"__GCC_IEC_559 2"
	.byte	0x1
	.uleb128 0
	.string	"__GCC_IEC_559_COMPLEX 2"
	.byte	0x1
	.uleb128 0
	.string	"__FLT_EVAL_METHOD__ 0"
	.byte	0x1
	.uleb128 0
	.string	"__FLT_EVAL_METHOD_TS_18661_3__ 0"
	.byte	0x1
	.uleb128 0
	.string	"__DEC_EVAL_METHOD__ 2"
	.byte	0x1
	.uleb128 0
	.string	"__FLT_RADIX__ 2"
	.byte	0x1
	.uleb128 0
	.string	"__FLT_MANT_DIG__ 24"
	.byte	0x1
	.uleb128 0
	.string	"__FLT_DIG__ 6"
	.byte	0x1
	.uleb128 0
	.string	"__FLT_MIN_EXP__ (-125)"
	.byte	0x1
	.uleb128 0
	.string	"__FLT_MIN_10_EXP__ (-37)"
	.byte	0x1
	.uleb128 0
	.string	"__FLT_MAX_EXP__ 128"
	.byte	0x1
	.uleb128 0
	.string	"__FLT_MAX_10_EXP__ 38"
	.byte	0x1
	.uleb128 0
	.string	"__FLT_DECIMAL_DIG__ 9"
	.byte	0x1
	.uleb128 0
	.string	"__FLT_MAX__ 3.40282346638528859811704183484516925e+38F"
	.byte	0x1
	.uleb128 0
	.string	"__FLT_NORM_MAX__ 3.40282346638528859811704183484516925e+38F"
	.byte	0x1
	.uleb128 0
	.string	"__FLT_MIN__ 1.17549435082228750796873653722224568e-38F"
	.byte	0x1
	.uleb128 0
	.string	"__FLT_EPSILON__ 1.19209289550781250000000000000000000e-7F"
	.byte	0x1
	.uleb128 0
	.string	"__FLT_DENORM_MIN__ 1.40129846432481707092372958328991613e-45F"
	.byte	0x1
	.uleb128 0
	.string	"__FLT_HAS_DENORM__ 1"
	.byte	0x1
	.uleb128 0
	.string	"__FLT_HAS_INFINITY__ 1"
	.byte	0x1
	.uleb128 0
	.string	"__FLT_HAS_QUIET_NAN__ 1"
	.byte	0x1
	.uleb128 0
	.string	"__FLT_IS_IEC_60559__ 1"
	.byte	0x1
	.uleb128 0
	.string	"__DBL_MANT_DIG__ 53"
	.byte	0x1
	.uleb128 0
	.string	"__DBL_DIG__ 15"
	.byte	0x1
	.uleb128 0
	.string	"__DBL_MIN_EXP__ (-1021)"
	.byte	0x1
	.uleb128 0
	.string	"__DBL_MIN_10_EXP__ (-307)"
	.byte	0x1
	.uleb128 0
	.string	"__DBL_MAX_EXP__ 1024"
	.byte	0x1
	.uleb128 0
	.string	"__DBL_MAX_10_EXP__ 308"
	.byte	0x1
	.uleb128 0
	.string	"__DBL_DECIMAL_DIG__ 17"
	.byte	0x1
	.uleb128 0
	.string	"__DBL_MAX__ ((double)1.79769313486231570814527423731704357e+308L)"
	.byte	0x1
	.uleb128 0
	.string	"__DBL_NORM_MAX__ ((double)1.79769313486231570814527423731704357e+308L)"
	.byte	0x1
	.uleb128 0
	.string	"__DBL_MIN__ ((double)2.22507385850720138309023271733240406e-308L)"
	.byte	0x1
	.uleb128 0
	.string	"__DBL_EPSILON__ ((double)2.22044604925031308084726333618164062e-16L)"
	.byte	0x1
	.uleb128 0
	.string	"__DBL_DENORM_MIN__ ((double)4.94065645841246544176568792868221372e-324L)"
	.byte	0x1
	.uleb128 0
	.string	"__DBL_HAS_DENORM__ 1"
	.byte	0x1
	.uleb128 0
	.string	"__DBL_HAS_INFINITY__ 1"
	.byte	0x1
	.uleb128 0
	.string	"__DBL_HAS_QUIET_NAN__ 1"
	.byte	0x1
	.uleb128 0
	.string	"__DBL_IS_IEC_60559__ 1"
	.byte	0x1
	.uleb128 0
	.string	"__LDBL_MANT_DIG__ 64"
	.byte	0x1
	.uleb128 0
	.string	"__LDBL_DIG__ 18"
	.byte	0x1
	.uleb128 0
	.string	"__LDBL_MIN_EXP__ (-16381)"
	.byte	0x1
	.uleb128 0
	.string	"__LDBL_MIN_10_EXP__ (-4931)"
	.byte	0x1
	.uleb128 0
	.string	"__LDBL_MAX_EXP__ 16384"
	.byte	0x1
	.uleb128 0
	.string	"__LDBL_MAX_10_EXP__ 4932"
	.byte	0x1
	.uleb128 0
	.string	"__DECIMAL_DIG__ 21"
	.byte	0x1
	.uleb128 0
	.string	"__LDBL_DECIMAL_DIG__ 21"
	.byte	0x1
	.uleb128 0
	.string	"__LDBL_MAX__ 1.18973149535723176502126385303097021e+4932L"
	.byte	0x1
	.uleb128 0
	.string	"__LDBL_NORM_MAX__ 1.18973149535723176502126385303097021e+4932L"
	.byte	0x1
	.uleb128 0
	.string	"__LDBL_MIN__ 3.36210314311209350626267781732175260e-4932L"
	.byte	0x1
	.uleb128 0
	.string	"__LDBL_EPSILON__ 1.08420217248550443400745280086994171e-19L"
	.byte	0x1
	.uleb128 0
	.string	"__LDBL_DENORM_MIN__ 3.64519953188247460252840593361941982e-4951L"
	.byte	0x1
	.uleb128 0
	.string	"__LDBL_HAS_DENORM__ 1"
	.byte	0x1
	.uleb128 0
	.string	"__LDBL_HAS_INFINITY__ 1"
	.byte	0x1
	.uleb128 0
	.string	"__LDBL_HAS_QUIET_NAN__ 1"
	.byte	0x1
	.uleb128 0
	.string	"__LDBL_IS_IEC_60559__ 1"
	.byte	0x1
	.uleb128 0
	.string	"__FLT16_MANT_DIG__ 11"
	.byte	0x1
	.uleb128 0
	.string	"__FLT16_DIG__ 3"
	.byte	0x1
	.uleb128 0
	.string	"__FLT16_MIN_EXP__ (-13)"
	.byte	0x1
	.uleb128 0
	.string	"__FLT16_MIN_10_EXP__ (-4)"
	.byte	0x1
	.uleb128 0
	.string	"__FLT16_MAX_EXP__ 16"
	.byte	0x1
	.uleb128 0
	.string	"__FLT16_MAX_10_EXP__ 4"
	.byte	0x1
	.uleb128 0
	.string	"__FLT16_DECIMAL_DIG__ 5"
	.byte	0x1
	.uleb128 0
	.string	"__FLT16_MAX__ 6.55040000000000000000000000000000000e+4F16"
	.byte	0x1
	.uleb128 0
	.string	"__FLT16_NORM_MAX__ 6.55040000000000000000000000000000000e+4F16"
	.byte	0x1
	.uleb128 0
	.string	"__FLT16_MIN__ 6.10351562500000000000000000000000000e-5F16"
	.byte	0x1
	.uleb128 0
	.string	"__FLT16_EPSILON__ 9.76562500000000000000000000000000000e-4F16"
	.byte	0x1
	.uleb128 0
	.string	"__FLT16_DENORM_MIN__ 5.96046447753906250000000000000000000e-8F16"
	.byte	0x1
	.uleb128 0
	.string	"__FLT16_HAS_DENORM__ 1"
	.byte	0x1
	.uleb128 0
	.string	"__FLT16_HAS_INFINITY__ 1"
	.byte	0x1
	.uleb128 0
	.string	"__FLT16_HAS_QUIET_NAN__ 1"
	.byte	0x1
	.uleb128 0
	.string	"__FLT16_IS_IEC_60559__ 1"
	.byte	0x1
	.uleb128 0
	.string	"__FLT32_MANT_DIG__ 24"
	.byte	0x1
	.uleb128 0
	.string	"__FLT32_DIG__ 6"
	.byte	0x1
	.uleb128 0
	.string	"__FLT32_MIN_EXP__ (-125)"
	.byte	0x1
	.uleb128 0
	.string	"__FLT32_MIN_10_EXP__ (-37)"
	.byte	0x1
	.uleb128 0
	.string	"__FLT32_MAX_EXP__ 128"
	.byte	0x1
	.uleb128 0
	.string	"__FLT32_MAX_10_EXP__ 38"
	.byte	0x1
	.uleb128 0
	.string	"__FLT32_DECIMAL_DIG__ 9"
	.byte	0x1
	.uleb128 0
	.string	"__FLT32_MAX__ 3.40282346638528859811704183484516925e+38F32"
	.byte	0x1
	.uleb128 0
	.string	"__FLT32_NORM_MAX__ 3.40282346638528859811704183484516925e+38F32"
	.byte	0x1
	.uleb128 0
	.string	"__FLT32_MIN__ 1.17549435082228750796873653722224568e-38F32"
	.byte	0x1
	.uleb128 0
	.string	"__FLT32_EPSILON__ 1.19209289550781250000000000000000000e-7F32"
	.byte	0x1
	.uleb128 0
	.string	"__FLT32_DENORM_MIN__ 1.40129846432481707092372958328991613e-45F32"
	.byte	0x1
	.uleb128 0
	.string	"__FLT32_HAS_DENORM__ 1"
	.byte	0x1
	.uleb128 0
	.string	"__FLT32_HAS_INFINITY__ 1"
	.byte	0x1
	.uleb128 0
	.string	"__FLT32_HAS_QUIET_NAN__ 1"
	.byte	0x1
	.uleb128 0
	.string	"__FLT32_IS_IEC_60559__ 1"
	.byte	0x1
	.uleb128 0
	.string	"__FLT64_MANT_DIG__ 53"
	.byte	0x1
	.uleb128 0
	.string	"__FLT64_DIG__ 15"
	.byte	0x1
	.uleb128 0
	.string	"__FLT64_MIN_EXP__ (-1021)"
	.byte	0x1
	.uleb128 0
	.string	"__FLT64_MIN_10_EXP__ (-307)"
	.byte	0x1
	.uleb128 0
	.string	"__FLT64_MAX_EXP__ 1024"
	.byte	0x1
	.uleb128 0
	.string	"__FLT64_MAX_10_EXP__ 308"
	.byte	0x1
	.uleb128 0
	.string	"__FLT64_DECIMAL_DIG__ 17"
	.byte	0x1
	.uleb128 0
	.string	"__FLT64_MAX__ 1.79769313486231570814527423731704357e+308F64"
	.byte	0x1
	.uleb128 0
	.string	"__FLT64_NORM_MAX__ 1.79769313486231570814527423731704357e+308F64"
	.byte	0x1
	.uleb128 0
	.string	"__FLT64_MIN__ 2.22507385850720138309023271733240406e-308F64"
	.byte	0x1
	.uleb128 0
	.string	"__FLT64_EPSILON__ 2.22044604925031308084726333618164062e-16F64"
	.byte	0x1
	.uleb128 0
	.string	"__FLT64_DENORM_MIN__ 4.94065645841246544176568792868221372e-324F64"
	.byte	0x1
	.uleb128 0
	.string	"__FLT64_HAS_DENORM__ 1"
	.byte	0x1
	.uleb128 0
	.string	"__FLT64_HAS_INFINITY__ 1"
	.byte	0x1
	.uleb128 0
	.string	"__FLT64_HAS_QUIET_NAN__ 1"
	.byte	0x1
	.uleb128 0
	.string	"__FLT64_IS_IEC_60559__ 1"
	.byte	0x1
	.uleb128 0
	.string	"__FLT128_MANT_DIG__ 113"
	.byte	0x1
	.uleb128 0
	.string	"__FLT128_DIG__ 33"
	.byte	0x1
	.uleb128 0
	.string	"__FLT128_MIN_EXP__ (-16381)"
	.byte	0x1
	.uleb128 0
	.string	"__FLT128_MIN_10_EXP__ (-4931)"
	.byte	0x1
	.uleb128 0
	.string	"__FLT128_MAX_EXP__ 16384"
	.byte	0x1
	.uleb128 0
	.string	"__FLT128_MAX_10_EXP__ 4932"
	.byte	0x1
	.uleb128 0
	.string	"__FLT128_DECIMAL_DIG__ 36"
	.byte	0x1
	.uleb128 0
	.string	"__FLT128_MAX__ 1.18973149535723176508575932662800702e+4932F128"
	.byte	0x1
	.uleb128 0
	.string	"__FLT128_NORM_MAX__ 1.18973149535723176508575932662800702e+4932F128"
	.byte	0x1
	.uleb128 0
	.string	"__FLT128_MIN__ 3.36210314311209350626267781732175260e-4932F128"
	.byte	0x1
	.uleb128 0
	.string	"__FLT128_EPSILON__ 1.92592994438723585305597794258492732e-34F128"
	.byte	0x1
	.uleb128 0
	.string	"__FLT128_DENORM_MIN__ 6.47517511943802511092443895822764655e-4966F128"
	.byte	0x1
	.uleb128 0
	.string	"__FLT128_HAS_DENORM__ 1"
	.byte	0x1
	.uleb128 0
	.string	"__FLT128_HAS_INFINITY__ 1"
	.byte	0x1
	.uleb128 0
	.string	"__FLT128_HAS_QUIET_NAN__ 1"
	.byte	0x1
	.uleb128 0
	.string	"__FLT128_IS_IEC_60559__ 1"
	.byte	0x1
	.uleb128 0
	.string	"__FLT32X_MANT_DIG__ 53"
	.byte	0x1
	.uleb128 0
	.string	"__FLT32X_DIG__ 15"
	.byte	0x1
	.uleb128 0
	.string	"__FLT32X_MIN_EXP__ (-1021)"
	.byte	0x1
	.uleb128 0
	.string	"__FLT32X_MIN_10_EXP__ (-307)"
	.byte	0x1
	.uleb128 0
	.string	"__FLT32X_MAX_EXP__ 1024"
	.byte	0x1
	.uleb128 0
	.string	"__FLT32X_MAX_10_EXP__ 308"
	.byte	0x1
	.uleb128 0
	.string	"__FLT32X_DECIMAL_DIG__ 17"
	.byte	0x1
	.uleb128 0
	.string	"__FLT32X_MAX__ 1.79769313486231570814527423731704357e+308F32x"
	.byte	0x1
	.uleb128 0
	.string	"__FLT32X_NORM_MAX__ 1.79769313486231570814527423731704357e+308F32x"
	.byte	0x1
	.uleb128 0
	.string	"__FLT32X_MIN__ 2.22507385850720138309023271733240406e-308F32x"
	.byte	0x1
	.uleb128 0
	.string	"__FLT32X_EPSILON__ 2.22044604925031308084726333618164062e-16F32x"
	.byte	0x1
	.uleb128 0
	.string	"__FLT32X_DENORM_MIN__ 4.94065645841246544176568792868221372e-324F32x"
	.byte	0x1
	.uleb128 0
	.string	"__FLT32X_HAS_DENORM__ 1"
	.byte	0x1
	.uleb128 0
	.string	"__FLT32X_HAS_INFINITY__ 1"
	.byte	0x1
	.uleb128 0
	.string	"__FLT32X_HAS_QUIET_NAN__ 1"
	.byte	0x1
	.uleb128 0
	.string	"__FLT32X_IS_IEC_60559__ 1"
	.byte	0x1
	.uleb128 0
	.string	"__FLT64X_MANT_DIG__ 64"
	.byte	0x1
	.uleb128 0
	.string	"__FLT64X_DIG__ 18"
	.byte	0x1
	.uleb128 0
	.string	"__FLT64X_MIN_EXP__ (-16381)"
	.byte	0x1
	.uleb128 0
	.string	"__FLT64X_MIN_10_EXP__ (-4931)"
	.byte	0x1
	.uleb128 0
	.string	"__FLT64X_MAX_EXP__ 16384"
	.byte	0x1
	.uleb128 0
	.string	"__FLT64X_MAX_10_EXP__ 4932"
	.byte	0x1
	.uleb128 0
	.string	"__FLT64X_DECIMAL_DIG__ 21"
	.byte	0x1
	.uleb128 0
	.string	"__FLT64X_MAX__ 1.18973149535723176502126385303097021e+4932F64x"
	.byte	0x1
	.uleb128 0
	.string	"__FLT64X_NORM_MAX__ 1.18973149535723176502126385303097021e+4932F64x"
	.byte	0x1
	.uleb128 0
	.string	"__FLT64X_MIN__ 3.36210314311209350626267781732175260e-4932F64x"
	.byte	0x1
	.uleb128 0
	.string	"__FLT64X_EPSILON__ 1.08420217248550443400745280086994171e-19F64x"
	.byte	0x1
	.uleb128 0
	.string	"__FLT64X_DENORM_MIN__ 3.64519953188247460252840593361941982e-4951F64x"
	.byte	0x1
	.uleb128 0
	.string	"__FLT64X_HAS_DENORM__ 1"
	.byte	0x1
	.uleb128 0
	.string	"__FLT64X_HAS_INFINITY__ 1"
	.byte	0x1
	.uleb128 0
	.string	"__FLT64X_HAS_QUIET_NAN__ 1"
	.byte	0x1
	.uleb128 0
	.string	"__FLT64X_IS_IEC_60559__ 1"
	.byte	0x1
	.uleb128 0
	.string	"__BFLT16_MANT_DIG__ 8"
	.byte	0x1
	.uleb128 0
	.string	"__BFLT16_DIG__ 2"
	.byte	0x1
	.uleb128 0
	.string	"__BFLT16_MIN_EXP__ (-125)"
	.byte	0x1
	.uleb128 0
	.string	"__BFLT16_MIN_10_EXP__ (-37)"
	.byte	0x1
	.uleb128 0
	.string	"__BFLT16_MAX_EXP__ 128"
	.byte	0x1
	.uleb128 0
	.string	"__BFLT16_MAX_10_EXP__ 38"
	.byte	0x1
	.uleb128 0
	.string	"__BFLT16_DECIMAL_DIG__ 4"
	.byte	0x1
	.uleb128 0
	.string	"__BFLT16_MAX__ 3.38953138925153547590470800371487867e+38BF16"
	.byte	0x1
	.uleb128 0
	.string	"__BFLT16_NORM_MAX__ 3.38953138925153547590470800371487867e+38BF16"
	.byte	0x1
	.uleb128 0
	.string	"__BFLT16_MIN__ 1.17549435082228750796873653722224568e-38BF16"
	.byte	0x1
	.uleb128 0
	.string	"__BFLT16_EPSILON__ 7.81250000000000000000000000000000000e-3BF16"
	.byte	0x1
	.uleb128 0
	.string	"__BFLT16_DENORM_MIN__ 9.18354961579912115600575419704879436e-41BF16"
	.byte	0x1
	.uleb128 0
	.string	"__BFLT16_HAS_DENORM__ 1"
	.byte	0x1
	.uleb128 0
	.string	"__BFLT16_HAS_INFINITY__ 1"
	.byte	0x1
	.uleb128 0
	.string	"__BFLT16_HAS_QUIET_NAN__ 1"
	.byte	0x1
	.uleb128 0
	.string	"__BFLT16_IS_IEC_60559__ 0"
	.byte	0x1
	.uleb128 0
	.string	"__DEC32_MANT_DIG__ 7"
	.byte	0x1
	.uleb128 0
	.string	"__DEC32_MIN_EXP__ (-94)"
	.byte	0x1
	.uleb128 0
	.string	"__DEC32_MAX_EXP__ 97"
	.byte	0x1
	.uleb128 0
	.string	"__DEC32_MIN__ 1E-95DF"
	.byte	0x1
	.uleb128 0
	.string	"__DEC32_MAX__ 9.999999E96DF"
	.byte	0x1
	.uleb128 0
	.string	"__DEC32_EPSILON__ 1E-6DF"
	.byte	0x1
	.uleb128 0
	.string	"__DEC32_SUBNORMAL_MIN__ 0.000001E-95DF"
	.byte	0x1
	.uleb128 0
	.string	"__DEC64_MANT_DIG__ 16"
	.byte	0x1
	.uleb128 0
	.string	"__DEC64_MIN_EXP__ (-382)"
	.byte	0x1
	.uleb128 0
	.string	"__DEC64_MAX_EXP__ 385"
	.byte	0x1
	.uleb128 0
	.string	"__DEC64_MIN__ 1E-383DD"
	.byte	0x1
	.uleb128 0
	.string	"__DEC64_MAX__ 9.999999999999999E384DD"
	.byte	0x1
	.uleb128 0
	.string	"__DEC64_EPSILON__ 1E-15DD"
	.byte	0x1
	.uleb128 0
	.string	"__DEC64_SUBNORMAL_MIN__ 0.000000000000001E-383DD"
	.byte	0x1
	.uleb128 0
	.string	"__DEC128_MANT_DIG__ 34"
	.byte	0x1
	.uleb128 0
	.string	"__DEC128_MIN_EXP__ (-6142)"
	.byte	0x1
	.uleb128 0
	.string	"__DEC128_MAX_EXP__ 6145"
	.byte	0x1
	.uleb128 0
	.string	"__DEC128_MIN__ 1E-6143DL"
	.byte	0x1
	.uleb128 0
	.string	"__DEC128_MAX__ 9.999999999999999999999999999999999E6144DL"
	.byte	0x1
	.uleb128 0
	.string	"__DEC128_EPSILON__ 1E-33DL"
	.byte	0x1
	.uleb128 0
	.string	"__DEC128_SUBNORMAL_MIN__ 0.000000000000000000000000000000001E-6143DL"
	.byte	0x1
	.uleb128 0
	.string	"__DEC64X_MANT_DIG__ 34"
	.byte	0x1
	.uleb128 0
	.string	"__DEC64X_MIN_EXP__ (-6142)"
	.byte	0x1
	.uleb128 0
	.string	"__DEC64X_MAX_EXP__ 6145"
	.byte	0x1
	.uleb128 0
	.string	"__DEC64X_MIN__ 1E-6143D64x"
	.byte	0x1
	.uleb128 0
	.string	"__DEC64X_MAX__ 9.999999999999999999999999999999999E6144D64x"
	.byte	0x1
	.uleb128 0
	.string	"__DEC64X_EPSILON__ 1E-33D64x"
	.byte	0x1
	.uleb128 0
	.string	"__DEC64X_SUBNORMAL_MIN__ 0.000000000000000000000000000000001E-6143D64x"
	.byte	0x1
	.uleb128 0
	.string	"__REGISTER_PREFIX__ "
	.byte	0x1
	.uleb128 0
	.string	"__USER_LABEL_PREFIX__ "
	.byte	0x1
	.uleb128 0
	.string	"__GNUC_STDC_INLINE__ 1"
	.byte	0x1
	.uleb128 0
	.string	"__NO_INLINE__ 1"
	.byte	0x1
	.uleb128 0
	.string	"__GCC_HAVE_SYNC_COMPARE_AND_SWAP_1 1"
	.byte	0x1
	.uleb128 0
	.string	"__GCC_HAVE_SYNC_COMPARE_AND_SWAP_2 1"
	.byte	0x1
	.uleb128 0
	.string	"__GCC_HAVE_SYNC_COMPARE_AND_SWAP_4 1"
	.byte	0x1
	.uleb128 0
	.string	"__GCC_HAVE_SYNC_COMPARE_AND_SWAP_8 1"
	.byte	0x1
	.uleb128 0
	.string	"__GCC_ATOMIC_BOOL_LOCK_FREE 2"
	.byte	0x1
	.uleb128 0
	.string	"__GCC_ATOMIC_CHAR_LOCK_FREE 2"
	.byte	0x1
	.uleb128 0
	.string	"__GCC_ATOMIC_CHAR8_T_LOCK_FREE 2"
	.byte	0x1
	.uleb128 0
	.string	"__GCC_ATOMIC_CHAR16_T_LOCK_FREE 2"
	.byte	0x1
	.uleb128 0
	.string	"__GCC_ATOMIC_CHAR32_T_LOCK_FREE 2"
	.byte	0x1
	.uleb128 0
	.string	"__GCC_ATOMIC_WCHAR_T_LOCK_FREE 2"
	.byte	0x1
	.uleb128 0
	.string	"__GCC_ATOMIC_SHORT_LOCK_FREE 2"
	.byte	0x1
	.uleb128 0
	.string	"__GCC_ATOMIC_INT_LOCK_FREE 2"
	.byte	0x1
	.uleb128 0
	.string	"__GCC_ATOMIC_LONG_LOCK_FREE 2"
	.byte	0x1
	.uleb128 0
	.string	"__GCC_ATOMIC_LLONG_LOCK_FREE 2"
	.byte	0x1
	.uleb128 0
	.string	"__GCC_ATOMIC_TEST_AND_SET_TRUEVAL 1"
	.byte	0x1
	.uleb128 0
	.string	"__GCC_DESTRUCTIVE_SIZE 64"
	.byte	0x1
	.uleb128 0
	.string	"__GCC_CONSTRUCTIVE_SIZE 64"
	.byte	0x1
	.uleb128 0
	.string	"__GCC_ATOMIC_POINTER_LOCK_FREE 2"
	.byte	0x1
	.uleb128 0
	.string	"__HAVE_SPECULATION_SAFE_VALUE 1"
	.byte	0x1
	.uleb128 0
	.string	"__GCC_HAVE_DWARF2_CFI_ASM 1"
	.byte	0x1
	.uleb128 0
	.string	"__PRAGMA_REDEFINE_EXTNAME 1"
	.byte	0x1
	.uleb128 0
	.string	"__SSP_STRONG__ 3"
	.byte	0x1
	.uleb128 0
	.string	"__SIZEOF_INT128__ 16"
	.byte	0x1
	.uleb128 0
	.string	"__SIZEOF_WCHAR_T__ 4"
	.byte	0x1
	.uleb128 0
	.string	"__SIZEOF_WINT_T__ 4"
	.byte	0x1
	.uleb128 0
	.string	"__SIZEOF_PTRDIFF_T__ 8"
	.byte	0x1
	.uleb128 0
	.string	"__amd64 1"
	.byte	0x1
	.uleb128 0
	.string	"__amd64__ 1"
	.byte	0x1
	.uleb128 0
	.string	"__x86_64 1"
	.byte	0x1
	.uleb128 0
	.string	"__x86_64__ 1"
	.byte	0x1
	.uleb128 0
	.string	"__SIZEOF_FLOAT80__ 16"
	.byte	0x1
	.uleb128 0
	.string	"__SIZEOF_FLOAT128__ 16"
	.byte	0x1
	.uleb128 0
	.string	"__ATOMIC_HLE_ACQUIRE 65536"
	.byte	0x1
	.uleb128 0
	.string	"__ATOMIC_HLE_RELEASE 131072"
	.byte	0x1
	.uleb128 0
	.string	"__GCC_ASM_FLAG_OUTPUTS__ 1"
	.byte	0x1
	.uleb128 0
	.string	"__k8 1"
	.byte	0x1
	.uleb128 0
	.string	"__k8__ 1"
	.byte	0x1
	.uleb128 0
	.string	"__code_model_small__ 1"
	.byte	0x1
	.uleb128 0
	.string	"__MMX__ 1"
	.byte	0x1
	.uleb128 0
	.string	"__SSE__ 1"
	.byte	0x1
	.uleb128 0
	.string	"__SSE2__ 1"
	.byte	0x1
	.uleb128 0
	.string	"__FXSR__ 1"
	.byte	0x1
	.uleb128 0
	.string	"__SSE_MATH__ 1"
	.byte	0x1
	.uleb128 0
	.string	"__SSE2_MATH__ 1"
	.byte	0x1
	.uleb128 0
	.string	"__MMX_WITH_SSE__ 1"
	.byte	0x1
	.uleb128 0
	.string	"__SEG_FS 1"
	.byte	0x1
	.uleb128 0
	.string	"__SEG_GS 1"
	.byte	0x1
	.uleb128 0
	.string	"__CET__ 3"
	.byte	0x1
	.uleb128 0
	.string	"__gnu_linux__ 1"
	.byte	0x1
	.uleb128 0
	.string	"__linux 1"
	.byte	0x1
	.uleb128 0
	.string	"__linux__ 1"
	.byte	0x1
	.uleb128 0
	.string	"linux 1"
	.byte	0x1
	.uleb128 0
	.string	"__unix 1"
	.byte	0x1
	.uleb128 0
	.string	"__unix__ 1"
	.byte	0x1
	.uleb128 0
	.string	"unix 1"
	.byte	0x1
	.uleb128 0
	.string	"__ELF__ 1"
	.byte	0x1
	.uleb128 0
	.string	"__DECIMAL_BID_FORMAT__ 1"
	.byte	0x3
	.uleb128 0
	.uleb128 0x1
	.file 2 "/usr/include/stdc-predef.h"
	.byte	0x3
	.uleb128 0
	.uleb128 0x2
	.byte	0x1
	.uleb128 0x13
	.string	"_STDC_PREDEF_H 1"
	.byte	0x1
	.uleb128 0x26
	.string	"__STDC_IEC_559__ 1"
	.byte	0x1
	.uleb128 0x27
	.string	"__STDC_IEC_60559_BFP__ 201404L"
	.byte	0x1
	.uleb128 0x30
	.string	"__STDC_IEC_559_COMPLEX__ 1"
	.byte	0x1
	.uleb128 0x31
	.string	"__STDC_IEC_60559_COMPLEX__ 201404L"
	.byte	0x1
	.uleb128 0x3e
	.string	"__STDC_ISO_10646__ 201706L"
	.byte	0x4
	.byte	0x1
	.uleb128 0x1
	.string	"FOO 1"
	.byte	0x4
	.byte	0
	.section	.debug_line,"",@progbits
.Ldebug_line0:
	.section	.debug_str,"MS",@progbits,1
.LASF0:
	.string	"GNU C23 15.2.0 -mtune=generic -march=x86-64 -g3 -gdwarf-4 -gstrict-dwarf -O0 -fasynchronous-unwind-tables -fstack-protector-strong -fstack-clash-protection -fcf-protection -fzero-init-padding-bits=all"
.LASF1:
	.string	"/home/davea/dwarf/regressiontests/macinfoIssue340"
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
