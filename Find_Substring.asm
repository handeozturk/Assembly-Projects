    mov si, offset str1
    mov di, offset str2  
    mov dx, 00h 
    
subStrLen:                ;Aranacak alt stringin(str2) karakter uzunlugunu bulan dongu 
    cmp [di], '$'         ;Alt string(str2)  terminate karakteri ile kiyaslaniyor
    je setStr             ;Eger terminate karaktere geldiyse arama dongusune geciyor
    inc di                ;str2'deki bir sonraki karakteri isaret edecek
    inc dl                ;dl registeri str2'nin uzunlugunu tutuyor
    loop subStrLen 
    
setStr: 
    mov di, offset str2 
    jmp isSubStr
    
isSubStr:   
    lodsb                 ;Icinde arama yapilacak string(str1), al registerina aliniyor 
    ;Karakterlerin terminate karakter olup olmadigi kontrol ediliyor      
    cmp al, '$'           
    je testAlg             
    cmp [di], '$'             
    je testAlg  
    call isEqual          ;Karakterlerin ayni olup olmadiklarini test eden prosedur   
    loop isSubStr 
    
isEqual:
    cmp [di], al          ;Eger ayni karakterlerse registerlarin degerleri arrtirilir
    je incReg  
    jne isCapital         ;Ayni karakter degillerse buyuk-kucuk karakter durumuna bakilir
retSubStr:
    ret       
    
isCapital:                ;Buyuk-kucuk harf kiyaslamasinin yapildigi etiket
                          ;Iki karakter arasinda 20h ya da E0 fark varsa ayni harf ancak
                          ;biri buyuk biri kucuk harftir
    mov bl, al
    sub bl, [di]
    cmp bl, 0020h
    je incReg
    cmp bl, 00E0h
    je incReg             
    mov dh, 00h           ;Karakterler arasinda buyuk-kucuk harf iliskisinin de bulunmamasi 
                          ;durumunda dh registeri temizlenir.
    jmp setStr            ;str2 tekrar alinir
    
incReg:     
    ;Her karakter eslesmesinde dh ve di registerleri 1 arttirilir         
    inc dh                 
    inc di   
    loop retSubStr
                                 
    
testAlg:                  ;Bu dongude str2 stringinin karakter uzunluguyla, string 
                          ;kiyaslamalarinda elde edilen toplam eslesme sayisinin esitlik 
                          ;durumlari kontrol edilir
    cmp dh, dl
    je printPosMsg        ;Eger bu register degerleri esitse str2, str1'de mevcut demektir.
                          ;Ekrana 'True' ciktisini veren etikete gider
    jne printNegMsg       ;Eger bu register degerleri esit degilse str2, str1'de mevcut degil
                          ;demektir.
                          ;Ekrana 'False' ciktisini veren etikete gider
    
printPosMsg:              ;Ekrana 'True' ciktisini veren etiket(Stringin bulunmasi durumu)
    lea dx,msg1 
    mov ah, 9
    int 21h 
    hlt 

printNegMsg:              ;Ekrana 'False' ciktisini veren etiket(Stringin bulunamamasi durumu)
    lea dx,msg2 
    mov ah, 9
    int 21h 
    hlt    

str1 db 'BilgisyarMimarisiLab$' ;Icerisinde arama yapilacak string
str2 db 'mimari$'               ;Aranacak string
msg1 db 'True$'
msg2 db 'False$'  