Progr           segment
                assume  cs:Progr, ds:dane, ss:stosik
start:
        mov     ax, dane
        mov     ds, ax
        mov     ax, stosik
        mov     ss, ax
        mov     sp, offset szczyt

wejscie:
        mov     ah, 9			; laduje 9 do rejestru ah
        mov     dx, offset komunikat	; ustawienie rejestru dx na poczatek komorki pamieci pod wskazanym adresem
        int     21h			; wywolanie przerwania, ktora wyswietla komunikat znajdujacy sie pod adresem wskazywanym przez rejest dx
        mov 	bx, 0	 		; ustawiamy wartosc rejestr bx na 0 (w tym rejestrze bedziemy przechowywac wynik)
        mov     cx, 10			; ustawiamy wartosc rejestr cx na 10 (liczba przez ktora bedziemy mnozyc)
        mov	si, 0			; ustawiamy wartosc rejestr si na 0 (bedziemy tutaj przechowywac znak)
        mov	dx, 0			; ustawiamy wartosc rejestr dx na 0 
        mov     ah, 1			; ustawiamy wartosc rejestr ah na 1
        int     21h			; wywolanie przerwania ktora odczytuje znak z klawiatury i zapisuje go w al
        cmp     al, '-'			; sprawdzamy czy wprowadzony znak jest -
        jne     czy_cyfra		; jesli jest rozny to skaczemy do wskazanego adresu
        mov     si, 1			; ustawiamy wartosc rejestru si na 1
        jmp     kolejna_cyfra		; skaczemy do wskazanego adresu

czy_cyfra:
        cmp     al, '0'			; sprawdzamy czy wartosc w rejestrze al to 0
        jb      bledne_dane		; jesli mniejsza to skaczemy do wskazanego adresu
        cmp     al, '9'			; sprawdzamy czy wartkosc w rejestrze al jest rowna 9
        ja      bledne_dane		; jesli jest wieksza to skaczemy do wskazanego adresu
        sub     al, 48			; od zawartosci rejestru al odejmujemy 48, aby uzyskac cyfre dziesietna
        mov	ah, 0			; ustawiamy zawartosc rejestru ah na 0
        mov     bx, ax			; przenosimy zawartosc rejestru ax do rejestru bx

kolejna_cyfra:
        mov     ah, 1			; ustawiamy zawartosc rejestru ah na 1
        int     21h			; wywolujemy przerwanie ktore odczytuje znak z klawiatury i zapisuje go do al
        cmp     al, 13			; sprawdzamy czy zawartosc al jest rowna 13, czyli czy uzytkownik wcisnal enter
        je      koniec_wejscia		; jezeli wartosci sa rowne to skaczemy do wskazanego adresu
        cmp     al, '0'			; sprawdzamy czy zawartosc rejestru al jest rowna 0
        jb      bledne_dane		; jesli jest mniejsza to skaczemy do wskazanego adresu
        cmp     al, '9'			; sprawdzamy czy zawartosc rejestru al jest rowna 9
        ja      bledne_dane		; jesli jest wieksza to skaczemy do wskazanego adresu
        sub     al, 48			; od zawartosci rejestru al odejmujemy 48 aby uzyskac cyfre dziesietna
        mov	ah, 0			; ustawiamy zawartosc rejestru ah na 0
        push    ax			; przenosimy zawartosc rejestru ax na stos
        mov     ax, bx			; przenosimy zawartosc rejestru bx do rejestru ax 
        cmp     ax, 3276    		; sprawdzamy czy zawartosc rejestru ax jest rowna 3276
        ja      poza_zakresem       	; jesli jest wieksza to skaczemy do wskazanego adresu
        mul     cx        		; mnozymy zawartosc rejestru ax z rejestrem cx (czyli mnozymy przez 10)
        mov     bx, ax			; przenosimy zawartosc rejestru ax do rejestru bx
        pop     ax			; sciagamy ze stosu zapisana zawartosc do rejestru ax
        add     bx, ax        		; do zawartosci rejestru bx dodajemy zawartosc rejestru ax
        cmp     si, 1       		; sprawdzamy czy zawartosci rejestru si jest rowna 1
        jne     zakres_dodatnia		; jestli nie jest rowna to skaczemy do wskazanego adresu (mamy liczbe dodatnia)
        cmp     bx, 8000h   		; sprawdzamy czy zawartosci rejestru bx jest rowna 8000h
        ja      poza_zakresem		; jesli jest wieksza to liczba nie miesci sie w zakresie i skaczemy do etykiety
        jmp     kolejna_cyfra		; skaczemy do wskazanego adresu

zakres_dodatnia:
        cmp     bx, 7FFFh   		; sprawdzamy czy zawartosci rejestru bx jest rowna 7FFFh
        ja      poza_zakresem		; jesli jest wieksza to liczba nie miesci sie w zakresie i skaczemy do etykiety
        jmp     kolejna_cyfra		; skaczemy do wskazanego adresu

poza_zakresem:
        mov     ah, 9			; ustawiamy zawartosci rejestru ah na 9
        mov     dx, offset bledny_zakres 	; ustawienie rejestru dx na poczatek komorki pamieci pod wskazanym adresem	
        int     21h			; wywolanie przerwania, ktora wyswietla komunikat znajdujacy sie pod adresem wskazywanym przez rejest dx
        jmp     wejscie			; skaczemy do wskazanego adresu

bledne_dane:	
        mov     ah, 9			; ustawiamy zawartosci rejestru ah na 9
        mov     dx, offset blad		; ustawienie rejestru dx na poczatek komorki pamieci pod wskazanym adresem
        int     21h			; wywolanie przerwanie, ktora wyswietla komunikat znajdujacy sie pod adresem wskazywanym przez rejest dx
        jmp     wejscie			; skaczemy do wskazanego adresu

koniec_wejscia:
        cmp     si, 1			; sprawdzamy czy zawartosci rejestru si jest rowna 1	
        jne     wyswietl_wyniki		; jestli jest rozna od 1 do skaczemy do wskazanego adresu
        neg     bx			; negujemy zawartosci rejestru bx

wyswietl_wyniki:
        push    bx			; przenosimy zawartosc rejestru bx na stos
        mov     ah, 9			; ustawiamy zawartosci rejestru ah na 9
        mov     dx, offset wynik_hex	; ustawienie rejestru dx na poczatek komorki pamieci pod wskazanym adresem
        int     21h			; wywolanie przerwania, ktora wyswietla komunikat znajdujacy sie pod adresem wskazywanym przez rejest dx
        mov     ax, bx			; ladujemy zawartosci rejestru bx do rejestru ax
        mov     cx, 4			; ustawiamy zawartosci rejestru cx na 4, poniewaz bedziemy wykonywac petle 4 razy

wyswietl_hex:
        push    cx			; przenosimy zawartosc rejestru cx na stos
        mov     cx, 4			; ustawiamy zawartosc rejestru cx na 4, aby rozkaz rol wykonal rotacje bitow w lewo o 4 pozycje
        rol     ax, cl			; rotujemy wszystkie bity z rejestru ax o 4 pozycje w lewo, bity ktore wypadaja z najbardziej znaczacej pozycji trafiaja na najmniej znaczaca pozycje
        push    ax			; przenosimy zawartosc rejestru ax na stos
        and     al, 0Fh			; wykonuje operacje logiczna AND pomiedzy rejestrem al (starsze 4 bity al sa zamieniane na 0, a mlodsze 4 bity zostaja bez zmian)
        add     al, 30h			; do zawartosci rejestru al dodajemy 30h
        cmp     al, 39h			; sprawdzamy czy zawartosci rejestru al jest rowna 39h
        jle     wyswietl_znak_hex	; jesli jest mniejsza badz rowna skaczemy do wskazanego adresu
        add     al, 7			; do zawartosci rejestru al dodajemy 7, aby uzyskac litery w systemie hex

wyswietl_znak_hex:
        mov     dl, al			; przenosimy zawartosci rejestru al do rejestru dl
        mov     ah, 2			; ustawiamy zawartosc rejestru ah na 2
        int     21h			; wywolujemy przerwanie, ktore wyswietla znak znajdujacy sie w rejestrze dl
        pop     ax			; sciagamy zapisana wartosc ze stosu do rejestru ax 
        pop     cx			; sciagamy zapisana wartosc ze stosu do rejestru cx
        loop    wyswietl_hex		; dekrementujemy zawartosc rejestru cx, jesli cx != 0 wracamy do adresu wskazanej etykiety

        mov     ah, 9			; ustawiamy zawartosc rejestru ah na 9
        mov     dx, offset nowa_linia	; ustawienie rejestru dx na poczatek komorki pamieci pod wskazanym adresem	
        int     21h			; wywolanie przerwania, ktore wyswietla komunikat znajdujacy sie pod adresem wskazywanym przez rejest dx
        mov     dx, offset wynik_bin	; ustawienie rejestru dx na poczatek komorki pamieci pod wskazanym adresem
        int     21h			; wywolanie przerwania, ktore wyswietla komunikat znajdujacy sie pod adresem wskazywanym przez rejest dx
        pop     bx			; sciagamy zapisana wartosc ze stosu do rejestru bx
        mov     ax, bx			; przenosimy zawartosc rejestru bx do rejestru ax
        mov     cx, 16			; ustawiamy zawartosc rejestru cx na 16 (licznik petli)

wyswietl_bin:
        shl     ax, 1			; przesuwamy wszystkie bity z rejestru ax o 1 w lewo, najmlodszy bit jest uzupelniany 0, a najstarszy bit, ktory wypada poza rejestr jest kopiowany do flagi C	
        jc      jedynka			; jezeli flaga C jest ustawiona na 1 to skaczemy do wskazanego adresu

zero:
        mov     dl, '0'			; ustawiamy zawartosc rejestru dl na znak '0'
        jmp     wyswietl_bit		; skaczemy do wskazanego adresu

jedynka:
        mov     dl, '1'			; ustawiamy zawartosc rejestru dl na znak '1'

wyswietl_bit:
        push    ax			; przenosimy zawartosc rejestru ax na stos
        mov     ah, 2			; ustawiamy zawartosc rejestru ah na 2
        int     21h			; wywolujemy przerwanie, ktore wyswietla znak znajdujacy sie w rejestrze dl
        pop     ax			; sciagamy wartosc zapisana na stosie do rejestru ax
        loop    wyswietl_bin		; dekrementujemy zawartosc rejestru cx, jesli cx != 0 wracamy do adresu wskazanej etykiety

        mov     ah, 9			; ustawiamy zawartosc rejestru ah na 9
        mov     dx, offset nowa_linia	; ustawienie rejestru dx na poczatek komorki pamieci pod wskazanym adresem
        int     21h			; wywolanie przerwania, ktore wyswietla komunikat znajdujacy sie pod adresem wskazywanym przez rejest dx
        jmp 	start			; skaczemy do wskazanego adresu
        mov     ax, 4C00h		
        int     21h

dane            segment
komunikat       db      13,10,'Wprowadz liczbe w zakresie od -32768 do 32767: $'
blad 		db      13,10,'Musisz wprowadzic liczbe.$'
bledny_zakres 	db 	13,10,'Liczba poza zakresem.$'
nowa_linia      db      13,10,'$'
wynik_hex   	db      'Hex: $'
wynik_bin   	db      'Bin: $'
dane            ends

stosik          segment stack
                dw      100h dup(0)
szczyt          label   word
stosik          ends

end start