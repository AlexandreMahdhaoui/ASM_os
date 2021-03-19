[BITS 32]
[ORG 0x1000]

jmp start
%include "IOSTREAM.INC"

start:

xor eax, eax
xor ebx, ebx
xor ecx, ecx
xor edx, edx

call clearscreen

mov ebx, [videoMap]
mov si, msg1
call printstring

mov si, msg2
call printstring

mov si, msg3
call printstring


end:
	jmp end

;--------------------------------------------------------------------

videoMap dd 0xB8000

msg1 db "Welcome in Esau's OS, I want to see if the return to the line works", 10, "This is second message", 10, 0
msg2 db "I want to check the scrolldown", 13, "scrolldown works if the 2nd msg is at the top", 10, 0
msg3 db "Scrolldown works, returns works", 10, 0
