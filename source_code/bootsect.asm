%define BASE 0x100
%define KSIZE 50 ; definit nmbre secteur de 512o a charger

[BITS 16]
[ORG 0x0]

jmp start
%include "UTIL.INC"

start:

; initialisation secteur de boot 0x07C0
	mov ax, 0x7C0
	mov ds, ax
	mov es, ax
	mov ax, 0x8000
	mov ss, ax
	mov sp, 0xf000

; recuperation unite de boot
	mov [bootdrv], dl

; permet d afficher message en appelant fonction afficher
	mov si, msgDebut
	call afficher

; permet de charger le noyau
	xor ax, ax
	int 0x13

	push es
	mov ax, BASE
	mov es, ax
	mov bx, 0
	mov ah, 2
	mov al, KSIZE
	mov ch, 0
	mov cl, 2
	mov dh, 0
	mov dl, [bootdrv]
	int 0x13
	pop es

; initialisation du pointeur sur la gdt
	; calcul la taille de la gdt et stocke la valeur dans le premier champs de gdptr
	mov ax, gdtend
	mov bx, gdt
	sub ax, bx
	mov word [gdtptr], ax
	; calcul de l adresse lineaire de la gdt en se basant sur valeur du segments de donnee ds
	xor eax, eax
	xor ebx, ebx
	mov ax, ds
	mov ecx, eax
	shl ecx, 4
	mov bx, gdt
	add ecx, ebx
	mov dword [gdtptr+2], ecx

; preparation au passage en mode protege
	; affichage du passage en pmode
	mov si, msgPmode
	call afficher
	cli	; permet de couper, inhiber les interruptions
	lgdt [gdtptr]	; registre gdtr est chargé avec l instruction lgdt pour indiquer ou se trouve la gdr

; passage en mode protege en mettant le bit 0 du registre cr0 a 1
	mov eax, cr0
	or ax, 1
	mov cr0, eax

; il faut reinitialiser selecteur de segment de code et de donnees
jmp next
next:
	; pour segments de donnees
	mov ax, 0x10
	mov ds, ax
	mov fs, ax
	mov gs, ax
	mov es, ax
	; pour la pile
	mov ss, ax
	mov esp, 0x9F000
	; reinitialise le selecteur de code et execute le noyau
	jmp dword 0x8:0x1000


;---------------------------------------------------------------------

; declaration des utilitaires pour le chargement du noyau
bootdrv: db 0

; declaration des messages a afficher
msgDebut db "esau's kernel loading...", 13, 10, 0
msgPmode db "switching in pmode", 13, 10, 0

; initialisation des parametres de la gdt pour ne pas avoir de probleme lors du changement de mode
gdt:
	db 0, 0, 0, 0, 0, 0, 0, 0
gdt_cs:
	db 0xFF, 0xFF, 0x0, 0x0, 0x0, 10011011b, 11011111b, 0x0
gdt_ds:
	db 0xFF, 0xFF, 0x0, 0x0, 0x0, 10010011b, 11011111b, 0x0
gdtend:

; declaration et initialisation de la gdtptr
; gdtptdr est un pointeur sur une structure qui contient les informations à charger dans le registre gdtr
gdtptr:
	dw 0	; limite
	dd 0    ; base

;---------------------------------------------------------------------


;; Demande a nasm de remplir les bits de 0 jusqu a 510 bit
;; 0xAA55 correspond a la signature a la signature de secteur de boot reconnaissable par les bios
times 510-($-$$) db 144
dw 0xAA55
