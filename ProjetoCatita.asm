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

    inputString db 50 dup(?)
    inputHandle dd ?
    outputHandle dd ?
    fileHandle dd ?
    consoleCount dd ?
    tamanhoString dd ?
    
    pixelBuffer db 3 dup(?)
    readCount 

.data
    DEBUG_MSG db "String lida: ", 0ah, 0
    prompt_arquivo db "Digite o nome do arquivo a ser usado:"
    prompt_cor db "Escolha uma color -> 0-Azul | 1-Verde | 2-Vermelho:", 0ah, 0
    prompt_increment db "Defina um increment para a color escolhida (de 0 a 255):", 0ah, 0

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
    invoke StrLen, addr prompt_arquivo
    mov tamanhoString, eax
    invoke WriteConsole, outputHandle, addr prompt_arquivo, tamanhoString, addr consoleCount, NULL
    invoke ReadConsole, inputHandle, addr inputString, sizeof inputString, addr consoleCount, NULL
    mov eax, inputString
    mov fileName, eax

    ; Lendo a color escolhida
    invoke StrLen, addr prompt_cor
    mov tamanhoString, eax
    invoke WriteConsole, outputHandle, addr prompt_cor, tamanhoString, addr consoleCount, NULL
    invoke ReadConsole, inputHandle, addr inputString, sizeof inputString, addr consoleCount, NULL
    push offset inputString
    call ParseNewLine
    push offset inputString
    call atodw
    mov color, eax

    ; Lendo o increment escolhido para a color
    invoke StrLen, addr prompt_increment
    mov tamanhoString, eax
    invoke WriteConsole, outputHandle, addr prompt_increment, tamanhoString, addr consoleCount, NULL
    invoke ReadConsole, inputHandle, addr inputString, sizeof inputString, addr consoleCount, NULL
    push offset inputString
    call ParseNewLine
    push offset inputString
    call atodw
    mov increment, eax

    ; Abrindo o arquivo para leitura
    invoke CreateFile, addr fileName, GENERIC_READ, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
    mov fileHandle, eax

    invoke ExitProcess, 0

ModifyPixel: ; 3 parâmetros (4 bytes cada) -> pixel db dup(3), cor dd, incremento dd
    push ebp
    mov ebp, esp
    sub esp, 
    
    mov 
    invoke ReadFile, fileHandle, addr pixelBuffer, 3, addr readCount, NULL

ParseNewLine:
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