;Code d output string fonction d affichage d une chaine de caractere en blanc sur noir
;bit impaire du mappage video correspondra a la couleur ici 0x7 sera adopter

;---------------------------------------------------------------------
clearscreen:
	push ax
	mov ebx, 0xB8000 ;réinitialisation de la memoire video
.clear:
	cmp ebx, 0xB8FA0 ;compare position de ebx par rapport à la limite de la memoire video
	jz .end
	mov word [ebx], 0
	add ebx, 2
	jmp .clear
.end:
	pop ax
	xor cl, cl	; on remet compteur de colonne à 0
	xor dl, dl	; on remet compteur de ligne à 0
	ret

;---------------------------------------------------------------------
printstring:

.print:
	cld		;pour remettre un flag à 0 et que lodsb fasse un inc de 1byte sur al
	lodsb 		;on met le byte qui est pointer par si dans al
	cmp al, 13	; si al=13 alors -> scroll down
	jz .initscrolldown
	cmp al, 10	;compare al à 10 pour notification de retour à la ligne
	jz .returnlign
	cmp al, 0 	;on compare al a 0 car 0 est le dernier byte de la chaine de caractere pointer par si
	jz .end		;si al = 0 alors on jump vers end
	mov byte [ebx], al
	add ebx, 1
	mov byte [ebx], 0x7
	add ebx, 1
	inc cl		;cl est le compteur de colonne, on l'incrémente de 1 pour chaque caractère imprimé
	cmp cl, 80	;on compare cx à 80 pour savoir si on a rempli 1 colonne
	je .ligncount
	jmp .print

.returnlign:
	xor eax, eax	
	mov al, cl	; on donne à al la valeur de cl
	add ax, ax	; on multiplie nombre de colonne par 2
	sub ebx, eax	; on retranche cl à ebx grace à eax
	add ebx, 160	; puis saut de 80*16 soit 1 ligne
	xor cl, cl	; on remet cl à zero vu qu'on a fait un retour a la ligne
	inc dl
	jmp .ligncheck

.ligncount:
	xor cl, cl	;on remet cl à 0
	inc dl		;on incrémente dl pour dire qu'on vient de passer à une ligne autre ligne
	jmp .ligncheck

.ligncheck:
        cmp dl, 24
        je .initscrolldown
        jmp .print

.initscrolldown:
	dec dl
	push ebx
	mov ebx, 0xB8000	; on retourne à la deuxième ligne
	jmp .scrolldown
	

.scrolldown:
	xor al, al
	cmp ebx, 0xB8F00
	je .endscrolldown
	add ebx, 160
	mov al, byte [ebx]	; on donne valeur de byte [ebx] à al
	sub ebx, 160		; on remnte ebx d'une ligne
	mov byte [ebx], al	; et on copie valeur al dans ebx
	add ebx, 1
	mov byte [ebx], 0x7
	add ebx, 1
	jmp .scrolldown

.endscrolldown:
	pop ebx
	sub ebx, 160
	mov al, cl      ; on donne à al la valeur de cl
        add ax, ax      ; on multiplie nombre de colonne par 2
        sub ebx, eax    ; on retranche cl à ebx grace à eax
        add ebx, 160    ; puis saut de 80*16 soit 1 ligne
        xor cl, cl      ; on remet cl à zero vu qu'on a fait un retour a la ligne
	jmp .print
	

.end:
	ret
