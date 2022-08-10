;********************************************************************
; #include <inttypes.h>                                             +
; typedef uint32_t u32                                              +
; typedef struct                                                    +
; {                                                                 +
;    u32 words[WORDS_LENGT];                                        +
; } BigInt;                                                         +    
;********************************************************************

;********************************************************************
; struc BigInt                                                      +
;   words resd WORDS_LENGTH                                         +
; endstruc                                                          +
;====================================================================

%define WORDS_LENGTH 0x6

section .rodata
    fmt         db "%08X ",0x0

section .data:
    test_data   dd 0x11,0x22,0x33,0x44,0x55,0x66,0x77,0x88
    test_length equ ($-test_data)/0x4
    
;********************************************
;   test_struct: istruc BigInt              +
;                   at words, dd ..., ...   +
;============================================

section .bss
    buf         resd WORDS_LENGTH

section .code
    global main:function
    extern printf,putchar

bigint_print:
    ;****************************************************************
    ; void bigint_print(const BigInt* element)                      +
    ; Prints a big integer to stdout.                               +
    ; @param[in] element - the big integer to print                 +
    ; element = RDI                                                 +
    ;================================================================

    mov     rcx, WORDS_LENGTH
.bigint_print_loop:    
    push    rcx
    push    rdi
    mov     esi, dword [rdi + rcx*0x4 - 0x4]
    lea     rdi, [fmt]
    xor     eax, eax
    call    printf
    pop     rdi
    pop     rcx
    dec     rcx
    test    rcx, rcx
    jnz     .bigint_print_loop

    mov     edi ,0xa
    call    putchar

        ret

bigint_set:
    ;****************************************************************************
    ; void bigint_set(BigInt* element, const u32* data, u32 data_wordlength)    +
    ; Sets a big integer to a fixed value.                                      +
    ; @param[out] element - the big integer to modify                           +
    ; @param[in] data - an array containing the data words;                     +
    ; @param[in] data_wordlength - the length of data in words                  +
    ; element = RDI, data = RSI, data_wordlength = RDX                          +
    ;============================================================================
    
    xor     rcx, rcx
    cmp     rdx, WORDS_LENGTH
    jbe     .bigint_set_loop
    mov     rdx, WORDS_LENGTH
.bigint_set_loop:
    push    rcx
    push    rdx
    push    rsi
    push    rdi

    mov     rax, rsi
    mov     r15d, dword [rax+rcx*0x4]
    mov     rax, rdi
    mov     dword [rax+rcx*0x4], r15d

    pop     rdi
    pop     rsi
    pop     rdx
    pop     rcx

    inc     rcx
    cmp     rcx, WORDS_LENGTH
    jb      .bigint_set_loop

    ret

bigint_setzero:
    ;********************************************************
    ; void bigint_setzero(BigInt* element)                  +
    ; set all bits of the BigInteger to 0                   +
    ; @param[out] element - the integer to set              +
    ;========================================================
    xor     rcx, rcx
.bigint_setzero_loop:
    push    rcx
    push    rdi

    mov     rax, rdi
    mov     dword [rax+rcx*0x4], 0x00

    pop     rdi
    pop     rcx
    inc     rcx
    cmp     rcx, WORDS_LENGTH
    jb      .bigint_setzero_loop

    ret

main:

    ;************************************************************
    ; We test in main the functions we implement above          +
    ;============================================================

    times   2 nop
    push    rbp
    mov     rbp, rsp

    lea     rdi, [buf]
    xor     eax, eax
    call    bigint_print

    lea     rdi, [buf]
    lea     rsi, [test_data]
    mov     rdx, test_length
    call    bigint_set

    mov     rdi, rax
    call    bigint_print

    xor     eax, eax
    leave
    ret

;****************************************************************
; compile: nasm -f elf64 -gstabs -F dwarf -o a.o -l bigint.lst  +
;          gcc -no-pie -o a.out a.o && rm a.o                   +
;          ./a.out                                              +
;================================================================
