section .data
    endl db 10,0

section .bss
    digitSpace resb 100
    digitSpacePos resb 8
    printSpace resb 8
    num resb 100
    num_pos resb 8

%macro print 1
    mov rax, %1
    mov [printSpace], rax
    mov rbx, 0
%%printLoop:
    mov cl, [rax]
    cmp cl, 0
    je %%endPrintLoop
    inc rbx
    inc rax
    jmp %%printLoop
%%endPrintLoop:
    mov rax, SYS_WRITE
    mov rdi, STDIN
    mov rsi, [printSpace]
    mov rdx, rbx
    syscall
%endmacro


%macro printLowReg 1
    xor rax, rax
    mov al, %1

    mov rcx, num
    mov bl, 0
    mov [rcx], bl

    mov [num_pos], rcx
%%printALLoop:
    mov rdx, 0
    mov rbx, 10
    div rbx
    push rax
    add dl, 48

    mov rcx, [num_pos]
    mov [rcx], dl
    inc rcx
    mov [num_pos], rcx

    pop rax
    cmp rax, 0
    jne %%printALLoop
%%printALLoop2:
    mov rcx, [num_pos]

    mov rax, 1
    mov rdi, 0
    mov rsi, rcx
    mov rdx, 1
    syscall

    mov rcx, [num_pos]
    dec rcx
    mov [num_pos], rcx

    cmp rcx, num
    jge %%printALLoop2

%endmacro


%macro printVal 1
    mov rax, %1
%%printRAX:
    mov rcx, digitSpace
    mov rbx, 0
    mov [rcx], rbx

    mov [digitSpacePos], rcx

%%printRAXLoop:
    mov rdx, 0
    mov rbx, 10
    div rbx
    push rax
    add rdx, 48

    mov rcx, [digitSpacePos]
    mov [rcx], dl
    inc rcx
    mov [digitSpacePos], rcx

    pop rax
    cmp rax, 0
    jne %%printRAXLoop

%%printRAXLoop2:
    mov rcx, [digitSpacePos]

    mov rax, 1
    mov rdi, 0
    mov rsi, rcx
    mov rdx, 1
    syscall

    mov rcx, [digitSpacePos]
    dec rcx
    mov [digitSpacePos], rcx

    cmp rcx, digitSpace
    jge %%printRAXLoop2

%endmacro

%macro exit 0
    mov rax, SYS_EXIT
    mov rdi, NO_ERROR
    syscall
%endmacro


STDIN   equ 0
STDOUT  equ 1
STDERR  equ 2


SYS_READ    equ 0
SYS_WRITE   equ 1
SYS_OPEN    equ 2
SYS_CLOSE   equ 3

SYS_EXIT    equ 60

NO_ERROR    equ 0
