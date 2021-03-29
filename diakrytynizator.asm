%include "macros.inc"

;SYS_READ    equ 0
;SYS_WRITE   equ 1
;SYS_EXIT    equ 60
;STDIN   	equ 0
;STDOUT  	equ 1

section .bss
	argc resb 8
	arg_arr resb 8
	mult resb 8
	sum resb 8
	buff resb 2
	char resb 1

section .text
	global _start



; - Take one byte from stdin and write it to bl
; - [out] bl: read char
; - [out] [char]: read char
; - [modifies] rax, rdi, rsi, rdx,
_scanf:
	mov rax, 0
	mov [char], rax

	mov rax, SYS_READ
	mov rdi, STDIN
	mov rsi, char
	mov rdx, 1
	syscall
	mov bl, [char]
	cmp bl, 0
	jne end_scanf

	mov rdi, 0
	mov rax, SYS_EXIT
	syscall

end_scanf:
	ret

; - Print continuation byte
; - [in] rbx: number of bits to shift to right
; - [in] r8: UTF-8 code
; - [modifies]: rax, rbx, rdi, rsi, rdx
_print_cont_byte:
	mov rax, r8
	div rbx					; shift rbx bits to right

	mov rbx, 63
	and rax, rbx			; leave only first 6 bits

	add rax, 128			; add continuation bits

	call _print_char		; print byte

	ret

; - Print 1 byte char stored in rax
; - [in] rax: byte to print
; - [modifies]: rax, rdi, rsi, rdx
_print_char:
	mov [buff], al
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	mov rsi, buff
	mov rdx, 1
	syscall
	ret

; - Asssert continuation byte; err_exit if byte doesn't start with 10
; - [in] bl: continuation byte
; - [modifies]:  al, bl
; - [out] bl: modified byte without continuation header
_assert_cont_byte:
	mov al, 128
	mov cl, 128
	and al, bl
	cmp al, cl
	jne _err_exit			; check if byte starts with 10

	not cl
	and bl, cl				; clear continuation header bytes

	ret

; - Get next UTF character from a string
_err_exit:
	mov rdi, 1
	mov rax, SYS_EXIT
	syscall

; - Get next UTF character from input
; - [out] rax: UTF-8 character number
; - [modifies] rax, rbx, rcx, r9
_next_utf_char:
	xor rax, rax			; rax = 0
	xor rbx, rbx			; rbx = 0
	xor r9, r9				; r9 = 0

;-------------------First Byte-------------------------
	call _scanf				; bl = _scanf()

	cmp bl, 128
	jae check_2_byte		; jump if first bit is 1

	mov r9, rbx				; r9 = rbx

	jmp end_next_utf_char	; jump to end
;-------------------First Byte-------------------------


;-------------------Second Byte------------------------
check_2_byte:
	mov bl, [char]

	cmp bl, 224
	jae check_3_byte		; jump if starts wtih 111

	mov rax, 64
	and al, bl
	cmp al, 0
	je _err_exit			; err if byte doesn't start with 110

	mov rax, 63
	and bl, al				; clear bits 7 and 8

	mov rcx, 64
	mov rax, rbx
	mul rcx					; shitft bits to 6 left

	mov r9, rax				; r9 = rax

	call _scanf				; bl = _scanf()

	call _assert_cont_byte	; assert_cont_byte()

	add r9, rbx				; add the 2nd byte's code

	jmp end_next_utf_char	; jump to end
;-------------------Second Byte------------------------

;-------------------Third Byte-------------------------
check_3_byte:
	mov bl, [char]

	cmp bl, 240
	jae check_4_byte		; jump if starts with 1111

	mov al, 240
	and al, bl
	mov cl, 224
	cmp al, cl
	jne _err_exit			; check if control bytes are 1110

	not cl
	and bl, cl				; clear control bytes

	mov rcx, 4096
	mov rax, rbx
	mul rcx					; shitft bits to 12 left

	mov r9, rax				; r9 = rax

	call _scanf				; bl = _scanf()

	call _assert_cont_byte	; assert_cont_byte()

	mov rcx, 64
	mov rax, rbx
	mul rcx					; shitft bits to 6 left

	add r9, rax				; add the 2nd byte's code

	call _scanf				; bl = _scanf()

	call _assert_cont_byte	; assert_cont_byte()

	add r9, rbx				; add the 3rd byte's code

	jmp end_next_utf_char	; jump to end



;-------------------Third Byte-------------------------

;-------------------Forth Byte-------------------------
check_4_byte:
	mov bl, [char]

	mov al, 248
	and al, bl
	mov cl, 240
	cmp al, cl
	jne _err_exit			; check if control bytes are 11110

	not cl
	and bl, cl				; clear control bytes

	mov rcx, 262144
	mov rax, rbx
	mul rcx					; shitft bits to 18 left

	mov r9, rax				; r9 = rax

	call _scanf				; bl = _scanf()

	call _assert_cont_byte	; assert_cont_byte()

	mov rcx, 4096
	mov rax, rbx
	mul rcx					; shitft bits to 12 left

	add r9, rax				; add the 2nd byte's code

	call _scanf				; bl = _scanf()

	call _assert_cont_byte	; assert_cont_byte()

	mov rcx, 64
	mov rax, rbx
	mul rcx					; shitft bits to 6 left

	add r9, rax				; add the third byte's code

	call _scanf				; bl = _scanf()

	call _assert_cont_byte	; assert_cont_byte()

	add r9, rbx				; add the 4th byte's code


;-------------------Forth Byte-------------------------
end_next_utf_char:

	mov rax, r9				; return rax = r9
	ret

; - Print UTF-8 Character from a given unicode code
; - [in] rax: UTF-8 Character code
; - [modifies] rax, rbx, rdi, rsi, rdx, r8
_print_utf_char:

	mov r8, rax				; r8 = rax

	xor rax, rax			; rax = 0
	xor rbx, rbx 			; rbx = 0
	xor rdi, rdi 			; rdi = 0
	xor rsi, rsi 			; rsi = 0
	xor rdx, rdx 			; rdx = 0

;-------------------One Byte---------------------------
	cmp r8, 128
	jae two_byte			; jump if requires more than a byte

	mov al, r8b
	call _print_char		; print(r8)

	jmp end_print_utf_char	; jump to end

;-------------------One Byte---------------------------
;-------------------Two Bytes--------------------------
two_byte:
	cmp r8, 2048
	jae three_byte			; jump if requires more than 2 bytes

	mov rax, r8
	mov rbx, 64
	div rbx					; shift 6 bits to right

	add rax, 192			; add control bits

	call _print_char		; print first byte

	mov rax, r8
	mov rbx, 63
	and rax, rbx			; leave only first 6 bits

	add rax, 128			; add continuation bits

	call _print_char		; print second byte

	jmp end_print_utf_char	; jump to end

;-------------------Two Bytes--------------------------
;-------------------Three Bytes------------------------
three_byte:
	cmp r8, 65536
	jae four_byte			; jump if requires more than 3 bytes

	mov rax, r8
	mov rbx, 4096
	div rbx					; shift 12 bits to right

	add rax, 224			; add control bits

	call _print_char		; print first byte


	mov rbx, 64
	call _print_cont_byte	; second byte

	mov rax, r8
	mov rbx, 63
	and rax, rbx			; leave only first 6 bits

	add rax, 128			; add continuation bits

	call _print_char		; print third byte

	jmp end_print_utf_char	; jump to end

;-------------------Three Bytes------------------------
;-------------------Four Bytes-------------------------
four_byte:
	mov rax, r8
	mov rbx, 262144
	div rbx					; shift 18 bits to right

	add rax, 240			; add control bits

	call _print_char		; print first byte



	mov rbx, 4096
	call _print_cont_byte	; second byte


	mov rbx, 64
	call _print_cont_byte	; third byte


	mov rax, r8
	mov rbx, 63
	and rax, rbx			; leave only first 6 bits

	add rax, 128			; add continuation bits

	call _print_char		; print forth byte
;-------------------Four Bytes-------------------------


end_print_utf_char:
	ret


; - Convert string to a number
; - [in]  rax: pointer to string
; - [out] rax: converted number
; - [modifies]: rbx, rdx, rcx, r8
_convert_to_int:
	mov r8, rax				; r8 = rax
	xor rax, rax			; rax = 0
	xor rbx, rbx			; rbx = 0
	xor r9, r9				; r9 = 0

start_int_loop:
	mov bl, [r8]
	cmp bl, 0
	je end_int_loop			; jump if bl == '\0'

	inc r9					; r9++

	cmp bl, 48
	jb _err_exit
	cmp bl, 57
	ja _err_exit			; err if not numeric

	sub bl, 48				; bl -= '0'

	cmp r9, 20
	jb under_64_bit
	ja _err_exit			; err if larger than uint64_t max

	mov rcx, 1844674407370955161
	cmp rax, rcx
	jb under_64_bit
	ja _err_exit			; err if larger than uint64_t max

	cmp bl, 5
	ja _err_exit			; err if larger than uint64_t max

under_64_bit:


	mov rdx, 10
	mul rdx
	add rax, rbx			; rax = rax*10 + bl

	inc r8					; r8++
	jmp start_int_loop		; jump start_int_loop

end_int_loop:
	ret

; - Modify unicode value according to the description
; - [in] r12: unicode value to modify
; - [out] r12: modified unicode value
; - [modifies]: rax, rbx, rcx, rdx, r10
_modify_val:

	cmp r12, 128
	jb end_modify_val		; jump if r12 < 128

	sub r12, 128			; r12 -= 128

	mov rax, 1
	mov [mult], rax 		; mult = 1

	mov rax, 0
	mov [sum], rax			; sum = 0

	xor r10, r10			; r10 = 0
	xor rax, rax			; rax = 0
	xor rbx, rbx			; rbx = 0
	xor rcx, rcx			; rcx = 0
	xor rdx, rdx			; rdx = 0
	xor r10, r10			; r10 = 0

print_args_loop:

	mov rax, r10

	mov rbx, [arg_arr]
	mov rax, [rbx + r10*8]	; rax = arg_arr + 8*r10


	mov rbx, [mult]
	mul rbx					; rax *= mult


	mov rbx, 1113984
	mov rdx, 0
	div rbx
	mov rax, rdx 			; rax %= 1113984

	mov rcx, [sum]
	add rcx, rax			; sum += rax



	mov rax, rcx
	mov rbx, 1113984
	mov rdx, 0
	div rbx
	mov [sum], rdx			; sum %= 1113984


	mov rax, [mult]
	mul r12					; mult*=r12 // r12 is x

	mov rbx, 1113984
	mov rdx, 0
	div rbx
	mov rax, rdx
	mov [mult], rax			; mult %= 1113984

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

	cmp rax, 1
	jae arguments_ok		; jump if rax >= 1

	call _err_exit			; err if arguments are less than 1

arguments_ok:
	pop rax					; remove first argument

	mov [arg_arr], rsp		; arg_arr = rsp

	call _convert_args		; convert input arguments

while_true:
	call _next_utf_char		; rax = _next_utf_char()

	mov r12, rax
	call _modify_val		; r12 = _modify_val(rax)

	mov rax, r12
	call _print_utf_char	; _print_utf_char(r12)

	jmp while_true			; jump to while_true
