mov si, offset str 
mov di, offset strEnc

lea bx, key              ;Anahtar mesajin adresi BX'te saklanir
lea ax, si               ;str adresi AX'e alinir
push ax                  ;AX'te tutulan str adresi stack'e atilir
    
strCntrl:
    pop ax               ;Stackteki adres alinir
    mov si, ax           ;Alinan adres SI'a atanir
    mov dx, ax           ;Bu adres DX'e alinir
    lodsb                ;SI'in isaret ettigi str'den karakter alinir
    cmp al, '$'          ;Karakterin terminate karakter olup olmadigi kontrol edilir
    je printEncStr       ;Terminate karakterse sifreli mesaj yazdirilir
    cmp al, 61h          ;Kucuk harf olup olmadigina bakilir
    jge strUpper         ;Eger kucuk harfse buyuk harfe cevrilir
    
pushEncStack:            ;Str adresini tutan DX bir arttirilarak tekrar stack'e atilit
    inc dx
    push dx  
    mov dl, al        
    jmp setEncKey
                         ;Stringte yer alan kucuk harfleri buyuk harflere cevirir
strUpper:
    sub al,20h
    jmp pushEncStack 
        
printEncStr:             ;Sifrelenmis mesajin ekrana yazdirildigi kisim
    xor ax, ax 
    mov al, '$'
    stosb
    xor ax, ax             
    mov dx, offset strEnc 
    mov ah, 9
    int 21h
    hlt 
    
setEncKey:               ;SI'a key mesajin adresi atilir
    mov si, bx           ;Key mesajin karakterleri alinir
    lodsb                ;Key mesajin bir sonraki karakterinin adresi BX'e atilir
    inc bx               ;Mesajin karakteri kucuk harf mi
    cmp al, 61h          ;Kucuk harfse buyuk harfe cevrilir
    jge keyUpper 
    
isEncKeyTerm:            ;Key karakter terminate karakterse key tekrarlanir
    cmp al, '$'
    je resetEncKey
     
encrypt:                 ;Key mesajin alfabedeki sirasi sifrelenecek mesajin alfabedeki
                         ;sirasina eklenir.
    mov dh, al
    sub dh, 40h
    add dh, dl
    cmp dh, 5Ah          ;Toplam sonucu Z harfini geciyorsa alfabede basa donulur
    jg isGreaterEnc 
    jmp isSmallerEnc     
    
isGreaterEnc:            ;Alfabede basa donulen dongu
    sub dh, 5Ah
    add dh, 40h
    xor ax,ax
    mov al, dh
    stosb
    loop strCntrl

isSmallerEnc:            ;Toplamlari Z harfini gecmiyorsa toplam sonucuna karsilik gelen karakter
                         ;sifreli mesaja yazdirilir
    xor ax,ax
    mov al, dh
    stosb
    loop strCntrl 
    
keyUpper:                ;Key mesajin buyuk harfe cevrildigi etiket
    sub al, 20h
    jmp isEncKeyTerm
    
resetEncKey:             ;Key mesaj terminate karaktere geldiginde key mesajda basa donulur
    lea bx, key
    jmp setEncKey    

str db 'hande$'
key db 'sifre$'
strEnc db 'xxxxxxxxxxxxxxxxxxxxxxxxx$'