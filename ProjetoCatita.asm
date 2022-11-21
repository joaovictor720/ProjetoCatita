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
    mov stringSize, eax
    invoke WriteConsole, outputHandle, addr prompt_arquivo, stringSize, addr consoleCount, NULL
    invoke ReadConsole, inputHandle, addr inputString, sizeof inputString, addr consoleCount, NULL
    push offset inputString
    call ParseNewLine
    mov eax, inputString
    mov fileName, eax

    ; Lendo a cor escolhida
    invoke StrLen, addr prompt_cor
    mov stringSize, eax
    invoke WriteConsole, outputHandle, addr prompt_cor, stringSize, addr consoleCount, NULL
    invoke ReadConsole, inputHandle, addr inputString, sizeof inputString, addr consoleCount, NULL
    push offset inputString
    call ParseNewLine
    push offset inputString
    call atodw
    mov color, eax

    ; Lendo o incremento escolhido para a cor
    invoke StrLen, addr prompt_increment
    mov stringSize, eax
    invoke WriteConsole, outputHandle, addr prompt_increment, stringSize, addr consoleCount, NULL
    invoke ReadConsole, inputHandle, addr inputString, sizeof inputString, addr consoleCount, NULL
    push offset inputString
    call ParseNewLine
    push offset inputString
    call atodw
    mov increment, eax

    ; Abrindo o arquivo original para leitura
    invoke CreateFile, addr fileName, GENERIC_READ, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
    mov fileInputHandle, eax

    ; Criando o novo arquivo de saída
    invoke CreateFile, addr newFileName, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
    mov fileOutputHandle, eax

    ; Copiando o cabeçalho do arquivo original para o novo
    invoke ReadFile, fileInputHandle, addr bmpHeader, sizeof bmpHeader, addr readCount, NULL
    invoke WriteFile, fileOutputHandle, addr bmpHeader, sizeof bmpHeader, addr writeCount, NULL

    readPixel:
        ; Lendo um pixel
        invoke ReadFile, fileInputHandle, addr pixelBuffer, sizeof pixelBuffer, addr readCount, NULL
        cmp readCount, 0 ; Verificando o final do arquivo
        je fim
        
        ; Chamando subrotina que modifica um pixel
        push increment
        push color
        push offset pixelBuffer
        call ModifyPixel

        ; Escrevendo o pixel modificado no novo arquivo
        invoke WriteFile, fileOutputHandle, addr pixelBuffer, sizeof pixelBuffer, addr writeCount, NULL
        jmp readPixel

    fim:

        invoke ExitProcess, 0

ModifyPixel: ; 3 parâmetros (4 bytes cada) -> pixel db dup(3), cor dd, incremento dd
    push ebp
    mov ebp, esp
    
    mov ebx, DWORD PTR [ebp+8] ; Pegando o endereço do array que é o pixel
    mov ecx, DWORD PTR [ebp+12] ; Pegando a cor
    mov edx, DWORD PTR [ebp+16] ; Pegando o incremento

    add ebx, ecx ; Ajustando o endereço do pixel pra acessar a cor certa
    add DWORD PTR[ebx], edx ; Incrementando lá na memória o valor da cor

    ;mov eax, [ebx][ecx] ; Pegando o valor da cor escolhida do pixel para ser incrementada
    ;add eax, edx ; Incrementando a cor
    ;mov [ebx][ecx], eax ; Devolvendo o valor incrementado para o pixel

    mov esp, ebp
    pop ebp
    ret 12

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