.686
.model flat, stdcall
option casemap :none
include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\masm32.inc
include \masm32\include\msvcrt.inc

includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib
includelib \masm32\lib\msvcrt.lib

include \masm32\macros\macros.asm

.data
    inputString dd 50 dup(0)
    inputHandle dd 0
    outputHandle dd 0
    console_count dd 0
    tamanho_string dd 0
    DEBUG_MSG db "String lida: ", 0ah, 0

.code
start:
    ; preparando para escrever no console
    push STD_OUTPUT_HANDLE
    call GetStdHandle
    mov outputHandle, eax

    printf("%s", addr DEBUG_MSG)

    fim:
        invoke ExitProcess, 0

end start