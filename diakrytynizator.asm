%include "macros.inc"

section .data
	textb2 db ": ",0

section .bss
	argc resb 8
	arg_arr resb 8
	i resb 8
	x resb 8
	mult resb 8
	sum resb 8

section .text
	global _start

convert_to_int:
	mov r8, rax
	xor rax, rax
	xor rbx, rbx

start_int_loop:
	mov bl, [r8]
	cmp bl, 0
	je end_int_loop	; jump if bl == '\0'

	mov rdx, 10
	mul rdx
	sub bl, 48
	add rax, rbx	; rax = rax*10 + (bl - '0')

	inc r8
	jmp start_int_loop

end_int_loop:
	ret


_start:
	mov rax, 2
	mov [x], rax			; x = 2

	mov rax, 1
	mov [mult], rax 		; mult = 1

	xor rax, rax
	mov [i], rax			; i = 0

	mov rax, 0
	mov [sum], rax			; sum = 0

	pop rax					; pop rax
	dec rax					; rax--
	mov [argc], rax			; argc = rax // we don't need the first argument

	pop rax					; remove first argument

	mov [arg_arr], rsp		; arg_arr = rsp


_printArgsLoop:

	mov rax, [i]
	printVal rax
	print textb2			; print(i + ": ")

	mov rbx, [arg_arr]
	mov rcx, [i]
	mov rbx, [rbx + rcx*8]	; rbx = arg_arr + 8*i

	mov rax, rbx
	call convert_to_int		; rax = convert_int(rbx)

	mov rbx, [mult]
	mul rbx

	mov rcx, [sum]
	add rcx, rax
	mov [sum], rcx			; sum += rax*mult



	mov rax, [mult]
	mov rbx, [x]
	mul rbx
	mov [mult], rax			; mult*=x

	printVal rcx
	print endl

	mov rax, [i]
    inc rax
    mov [i], rax			; i++

	mov rax, [i]
	mov rbx, [argc]
	cmp rax, rbx
	jne _printArgsLoop		; jump if(i != argc)

	exit