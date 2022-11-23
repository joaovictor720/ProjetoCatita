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
    color dd ?
    increment dd ?
    fileName db 50 dup(?)
    newFileName db 50 dup(?)
    pixelBuffer db 3 dup(?)

    inputString db 50 dup(?)
    inputHandle dd ?
    outputHandle dd ?
    consoleCount dd ?
    stringSize dd ?
    
    fileInputHandle dd ?
    fileOutputHandle dd ?
    readCount dd ?
    writeCount dd ?
    bmpHeader db 54 dup(?)

.data
    DEBUG_MSG db "String lida: ", 0ah, 0
    prompt_fileName db "Digite o nome do arquivo a ser usado:", 0
    prompt_color db "Escolha uma cor -> 0-Azul | 1-Verde | 2-Vermelho:", 0ah, 0
    prompt_increment db "Defina um increment para a cor escolhida (de 0 a 255):", 0ah, 0
    prompt_newFileName db "Digite o nome do arquivo de saída", 0

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

    ; Lendo nome do arquivo a ser usado
    invoke StrLen, addr prompt_fileName
    mov stringSize, eax
    invoke WriteConsole, outputHandle, addr prompt_fileName, stringSize, addr consoleCount, NULL
    invoke ReadConsole, inputHandle, addr fileName, sizeof fileName, addr consoleCount, NULL
    ;push offset inputString
    ;call ParseNewLine
    ;mov eax, offset inputString
    ;mov fileName, eax

    printf(offset fileName)

    invoke ExitProcess, 0

end start