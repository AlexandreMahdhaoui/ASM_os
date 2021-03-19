afficher:
    push ax
    push bx
.debut:
        lodsb
        cmp al,0
        jz .fin
        mov ah, 0x0E
        mov bx, 0x07
        int 0x10
        jmp .debut

.fin:
        pop bx
        pop ax
        ret

