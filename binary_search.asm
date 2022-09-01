%define INT_SIZE 0x04

SECTION .rodata
    output_0:   db "[-] Element not found",0x0a,0x00
    len_0:      equ $-output_0
    output_1:   db "[+] Element found",0x0a,0x00
    len_1:      equ $-output_1

SECTION .data
    array:      dd -1000,-485,-224,924,4815,18904,49195,190712
    size:       equ ($-array)/INT_SIZE

SECTION .text
    global main:function

bin_search:
    SECTION .bss
        .item:  resd 0x01

    SECTION .text
        xor     r14d, r14d
        mov     r15d, esi
        dec     r15d
        mov     dword [.item], edx

    .bin_search_loop:
        mov     eax, r15d
        sub     eax, r14d
        mov     edx, eax
        shr     edx, 31
        add     eax, edx
        sar     eax, 0x01
        mov     edx, eax
        mov     eax, r14d
        add     eax, edx
        mov     r13d, eax
        mov     eax, r13d
        cdqe
        movsx   rax, eax
        lea     rdx, [rax*0x04]
        mov     rax, rdi
        add     rax, rdx
        mov     eax, dword [rax]
        cmp     dword [.item], eax
        jne     .low_inc
        mov     eax, r13d
        movsx   rax, eax
        jmp     .bin_search_exit
    
    .low_inc:
        mov     eax, r13d
        cdqe
        movsx   rax, eax
        lea     rdx, [rax*0x04]
        mov     rax, rdi
        add     rax, rdx
        mov     eax, dword [rax]
        cmp     dword [.item], eax
        jle     .high_inc
        mov     eax, dword [.item]
        inc     eax
        mov     r14d, eax
        jmp     .chk_pt
    .high_inc:
        mov     eax, r13d
        dec     eax
        mov     r15d, eax

    .chk_pt:
        mov     eax, r14d
        cmp     eax, r15d
        jle     .bin_search_loop
        mov     eax, -1
        movsx   rax, eax
    .bin_search_exit:
        ret

main:
    times   0x04 nop
    lea     rdi, [array]
    mov     esi, size
    mov     edx, 190712
    call    bin_search

    cmp     rax, -1
    jns      .main_found

    mov     rax, 0x01
    mov     rdi, 0x01
    lea     rsi, [output_0]
    mov     rdx, len_0
    syscall

    jmp     .main_exit

.main_found:

    mov     rax, 0x01
    mov     rdi, 0x01
    lea     rsi, [output_1]
    mov     rdx, len_1
    syscall

.main_exit:
    mov     rax, 0x3c
    xor     rdi, rdi
    syscall
