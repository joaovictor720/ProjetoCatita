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
    prompt_fileName db "Digite o nome do imagem a ser usada (coloque .bmp ao final): ", 0
    prompt_color db "Escolha uma cor -> 0-Azul | 1-Verde | 2-Vermelho:", 0ah, 0
    prompt_increment db "Defina um incremento para a cor escolhida (de 0 a 255):", 0ah, 0
    prompt_newFileName db "Digite o nome do arquivo de saida (coloque .bmp ao final): ", 0
    prompt_ending db "Imagem modificada com sucesso!", 0ah, 0

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
    push offset fileName
    call ParseNewLine

    ; Lendo nome do arquivo de saída
    invoke StrLen, addr prompt_newFileName
    mov stringSize, eax
    invoke WriteConsole, outputHandle, addr prompt_newFileName, stringSize, addr consoleCount, NULL
    invoke ReadConsole, inputHandle, addr newFileName, sizeof newFileName, addr consoleCount, NULL
    push offset newFileName
    call ParseNewLine

    ; Lendo a cor escolhida
    invoke StrLen, addr prompt_color
    mov stringSize, eax
    invoke WriteConsole, outputHandle, addr prompt_color, stringSize, addr consoleCount, NULL
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

    ; Criando o novo arquivo para escrita
    invoke CreateFile, addr newFileName, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
    mov fileOutputHandle, eax

    invoke ReadFile, fileInputHandle, addr bmpHeader, sizeof bmpHeader, addr readCount, NULL
    invoke WriteFile, fileOutputHandle, addr bmpHeader, sizeof bmpHeader, addr writeCount, NULL

    readPixel:
        ; Lendo um pixel
        invoke ReadFile, fileInputHandle, addr pixelBuffer, sizeof pixelBuffer, addr readCount, NULL
        cmp readCount, 0 ; Verificando o final do arquivo
        je ending
        
        ; Chamando subrotina que modifica um pixel
        push increment
        push color
        push offset pixelBuffer
        call ModifyPixel

        ; Escrevendo o pixel modificado no novo arquivo
        invoke WriteFile, fileOutputHandle, addr pixelBuffer, sizeof pixelBuffer, addr writeCount, NULL
        jmp readPixel

    ending:
        ; Fechando o arquivo
        invoke CloseHandle, fileInputHandle
        invoke CloseHandle, fileOutputHandle

        ; Mensagem final
        invoke StrLen, addr prompt_ending
        mov stringSize, eax
        invoke WriteConsole, outputHandle, addr prompt_ending, stringSize, addr consoleCount, NULL

        invoke ExitProcess, 0

ModifyPixel: ; 3 parâmetros (4 bytes cada) -> pixel db dup(3), cor dd, incremento dd
    push ebp
    mov ebp, esp
    
    mov ebx, DWORD PTR [ebp+8] ; Pegando o endereço do array que é o pixel
    mov ecx, DWORD PTR [ebp+12] ; Pegando a cor
    mov edx, DWORD PTR [ebp+16] ; Pegando o incremento

    mov al, [ebx][ecx] ; Recuperando o valor da cor escolhida do pixel para ser incrementada
    add ax, dx ; Incrementando a cor localmente no processador
    cmp ax, 255
    jbe colorFixed ; Checando se houve overflow na soma de cor
    mov al, 255 ; Corrigindo cor, se a soma for maior que 255
    colorFixed:
        mov [ebx][ecx], al; Devolvendo o valor incrementado para o pixel

    mov esp, ebp
    pop ebp
    ret 12

ParseNewLine:
    push ebp
    mov ebp, esp

    mov esi, DWORD PTR [ebp+8] ; Armazenar apontador da string (parâmetro 1) em esi
    proximo: 
        mov al, [esi] ; Mover caractere atual para al 
        inc esi ; Apontar para o proximo caractere 
        cmp al, 13 ; Verificar se eh o caractere ASCII CR - FINALIZAR 
        jne  proximo 
        dec esi ; Apontar para caractere anterior 
        xor al, al ; ASCII 0 
        mov [esi], al ; Inserir ASCII 0 no lugar do ASCII CR

    mov esp, ebp
    pop ebp
    ret 4

end start