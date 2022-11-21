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

.data?
    cor dd ?
    incremento dd ?
    inputString db 50 dup(?)

.data
    inputHandle dd 0
    outputHandle dd 0
    console_count dd 0
    tamanho_string dd 0

    DEBUG_MSG db "String lida: ", 0ah, 0
    prompt_cor db "Escolha uma cor -> 0-Azul | 1-Verde | 2-Vermelho", 0ah, 0
    prompt_incremento db "Defina um incremento para a cor escolhida (de 0 a 255)", 0ah, 0

.code
start:
    ; Preparando para ler do console
    push STD_INPUT_HANDLE
    call GetStdHandle
    mov inputHandle, eax

    ; Preparando para escrever no console
    push STD_OUTPUT_HANDLE
    call GetStdHandle
    mov outputHandle, eax

    ; Lendo do usuário qual a cor escolhida
    invoke StrLen, addr prompt_cor
    mov tamanho_string, eax
    invoke WriteConsole, outputHandle, addr prompt_cor, tamanho_string, addr console_count, NULL
    invoke ReadConsole, inputHandle, addr inputString, sizeof inputString, addr console_count, NULL
    push offset inputString
    call TratarNewLine
    push offset inputString
    call atodw
    mov cor, eax

    ; Lendo do usuário qual o incremento escolhido para a cor
    invoke StrLen, addr prompt_incremento
    mov tamanho_string, eax
    invoke WriteConsole, outputHandle, addr prompt_incremento, tamanho_string, addr console_count, NULL
    invoke ReadConsole, inputHandle, addr inputString, sizeof inputString, addr console_count, NULL
    push offset inputString
    call TratarNewLine
    push offset inputString
    call atodw
    mov incremento, eax

    ;printf("%d\n", cor)
    ;printf("%d\n", incremento)

    invoke ExitProcess, 0

TratarNewLine:
    push ebp
    mov ebp, esp

    mov esi, DWORD PTR [ebp+8] ; Armazenar apontador da string (parâmetro 1) em esi
    proximo:
        mov al, [esi] ; Mover caracter atual para al
        inc esi ; Apontar para o proximo caracter
        cmp al, 48 ; Verificar se menor que ASCII 48 - FINALIZAR
        jl terminar
        cmp al, 58 ; Verificar se menor que ASCII 58 - CONTINUAR
        jl proximo
    terminar:
        dec esi ; Apontar para caracter anterior
        xor al, al ; 0 ou NULL
        mov [esi], al ; Inserir NULL logo apos o termino do numero

    mov esp, ebp
    pop ebp
    ret 4

end start