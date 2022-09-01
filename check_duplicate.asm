%define INT_SIZE 0x04

SECTION .rodata
    str_0:  db "No duplication",0x0a,0x00
    len_0:  equ $-str_0
    str_1:  db "Duplication found",0x0a,0x00
    len_1   equ $-str_1

SECTION .data
    array:  dd 10,20,33,44,10,1084,714,4051,10,2895
    len:    equ ($-array)/INT_SIZE

SECTION .text
    global main:function

chk_dup:
    xor     r14d, r14d
    xor     r15d, r15d
.chk_dup_loop:
    cmp     r14d, r15d
    je      .no_dup_found
    mov     eax, r14d
    cdqe
    movsx   rax, eax
    lea     rdx, [rax*0x04]
    mov     rax, rdi
    add     rax, rdx
    mov     edx, dword [rax]

    mov     eax, r15d
    cdqe
    movsx   rax, eax
    lea     rcx, [rax*0x04]
    mov     rax, rdi
    add     rax, rcx
    mov     eax, dword [rax]

    cmp     edx, eax
    jne     .no_dup_found
    mov     rax, 0x01
    jmp     .done

.no_dup_found:
    inc     r15d
    mov     eax, r15d
    cdqe
    movsx   rax, eax
    cmp     rsi, rax
    ja      .chk_dup_loop
    inc     r14d
    mov     edx, r14d
    cdqe
    movsx   rdx, edx
    dec     rdx
    cmp     rdx, rsi
    jb      .chk_dup_loop
    xor     rax, rax

.done:
    ret
    
main:
    
    lea     rdi, [array]
    mov     rsi, len
    call    chk_dup

    cmp     rax, 0x1
    je      .main_dup_found

    mov     rax, 0x01
    mov     rdi, 0x01
    lea     rsi, [str_0]
    mov     rdx, len_0
    syscall
    jmp     .main_exit

.main_dup_found:
    mov     rax, 0x01
    mov     rdi, 0x01
    lea     rsi, [str_1]
    mov     rdx, len_1
    syscall

.main_exit:
    mov     rax, 0x3c
    xor     rdi, rdi
    syscall
