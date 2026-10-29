; =============== Driver code to call SOME functionality ===============
; Written by: Tomáš Tytykalo
; Last update: 2025-03-16
; Platform: x86_64/Linux64/nasm/gcc linker
; Description: User style executable for calling external functionality
; ======================================================================

section .text
    global main
    extern some ; assignment library

main:
    push    rbp
    mov     rbp, rsp
                            ; Forward argc and argv
    dec     rdi             ; Decrement argc, because we don't care about first argument
    lea     rsi, [rsi + 8]  ; Skip first arg in argv
    call    some

    xor     eax, eax
    leave
    ret

section .note.GNU-stack noalloc noexec nowrite progbits
