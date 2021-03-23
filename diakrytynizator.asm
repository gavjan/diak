%include "macros.inc"

section .data
	textb2 db ": ",0

section .bss
	argc resb 8
	arg_arr resb 8
	mult resb 8
	sum resb 8

section .text
	global _start

; - Convert string to a number
; - [in]  rax: pointer to string
; - [out] rax: converted number
; - [modifies]: rbx, rdx, r8
_convert_to_int:
	mov r8, rax				; r8 = rax
	xor rax, rax			; rax = 0
	xor rbx, rbx			; rbx = 0

start_int_loop:
	mov bl, [r8]
	cmp bl, 0
	je end_int_loop			; jump if bl == '\0'

	mov rdx, 10
	mul rdx
	sub bl, 48
	add rax, rbx			; rax = rax*10 + (bl - '0')

	inc r8					; r8++
	jmp start_int_loop		; jump start_int_loop

end_int_loop:
	ret

; - Modify unicode value according to the description
; - [in] r12: unicode value to modify
; - [out] r12: modified unicode value
; - [modifies]:
_modify_val:

	cmp r12, 128
	jb end_modify_val		; jump if r12 < 128

	sub r12, 128

	mov rax, 1
	mov [mult], rax 		; mult = 1

	mov rax, 0
	mov [sum], rax			; sum = 0

	xor r10, r10			; r10 = 0

print_args_loop:

	mov rax, r10

	mov rbx, [arg_arr]
	mov rax, [rbx + r10*8]	; rax = arg_arr + 8*r10


	mov rbx, [mult]
	mul rbx
	mov rbx, 1113984
	div rbx
	mov rax, rdx			; rax = (rax*mult)%1113984

	mov rcx, [sum]
	add rcx, rax
	mov rax, rcx
	mov rbx, 1113984
	div rbx
	mov [sum], rdx 			; sum = (sum + rax)%1113984

	mov rax, [mult]
	mul r12
	mov rbx, 1113984
    div rbx
	mov [mult], rdx			; mult = (mult*r12)%1113984 // r12 is x

    inc r10

	mov rbx, [argc]
	cmp r10, rbx
	jne print_args_loop		; jump if(r10 != argc)

	mov r12, [sum]

	add r12, 128			; r12 += 128
end_modify_val:
	ret


_convert_args:

convert_args_loop:

	mov rbx, [arg_arr]
	mov rax, [rbx + r10*8]	; rax = arg_arr + 8*r10

	call _convert_to_int	; rax = convert_int(rax)

	mov rbx, 1113984
	div rbx
	mov rax, rdx			; rax %= 1113984

	mov rbx, [arg_arr]
	mov [rbx + r10*8], rax 	; rbx = arg_arr + 8*r10

	inc r10					; r10++

	mov rbx, [argc]
	cmp r10, rbx
	jne convert_args_loop	; jump if(r10 != argc)

	ret


_start:
	pop rax					; pop rax
	dec rax					; rax--
	mov [argc], rax			; argc = rax // we don't need the first argument

	pop rax					; remove first argument

	mov [arg_arr], rsp		; arg_arr = rsp

	call _convert_args		; convert input arguments

	mov r12, 1000
	call _modify_val

	printVal r12
    print endl

	exit




