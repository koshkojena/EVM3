.model tiny
.data
    BUFFER_SIZE EQU 200        ; ???????????? ?????? ??????
    buf db BUFFER_SIZE dup(0)  ; ????? ??? ????? ??????
    prompt db 'Enter a string (max. 200 characters): $'
    outputMsg db 0Dh, 0Ah, 'Result: $'
    finishMsg db 0Dh, 0Ah, 'The input is completed.$'
    errOverflow db 0Dh, 0Ah, 'Error: Buffer overflow.$'
    strLen db 0                ; ????? ??????

.code
start:
    ; ????????????? ???????? ??????
    mov ax, @data
    mov ds, ax

    ; ????? ???????
    call printPrompt          ; ????? ???????????
    call readInput            ; ?????? ??????
    call sortString           ; ?????????? ??????
    call displayResult        ; ????? ??????????

    ; ?????????? ?????????
    call terminate

; ------------------ ??????? ------------------

; ????? ???????????
printPrompt:
    mov dx, offset prompt
    mov ah, 09h
    int 21h
    ret

; ?????? ?????
readInput:
    lea di, buf + 2            ; ????????? ?? ?????? ??????
    mov byte ptr [buf], BUFFER_SIZE ; ?????? ????. ??????? ? ?????? ??????
    mov byte ptr [strLen], 0   ; ????????? ????? ??????

inputLoop:
    mov ah, 01h
    int 21h                    ; ?????????? ???????
    cmp al, 0Dh                ; ???????? ?? Enter
    je inputDone               ; ???? Enter, ????????? ????
    cmp byte ptr [strLen], 199 ; ???????? ?? ????????????
    ja handleOverflow          ; ???? ????????????, ????????? ??????

    mov [di], al               ; ?????????? ???????
    inc di
    inc byte ptr [strLen]
    jmp inputLoop              ; ?????? ??????

inputDone:
    mov byte ptr [di], '$'     ; ?????????? ??????
    ret

; ?????????? ??????
sortString:
    lea si, buf + 2            ; ????????? ?? ??????
    mov cl, [strLen]           ; ????? ??????

sortOuterLoop:
    dec cl
    jz sortComplete            ; ???? ????? 0, ????????? ??????????
    mov di, si
    mov bl, cl

sortInnerLoop:
    mov al, [di]
    mov ah, [di + 1]
    cmp al, ah
    jbe skipSwap
    xchg al, ah
    mov [di], al
    mov [di + 1], ah

skipSwap:
    inc di
    dec bl
    jnz sortInnerLoop          ; ??????????? ??????????? ?????
    jmp sortOuterLoop          ; ??????? ?? ??????? ????

sortComplete:
    lea si, buf + 2
    mov al, [strLen]
    xor ah, ah
    add si, ax
    mov byte ptr [si], '$'
    ret

; ????? ??????????
displayResult:
    mov dx, offset outputMsg
    mov ah, 09h
    int 21h

    lea dx, buf + 2
    mov ah, 09h
    int 21h

    mov dx, offset finishMsg
    mov ah, 09h
    int 21h
    ret

; ????????? ????????????
handleOverflow:
    mov dx, offset errOverflow
    mov ah, 09h
    int 21h
    call terminate

; ?????????? ?????????
terminate:
    mov ax, 4C00h
    int 21h

end start