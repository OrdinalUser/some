	.file	"some.c"
	.text
	.p2align 4
	.globl	copy_path_string
	.type	copy_path_string, @function
copy_path_string:
.LFB24:
	.cfi_startproc
	movzbl	(%rsi), %ecx
	testb	$-33, %cl
	je	.L4
	movl	$1, %edx
	.p2align 4,,10
	.p2align 3
.L3:
	movb	%cl, (%rdi)
	movzbl	(%rsi,%rdx), %ecx
	addq	$1, %rdi
	movq	%rdx, %rax
	addq	$1, %rdx
	testb	$-33, %cl
	jne	.L3
	movb	$0, (%rdi)
	ret
	.p2align 4,,10
	.p2align 3
.L4:
	movb	$0, (%rdi)
	xorl	%eax, %eax
	ret
	.cfi_endproc
.LFE24:
	.size	copy_path_string, .-copy_path_string
	.p2align 4
	.globl	std_strlen
	.type	std_strlen, @function
std_strlen:
.LFB25:
	.cfi_startproc
	cmpb	$0, (%rdi)
	je	.L9
	leaq	1(%rdi), %rax
	subq	$8, %rsp
	.cfi_def_cfa_offset 16
	movq	%rax, %rdi
	call	strlen@PLT
	addq	$8, %rsp
	.cfi_def_cfa_offset 8
	addq	$1, %rax
	ret
	.p2align 4,,10
	.p2align 3
.L9:
	xorl	%eax, %eax
	ret
	.cfi_endproc
.LFE25:
	.size	std_strlen, .-std_strlen
	.p2align 4
	.globl	std_strlen_c
	.type	std_strlen_c, @function
std_strlen_c:
.LFB26:
	.cfi_startproc
	movzbl	(%rdi), %eax
	movl	%esi, %ecx
	testb	%al, %al
	je	.L18
	cmpb	%sil, %al
	je	.L18
	xorl	%eax, %eax
	jmp	.L16
	.p2align 4,,10
	.p2align 3
.L30:
	cmpb	%cl, %dl
	je	.L29
.L16:
	addq	$1, %rax
	movzbl	(%rdi,%rax), %edx
	testb	%dl, %dl
	jne	.L30
	ret
	.p2align 4,,10
	.p2align 3
.L29:
	ret
	.p2align 4,,10
	.p2align 3
.L18:
	xorl	%eax, %eax
	ret
	.cfi_endproc
.LFE26:
	.size	std_strlen_c, .-std_strlen_c
	.p2align 4
	.globl	std_strcpy
	.type	std_strcpy, @function
std_strcpy:
.LFB27:
	.cfi_startproc
	jmp	.L38
	.p2align 4,,10
	.p2align 3
.L33:
	movb	%al, (%rdi)
	addq	$1, %rdi
	addq	$1, %rsi
.L38:
	movzbl	(%rsi), %eax
	testb	%al, %al
	jne	.L33
	movb	$0, (%rdi)
	ret
	.cfi_endproc
.LFE27:
	.size	std_strcpy, .-std_strcpy
	.p2align 4
	.globl	std_strncpy
	.type	std_strncpy, @function
std_strncpy:
.LFB28:
	.cfi_startproc
	leaq	(%rdi,%rdx), %rcx
	testq	%rdx, %rdx
	jne	.L40
	jmp	.L41
	.p2align 4,,10
	.p2align 3
.L42:
	addq	$1, %rdi
	addq	$1, %rsi
	movb	%al, -1(%rdi)
	cmpq	%rcx, %rdi
	je	.L41
.L40:
	movzbl	(%rsi), %eax
	testb	%al, %al
	jne	.L42
.L41:
	movb	$0, (%rdi)
	ret
	.cfi_endproc
.LFE28:
	.size	std_strncpy, .-std_strncpy
	.p2align 4
	.globl	puts_ln
	.type	puts_ln, @function
puts_ln:
.LFB29:
	.cfi_startproc
	pushq	%r15
	.cfi_def_cfa_offset 16
	.cfi_offset 15, -16
	pushq	%r14
	.cfi_def_cfa_offset 24
	.cfi_offset 14, -24
	pushq	%r13
	.cfi_def_cfa_offset 32
	.cfi_offset 13, -32
	pushq	%r12
	.cfi_def_cfa_offset 40
	.cfi_offset 12, -40
	movq	%rsi, %r12
	pushq	%rbp
	.cfi_def_cfa_offset 48
	.cfi_offset 6, -48
	pushq	%rbx
	.cfi_def_cfa_offset 56
	.cfi_offset 3, -56
	subq	$8, %rsp
	.cfi_def_cfa_offset 64
	movzbl	(%rdi), %ebx
	cmpb	$10, %bl
	je	.L51
	testb	%bl, %bl
	je	.L51
	movq	%rdi, %r14
	xorl	%r13d, %r13d
	xorl	%ebp, %ebp
	call	__ctype_b_loc@PLT
	movq	stdout(%rip), %rsi
	movq	%rax, %r15
	jmp	.L49
	.p2align 4,,10
	.p2align 3
.L47:
	cmpb	$9, %bl
	je	.L64
.L48:
	movzbl	1(%r14,%r13), %ebx
	leaq	1(%r13), %rax
	cmpb	$10, %bl
	je	.L53
.L65:
	testb	%bl, %bl
	je	.L53
	movq	%rax, %r13
.L49:
	movq	(%r15), %rdx
	movsbq	%bl, %rax
	testb	$64, 1(%rdx,%rax,2)
	je	.L47
	movsbl	%bl, %edi
	addq	$1, %rbp
	call	putc@PLT
	movzbl	1(%r14,%r13), %ebx
	movq	stdout(%rip), %rsi
	leaq	1(%r13), %rax
	cmpb	$10, %bl
	jne	.L65
	.p2align 4,,10
	.p2align 3
.L53:
	addq	$2, %r13
.L46:
	movq	%r13, (%r12)
	movl	$10, %edi
	call	putc@PLT
	addq	$8, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 56
	movq	%rbp, %rax
	popq	%rbx
	.cfi_def_cfa_offset 48
	popq	%rbp
	.cfi_def_cfa_offset 40
	popq	%r12
	.cfi_def_cfa_offset 32
	popq	%r13
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%r15
	.cfi_def_cfa_offset 8
	ret
	.p2align 4,,10
	.p2align 3
.L64:
	.cfi_restore_state
	movl	$32, %edi
	addq	$1, %rbp
	call	putc@PLT
	movq	stdout(%rip), %rsi
	jmp	.L48
	.p2align 4,,10
	.p2align 3
.L51:
	movq	stdout(%rip), %rsi
	movl	$1, %r13d
	xorl	%ebp, %ebp
	jmp	.L46
	.cfi_endproc
.LFE29:
	.size	puts_ln, .-puts_ln
	.p2align 4
	.globl	std_utoa
	.type	std_utoa, @function
std_utoa:
.LFB30:
	.cfi_startproc
	movq	%rdi, %rdx
	testl	%esi, %esi
	jne	.L71
	movl	$48, %eax
	movl	$1, %r10d
	movw	%ax, (%rdi)
.L66:
	movq	%r10, %rax
	ret
	.p2align 4,,10
	.p2align 3
.L71:
	movq	%rdi, %r9
	xorl	%r10d, %r10d
	movl	$3435973837, %r11d
	.p2align 4,,10
	.p2align 3
.L67:
	movl	%esi, %ecx
	movl	%esi, %edi
	movq	%r9, %rax
	addq	$1, %r10
	imulq	%r11, %rcx
	leaq	1(%r9), %r9
	shrq	$35, %rcx
	leal	(%rcx,%rcx,4), %r8d
	addl	%r8d, %r8d
	subl	%r8d, %edi
	addl	$48, %edi
	movb	%dil, -1(%r9)
	movl	%esi, %edi
	movl	%ecx, %esi
	cmpl	$9, %edi
	ja	.L67
	movb	$0, (%r9)
	cmpq	%rax, %rdx
	jnb	.L66
	.p2align 4,,10
	.p2align 3
.L69:
	movzbl	(%rdx), %ecx
	movzbl	(%rax), %esi
	addq	$1, %rdx
	subq	$1, %rax
	movb	%sil, -1(%rdx)
	movb	%cl, 1(%rax)
	cmpq	%rax, %rdx
	jb	.L69
	movq	%r10, %rax
	ret
	.cfi_endproc
.LFE30:
	.size	std_utoa, .-std_utoa
	.p2align 4
	.globl	digitcount
	.type	digitcount, @function
digitcount:
.LFB31:
	.cfi_startproc
	movq	%rdi, %rdx
	xorl	%esi, %esi
	movabsq	$-3689348814741910323, %rdi
	.p2align 4,,10
	.p2align 3
.L76:
	movq	%rdx, %rax
	movq	%rdx, %rcx
	addl	$1, %esi
	mulq	%rdi
	shrq	$3, %rdx
	cmpq	$9, %rcx
	ja	.L76
	movl	%esi, %eax
	ret
	.cfi_endproc
.LFE31:
	.size	digitcount, .-digitcount
	.p2align 4
	.globl	truncate_filepath
	.type	truncate_filepath, @function
truncate_filepath:
.LFB32:
	.cfi_startproc
	movzwl	%cx, %eax
	movzwl	%dx, %r9d
	movq	%rsi, %r8
	movzbl	(%rdi), %esi
	subl	$3, %eax
	cmpl	%eax, %r9d
	jl	.L136
	subl	%ecx, %edx
	pushq	%rbx
	.cfi_def_cfa_offset 16
	.cfi_offset 3, -16
	leal	3(%rdx), %r9d
	cmpb	$47, %sil
	je	.L138
	movq	%r8, %rdx
	movq	%rdi, %rax
	xorl	%r11d, %r11d
	xorl	%r10d, %r10d
.L83:
	testb	%sil, %sil
	je	.L98
	cmpb	$47, %sil
	je	.L98
	xorl	%ecx, %ecx
	jmp	.L85
	.p2align 4,,10
	.p2align 3
.L139:
	testb	%sil, %sil
	je	.L101
.L85:
	addq	$1, %rcx
	movzbl	(%rax,%rcx), %esi
	cmpb	$47, %sil
	jne	.L139
.L101:
	addl	$1, %ecx
	movzwl	%cx, %esi
	testq	%rsi, %rsi
	je	.L140
.L84:
	leaq	(%rax,%rsi), %r11
	jmp	.L88
	.p2align 4,,10
	.p2align 3
.L89:
	addq	$1, %rax
	addq	$1, %rdx
	movb	%sil, -1(%rdx)
	cmpq	%r11, %rax
	je	.L137
.L88:
	movzbl	(%rax), %esi
	testb	%sil, %sil
	jne	.L89
.L137:
	addl	%ecx, %r10d
	movzwl	%r10w, %r11d
	leaq	(%r8,%r11), %rbx
	leaq	(%rdi,%r11), %rax
.L87:
	movb	$0, (%rdx)
	testw	%r9w, %r9w
	jle	.L90
	movl	%r10d, %esi
	.p2align 4,,10
	.p2align 3
.L94:
	movzwl	%si, %ecx
	addq	%rdi, %rcx
	movzbl	(%rcx), %eax
	testb	%al, %al
	je	.L100
	cmpb	$47, %al
	je	.L100
	xorl	%eax, %eax
	jmp	.L92
	.p2align 4,,10
	.p2align 3
.L141:
	testb	%dl, %dl
	je	.L102
.L92:
	addq	$1, %rax
	movzbl	(%rcx,%rax), %edx
	cmpb	$47, %dl
	jne	.L141
.L102:
	addl	$1, %eax
.L91:
	subl	%eax, %r9d
	addl	%eax, %esi
	testw	%r9w, %r9w
	jg	.L94
	movzwl	%si, %eax
	addq	%rdi, %rax
.L90:
	movzwl	.LC0(%rip), %edx
	movb	$46, (%rbx)
	movw	%dx, 1(%r8,%r11)
	leal	3(%r10), %edx
	movzbl	(%rax), %ecx
	movzwl	%dx, %edx
	addq	%r8, %rdx
	testb	%cl, %cl
	je	.L95
	.p2align 4,,10
	.p2align 3
.L96:
	addq	$1, %rax
	movb	%cl, (%rdx)
	addq	$1, %rdx
	movzbl	(%rax), %ecx
	testb	%cl, %cl
	jne	.L96
.L95:
	movb	$0, (%rdx)
	popq	%rbx
	.cfi_def_cfa_offset 8
	ret
	.p2align 4,,10
	.p2align 3
.L81:
	.cfi_restore 3
	addq	$1, %rdi
	movb	%sil, (%r8)
	addq	$1, %r8
	movzbl	(%rdi), %esi
.L136:
	testb	%sil, %sil
	jne	.L81
	movb	$0, (%r8)
	ret
.L138:
	.cfi_def_cfa_offset 16
	.cfi_offset 3, -16
	movb	$47, (%r8)
	leaq	1(%rdi), %rax
	movzbl	1(%rdi), %esi
	leaq	1(%r8), %rdx
	movl	$1, %r11d
	movl	$1, %r10d
	jmp	.L83
	.p2align 4,,10
	.p2align 3
.L100:
	movl	$1, %eax
	jmp	.L91
.L98:
	movl	$1, %esi
	movl	$1, %ecx
	jmp	.L84
.L140:
	movq	%rdx, %rbx
	jmp	.L87
	.cfi_endproc
.LFE32:
	.size	truncate_filepath, .-truncate_filepath
	.p2align 4
	.globl	some_read_terminal_size
	.type	some_read_terminal_size, @function
some_read_terminal_size:
.LFB33:
	.cfi_startproc
	subq	$24, %rsp
	.cfi_def_cfa_offset 32
	movl	$21523, %esi
	movl	$1, %edi
	xorl	%eax, %eax
	leaq	8(%rsp), %rdx
	call	ioctl@PLT
	movzwl	10(%rsp), %eax
	movw	%ax, g_terminal_width(%rip)
	movzwl	8(%rsp), %eax
	movw	%ax, g_terminal_height(%rip)
	addq	$24, %rsp
	.cfi_def_cfa_offset 8
	ret
	.cfi_endproc
.LFE33:
	.size	some_read_terminal_size, .-some_read_terminal_size
	.p2align 4
	.globl	some_init
	.type	some_init, @function
some_init:
.LFB34:
	.cfi_startproc
	pushq	%rbx
	.cfi_def_cfa_offset 16
	.cfi_offset 3, -16
	movl	$21523, %esi
	movl	%edi, %ebx
	xorl	%eax, %eax
	movl	$1, %edi
	subq	$16, %rsp
	.cfi_def_cfa_offset 32
	leaq	8(%rsp), %rdx
	call	ioctl@PLT
	movzwl	8(%rsp), %eax
	movzwl	10(%rsp), %edx
	movw	%ax, g_terminal_height(%rip)
	subw	g_reserved_rows(%rip), %ax
	movw	%dx, g_terminal_width(%rip)
	movw	%ax, g_display_rows(%rip)
	testb	%bl, %bl
	je	.L146
	imull	%edx, %eax
	movzwl	%ax, %edi
.L145:
	movw	%ax, g_page_buffer_size(%rip)
	call	malloc@PLT
	movq	%rax, g_page_buffer(%rip)
	addq	$16, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 16
	popq	%rbx
	.cfi_def_cfa_offset 8
	ret
	.p2align 4,,10
	.p2align 3
.L146:
	.cfi_restore_state
	movl	$65535, %edi
	movl	$-1, %eax
	jmp	.L145
	.cfi_endproc
.LFE34:
	.size	some_init, .-some_init
	.p2align 4
	.globl	some_exit
	.type	some_exit, @function
some_exit:
.LFB35:
	.cfi_startproc
	movq	g_page_entries(%rip), %rdi
	testq	%rdi, %rdi
	je	.L154
	subq	$8, %rsp
	.cfi_def_cfa_offset 16
	call	free@PLT
	movq	g_page_buffer(%rip), %rdi
	addq	$8, %rsp
	.cfi_def_cfa_offset 8
	jmp	free@PLT
	.p2align 4,,10
	.p2align 3
.L154:
	movq	g_page_buffer(%rip), %rdi
	jmp	free@PLT
	.cfi_endproc
.LFE35:
	.size	some_exit, .-some_exit
	.section	.rodata.str1.8,"aMS",@progbits,1
	.align 8
.LC1:
	.string	"Usage: some <options> <filepath>\n"
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC2:
	.string	"\t ex.: some -p ../cities.csv\n"
	.section	.rodata.str1.8
	.align 8
.LC3:
	.string	"-h : prints this information\n-p : uses page system to view file\n"
	.text
	.p2align 4
	.globl	some_print_help
	.type	some_print_help, @function
some_print_help:
.LFB36:
	.cfi_startproc
	subq	$8, %rsp
	.cfi_def_cfa_offset 16
	movq	stderr(%rip), %rcx
	movl	$33, %edx
	movl	$1, %esi
	leaq	.LC1(%rip), %rdi
	call	fwrite@PLT
	movl	$29, %edx
	movq	stderr(%rip), %rcx
	movl	$1, %esi
	leaq	.LC2(%rip), %rdi
	call	fwrite@PLT
	movl	$64, %edx
	movq	stderr(%rip), %rcx
	addq	$8, %rsp
	.cfi_def_cfa_offset 8
	movl	$1, %esi
	leaq	.LC3(%rip), %rdi
	jmp	fwrite@PLT
	.cfi_endproc
.LFE36:
	.size	some_print_help, .-some_print_help
	.p2align 4
	.globl	some_parse_arg_string
	.type	some_parse_arg_string, @function
some_parse_arg_string:
.LFB37:
	.cfi_startproc
	testl	%esi, %esi
	je	.L171
	leal	-1(%rsi), %eax
	pushq	%r13
	.cfi_def_cfa_offset 16
	.cfi_offset 13, -16
	movq	%rdx, %r13
	pushq	%r12
	.cfi_def_cfa_offset 24
	.cfi_offset 12, -24
	movslq	%eax, %rdx
	movl	%eax, %eax
	movq	%rcx, %r12
	pushq	%rbp
	.cfi_def_cfa_offset 32
	.cfi_offset 6, -32
	salq	$3, %rdx
	salq	$3, %rax
	pushq	%rbx
	.cfi_def_cfa_offset 40
	.cfi_offset 3, -40
	leaq	-8(%rdi,%rdx), %rbp
	leaq	(%rdi,%rdx), %rbx
	subq	%rax, %rbp
	leaq	g_filepath(%rip), %rdx
	subq	$8, %rsp
	.cfi_def_cfa_offset 48
	jmp	.L165
	.p2align 4,,10
	.p2align 3
.L175:
	movzbl	1(%rsi), %eax
	cmpb	$104, %al
	je	.L174
	cmpb	$112, %al
	jne	.L164
	movb	$1, (%r12)
.L164:
	subq	$8, %rbx
	cmpq	%rbp, %rbx
	je	.L159
.L165:
	movq	(%rbx), %rsi
	cmpb	$45, (%rsi)
	je	.L175
	movq	%rdx, %rdi
	subq	$8, %rbx
	call	strcpy@PLT
	movq	%rax, %rdx
	cmpq	%rbp, %rbx
	jne	.L165
.L159:
	addq	$8, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 40
	popq	%rbx
	.cfi_def_cfa_offset 32
	popq	%rbp
	.cfi_def_cfa_offset 24
	popq	%r12
	.cfi_def_cfa_offset 16
	popq	%r13
	.cfi_def_cfa_offset 8
	ret
	.p2align 4,,10
	.p2align 3
.L174:
	.cfi_restore_state
	movb	$1, 0(%r13)
	addq	$8, %rsp
	.cfi_def_cfa_offset 40
	popq	%rbx
	.cfi_def_cfa_offset 32
	popq	%rbp
	.cfi_def_cfa_offset 24
	popq	%r12
	.cfi_def_cfa_offset 16
	popq	%r13
	.cfi_def_cfa_offset 8
	ret
.L171:
	.cfi_restore 3
	.cfi_restore 6
	.cfi_restore 12
	.cfi_restore 13
	ret
	.cfi_endproc
.LFE37:
	.size	some_parse_arg_string, .-some_parse_arg_string
	.section	.rodata.str1.1
.LC4:
	.string	"rb"
	.text
	.p2align 4
	.globl	some_simple
	.type	some_simple, @function
some_simple:
.LFB38:
	.cfi_startproc
	pushq	%r15
	.cfi_def_cfa_offset 16
	.cfi_offset 15, -16
	leaq	.LC4(%rip), %rsi
	leaq	g_filepath(%rip), %rdi
	pushq	%r14
	.cfi_def_cfa_offset 24
	.cfi_offset 14, -24
	pushq	%r13
	.cfi_def_cfa_offset 32
	.cfi_offset 13, -32
	pushq	%r12
	.cfi_def_cfa_offset 40
	.cfi_offset 12, -40
	movl	$2, %r12d
	pushq	%rbp
	.cfi_def_cfa_offset 48
	.cfi_offset 6, -48
	pushq	%rbx
	.cfi_def_cfa_offset 56
	.cfi_offset 3, -56
	movl	$3, %ebx
	subq	$24, %rsp
	.cfi_def_cfa_offset 80
	call	fopen@PLT
	movl	$65535, %edi
	movq	%rax, 8(%rsp)
	call	malloc@PLT
	movq	g_page_buffer(%rip), %rdi
	movq	%rax, %r14
	movzwl	.LC5(%rip), %eax
	movb	$32, 2(%r14)
	movw	%ax, (%r14)
	.p2align 4,,10
	.p2align 3
.L177:
	movzwl	g_page_buffer_size(%rip), %edx
	movq	8(%rsp), %rcx
	movl	$1, %esi
	call	fread@PLT
	movq	%rax, %rbp
	testq	%rax, %rax
	je	.L189
	movq	g_page_buffer(%rip), %rdi
	xorl	%r15d, %r15d
	jmp	.L183
	.p2align 4,,10
	.p2align 3
.L178:
	movl	%edx, %ebx
	cmpb	$10, %al
	je	.L190
.L180:
	addq	$1, %r15
	cmpq	%r15, %rbp
	je	.L177
.L183:
	movzbl	(%rdi,%r15), %eax
	leal	1(%rbx), %edx
	movslq	%ebx, %rbx
	movb	%al, (%r14,%rbx)
	cmpl	$65534, %edx
	jle	.L178
	movq	%r14, %rdi
	movl	$65535, %edx
	movl	$1, %esi
	xorl	%ebx, %ebx
	movq	stdout(%rip), %rcx
	call	fwrite@PLT
	movq	g_page_buffer(%rip), %rdi
	cmpb	$10, (%rdi,%r15)
	jne	.L180
.L179:
	movq	%r14, %rdi
	xorl	%ebx, %ebx
.L182:
	movl	%r12d, %esi
	leal	1(%r12), %r13d
	call	std_utoa
	movzwl	.LC6(%rip), %ecx
	movl	%r13d, %r12d
	movq	g_page_buffer(%rip), %rdi
	addl	%ebx, %eax
	leal	2(%rax), %ebx
	cltq
	movw	%cx, (%r14,%rax)
	jmp	.L180
	.p2align 4,,10
	.p2align 3
.L190:
	movslq	%edx, %rdx
	leaq	(%r14,%rdx), %rdi
	cmpl	$65522, %ebx
	jle	.L182
	movq	stdout(%rip), %rcx
	movl	$1, %esi
	movq	%r14, %rdi
	call	fwrite@PLT
	jmp	.L179
	.p2align 4,,10
	.p2align 3
.L189:
	testl	%ebx, %ebx
	jle	.L185
	movq	stdout(%rip), %rcx
	movslq	%ebx, %rdx
	movl	$1, %esi
	movq	%r14, %rdi
	call	fwrite@PLT
.L185:
	movq	%r14, %rdi
	call	free@PLT
	movq	8(%rsp), %rdi
	addq	$24, %rsp
	.cfi_def_cfa_offset 56
	popq	%rbx
	.cfi_def_cfa_offset 48
	popq	%rbp
	.cfi_def_cfa_offset 40
	popq	%r12
	.cfi_def_cfa_offset 32
	popq	%r13
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%r15
	.cfi_def_cfa_offset 8
	jmp	fclose@PLT
	.cfi_endproc
.LFE38:
	.size	some_simple, .-some_simple
	.section	.rodata.str1.8
	.align 8
.LC7:
	.string	"Commit page: size %u, offset %llu, line number: %u\n"
	.section	.rodata.str1.1
.LC8:
	.string	"Total bytes paged: %llu\n"
	.text
	.p2align 4
	.globl	some_precompute_pages
	.type	some_precompute_pages, @function
some_precompute_pages:
.LFB39:
	.cfi_startproc
	pushq	%r15
	.cfi_def_cfa_offset 16
	.cfi_offset 15, -16
	pushq	%r14
	.cfi_def_cfa_offset 24
	.cfi_offset 14, -24
	movabsq	$-3689348814741910323, %r14
	pushq	%r13
	.cfi_def_cfa_offset 32
	.cfi_offset 13, -32
	xorl	%r13d, %r13d
	pushq	%r12
	.cfi_def_cfa_offset 40
	.cfi_offset 12, -40
	pushq	%rbp
	.cfi_def_cfa_offset 48
	.cfi_offset 6, -48
	movl	$1, %ebp
	pushq	%rbx
	.cfi_def_cfa_offset 56
	.cfi_offset 3, -56
	subq	$40, %rsp
	.cfi_def_cfa_offset 96
	movq	$10, g_page_entries_capacity(%rip)
	movq	%rdi, (%rsp)
	movl	$160, %edi
	call	malloc@PLT
	movzwl	g_page_buffer_size(%rip), %ebx
	xorl	%ecx, %ecx
	xorl	%esi, %esi
	movl	$1, %edx
	xorl	%edi, %edi
	xorl	%r8d, %r8d
	movw	%cx, 8(%rsp)
	movw	%dx, 16(%rsp)
	movw	%si, 10(%rsp)
	movw	%di, 12(%rsp)
	movw	%r8w, 18(%rsp)
	movq	$0, 24(%rsp)
	movl	%ebx, 20(%rsp)
	movq	%rax, g_page_entries(%rip)
	movl	%ebx, %eax
	.p2align 4,,10
	.p2align 3
.L192:
	movq	(%rsp), %rcx
	movq	g_page_buffer(%rip), %rdi
	movzwl	%ax, %edx
	movl	$1, %esi
	call	fread@PLT
	movq	%rax, %r15
	testq	%rax, %rax
	je	.L214
	xorl	%r12d, %r12d
	jmp	.L200
	.p2align 4,,10
	.p2align 3
.L193:
	movq	g_page_buffer(%rip), %rax
	cmpb	$10, (%rax,%r12)
	je	.L194
	addq	$1, %r12
	movl	%ebx, %r13d
	cmpq	%r12, %r15
	je	.L215
.L200:
	movq	(%rsp), %rdi
	leal	1(%r13), %ebx
	call	feof@PLT
	testl	%eax, %eax
	je	.L193
	leaq	-1(%r15), %rax
	cmpq	%r12, %rax
	jne	.L193
.L194:
	movzwl	%bp, %edx
	xorl	%ecx, %ecx
	.p2align 4,,10
	.p2align 3
.L196:
	movq	%rdx, %rax
	movq	%rdx, %rsi
	movl	%ecx, %edi
	addl	$1, %ecx
	mulq	%r14
	shrq	$3, %rdx
	cmpq	$9, %rsi
	ja	.L196
	leal	4(%r13,%rdi), %r13d
	movswl	g_terminal_width(%rip), %ecx
	movl	20(%rsp), %esi
	movswl	%r13w, %eax
	addl	$1, %ecx
	cltd
	idivl	%ecx
	movzwl	12(%rsp), %edx
	movl	%edx, %edi
	leal	1(%rax), %r10d
	movzwl	%r13w, %eax
	addl	%edx, %eax
	cmpl	%esi, %eax
	jg	.L197
	movzwl	18(%rsp), %eax
	movswl	%r10w, %ecx
	movl	%eax, %esi
	addl	%ecx, %eax
	movswl	g_display_rows(%rip), %ecx
	cmpl	%ecx, %eax
	jg	.L197
	addl	%r13d, %edi
	addl	%r10d, %esi
	addw	%bx, 8(%rsp)
	movw	%di, 12(%rsp)
	movw	%si, 18(%rsp)
.L198:
	addq	$1, %r12
	addl	$1, %ebp
	xorl	%r13d, %r13d
	cmpq	%r12, %r15
	jne	.L200
.L215:
	movzwl	g_page_buffer_size(%rip), %eax
	jmp	.L192
	.p2align 4,,10
	.p2align 3
.L197:
	movq	stderr(%rip), %rdi
	movzwl	10(%rsp), %ecx
	xorl	%eax, %eax
	movl	%r10d, 12(%rsp)
	movzwl	16(%rsp), %r8d
	leaq	.LC7(%rip), %rsi
	call	fprintf@PLT
	movzwl	16(%rsp), %edx
	movl	12(%rsp), %r10d
	movq	g_page_entries_len(%rip), %rax
	movq	g_page_entries(%rip), %rdi
	leaq	1(%rax), %rsi
	salq	$4, %rax
	addq	%rdi, %rax
	movq	%rsi, g_page_entries_len(%rip)
	cmpq	g_page_entries_capacity(%rip), %rsi
	movw	%dx, (%rax)
	movzwl	8(%rsp), %edx
	movw	%dx, 2(%rax)
	movzwl	10(%rsp), %edx
	movq	%rdx, 8(%rax)
	je	.L216
.L199:
	movzwl	8(%rsp), %edi
	addq	$1, 24(%rsp)
	addw	%di, 10(%rsp)
	movw	%r10w, 18(%rsp)
	movw	%bx, 8(%rsp)
	movw	%r13w, 12(%rsp)
	movw	%bp, 16(%rsp)
	jmp	.L198
	.p2align 4,,10
	.p2align 3
.L216:
	leaq	(%rsi,%rsi), %rax
	salq	$5, %rsi
	movq	%rax, g_page_entries_capacity(%rip)
	call	realloc@PLT
	movl	12(%rsp), %r10d
	movq	%rax, g_page_entries(%rip)
	jmp	.L199
.L214:
	cmpw	$0, 12(%rsp)
	jne	.L217
.L201:
	movzwl	10(%rsp), %edx
	movq	stderr(%rip), %rdi
	leaq	.LC8(%rip), %rsi
	xorl	%eax, %eax
	call	fprintf@PLT
	movq	24(%rsp), %rax
	addq	$40, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 56
	popq	%rbx
	.cfi_def_cfa_offset 48
	popq	%rbp
	.cfi_def_cfa_offset 40
	popq	%r12
	.cfi_def_cfa_offset 32
	popq	%r13
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%r15
	.cfi_def_cfa_offset 8
	ret
.L217:
	.cfi_restore_state
	movzwl	10(%rsp), %ecx
	movzwl	12(%rsp), %edx
	xorl	%eax, %eax
	leaq	.LC7(%rip), %rsi
	movzwl	16(%rsp), %r8d
	movq	stderr(%rip), %rdi
	movl	%ecx, %ebx
	movl	%r8d, %r14d
	call	fprintf@PLT
	movq	g_page_entries_len(%rip), %rax
	movzwl	8(%rsp), %ecx
	movq	g_page_entries(%rip), %rdi
	leaq	1(%rax), %rdx
	salq	$4, %rax
	addq	%rdi, %rax
	movq	%rdx, g_page_entries_len(%rip)
	cmpq	g_page_entries_capacity(%rip), %rdx
	movw	%cx, 2(%rax)
	movzwl	%bx, %ecx
	movw	%r14w, (%rax)
	movq	%rcx, 8(%rax)
	je	.L218
.L202:
	movzwl	8(%rsp), %ebx
	addq	$1, 24(%rsp)
	addw	%bx, 10(%rsp)
	jmp	.L201
.L218:
	movq	%rdx, %rsi
	leaq	(%rdx,%rdx), %rax
	salq	$5, %rsi
	movq	%rax, g_page_entries_capacity(%rip)
	call	realloc@PLT
	movq	%rax, g_page_entries(%rip)
	jmp	.L202
	.cfi_endproc
.LFE39:
	.size	some_precompute_pages, .-some_precompute_pages
	.p2align 4
	.globl	some_page_lookup
	.type	some_page_lookup, @function
some_page_lookup:
.LFB40:
	.cfi_startproc
	movzwl	%di, %edi
	salq	$4, %rdi
	addq	g_page_entries(%rip), %rdi
	movdqu	(%rdi), %xmm0
	movups	%xmm0, (%rsi)
	ret
	.cfi_endproc
.LFE40:
	.size	some_page_lookup, .-some_page_lookup
	.section	.rodata.str1.1
.LC9:
	.string	": "
	.text
	.p2align 4
	.globl	print_page
	.type	print_page, @function
print_page:
.LFB41:
	.cfi_startproc
	pushq	%r15
	.cfi_def_cfa_offset 16
	.cfi_offset 15, -16
	xorl	%edx, %edx
	pushq	%r14
	.cfi_def_cfa_offset 24
	.cfi_offset 14, -24
	pushq	%r13
	.cfi_def_cfa_offset 32
	.cfi_offset 13, -32
	pushq	%r12
	.cfi_def_cfa_offset 40
	.cfi_offset 12, -40
	pushq	%rbp
	.cfi_def_cfa_offset 48
	.cfi_offset 6, -48
	movq	%rdi, %rbp
	pushq	%rbx
	.cfi_def_cfa_offset 56
	.cfi_offset 3, -56
	movq	%rsi, %rbx
	subq	$56, %rsp
	.cfi_def_cfa_offset 112
	movq	8(%rsi), %rsi
	call	fseek@PLT
	movzwl	2(%rbx), %edx
	movq	%rbp, %rcx
	movq	g_page_buffer(%rip), %rdi
	movl	$1, %esi
	call	fread@PLT
	movq	g_page_buffer(%rip), %rcx
	movslq	%eax, %rdx
	movb	$0, (%rcx,%rdx)
	movq	g_page_buffer(%rip), %rbp
	movzwl	(%rbx), %r14d
	testl	%eax, %eax
	jle	.L223
	movl	%eax, %r15d
	leaq	24(%rsp), %rax
	leaq	36(%rsp), %r12
	xorl	%r13d, %r13d
	movq	%rax, 8(%rsp)
	.p2align 4,,10
	.p2align 3
.L222:
	movzwl	%r14w, %esi
	movq	%r12, %rdi
	addl	$1, %r14d
	call	std_utoa
	movq	stdout(%rip), %rcx
	movl	$1, %esi
	movq	%r12, %rdi
	movq	%rax, %rdx
	movq	%rax, %rbx
	call	fwrite@PLT
	movl	$2, %edx
	movq	stdout(%rip), %rcx
	movl	$1, %esi
	leaq	.LC9(%rip), %rdi
	call	fwrite@PLT
	movq	8(%rsp), %rsi
	movq	%rbp, %rdi
	movq	$0, 24(%rsp)
	call	puts_ln
	movswl	g_terminal_width(%rip), %ecx
	movq	%rax, %rdx
	movq	24(%rsp), %rax
	addl	$1, %ecx
	subl	%eax, %r15d
	addq	%rax, %rbp
	leal	2(%rbx,%rdx), %eax
	cwtl
	cltd
	idivl	%ecx
	leal	1(%r13,%rax), %r13d
	testl	%r15d, %r15d
	jg	.L222
.L220:
	addq	$56, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 56
	movl	%r13d, %eax
	popq	%rbx
	.cfi_def_cfa_offset 48
	popq	%rbp
	.cfi_def_cfa_offset 40
	popq	%r12
	.cfi_def_cfa_offset 32
	popq	%r13
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%r15
	.cfi_def_cfa_offset 8
	ret
	.p2align 4,,10
	.p2align 3
.L223:
	.cfi_restore_state
	xorl	%r13d, %r13d
	jmp	.L220
	.cfi_endproc
.LFE41:
	.size	print_page, .-print_page
	.section	.rodata.str1.8
	.align 8
.LC10:
	.string	"Page: %d/%d (%d%%) %04d-%02d-%02d\n"
	.text
	.p2align 4
	.globl	some_print_user_info
	.type	some_print_user_info, @function
some_print_user_info:
.LFB42:
	.cfi_startproc
	pushq	%r14
	.cfi_def_cfa_offset 16
	.cfi_offset 14, -16
	pushq	%r13
	.cfi_def_cfa_offset 24
	.cfi_offset 13, -24
	pushq	%r12
	.cfi_def_cfa_offset 32
	.cfi_offset 12, -32
	pushq	%rbp
	.cfi_def_cfa_offset 40
	.cfi_offset 6, -40
	movzwl	%di, %ebp
	xorl	%edi, %edi
	pushq	%rbx
	.cfi_def_cfa_offset 48
	.cfi_offset 3, -48
	movzwl	%si, %ebx
	subq	$16, %rsp
	.cfi_def_cfa_offset 64
	call	time@PLT
	leaq	8(%rsp), %rdi
	movq	%rax, 8(%rsp)
	call	localtime@PLT
	leaq	g_display_filepath(%rip), %rdi
	movl	12(%rax), %r14d
	movl	16(%rax), %r13d
	movl	20(%rax), %r12d
	call	puts@PLT
	imull	$100, %ebp, %eax
	subq	$8, %rsp
	.cfi_def_cfa_offset 72
	leal	1(%r13), %r9d
	pushq	%r14
	.cfi_def_cfa_offset 80
	movl	%ebp, %esi
	leal	1900(%r12), %r8d
	leaq	.LC10(%rip), %rdi
	cltd
	idivl	%ebx
	movl	%ebx, %edx
	movswl	%ax, %ecx
	xorl	%eax, %eax
	call	printf@PLT
	addq	$32, %rsp
	.cfi_def_cfa_offset 48
	popq	%rbx
	.cfi_def_cfa_offset 40
	popq	%rbp
	.cfi_def_cfa_offset 32
	popq	%r12
	.cfi_def_cfa_offset 24
	popq	%r13
	.cfi_def_cfa_offset 16
	popq	%r14
	.cfi_def_cfa_offset 8
	ret
	.cfi_endproc
.LFE42:
	.size	some_print_user_info, .-some_print_user_info
	.section	.rodata.str1.1
.LC11:
	.string	"Failed to open file: \"%s\"\n"
	.section	.rodata.str1.8
	.align 8
.LC12:
	.string	"[Q]uit | [N]ext | [P]revious : "
	.section	.rodata.str1.1
.LC13:
	.string	"clear"
	.text
	.p2align 4
	.globl	some_paging
	.type	some_paging, @function
some_paging:
.LFB43:
	.cfi_startproc
	pushq	%r15
	.cfi_def_cfa_offset 16
	.cfi_offset 15, -16
	pushq	%r14
	.cfi_def_cfa_offset 24
	.cfi_offset 14, -24
	pushq	%r13
	.cfi_def_cfa_offset 32
	.cfi_offset 13, -32
	pushq	%r12
	.cfi_def_cfa_offset 40
	.cfi_offset 12, -40
	pushq	%rbp
	.cfi_def_cfa_offset 48
	.cfi_offset 6, -48
	pushq	%rbx
	.cfi_def_cfa_offset 56
	.cfi_offset 3, -56
	subq	$40, %rsp
	.cfi_def_cfa_offset 96
	cmpb	$0, g_filepath(%rip)
	je	.L240
	leaq	1+g_filepath(%rip), %rdi
	call	strlen@PLT
	leaq	1(%rax), %rdx
	movzwl	%dx, %edx
.L229:
	movzwl	g_terminal_width(%rip), %ecx
	leaq	g_filepath(%rip), %rbx
	leaq	g_display_filepath(%rip), %rsi
	movq	%rbx, %rdi
	call	truncate_filepath
	leaq	.LC4(%rip), %rsi
	movq	%rbx, %rdi
	call	fopen@PLT
	movq	%rax, %r12
	testq	%rax, %rax
	je	.L248
	movq	%rax, %rdi
	xorl	%ebp, %ebp
	xorl	%r13d, %r13d
	movl	$1, %r14d
	call	some_precompute_pages
	movq	%rax, 8(%rsp)
	movzwl	%ax, %r15d
	leaq	16(%rsp), %rax
	movq	%rax, (%rsp)
	.p2align 4,,10
	.p2align 3
.L231:
	leaq	.LC13(%rip), %rdi
	call	system@PLT
	movq	%r13, %rax
	movq	(%rsp), %rsi
	movq	%r12, %rdi
	salq	$4, %rax
	addq	g_page_entries(%rip), %rax
	movdqu	(%rax), %xmm0
	movaps	%xmm0, 16(%rsp)
	call	print_page
	movzwl	g_display_rows(%rip), %ebx
	subw	%ax, %bx
	je	.L239
	.p2align 4,,10
	.p2align 3
.L232:
	movq	stdout(%rip), %rsi
	movl	$10, %edi
	call	putc@PLT
	subw	$1, %bx
	jne	.L232
.L239:
	leal	1(%rbp), %ebx
	movl	%r15d, %esi
	movzwl	%bx, %edi
	call	some_print_user_info
	leaq	.LC12(%rip), %rdi
	xorl	%eax, %eax
	call	printf@PLT
	movq	stdin(%rip), %rdi
	call	getc@PLT
	cmpb	$10, %al
	je	.L233
	leal	-97(%rax), %ecx
	cmpb	$22, %cl
	ja	.L231
	movq	%r14, %rax
	salq	%cl, %rax
	testl	$294913, %eax
	jne	.L235
	testl	$4202504, %eax
	jne	.L236
	cmpb	$16, %cl
	jne	.L231
	addq	$40, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 56
	popq	%rbx
	.cfi_def_cfa_offset 48
	popq	%rbp
	.cfi_def_cfa_offset 40
	popq	%r12
	.cfi_def_cfa_offset 32
	popq	%r13
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%r15
	.cfi_def_cfa_offset 8
	ret
	.p2align 4,,10
	.p2align 3
.L236:
	.cfi_restore_state
	movzwl	%bp, %eax
	movq	8(%rsp), %rdx
	addq	$1, %rax
	cmpq	%rdx, %rax
	jnb	.L231
	movzwl	%bx, %r13d
	movq	%r13, %rbp
	jmp	.L231
	.p2align 4,,10
	.p2align 3
.L235:
	testw	%bp, %bp
	je	.L231
	subl	$1, %ebp
	movzwl	%bp, %r13d
	jmp	.L231
	.p2align 4,,10
	.p2align 3
.L233:
	movq	stdout(%rip), %rsi
	movl	$10, %edi
	call	putc@PLT
	jmp	.L231
.L240:
	xorl	%edx, %edx
	jmp	.L229
.L248:
	movq	stderr(%rip), %rdi
	addq	$40, %rsp
	.cfi_def_cfa_offset 56
	movq	%rbx, %rdx
	leaq	.LC11(%rip), %rsi
	popq	%rbx
	.cfi_def_cfa_offset 48
	xorl	%eax, %eax
	popq	%rbp
	.cfi_def_cfa_offset 40
	popq	%r12
	.cfi_def_cfa_offset 32
	popq	%r13
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%r15
	.cfi_def_cfa_offset 8
	jmp	fprintf@PLT
	.cfi_endproc
.LFE43:
	.size	some_paging, .-some_paging
	.section	.rodata.str1.1
.LC14:
	.string	"No filepath provided\n"
	.text
	.p2align 4
	.globl	some
	.type	some, @function
some:
.LFB44:
	.cfi_startproc
	pushq	%r12
	.cfi_def_cfa_offset 16
	.cfi_offset 12, -16
	pushq	%rbp
	.cfi_def_cfa_offset 24
	.cfi_offset 6, -24
	pushq	%rbx
	.cfi_def_cfa_offset 32
	.cfi_offset 3, -32
	testl	%edi, %edi
	je	.L250
	leal	-1(%rdi), %eax
	xorl	%r12d, %r12d
	movslq	%eax, %rdx
	movl	%eax, %eax
	salq	$3, %rdx
	salq	$3, %rax
	leaq	-8(%rsi,%rdx), %rbp
	leaq	(%rsi,%rdx), %rbx
	subq	%rax, %rbp
	leaq	g_filepath(%rip), %rdx
	jmp	.L255
	.p2align 4,,10
	.p2align 3
.L275:
	movzbl	1(%rsi), %eax
	cmpb	$104, %al
	je	.L252
	cmpb	$112, %al
	movl	$1, %eax
	cmove	%eax, %r12d
	subq	$8, %rbx
	cmpq	%rbp, %rbx
	je	.L274
.L255:
	movq	(%rbx), %rsi
	cmpb	$45, (%rsi)
	je	.L275
	movq	%rdx, %rdi
	subq	$8, %rbx
	call	strcpy@PLT
	movq	%rax, %rdx
	cmpq	%rbp, %rbx
	jne	.L255
.L274:
	cmpb	$0, g_filepath(%rip)
	je	.L261
	movsbl	%r12b, %edi
	call	some_init
	testb	%r12b, %r12b
	je	.L258
	xorl	%eax, %eax
	call	some_paging
.L259:
	movq	g_page_entries(%rip), %rdi
	testq	%rdi, %rdi
	je	.L260
	call	free@PLT
.L260:
	movq	g_page_buffer(%rip), %rdi
	popq	%rbx
	.cfi_remember_state
	.cfi_def_cfa_offset 24
	popq	%rbp
	.cfi_def_cfa_offset 16
	popq	%r12
	.cfi_def_cfa_offset 8
	jmp	free@PLT
.L250:
	.cfi_restore_state
	cmpb	$0, g_filepath(%rip)
	jne	.L257
.L261:
	movq	stderr(%rip), %rcx
	popq	%rbx
	.cfi_remember_state
	.cfi_def_cfa_offset 24
	movl	$21, %edx
	movl	$1, %esi
	popq	%rbp
	.cfi_def_cfa_offset 16
	leaq	.LC14(%rip), %rdi
	popq	%r12
	.cfi_def_cfa_offset 8
	jmp	fwrite@PLT
.L257:
	.cfi_restore_state
	xorl	%edi, %edi
	call	some_init
	.p2align 4,,10
	.p2align 3
.L258:
	xorl	%eax, %eax
	call	some_simple
	jmp	.L259
	.p2align 4,,10
	.p2align 3
.L252:
	popq	%rbx
	.cfi_def_cfa_offset 24
	xorl	%eax, %eax
	popq	%rbp
	.cfi_def_cfa_offset 16
	popq	%r12
	.cfi_def_cfa_offset 8
	jmp	some_print_help
	.cfi_endproc
.LFE44:
	.size	some, .-some
	.globl	g_page_entries_capacity
	.bss
	.align 8
	.type	g_page_entries_capacity, @object
	.size	g_page_entries_capacity, 8
g_page_entries_capacity:
	.zero	8
	.globl	g_page_entries_len
	.align 8
	.type	g_page_entries_len, @object
	.size	g_page_entries_len, 8
g_page_entries_len:
	.zero	8
	.globl	g_page_entries
	.align 8
	.type	g_page_entries, @object
	.size	g_page_entries, 8
g_page_entries:
	.zero	8
	.globl	g_display_filepath
	.align 32
	.type	g_display_filepath, @object
	.size	g_display_filepath, 1920
g_display_filepath:
	.zero	1920
	.globl	g_filepath
	.align 32
	.type	g_filepath, @object
	.size	g_filepath, 1920
g_filepath:
	.zero	1920
	.globl	g_page_buffer_size
	.align 2
	.type	g_page_buffer_size, @object
	.size	g_page_buffer_size, 2
g_page_buffer_size:
	.zero	2
	.globl	g_page_buffer
	.align 8
	.type	g_page_buffer, @object
	.size	g_page_buffer, 8
g_page_buffer:
	.zero	8
	.globl	g_display_rows
	.align 2
	.type	g_display_rows, @object
	.size	g_display_rows, 2
g_display_rows:
	.zero	2
	.globl	g_reserved_rows
	.data
	.align 2
	.type	g_reserved_rows, @object
	.size	g_reserved_rows, 2
g_reserved_rows:
	.value	3
	.globl	g_terminal_height
	.bss
	.align 2
	.type	g_terminal_height, @object
	.size	g_terminal_height, 2
g_terminal_height:
	.zero	2
	.globl	g_terminal_width
	.align 2
	.type	g_terminal_width, @object
	.size	g_terminal_width, 2
g_terminal_width:
	.zero	2
	.section	.rodata.cst2,"aM",@progbits,2
	.align 2
.LC0:
	.byte	46
	.byte	47
	.align 2
.LC5:
	.byte	49
	.byte	58
	.align 2
.LC6:
	.byte	58
	.byte	32
	.ident	"GCC: (Debian 12.2.0-14) 12.2.0"
	.section	.note.GNU-stack,"",@progbits
