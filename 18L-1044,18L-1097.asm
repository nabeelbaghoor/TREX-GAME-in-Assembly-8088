[org 0x100]
;make all thos things mb ,and copy oxb800 permanently
;must pusha  popa
jmp start
printFlag:dw 1
line: db 0
column: db 0   
currentPlayerLine:db 10
currentPlayerCol:db 1
currentHurdle_1Line:db 10
currentHurdle_1Col:db 30
currentHurdle_2Line:db 10
currentHurdle_2Col:db 60
currentHurdle_3Line:db 10
currentHurdle_3Col:db 70
noOfLinesInHurdle1:dw 3
noOfColumnsInHurdle1:dw 5

noOfLinesInHurdle2:dw 3
noOfColumnsInHurdle2:dw 5

noOfLinesInHurdle3:dw 3
noOfColumnsInHurdle3:dw 5

playerFallFlag:db 0
playerFallCounter:db 0
byteOffset:dw 0
page_number: db 0
printInput: dw 0 		
delayTime:dw 100;*1000 inner
defaultDelayTime:dw 110;*1000 inner
score:dw 0
scoreMsg:db 'Score: ','$'
scoreMsgErase:db '           ','$'
firstColumn:times 26 dw '$';for now
firstColumnForHurdle:times 4 dw '$';for now
gameOver:db 0
isCollison:db 0	

jump_taken:db 0
jumpStartTime: dw 0;updates when jump starts
jumpDuration:dw 20;actual seconds mb
seconds: dw 0
oldkb: dd 0
oldTimerIsr: dd 0
oldisr: dd 0 ;
trexLogo:
db" _________  _______     ________  ____  ____",10  
db"|  _   _  ||_   __ \   |_   __  ||_  _||_  _|",10 
db"|_/ | | \_|  | |__) |    | |_ \_|  \ \  / /",10   
db"    | |      |  __ /     |  _| _    > `' <",10    
db"   _| |_    _| |  \ \_  _| |__/ | _/ /'`\ \_",10  
db"  |_____|  |____| |___||________||____||____|","$" 
nullLogo:  
db" ____  _____  _____  _____  _____     _____",10     
db"|_   \|_   _||_   _||_   _||_   _|   |_   _|",10    
db"  |   \ | |    | |    | |    | |       | |",10      
db"  | |\ \| |    | '    ' |    | |   _   | |   _",10  
db" _| |_\   |_    \ \__/ /    _| |__/ | _| |__/ |",10 
db"|_____|\____|    `.__.'    |________||________|","$" 
studiosLogo:                                             
db"  ______   _________  _____  _____  ______   _____   ___     ______",10   
db".' ____ \ |  _   _  ||_   _||_   _||_   _ `.|_   _|.'   `. .' ____ \",10  
db"| (___ \_||_/ | | \_|  | |    | |    | | `. \ | | /  .-.  \| (___ \_|",10 
db" _.____`.     | |      | '    ' |    | |  | | | | | |   | | _.____`.",10  
db"| \____) |   _| |_      \ \__/ /    _| |_.' /_| |_\  `-'  /| \____) |",10 
db" \______.'  |_____|      `.__.'    |______.'|_____|`.___.'  \______.'","$" 
;change it
game: 
db"  __ _  __ _ _ __ ___   ___",10 
db" / _` |/ _` | '_ ` _ \ / _ \",10
db"| (_| | (_| | | | | | |  __/",10 
db" \__, |\__,_|_| |_| |_|\___|",10
db"  __/ |",10                     
db" |___/","$"                
over:
db"  _____   _____ _ __",10 
db" / _ \ \ / / _ \ '__|",10
db"| (_) \ V /  __/ |",10   
db" \___/ \_/ \___|_|","$"      
                                                               
; trex:
; db"(. .)",10
; db" -|-",10
; db" / \","$"
trex:;changed
db"(. .)",10
db" -|-",10
db" / \","$"
antitrex:;change these
db"     ",10
db"    ",10
db"    ","$" 

hurdle1:
db"[[[  ",10
db"[[[[[",10
db"[[[[[","$"
hurdle2:
db"  [[[",10
db"[[[[[",10
db" [[[[","$"
hurdle3:
db"  [[ ",10
db" {[[ ",10
db"[[[[ ","$"
antiHurdle1:
db"     ",10
db"     ",10
db"     ","$"
antiHurdle2:
db"     ",10
db"     ",10
db"     ","$"
antiHurdle3:
db"     ",10
db"     ",10
db"     ","$"
strlen: 
push bp
mov bp,sp
push es
push cx
push di
les di, [bp+4] ; point es:di to string
mov cx, 0xffff ; load maximum number in cx
xor al, al ; load a zero in al
repne scasb ; find zero in the string
mov ax, 0xffff ; load maximum number in ax
sub ax, cx ; find change in cx
dec ax ; exclude null from length
pop di
pop cx
pop es
pop bp
ret 4

; subroutine to print a number at top left of screen
; takes the number to be printed as its parameter
printnum: 
push bp
mov bp, sp
push es
push ax
push bx
push cx
push dx
push di
mov ax, 0xb800
mov es, ax ; point es to video base
mov ax, [bp+4] ; load number in ax
mov bx, 10 ; use base 10 for division
mov cx, 0 ; initialize count of digits
nextdigit: mov dx, 0 ; zero upper half of dividend
div bx ; divide by 10
add dl, 0x30 ; convert digit into ascii value
push dx ; save ascii value on stack
inc cx ; increment count of values
cmp ax, 0 ; is the quotient zero
jnz nextdigit ; if no divide it again
mov di, [bp+6] ; point di to 70th column
nextpos: pop dx ; remove a digit from the stack
mov dh, 0x07 ; use normal attribute
mov [es:di], dx ; print char on screen
add di, 2 ; move to next screen location
loop nextpos ; repeat for all digits on stack
pop di
pop dx
pop cx
pop bx
pop ax
pop es
pop bp
ret 4

; subroutine to print a string
; takes the x position, y position, attribute, and address of a null
; terminated string as parameters
printstr: 
push bp
mov bp, sp
push es
push ax
push cx
push si
push di
push ds ; push segment of string
mov ax, [bp+4]
push ax ; push offset of string
call strlen ; calculate string length
cmp ax, 0 ; is the string empty
jz exit2 ; no printing if string is empty
mov cx, ax ; save length in cx
mov ax, 0xb800
mov es, ax ; point es to video base
mov al, 80 ; load al with columns per row
mul byte [bp+8] ; multiply with y position
add ax, [bp+10] ; add x position
shl ax, 1 ; turn into byte offset
mov di,ax ; point di to required location
mov si, [bp+4] ; point si to string
mov ah, [bp+6] ; load attribute in ah
cld ; auto increment mode
nextchar: lodsb ; load next char in al
stosw ; print char/attribute pair
loop nextchar ; repeat for the whole string
exit2: pop di
pop si
pop cx
pop ax
pop es
pop bp
ret 8

clrscr: 
	 push es
	 push ax
	 push cx
	 push di
	 mov ax, 0xb800
	 mov es, ax ; point es to video base
	 xor di, di ; point di to top left column
	 mov ax, 0x0720 ; space char in normal attribute
	 mov cx, 2000 ; number of screen locations
	 cld ; auto increment mode
	 rep stosw ; clear the whole screen
	 pop di 
	 pop cx
	 pop ax
	 pop es
	 ret 
	 
background:

push ax
push cx
push di
push es

push 0xb800
pop es 
mov di, 2080
mov ah,07h
mov al,'-'
mov cx ,80
rep stosw
pop es
pop di
pop cx
pop ax

ret
printScreen2:    ;print digit in SI until find "$"  
	push ax
	push cx
	push dx
	push si
	push ds
	
	mov si,word [printInput]
	call    set_cursor
	print_main2:     
	mov dh, 0                  
	mov dl,[ds:si]
	cmp dx, "$"
	je end_print2
	cmp dx, 10
	je new_line2             
	;link
	;http://spike.scu.edu.au/~barry/interrupts.html#ah02
	;9h is with breaks
	mov dh,0
	cmp dl,' '
	je skipxdb
	mov dl,0xdb
	skipxdb:
	mov ah,06h
	int 21h  

	inc si
	jmp print_main2                    

	new_line2:
	mov cl,1
	add [line],cl
	call set_cursor 
	inc si 
	jmp print_main2

	end_print2:
	pop ds
	pop si
	pop dx
	pop cx
	pop ax
	ret  
printScreen:    ;print digit in SI until find "$"  
	push ax
	push cx
	push dx
	push si
	push ds
	;call clear_screen
	
	mov si,word [printInput]
	call    set_cursor
	print_main:     
	mov dh, 0                  
	mov dl,[ds:si]
	cmp dx, "$"
	je end_print
	cmp dx, 10
	je new_line              
	;link
	;http://spike.scu.edu.au/~barry/interrupts.html#ah02
	;9h is with breaks
	mov ah,06h
	int 21h  

	inc si
	jmp print_main                    

	new_line:
	mov cl,1
	add [line],cl
	call set_cursor 
	inc si 
	jmp print_main

	end_print:
	pop ds
	pop si
	pop dx
	pop cx
	pop ax
	ret  
	
set_cursor:  
	push ax
	push bx
	push dx
	;BH = Page Number, DH = Row, DL = Column          
    mov     ah, 2
    mov     bh, [page_number]
    mov     dh, [line]
    mov     dl, [column]
    int     10h
	pop dx
	pop bx
	pop ax
	ret      
    
clear_screen:   ; get and set video mode
	push ax
	mov     ah, 0fh
    int     10h    
    mov     ah, 0
    int     10h
	pop ax
	ret	
	
print10h:
	push ax
	push bx
	push cx
	push dx
	push cs
	push es
	push bp
	
	;push word [print10hInput]
	;call strlen
	mov bp,dx;for now
	mov cx,1;for now
	mov ah,13h   
	mov al,1
    mov bh, [page_number]
    mov bl,1
	mov dh, [line];line is row
    mov dl, [column]
	push cs
	pop es
	int 10h
	
	push bp
	push es
	push cs
	push dx
	push cx
	push bx
	push ax
	ret      
delay:
push cx
mov cx,word [delayTime];word [delayTime]???
Dl1:
push cx
mov cx,1000
Dl2:
loop Dl2
pop cx
loop Dl1

pop cx
ret
getByteOffset:
push ax
push dx
mov al, 80 ; load al with columns per row
mul byte [line] ; multiply with y position
xor dh,dh
mov dl,byte [column]
add ax,dx ; add x position
shl ax, 1 ; turn into byte offset
mov word [byteOffset],ax
pop dx
pop ax
ret

moveHurdle1ByOneWord:;hurdle should be arleady present
push ax
cmp byte[currentHurdle_1Col],0;mb
je moveCornerCase
cmp byte[currentHurdle_1Col],79;mb
je moveCornerCase
cmp byte[currentHurdle_1Col],78;mb
je moveCornerCase
cmp byte[currentHurdle_1Col],77;mb
je moveCornerCase
cmp byte[currentHurdle_1Col],76;mb
je moveCornerCase
cmp byte[currentHurdle_1Col],75;mb
je moveCornerCase

;erase at old location
mov word [printInput],antiHurdle1
mov al,byte [currentHurdle_1Line]
mov byte [line],al
mov al,byte [currentHurdle_1Col]
mov byte [column],al
call printScreen2

;print at new location
dec byte [currentHurdle_1Col]

mov word [printInput],hurdle1
mov al,byte [currentHurdle_1Line]
mov byte [line],al
mov al,byte [currentHurdle_1Col]
mov byte [column],al
call printScreen2

jmp skipCornerCase

moveCornerCase:


mov al,byte [currentHurdle_1Line]
mov byte [line],al
mov al,byte [currentHurdle_1Col]
mov byte [column],al

call moveScreenByOneWord1

cmp byte[currentHurdle_1Col],0;mb
je skipDec
dec byte [currentHurdle_1Col]
jmp skipDec2

skipDec:
mov byte [currentHurdle_1Col],79;mb
skipDec2:

skipCornerCase:
pop ax
ret
lines:dw 3
;new imp
moveScreenByOneWord1:
push ax
push bx
push cx
push dx
push si
push di
push ds
push es

mov dx,ds

;to copy first column in "firstColumn"
push dx
pop es
push 0xb800
pop ds

mov si,1600;0
mov bx,1600;0
mov di,firstColumnForHurdle
mov cx,3;25
;we are using bx to set "si" manually
l1:
mov si,bx
lodsw
add bx,160
stosw
loop l1
;to movs all except column#1 by 1 word
push 0xb800
pop ds
push 0xb800
pop es
mov di,1600;0
mov si,1602;
mov cx,3;25
l2:
push di
push cx
mov cx,5;79
rep movsw
pop cx
pop di

add di,160
mov si,di
add si,2
loop l2
;to past stored "firstColumn" to Last column
mov ds,dx
push 0xb800
pop es
mov si,firstColumnForHurdle
mov di,1758;158;mb
mov bx,1758;158
mov cx,3;25
;we are using bx to set "si" manually
l3:
lodsw
mov di,bx
stosw
add bx,160
loop l3

pop es
pop ds
pop di
pop si
pop dx
pop cx
pop bx
pop ax
ret


moveHurdle2ByOneWord:;hurdle should be arleady present
push ax
;for now
cmp byte[currentHurdle_2Col],0;mb
je moveCornerCase2
cmp byte[currentHurdle_2Col],79;mb
je moveCornerCase2
cmp byte[currentHurdle_2Col],78;mb
je moveCornerCase2
cmp byte[currentHurdle_2Col],77;mb
je moveCornerCase2
cmp byte[currentHurdle_2Col],76;mb
je moveCornerCase2
cmp byte[currentHurdle_2Col],75;mb
je moveCornerCase2

;erase at old location
mov word [printInput],antiHurdle2
mov al,byte [currentHurdle_2Line]
mov byte [line],al
mov al,byte [currentHurdle_2Col]
mov byte [column],al
call printScreen2

;print at new location
dec byte [currentHurdle_2Col]

mov word [printInput],hurdle2
mov al,byte [currentHurdle_2Line]
mov byte [line],al
mov al,byte [currentHurdle_2Col]
mov byte [column],al
call printScreen2
jmp skipCornerCase2

moveCornerCase2:

mov al,byte [currentHurdle_2Line]
mov byte [line],al
mov al,byte [currentHurdle_2Col]
mov byte [column],al

call moveScreenByOneWord2

cmp byte[currentHurdle_2Col],0;mb
je skipDec_2
dec byte [currentHurdle_2Col]
jmp skipDec2_2

skipDec_2:
mov byte [currentHurdle_2Col],79;mb
skipDec2_2:

skipCornerCase2:
pop ax
ret

moveScreenByOneWord2:
push ax
push bx
push cx
push dx
push si
push di
push ds
push es

mov dx,ds

;to copy first column in "firstColumn"
push dx
pop es
push 0xb800
pop ds

mov si,1600;0
mov bx,1600;0
mov di,firstColumnForHurdle
mov cx,3;25
;we are using bx to set "si" manually
l1_2:
mov si,bx
lodsw
add bx,160
stosw
loop l1_2
;to movs all except column#1 by 1 word
push 0xb800
pop ds
push 0xb800
pop es
mov di,1600;0
mov si,1602;
mov cx,3;25
l2_2:
push di
push cx
mov cx,5;79
rep movsw
pop cx
pop di

add di,160
mov si,di
add si,2
loop l2_2
;to past stored "firstColumn" to Last column
mov ds,dx
push 0xb800
pop es
mov si,firstColumnForHurdle
mov di,1758;158;mb
mov bx,1758;158
mov cx,3;25
;we are using bx to set "si" manually
l3_2:
lodsw
mov di,bx
stosw
add bx,160
loop l3_2

pop es
pop ds
pop di
pop si
pop dx
pop cx
pop bx
pop ax
ret

moveHurdle3ByOneWord:;hurdle should be arleady present
push ax
cmp byte[currentHurdle_3Col],0;mb
je moveCornerCase_3
cmp byte[currentHurdle_3Col],79;mb
je moveCornerCase_3
cmp byte[currentHurdle_3Col],78;mb
je moveCornerCase_3
cmp byte[currentHurdle_3Col],77;mb
je moveCornerCase_3
cmp byte[currentHurdle_3Col],76;mb
je moveCornerCase_3
cmp byte[currentHurdle_3Col],75;mb
je moveCornerCase_3

;erase at old location
mov word [printInput],antiHurdle3
mov al,byte [currentHurdle_3Line]
mov byte [line],al
mov al,byte [currentHurdle_3Col]
mov byte [column],al
call printScreen2

;print at new location
dec byte [currentHurdle_3Col]

mov word [printInput],hurdle3
mov al,byte [currentHurdle_3Line]
mov byte [line],al
mov al,byte [currentHurdle_3Col]
mov byte [column],al
call printScreen2

jmp skipCornerCase_3

moveCornerCase_3:


mov al,byte [currentHurdle_3Line]
mov byte [line],al
mov al,byte [currentHurdle_3Col]
mov byte [column],al

call moveScreenByOneWord3

cmp byte[currentHurdle_3Col],0;mb
je skipDec_3
dec byte [currentHurdle_3Col]
jmp skipDec2_3

skipDec_3:
mov byte [currentHurdle_3Col],79;mb
skipDec2_3:

skipCornerCase_3:
pop ax
ret

;new imp
moveScreenByOneWord3:
push ax
push bx
push cx
push dx
push si
push di
push ds
push es

mov dx,ds

;to copy first column in "firstColumn"
push dx
pop es
push 0xb800
pop ds

mov si,1600;0
mov bx,1600;0
mov di,firstColumnForHurdle
mov cx,3;25
;we are using bx to set "si" manually
l1_3:
mov si,bx
lodsw
add bx,160
stosw
loop l1_3
;to movs all except column#1 by 1 word
push 0xb800
pop ds
push 0xb800
pop es
mov di,1600;0
mov si,1602;
mov cx,3;25
l2_3:
push di
push cx
mov cx,5;79
rep movsw
pop cx
pop di

add di,160
mov si,di
add si,2
loop l2_3
;to past stored "firstColumn" to Last column
mov ds,dx
push 0xb800
pop es
mov si,firstColumnForHurdle
mov di,1758;158;mb
mov bx,1758;158
mov cx,3;25
;we are using bx to set "si" manually
l3_3:
lodsw
mov di,bx
stosw
add bx,160
loop l3_3

pop es
pop ds
pop di
pop si
pop dx
pop cx
pop bx
pop ax
ret
printScoreGameOver:
	;to print score String
	push ax
	push bx
	push dx
	push ds
	mov byte [line],4;wow
	mov byte [column],64
	call set_cursor
	mov dx,scoreMsg
	mov ah,9h
	int 21h
	;to print score
	inc word [ds:score] ; increment tick count
	push 780
	push word [ds:score]
	call printnum ; print tick count
	pop ds
	pop dx
	pop bx
	pop ax
	ret	
printScore:
	;to print score String
	push ax
	push bx
	push dx
	push ds
	mov byte [line],4;wow
	mov byte [column],64
	call set_cursor
	mov dx,scoreMsg
	mov ah,9h
	int 21h
	;to print score
	inc word [ds:score] ; increment tick count
	push 780
	push word [ds:score]
	call printnum ; print tick count
	pop ds
	pop dx
	pop bx
	pop ax
	ret
	
eraseScore:;changed 
	push ax
	push dx
	;to erase score string+score
	mov byte [line],4;wow
	mov byte [column],64
	call set_cursor
	mov dx,scoreMsgErase
	mov ah,9h
	int 21h
	
	pop dx
	pop ax
	ret
	
jump_up:
	push ax
	push bx
	push cx
	push dx
	mov DL,5;19;right col
	mov DH,12;12;12;lower row
	mov CL,1;14;left col
	mov CH, 5;10;5;upper row
	mov  ax, 0605h  ; AL == 10, AH == 06h
	mov  bh, 0x0f;0Eh    ; yellow foreground, black background
	int  10h
	
	;set current line/column
	mov byte[currentPlayerLine],5
	mov byte[currentPlayerCol],1;remains same
	pop dx
	pop cx
	pop bx
	pop ax
	ret	
	
fall_down:
	push ax
	push bx
	push cx
	push dx
	mov DL,5;19;right col
	mov DH,12;12;lower row
	mov CL,1;14;left col
	mov CH, 5;10;5;upper row
	mov  ax, 0705h  ; AL == 10, AH == 06h
	mov  bh, 0x0f;0Eh    ; yellow foreground, black background
	int  10h
	mov byte[currentPlayerLine],10
	mov byte[currentPlayerCol],1;remains same
	pop dx
	pop cx
	pop bx
	pop ax
	ret	
	
printDragon:;fixes row/col to current
;to print dino2
	push ax
	mov word [printInput],trex;should be ptr
	mov al,byte [currentPlayerLine]
	mov byte [line],al
	mov al,byte [currentPlayerCol]
	mov byte [column],al
	call printScreen
	pop ax
	ret
printantiDragon:;fixes row/col to current
;to print dino2
	push ax
	mov word [printInput],antitrex;should be ptr
	mov al,byte [currentPlayerLine]
	mov byte [line],al
	mov al,byte [currentPlayerCol]
	mov byte [column],al
	call printScreen
	pop ax
	ret
	
;jumper was here

kbisr:;mb only
push ax
push dx
in al, 0x60 ; read a char from keyboard port

cmp al,34;p:: mb 
jne skipG
mov word[isCollison],1
skipG:

cmp al,1
jne skipGameOver
mov byte[gameOver],1
skipGameOver:

cmp word [printFlag],0
jne skipUnPause
cmp al,25;p:: mb 
jne skipUnPause
mov word [printFlag],1

jmp skipPause
skipUnPause:

cmp word [printFlag],0
je skipKbisr

cmp al,25;p:: mb 
jne skipPause
mov word[printFlag],0
skipPause:

cmp byte [jump_taken],1
je skipJmp

cmp al, 57
jne skipJmp
mov dx,word [seconds]
mov word [jumpStartTime],dx
mov byte[jump_taken],1
call jump_up
skipJmp:

skipKbisr:
pop dx
pop ax
jmp far [cs:oldkb]
iret

; timer interrupt service routine
timer: 
push ax
push dx
cmp word [ds:printFlag], 0 ; is the printing flag set:WAS CS
je skipall ; no, leave the ISR
	inc word [ds:seconds] ; increment tick count

	cmp byte [jump_taken],0
	je skipJump_taken
	
	mov dx,[ds:seconds]
	sub dx,word [jumpStartTime]
	cmp dx,word [jumpDuration]
	jne skipFall_down
	mov byte[jump_taken],0
	call fall_down
	skipFall_down:
	
	skipJump_taken:
	
	call printScore	
	call delay;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	call moveHurdle1ByOneWord
	call moveHurdle2ByOneWord
	;call moveHurdle3ByOneWord
	
	;call checkUpperCollison
	call checkCollison
	cmp byte [isCollison],1
	jne skipIsCollsion
	mov word[printFlag],0
	call printGameover
	skipIsCollsion:
skipall:
mov al, 0x20
out 0x20, al ; send EOI to PIC
pop dx
pop ax
iret ; return from interrupt
checkCollison:
pusha
push 0xb800

pop es
;mov ah,03
mov al,0xdb
mov di,1920
scasb
jne nextcollision1
cmp byte [jump_taken],1
je nextcollision1
jmp collisionn
nextcollision1:
mov di,1932
scasb
jne nextcollision
cmp byte [jump_taken],1
je nextcollision

jmp collisionn
nextcollision:


mov di,1774
scasb
jne upright
cmp byte [jump_taken],1
je  upright

jmp collisionn
upright:
mov di,1614
scasb
jne nocollision
cmp byte [jump_taken],1
je nocollision

jmp collisionn



scasb

nocollision:
cmp byte [jump_taken],0
jne no
mov di, 1610
mov dl,')'
cmp dl,[es:di]
jne collisionn
cmp byte [jump_taken],0
jne no
mov di, 1608
mov dl,'.'
cmp dl,[es:di]
jne collisionn
mov di, 1606
mov dl,' '
cmp dl,[es:di]
mov di, 1604
mov dl,'.'
cmp dl,[es:di]
jne collisionn
mov di, 1602
mov dl,'('
cmp dl,[es:di]
jne collisionn

jne collisionn


jmp no
collisionn:
mov byte[isCollison],1
no:
popa
ret
printGameover:
push ax
;call eraseScore
mov byte[line],3
mov byte[column],13
mov word[printInput],game

call printScreen
mov byte[line],3
mov byte[column],43
mov word[printInput],over
call printScreen

mov ax,0
int 16h

pop ax
ret

printHurdles:
mov word [printInput],hurdle1
mov al,byte [currentHurdle_1Line]
mov byte [line],al
mov al,byte [currentHurdle_1Col]
mov byte [column],al
call printScreen2

mov word [printInput],hurdle2
mov al,byte [currentHurdle_2Line]
mov byte [line],al
mov al,byte [currentHurdle_2Col]
mov byte [column],al
call printScreen2

; mov word [printInput],hurdle3
; mov al,byte [currentHurdle_3Line]
; mov byte [line],al
; mov al,byte [currentHurdle_3Col]
; mov byte [column],al
; call printScreen2
ret
menu:
;use it for menu
; INT 10h / AH = 03h - get cursor position and size.
; input:
; BH = page number.
; return:
; DH = row.
; DL = column.
; CH = cursor start line.
; CL = cursor bottom line.
ret
subMenu:

ret
printStartScreen:
push ax
call clrscr
mov byte[line],4
mov byte[column],6
mov word[printInput],nullLogo

call printScreen
mov byte[line],11
mov byte[column],6
mov word[printInput],studiosLogo
call printScreen
mov word[delayTime],5000
call delay
call clrscr
mov byte[line],7
mov byte[column],15
mov word[printInput],trexLogo
call printScreen
mov word[delayTime],5000
call delay

mov ax,word[defaultDelayTime]
mov word[delayTime],ax

pop ax
ret


setSettings:
push ax
push cx
;hide cursor must
mov cx,0xffff;for now 
mov ah, 1
int 10h
;to remove mouse cursor
mov ax, 2
int 33h
pop cx
pop ax
ret
start: ;pagenumber label not applied to whole code well

call setSettings
call printStartScreen
call clrscr
call background
call printDragon
call printHurdles

xor ax, ax
mov es, ax ; point es to IVT base
;save old 9h
mov ax, [es:9*4]
mov [oldkb], ax ; save offset of old routine
mov ax, [es:9*4+2]
mov [oldkb+2], ax ; save segment of old routine
;save old 8h
mov ax, [es:8*4]
mov [oldTimerIsr], ax ; save offset of old routine
mov ax, [es:8*4+2]
mov [oldTimerIsr+2], ax ; save segment of old routine
;hook 9h and 8h
cli ; disable interrupts
mov word [es:9*4], kbisr ; store offset at n*4
mov [es:9*4+2], cs ; store segment at n*4+2
mov word [es:8*4], timer ; store offset at n*4
mov [es:8*4+2], cs ; store segment at n*4+
sti ; enable interrupts
;jmp endPro
;p for pause
driver:

cmp byte [gameOver],1
jne driver

mov byte[line],0
mov byte[column],0
call set_cursor
call clrscr
xor ax, ax
mov es, ax ; point es to IVT base
;for now

cli

;unhook 9h
mov ax, [oldkb]
mov [es:9*4], ax ; save offset of old routine
mov ax,[oldkb+2] 
mov [es:9*4+2], ax ; save segment of old routine
;unhook 8h
mov ax,[oldTimerIsr] 
mov [es:8*4], ax ; save offset of old routine
mov ax,[oldTimerIsr+2] 
mov [es:8*4+2], ax ; save segment of old routine
sti

endPro: 
mov ax,0x4c00
int 0x21