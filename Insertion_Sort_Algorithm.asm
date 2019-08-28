mov si, offset nums     
mov di, offset nums

mov bx, di  
push si

compare:              ;Sayilarin karsilastirmasini yapacak olan dongu.
                      ;Kiyaslanacak sayilardan birinin adrresi SI digerinin adresi ise DI'da
                      ;tutulacaktir.
    pop si         
    inc si 
    push si           
    mov ax, si
    dec ax
    mov di, ax        ;DI her zaman  SI'dan bir onceki elemani isaret edecek sekilde atanir.
    mov dh,[di]        
    mov dl,[si]
    cmp dl, '$'       ;Dongu, siralanacak dizinin terminate karakteri olan '$' a gelene kadar
                      ;devam edecek.
    je show           ;Eger terminate karakterine gelindiyse diziyi yazdiran donguye gececek.
    cmp dl, dh        ;SI'in gosterdigi deger, DI'in gosterdigi degerden kucukse degistirme
                      ;isleminin yapildigi donguye gider.
    jl swap
    loop compare    
    
swap:                 ;Bu dongude SI ve DI'in isaret ettigi elemanlar yer degistirir
    mov [si], dh
    mov [di], dl 
    cmp di, bx        ;Eger DI, dizinin ilk elemanini isaret etmiyorsa, SI'in dizinin ilk 
                      ;elemanina kadar olan sayilarla kiyaslanabilmesi icin 'smaller' adli
                      ;donguye gider.
    jne smaller   
    jmp compare
    
smaller:              ;Bu dongude SI, dizinin ilk elemanina kadar sirayla kiyaslanir.
    dec si
    dec di
    mov dh, [di]
    mov dl, [si]
    cmp dl, dh
    jl swap
    jmp compare
    
show: 
    mov si, offset nums 
    
print:               ;Bu dongude siralanmis dizi yazdirilir. Burada sayilarin ekrana
                     ;yazdirilabilmesi icin ASCII donusumu yapilmistir.
    mov al, [si] 
    cmp al, '$'
    je progHlt 
    cmp al, 0
    jns isPositive   ;Sayi pozitif ise direk bu donguye gidilir.
    mov  dl, "-"     ;Sayi negatif ise once ekrana - isareti yazdirilir.   
    mov  ah, 02h
    int  21h 
    xor ax, ax
    mov al, [si]
    neg  al          ;Sayinin negatif olmasi durumunda tekrar negatifi alinarak pozitif
                     ;sayiya donusturulur.
    
isPositive:          ;Sayilarin ASCII donusumlerinin yapildigi dongu.
    aam
    add ax, 3030h
    push ax
    mov dl, ah
    mov ah, 02h
    int 21h
    pop dx
    mov ah, 02h
    int 21h
    call comma
    inc si
    jmp print  
    
proc comma           ;Yazdirilan sayilar arasina , isareti konulmasi icin olusturulan dongu.
    mov dx,',' 
    mov ah, 2
    int 21h 
    ret     
    
progHlt:
    hlt
    
nums db -8,90,62,11,70,-3,-20,65,88,'$'