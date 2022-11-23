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
    ; fileName db 50 dup(?)
    ; newFileName db 50 dup(?)
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
    DEBUG_MSG db "em ModifyPixel", 0ah, 0
    prompt_fileName db "Digite o nome do imagem a ser usada (coloque .bmp ao final): ", 0
    prompt_color db "Escolha uma cor -> 0-Azul | 1-Verde | 2-Vermelho:", 0ah, 0
    prompt_increment db "Defina um incremento para a cor escolhida (de 0 a 255):", 0ah, 0
    prompt_newFileName db "Digite o nome do arquivo de saida (coloque .bmp ao final): ", 0
    prompt_ending db "Imagem modificada com sucesso!", 0ah, 0

    fileName db "catita.bmp", 0
    newFileName db "catita2.bmp", 0

.code
start:

    printf(addr fileName)
    printf(addr newFileName)

    printf("Indo abrir o arquivo\n")

    ; Abrindo o arquivo original para leitura
    invoke CreateFile, addr fileName, GENERIC_READ, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
    mov fileInputHandle, eax

    printf("Indo criar o arquivo\n")

    invoke CreateFile, addr newFileName, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
    mov fileOutputHandle, eax

    printf("Depois de abrir o arquivo")

    invoke ReadFile, fileInputHandle, addr bmpHeader, sizeof bmpHeader, addr readCount, NULL
    invoke WriteFile, fileOutputHandle, addr bmpHeader, sizeof bmpHeader, addr writeCount, NULL

    invoke CloseHandle, fileInputHandle

end start