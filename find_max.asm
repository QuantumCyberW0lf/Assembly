%define INT_MIN -2147483648
%define INT_SIZE 0x04

SECTION .rodata
    output:     db "The maximum element is: %d",0x0a,0x0

SECTION .data
    array:      dd 305,102,211,784,6531,100,12,34,156,123,982501
    len:        equ ($-array)/INT_SIZE
SECTION .text
    global main:function
    extern printf

find_max:
    SECTION .bss
        .max:   resd 0x01

    SECTION .text
        mov     dword [.max], INT_MIN
        mov     rcx, rsi
        xor     r15d, r15d

    .find_max_loop:
        mov     eax, r15d
        movsx   rax, eax
        lea     rdx, [rax*0x04]
        mov     rax, rdi
        add     rax, rdx
        mov     eax, dword [rax]
        cmp     dword [.max], eax
        jge     .not_swap

        mov     eax, r15d
        movsx   rax, eax
        lea     rdx, [rax*0x04]
        mov     rax, rdi
        add     rax, rdx
        mov     eax, dword [rax]
        mov     dword [.max], eax
    .not_swap:
        inc     r15d
        loop    .find_max_loop

        mov     eax, dword [.max]
        movsx   rax, eax
        ret

main:
    times   0x02 nop
    lea     rdi, [array]
    mov     rsi, len

    call    find_max

    lea     rdi, [output]
    mov     rsi, rax
    xor     eax, eax
    call    printf

    mov     rax, 0x3c
    xor     rdi, rdi
    syscall
