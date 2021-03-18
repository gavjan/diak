%include "macros.inc"

section .data
	textb2 db ": ",0

section .bss
	argc resb 8
	arg_arr resb 8
	i resb 8
	x resb 8
	mult resb 8

section .text
	global _start

_start:
	mov rax, 2
	mov [x], rax	; x = 2

	mov rax, 1
	mov [mult], rax ; mult = 1

	xor rax, rax
	mov [i], rax	; i = 0

	pop rax				; pop rax
	dec rax				; rax--
	mov [argc], rax		; argc = rax // we don't need the first argument

	pop rax				; remove first argument

	mov [arg_arr], rsp

_printArgsLoop:

	mov rax, [i]
	printVal rax
	print textb2		; print(i + ": ")

	mov rbx, [arg_arr]
	mov rax, 8
	mov rcx, [i]
    mul rcx
	add rbx, rax
	mov rbx, [rbx]		; rbx = arg_arr + 8*i


	printVal [rbx]
	print endl			; print(pop() + "\n")

	mov rax, [i]
    inc rax
    mov [i], rax	; i++

	mov rax, [i]
	mov rbx, [argc]
	cmp rax, rbx
	jne _printArgsLoop	; jump if(i != argc)

	exit