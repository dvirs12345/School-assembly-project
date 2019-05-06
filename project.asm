IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
; Your variables here
; --------------------------
paddle1y dw 75
bally dw 99
ballx dw 159
ballSpeed dw 3
ballSpeedX dw -3
scorecount1 db 30h
scorecount2 db 30h
youWin db 'You win$'
youLose db 'you lose$'
randomAddition dw 0
welcome db 'Welcome To Pong$'
press db 'Press any key to exit$'
yourscore db 'the cycles you lasted:$'
outof db '/900$'
hunds db 30h
tens db 30h
digits db 30h
CODESEG
; פעולה המציירת את הנקודה במקום הרצוי
proc drawPixel
	push bp
	mov bp,sp
	push ax
	push bx
	push dx
	color EQU [bp+8]
    x EQU [bp+6]
    y EQU [bp+4]
	mov ax,y;תחילת נוסחת הגרפיקה
	dec ax
	mov bx,320
	mul bx
	add ax,x
	dec ax;סיום הנוסחא
	mov di,ax
	mov dx,color
	mov [es:di],dl;ציור הנקודה
	pop dx
	pop bx
	pop ax
	pop bp
	ret 6
endp drawPixel



; פעולה שמכינה את המסך לציור
proc setScreen
	mov ax,13h
	int 10h;העברה למצב ציור
	mov ax,0A000h;העברה של המסך למקום הרצוי בes
	mov es,ax
	ret
endp setScreen


proc gotext;פעולה שחוזרת למוד טקסט
	mov ax, 3h
	int 10h
ret
endp gotext


proc drawhorizonal;פעולה שמקבלת אורך קו צבע ומקום והיא מציירת קו אופי
	push bp 
	mov bp,sp
	mov si,x
	mov ax,y
	linelength EQU [bp+10]
	color EQU [bp+8]
	x EQU [bp+6]
	y EQU [bp+4]
	mov cx,linelength
	; לולאה שצובעת את המקום הרצוי כמות הפעמים או אורך שניתן
	proceed:
		push color
		push si
		push ax
		call drawPixel
		inc si
	loop proceed
	pop bp
ret 8
endp drawhorizonal



proc drawvertical;פעולה שמקבלת אורך קו צבעו ומיקומו ומציירת קו אנכי
	push bp 
	mov bp,sp
	linelength EQU [bp+10]
	color EQU [bp+8]
	x EQU [bp+6]
	y EQU [bp+4]
	push cx
	push ax
	push si
	push bx
	mov ax,y
	mov cx,linelength
	; לולאה שצובעת את המקום הרצוי כמות הפעמים או אורך שניתן
	proceed4:
		push color
		push x
		push ax
		call drawPixel
		inc ax
	loop proceed4
	pop bx
	pop si
	pop ax
	pop cx
	pop bp
ret 8
endp drawvertical



; פעולה שמציירת את איך שהמשחק נראה.
proc drawlook
	; אנכי שמאלי
	push 200
	push 15
	push 1
	push 1
	call drawvertical
	
	
	; אופקי למעלה
	push 320
	push 15
	push 1
	push 1
	call drawhorizonal
	
	
	; אנכי ימני
	push 200
	push 15
	push 320
	push 1
	call drawvertical
	
	; אופקי למטה
	push 320
	push 15
	push 1
	push 200
	call drawhorizonal
	
	
	מצייר קו באמצע 
	push 5;linelength
	push 15;color
	push 160;x
	mov si,1
	push si
	call drawvertical;מצייר לבן
	mov cx,20
	white:
		add si,5
		push 5
		push 255
		push 160
		push si
		call drawvertical;מצייר שחור
		add si,5
		push 5;linelength
		push 15;color
		push 160;x
		; y
		push si 
		call drawvertical;מצייר לבן
	loop white
ret
endp drawlook



proc drawpaddle;פעולה שמקבל מיקום yומציירת את אחת המטקות במקום הרצוי
	push bp
	mov bp,sp
	color EQU [bp+6]
	y EQU [bp+4]
	push 25
	push color
	push 30
	push y
	call drawvertical;מצייר את הקו
	pop bp
ret 4
endp drawpaddle



proc movePaddle;צריך לעצור למטה;;;;;;;;;;;;;;;;;;;;;;
	mov ah,1;קורא תו
	int 16h;קורא תו
	mov dl,ah;שמירה של הערך
	mov ax,0c00h;מנקה את המקום שבודק את התוים המוכנסים
	int 21h;ממשיך כנ"ל
	cmp [paddle1y],3;חוסם תזוזה למעלה
	je blockTop
	cmp dl, 48h;48h = up
	jne notleft;;
		push 255 ;מוחק למעלה
		push [paddle1y]
		call drawPaddle
		sub [paddle1y],3
		push 15;מצייר למעלה
		push [paddle1y]
		call drawPaddle
		
	notleft:;;
		cmp [paddle1y], 174;;;;;;
		jg blockbot
		blockTop:
		cmp dl,50h;down-50h
		jne notRight;;
		push 255;מוחק למטה
		push [paddle1y]
		call drawPaddle
		add [paddle1y],3
		push 15;מצייר למטה
		push [paddle1y]
		call drawPaddle
		blockbot:;;;;;
	notRight:
	; left-4bh-no need
	; right-4dh-no need
	;down-50h
	;up-48h
ret
endp movePaddle



proc drawpaddle2;פעולה שמציירת את המטקה של היריב 
	push bp
	mov bp,sp
	push ax
	color EQU [bp+6]
	y EQU [bp+4]
	mov ax,y
	sub ax, 3
	push 25
	push color
	push 290
	push ax
	call drawvertical;מצייר את המטקה
	pop ax
	pop bp
ret 4
endp drawpaddle2



proc drawball;פעולה שמצייר את הכדור
	push bp
	mov bp,sp
	push cx;שמירת ערכים
	push dx
	push ax
	push bx
	push si
	color EQU [bp+8]
	x EQU [bp+6]
	y EQU [bp+4]
	mov ax,color
	mov si,x
	mov bx,y
	push 2;length
	push ax;color
	push si;x
	push bx;y
	call drawvertical;מצייר את הקו העליון מהכדור
	inc si
	push 2
	push ax
	push si
	push bx
	call drawvertical;מצייר את הקו התחתון מהכדור
	pop si
	pop bx
	pop ax
	pop dx
	pop cx
	pop bp
ret 6
endp drawball



proc moveBall;מעולה שאחראית על הזזת הכדור בצורה הגיונית, קפיצת הכדור מהמטקות ומהשוליים
	push ax;שמירה על ערכים
	push dx
	; delay
	mov cx, 1
	mov dx, 0Fh
	mov ah, 86H
	int 15H
	; delayend
	pop dx
	pop ax
	mov ax,[ballSpeed]
	cmp [bally],198;בודק אם פגע בשוליים
	je downstairs
	cmp [bally] ,3;למעלה?
	je bounce
	jmp overthis
	bounce:
	downstairs:
	add ax,ax
	sub [ballSpeed],ax;הופך את הזזת הכדור בy
	mov ax,[ballSpeed]
	overthis:
	mov dx, [bally]
	mov si, [paddle1y]
	cmp [ballx], 30;xנכון?
	je gamal
	cmp [ballx], 288;xנכוןלמטקה שנייה?
	jne notXhit
	mov si, [bally]
	sub si, 3
	gamal:
	cmp dx, si;;;;;;
	jb notundertopY
	add si, 25
	cmp dx,si
	jg tounder;jng
	sub si, 25
	push si
	call bouncepaddle
	tounder:
	notundertopY:
	notXhit:
	push 255
	push [ballx]
	push [bally]
	call drawball
	push 255
	push[bally]
	call drawpaddle2
	
	mov si,[ballSpeedX]
	add [ballx],si;;;;;;;;si
	add [bally],ax
	push 15
	push [ballx]
	push [bally]
	call drawball
	
	cmp [bally],177
	jg yhu
	
	push 15
	push[bally]
	call drawPaddle2
	jmp hi
	yhu:
	push 15
	push 177
	call drawPaddle2
	hi:
ret
endp moveBall



proc bouncepaddle;פעולה עוזרת לפעולה שמזיזה את הכדור. הפעולה זאת אחראית על הקפצת הכדור ממטקה.
	push bp
	mov bp,sp
	y EQU [bp+4]
	mov ax, y
	add ax, 8
	cmp dx,ax
	jg notinup
	mov [ballSpeed], -3;;;;;;;;
	jmp HitSomwhere
	notinup:
	add ax, 9
	cmp dx,ax
	jng HitSomwhere
	mov [ballSpeed],3
	HitSomwhere:
	push 255
	push[ballx]
	push [bally]
	call drawball
	mov si,[ballSpeedX];;;;;;;;
	add si,si
	sub [ballSpeedX],si
	mov ax,[ballSpeedx]
	add [ballx],ax
	push 15
	push[ballx]
	push [bally]
	call drawball
	pop bp
ret 2
endp bouncepaddle



proc resetscreen;פעולה שצובעת את כל המסך בשחור
	call gotext;עובר למצב טקסט
	call setScreen;עובר למצב ציור
ret
endp resetscreen



proc updatetimer;מעדכן את השעון של ההישרדות
	inc [digits];עדכון
	cmp [digits],39h;צריך להעלות עשרות?
	jng d9
	mov [digits],30h
	inc [tens]
	cmp [tens],39h;צריך להעלות מאיות
	jng t9
	mov [tens],30h
	inc [hunds]
	t9:
	d9:
ret
endp updatetimer



proc drawscore;פעולה שמציירת את כמות הפסילות של השחקן
	mov dl,' '
	mov ah,2h
	mov cx,58
	spaceit:;לולאה שיוצרת רווח
		int 21h
	loop spaceit
	mov dl,[scorecount2]
	mov ah,2 
	int 21h;מדפיס את המשתנה ש בDL
ret
endp drawscore



proc checkwin;פעולה שבודקת ניצחון והעלאת נקודה ולמי?
	cmp [ballx],21;עבר את המטקה?
	je toleft
	cmp [ballx],294;עבר את המטקה השניה?
	je toright
	jmp neither;אף אחד?
	toright:
	inc [scorecount1];העלאת נקודה
	jmp overleft
	toleft:
	inc [scorecount2];העלאת נקודה שנייה
	overleft:
	call resetscreen;מאפס את המשחק, מתחיל מההתחלה
	call drawscore
	jmp start
	neither:
ret
endp checkwin



proc completewin;;;;;;;;;;;;;;;;;;;;;;;;;;
	cmp [hunds],39h
	je go3
	cmp [scorecount2],32h
	je go32
	jmp notwin
	go32:
	call gotext;מנקה את המסך
	call setScreen
	mov cx,175
	mov ah,2h
	mov dl,' '
	dis:
		int 21h
	loop dis
	mov ah,9h
	lea dx, [youLose];מדפיס הפסד
	int 21h
	mov cx,105
	mov ah,2h
	mov dl,' '
	dis2:
		int 21h
	loop dis2
	mov ah,9h
	lea dx, [press];תלחץ על כל מקש כדי לצאת
	int 21h
	;;;;
	endscreen:
	mov dl,' '
	mov ah,2h
	mov cx,95
	spaceit3:
		int 21h
	loop spaceit3
	mov ah,9h
	lea dx,[yourscore];הניקוד שלך
	int 21h
	mov dl,[hunds]
	mov ah,2 
	int 21h;מדפיס את המשתנה ש בDL
	mov dl,[tens]
	mov ah,2 
	int 21h;מדפיס את המשתנה ש בDL
	mov dl,[digits]
	mov ah,2 
	int 21h;מדפיס את המשתנה ש בDL
	mov ah,9h
	lea dx,[outof]
	int 21h
	jmp over3
	go3:
	
	call resetscreen
	mov dl,' '
	mov ah,2h
	mov cx,60
	spaceit2:
		int 21h
	loop spaceit2
	mov ah,9h
	lea dx, [youWin];;;;;מדפיס ניצחון
	int 21h
	jmp endscreen
	notwin:
ret 
	over3:
	pop ax
	mov ah,7
	int 21h
	call gotext
	jmp exit
endp completewin



; proc random
	; push bp
	; mov bp, sp
	; push cx
	; min EQU [bp+6]
	; max EQU [bp+4]
	; mov ah, 0h
	; int 1Ah
	; mov ax, dx
	; add ax, [randomAddition]
	; inc [randomAddition]
	; mov cx, 65521;large prime number
	; mul cx
	; mov cx, 65003;another large prime number
	; div cx
	; mov ax, dx
	; xor dx, dx
	; mov cx, max
	; sub cx, min
	; div cx
	; mov ax, dx
	; add ax, min
	; pop cx
	; pop bp
; ret 4
; endp random



; proc side
	; push 0
	; push 100
	; call random
	; test ax,1
	; jz 
; ret
; endp side



start:
	mov ax, @data
	mov ds, ax
; --------------------------
; Your code here
; --------------------------
	; setting the screen
	call setScreen
	call drawscore
	call drawlook
	mov [paddle1y],75
	push 15
	push 75
	call drawPaddle
	mov [bally],99
	mov [ballx],159
	push 15
	push [ballx]
	push [bally]
	call drawball
	push 15
	push [bally]
	call drawpaddle2
	fuckit:;לולאה של משחק
		call updatetimer;;;;;;
		call drawlook
		call movePaddle
		call moveBall
		call checkwin
		call completewin
	jmp fuckit
exit:
	mov ax, 4c00h
	int 21h
END start


