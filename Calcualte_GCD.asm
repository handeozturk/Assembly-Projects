setDivider:            ;Bu etikette num1 al'ye ve bolen sayi olarak dl'ye atanmistir.
    mov al, num1        
    mov dl, al
getSmaller:            ;Burada iki sayi karsilastiriliyor. En kucuk olan sayi num1'e ve
                       ;AL'ye atanacak.
                       ;Bu sebeple eger ilk sayi buyukse sayilarin yerleri degistirilecek.
    cmp num1, 0        ;Eger sayilardan biri 0'sa hata mesajina gidilip program sonlandirilacak.
    je zeroValues
    cmp num2, 0
    je zeroValues         
    cmp al, num2    
    jg chooseSmall 
    jle divideOp

chooseSmall:           ;Sayilardan kucuk olanin num1 ve al'ye; digerinin num2'ye atandigi kisim.
    mov ah, al
    mov al, num2
    mov num2, ah
    mov num1, al
    mov ah, 00 
    jmp setDivider

divideOp: 
    cmp dl,0           ;Bolen sayi 0 olduysa diger buyuk sayi al'ye alinacak.
    je setGreater
    mov al, num1       
    div dl               
    dec dl     
    cmp ah, 0          ;num1/dl sonucu kalan vermezse "noRemain" etiketine gider.
    je noRemain
    mov ax, 00h 
    jmp divideOp  

setGreater:            ;num1'in tum bolenleri stack'e atildiktan sonra buyuk sayinin 
                       ;al<-num2 atamasi yapiliyor.
    mov al, num2 
    mov ah, 00
    
getNums:               ;Stack'teki bolenler bx registerina aliniyor.
    pop bx             ;num2, stackten alinan degerlere bolunuyor. Eger kalansiz bolunurse
                       ;testGCD etiketine gidilecek
    div bl
    cmp ah, 0
    je testGCD           
    jmp setGreater       
   
noRemain:              ;num1'e ait bolenleri bulma islemi yapilirken bolme islemi kalansiz ise
                       ;bu etikete gidilir.
    push ax            ;Bolen sayi stack'e atilir.
    inc cl
    jmp divideOp
    
testGCD:               ;Ortak bolenin kontrol edildigi etiket.
    mov comDiv, bl
    cmp comDiv, 1      ;EBOB=1 ise 1 haricinde ortak bolen yok demektir. 
    je notFoundComDiv
    
foundGCD:              ;EBOB bulundugunda bu etikete gidilir.
    lea dx,msg1 
    mov ah, 9
    int 21h 
    hlt 
    hlt   
    
notFoundComDiv:        ;1 den farkli ortak bolen bulunamadiginda bu etikete gidilir.
    lea dx,msg2 
    mov ah, 9
    int 21h 
    hlt    
    
zeroValues:            ;Sayilardan biri 0 oldugunda bu etikete gidilir.
    lea dx,msg3 
    mov ah, 9
    int 21h 
    hlt 
    
num1 db 15
num2 db 40   
comDiv db 0
msg1 db 'GCD is found$'
msg2 db 'There is no common divisor except 1$'
msg3 db 'Values must be non-zero$' 
            


          
