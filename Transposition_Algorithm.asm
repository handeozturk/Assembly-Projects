mov si, offset key 
mov di, offset keySrt 

findKeyLen:             ;Sifrelemede kullanilacak anahtarin(key) boyutu hesaplanir
    lodsb                  
    cmp al, '$'         ;Terminate karakterine gelinceye kadar cl arttirilir
    je setSIforStr  
    inc cl                 
    jmp findKeyLen
    
setSIforStr:
    mov keyLen, cl      ;key'in boyutu keyLen degiskeninde tutulur
    mov si, offset str  ;Sifrelenecek stringin adresi si'ya atandi
    
findStrLen:             ;Sifrelenecek stringin uzunlugu hesaplanir
    lodsb
    cmp al, '$'         ;Terminate karakterine gelinceye kadar ch arttirilir
    je setSIforKey  
    inc ch                 
    jmp findStrLen
    
setSIforKey:               
    mov strLen, ch
    xor cx, cx          ;Stringin boyutu strLen degiskeninde tutulur
    mov si, offset key  ;key degiskeninin adresi si'ya atandi

cpyKey:                 ;key degiskenine ait harflerin sozluge gore siralanmasi
                        ;icin bu degisken keySrt(Key Sorted) degiskenine kopylanir
    lodsb
    cmp al, '$'
    je setRegs          ;Terminate karakterine gelinceye kadar kopyalanir
    stosb
    jmp cpyKey
    
setRegs:                ;Karakterlerin karsilastirmasi icin yapilan atamalar
    stosb 
    xor ax, ax  
    mov si, offset keySrt 
    mov di, offset keySrt 
    mov bx, di  
    push si

compare:                ;Anahtar kelimeyi alfabetik siralayacak olan dongu
                        ;Kiyaslanacak harflerin birinin adrresi SI digerinin adresi ise DI'da
                        ;tutulacaktir.
    pop si         
    inc si 
    push si           
    mov ax, si
    dec ax
    mov di, ax          ;DI her zaman  SI'dan bir onceki elemani isaret edecek sekilde atanir.
    mov dh,[di]        
    mov dl,[si]
    cmp dl, '$'         ;Dongu, siralanacak anahtarin terminate karakteri olan '$' a gelene kadar
                        ;devam edecek.
    je setStrs          ;Eger terminate karakterine gelindiyse stringe X ekleyen donguye gececek.
    cmp dl, dh          ;SI'in gosterdigi deger, DI'in gosterdigi degerden kucukse degistirme
                        ;isleminin yapildigi donguye gider.
    jl swap
    jmp compare    
    
swap:                   ;Bu dongude SI ve DI'in isaret ettigi elemanlar yer degistirir
    mov [si], dh
    mov [di], dl 
    cmp di, bx          ;Eger DI, dizinin ilk elemanini isaret etmiyorsa, SI'in dizinin ilk 
                        ;elemanina kadar olan karakterlerle kiyaslanabilmesi icin 'smaller' adli
                        ;donguye gider.
    jne smaller   
    jmp compare
    
smaller:                ;Bu dongude SI, dizinin ilk elemanina kadar sirayla kiyaslanir.
    dec si
    dec di
    mov dh, [di]
    mov dl, [si]
    cmp dl, dh
    jl swap
    jmp compare  
  
;----------------------------------------------------------------------------------------  

setStrs:
    mov si, offset str 
    mov di, offset strTmp
    
setStrTmp:              ;strTemp degiskeninin olusturuldugu dongu
    lodsb
    cmp al, '$'
    je cpyStr
    stosb
    jmp setStrTmp    
        
cpyStr:                ;Sifrelenecek stringin sonuna X karakteri eklemesi icin yapilan atamalar.
    xor ax, ax 
    xor dx, dx
    mov al, strLen      
    mov ah, keyLen
    cmp ah, al          ;Stringin uzunlugu ile key'in uzunlugu kiyaslanir.
    jl findMod          ;Eger string daha uzunsa sonuna ne kadar X karakteri atanacaginin
                        ;belirlenmesi icin modu alinir.  
    jg countX       
    jmp setStrTrm       ;String anahtardan daha uzun degilse bu etikete gidilir.  
    
findMod:                ;Mod alinan etiket
    mov dl, ah 
    mov ah, 00h
    div dl 
    mov mod, ah         
    mov ah, keyLen
    mov al, mod     
                            
countX:                 ;stringin sonuna ne kadar X eklenecegi hesaplanir
    sub ah, al  
    mov cl, ah
    xor ax, ax
    jmp putX   
    
putX:                   ;Bulunan sayi kadar X eklenir
    mov al, 'X'
    stosb
    loop putX  

setStrTrm:
    mov al, '$'

stosb                   ;string(strTmp) olusturulur
xor ax, ax 
xor cx, cx
mov si, offset strTmp 

findStrTmpLen:          ;strTmp uzunlugunun bulundugu dongu
    lodsb
    cmp al, '$'
    je encryptLbl
    inc cl  
    mov strTmpLen, cl
    jmp findStrTmpLen   
    
;---------------------------------------------------------------------------------------- 

encryptLbl:             ;Sifreleme islemleri icin kullanilacak degiskenlerin atamalarinin
                        ;yapildigi bolum. Burada strTmp degiskeni        

    
mov di, offset strEnc
mov offsetEnc, di 
mov di, offset strTmp
mov offsetTmp, di
mov si, offset keySrt
mov di, offset key
xor cx, cx 
mov al, strTmpLen 
mov counter, al
xor ax, ax 
xor dx, dx 
push si 
                        
findPos:                ;Alinan degerin ve counter durumlarinin kontrol edildigi etiket
    pop si 
    lodsb        
    cmp al, '$'         ;Deger terminate ise key yeniden basa doner
    je resetKeyStr 
    mov dl, counter     ;counter 0 a geldiyse terminate karakteri konularak sonlandirilir
    cmp dl, 00h
    je putTerm
    dec counter
    xor dl, dl            
    mov cl, keyLen  
    
loopEqual:
    call findEqual 
    loop loopEqual    
    
resetKeyStr:           ;key terminate karaktere geldiginde tekrarlanir
    mov si, offset keySrt
    push si
    mov di, offset key 
    cmp cntrDec, 00h   ;Decrypt icin olusturulan counter kontrol edilir
    jne setForDec      ;Eger counter 0 dan buyukse decrypt islemidir ve ilgili etikete gider
    mov bx, offsetTmp 
    xor ax, ax 
    mov al, keyLen     ;offsetTmp key uzunlugu kadar arttirilir
    add bx, ax
    xor ax, ax   
    mov offsetTmp, bx
    jmp findPos
    
setForDec:             ;Sifrele cozme islemleri icin kullanilacak degiskenlerin atamalarinin
                       ;yapildigi bolum. 
    mov bx, offsetEnc 
    xor ax, ax 
    mov al, keyLen
    add bx, ax
    xor ax, ax   
    mov offsetEnc, bx
    jmp findPos
    
decryptLbl:            ;Decrypt islemi icin gerekli atamalarin yapildigi kisim
    inc cntrDec
    mov di, offset strDec
    mov offsetDec, di 
    mov di, offset strEnc
    mov offsetEnc, di
    mov si, offset keySrt
    mov di, offset key
    xor cx, cx 
    mov al, strTmpLen 
    mov counter, al
    xor ax, ax 
    xor dx, dx 
    push si
    jmp findPos        
    
putTerm:               ;Stringin sonuna terminate karakterinin eklendigi kisim
    xor ax, ax
    mov ah, cntrDec 
    mov al, '$'
    cmp ah, 00h
    jne putTermDec     ;Decrypt islemi ise bu etikete gider
    jmp putTermEnc     ;Encrypt islemi ise bu etikete gider   
    
putTermEnc: 
    mov di, offsetEnc
    stosb
    jmp decryptLbl 
     
putTermDec:
    mov di, offsetDec
    stosb
                       
print:                 ;Encrypt ve decrypt edilmis stringlerin yazdirildigi kisim
    xor ax, ax 
    lea dx, encryptedMsg 
    mov ah, 9 
    int 21h
    lea dx, strEnc
    int 21h  
    lea dx, decryptedMsg
    int 21h
    lea dx, strDec
    int 21h 
    hlt   

encrypt:                ;Encryption isleminin yapildigi etiket
    push si
    mov si, offsetTmp   ;strTemp encrypt edilerek
    mov di, offsetEnc   ;strEnc'e yazilir
    xor ax, ax
    mov al, pos         ;findEqual etiketinde hesaplanan pos degeri stringe offset olarak eklenir
    add si, ax
    xor ax, ax
    lodsb
    stosb 
    mov offsetEnc, di   ;Sonraki dongu icin isaretciler tekrar atanir
    mov di, offset key
    xor dx, dx
    jmp findPos   
    
decrypt:                ;Decryption isleminin yapildigi etiket
    push si
    mov si, offsetEnc
    mov di, offsetDec
    xor ax, ax
    mov al, pos         ;findEqual etiketinde hesaplanan pos degeri stringe offset olarak eklenir
    add si, ax
    xor ax, ax
    lodsb
    cmp al, 'X'
    je putTerm
    stosb 
    mov offsetDec, di
    mov di, offset key
    xor dx, dx
    jmp findPos    
    
encOrDec:              ;Decryption mu encryption mu? Karar verilen kisim
    mov al, cntrDec
    cmp al, 00h
    jne decrypt
    jmp encrypt
    
proc findEqual         ;Sirali key karakteri ile orjinal key karakteri ayni mi
    mov pos, dl        ;keyStr'deki elemanin diger key'de nerede oldugunu pos'ta tutuyoruz
    cmp al, [di]
    je encOrDec
    inc dl
    inc di
    ret            

str       db 'DCODE$'
key       db 'KEY$'         
strLen    db 0 
strTmpLen db 0
keyLen    db 0  
mod       db 0  
pos       db 0
counter   db 0
offsetTmp dw 0
offsetEnc dw 0  
offsetDec dw 0
cntrDec   db 0 
keySrt    db 'xxxxxxxxxxxxxxxxxxxxxxxxx$'
strTmp    db 'xxxxxxxxxxxxxxxxxxxxxxxxx$'  
strEnc    db 'xxxxxxxxxxxxxxxxxxxxxxxxx$'
strDec    db 'xxxxxxxxxxxxxxxxxxxxxxxxx$'     
encryptedMsg db 'Encrypted string is: $'
decryptedMsg db ' - Decrypted string is: $'