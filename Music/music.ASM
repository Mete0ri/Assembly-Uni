prog            segment
assume          CS:prog, DS:dane, SS:stosik

start:          MOV     AX,dane			; ladujemy adres segmentu danych do rejestru ax
                MOV     DS,AX			; ustawiamy rejestr ds na segment danych
                MOV     AX,stosik		; ladujemy adres segmentu stosu do rejestru ax
                MOV     SS,AX			; ustawiamy rejestr ss na stos segment
                MOV     SP,offset szczyt	; ustawiamy wskaznik stosu na szczyt

                MOV     CL,ES:[80h]		; pobieramy dlugosc argumentow z psp (program segment prefix)
                CMP     CL,0			; sprawdzamy czy sa argumenty
                JE      bladParametru		; jesli nie ma to skaczemy do wskazanego adresu
                DEC     CL			; dekrementujemy rejestr cl, poniewaz zawiera spacje
                MOV     DI,offset plik		; ustawiamy adres docelowy dla nazwy przekazanego pliku
                MOV     SI,82h			; ustawiamy wskaznik na pierwszy argument w psp (pierwsza litera parametru)

                PUSH    DS			; zapis segmentu danych na stos		
                PUSH    ES			; zapis ekstra segmentu na stos

                PUSH    DS			; zapis segmentu danych na stos	
                PUSH    ES			; zapis ekstra segmentu na stos
                POP     DS			; przywrocenie segmentu danych ze stosu
                POP     ES			; przywrocenie ekstra segmentu ze stosu
		
                REP     MOVSB			; kopiowanie nazwy pliku do komorki pamieci

                POP     ES			; przywracanie ekstra segmentu ze stosu
                POP     DS			; przywracanie segmentu danych ze stosu
	
                MOV     AX,3D00h		; ladujemy funkcje, ktora otwiera plik do rejestru ax
                MOV     DX,offset plik		; ustawiamy wskaznik na poczatek komorki pamieci z nazwa pliku	
                INT     21h			; wywolanie przerwania
                CMP     AX,5			; sprawdzamy czy udalo sie otworzyc plik, czy wystapil blad
                JL      blednyPlik		; jesli mniejsze to skaczemy do wskazanego adresu
                MOV     idPliku,AX		; przenosimy zawartosc rejestru ax do komorki pamieci
                JMP     nazwaUtworu		; skaczemy do wskazanego adresu

bladParametru:  MOV     DX,offset errorParametru	; ustawiamy wskaznik na komunikat o bledzie
                MOV     AH,09h			; ladujemy funkcje, ktora wyswietla ciag znakow do ah
                INT     21h			; wywolanie przerwania
                JMP     koniec			; skaczemy do wskazanego adresu

blednyPlik: 	MOV     DX,offset errorNazwy	; ustawiamy wskaznik na komunikat o bledzie
                MOV     AH,09h			; ladujemy funkcje, ktora wyswietla ciag znakow do ah
                INT     21h			; wywolanie przerwania
                JMP     koniec			; skaczemy do wskazanego adresu

nazwaUtworu:    MOV     DX,offset obecnyUtwor	; ustawiamy wskaznik na poczatek komorki pamieci wskazanej etykieta
                MOV     AH,09h			; ladujemy funkcje, ktora wyswietla ciag znakow do ah
                INT     21h			; wywolanie przerwania
                MOV     DX,offset plik		; ustawiamy wskaznik na poczatek komorki pamieci z nazwia pliku
                MOV     AH,09h			; ladujemy funkcje, ktora wyswietla ciag znakow do ah
                INT     21h			; wywolanie przerwania

pobierzLinie:   MOV     BX,idPliku		; ladujemy zawartosc komorki pamieci do rejestry bx 
                MOV     AH,3Fh			; ladujemy funkcje, ktora wczytuje z pliku do ah
                MOV     CX,5			; ladujemy 5 do rejestru cx (liczba bajtow do pobrania)
                MOV     DX,offset obecnaLinia	; ladujemy do dx adres poczatku komorki pamieci 
                INT     21H			; wywolanie przerwania

                CMP     AX,CX			; sprawdzamy czy pobralismy wszystkie bajty
                JE      pobierzNute		; jesli rowne to przechodzimy do przetwarzania nuty
                MOV     endOfFile,1		; jesli nie to ustaw flage konca pliku na 1

pobierzNute:    MOV     DX,pauza		; domyslnie ustawiamy rejestr dx na pauze
                MOV     AL,obecnaLinia[0]	; ladujemy do rejestry al pierwszy bajt nuty

                SUB     AL,'A'			; konwertujemy nute na wartosc numeryczna przez odjecie kodu asci A
                CMP     AX,16			; sprawdzamy czy nuta jest wielka litera
                JL      nuta			; jesli jest mniejsza to przechodzimy do obslugi pelnych nut
                JMP     blednaNuta		; skaczemy do wskazanego adresu

nuta:           CMP     AL,15			; sprawdzamy zakres dla pelnych nut
                JE      zwrocPauze		; jesli rowne to skaczemy do wskazanego adresu
                CMP     AL,6			; sprawdzamy czy nuta znajduje sie w odpowiednim zakresie
                JG      blednaNuta		; jesli wieksza przechodzimy do obslugi bledu
                MOV     BX,offset nut		; ladujemy adres tablicy zawierajacej pelne nuty 
                JMP     zwrocNute		; skaczemy do wskazanego adresu

zwrocNute:      XOR     AH,AH			; zerujemy gorne bajty ax
                SAL     AX,1			; przesuwamy nute w lewo o 1 pozycje (mnożenie przez 2)
                MOV     DI,AX			; ladujemy nute do di jako wskaznik
                MOV     DX,[BX][DI]		; pobieramy czestotliwosc nuty z komorki pamieci

zwrocPauze:     MOV     obecnaNuta,DX		; zapisujemy czestotliwosc nuty do komorki pamieci
                JMP     pobierzOktawe		; skaczemy do wskazanego adresu

blednaNuta:	MOV     DX,offset errorNuty	; ustawiamy wskaznik na komunikat o bledzie
                MOV     AH,09h			; ladujemy funkcje, ktora wyswietla ciag znakow do ah
                INT     21h			; wywolanie przerwania
                JMP     koniec			; skaczemy do wskazanego adresu

pobierzOktawe:  MOV     AL,obecnaLinia[1]	; ladujemy do rejestru al oktawe naszej nuty
                SUB     AL,'0'			; konwertujemy znak na wartosc numeryczna
                CMP     AL,1			; sprawdzamy czy oktawa jest wieksza lub rowna 1
                JL      blednaOktawa		; jesli mniejsza to skaczemy do wskazanego adresu
                CMP     AL,7			; sprawdzamy czy oktawa jest mniejsza badz rowna 7
                JG      blednaOktawa		; jesli wieksza to skaczemy do wskazanego adresu
                MOV     obecnaOktawa,AL		; zapisujemy oktawe do komorki pamieci
                JMP     pobierzDlugosc		; skaczemy do wskazanego adresu

blednaOktawa:   MOV     DX,offset errorOktawy	; ustawiamy wskaznik na komunikat o bledzie
                MOV     AH,09h			; ladujemy funkcje, ktora wyswietla ciag znakow do ah
                INT     21h			; wywolanie przerwania
                JMP     koniec			; skaczemy do wskazanego adresu

pobierzDlugosc: MOV     AL,obecnaLinia[2]	; ladujemy do rejestru al dlugosc naszej nuty z komorki pamieci
                CMP     AL,'9'			; sprawdzamy czy jest cyfra
                JLE     zakresCyfra		; jesli mniejsza lub rowna skaczemy do wskazanego adresu
                CMP     AL,'A'			; sprawdzamy czy dlugosc jest litera
                JGE     zakresLitera		; jesli jest wieksza badz rowna skaczemy do wskazanego adresu
                JMP     blednaDlugosc		; skaczemy do wskazanego adresu

zakresCyfra:    SUB     AL,'0'			; konwertujemy cyfre zapisana w asci na wartosc numeryczna
                CMP     AL,1			; sprawdzamy czy jest wieksza badz rowna 1
                JL      blednaDlugosc		; jesli jest mniejsza to skaczemy do wskazanego adresu
                JMP     zwrocDlugosc		; skaczemy do wskazanego adresu

zakresLitera:   SUB     AL,'A'			; konwertujemy litere w asci na wartosc numeryczna
                CMP     AL,16			; sprawdzamy czy dlugosc jest w odpowiednim zakresie
                JG      blednaDlugosc		; jesli jest wieksze to skaczemy do wskazanego adresu

zwrocDlugosc:   MOV     obecnaDlugosc,AX	; zapisujemy dlugosc do komorki pamieci
                JMP     obliczCzesto		; skaczemy do wskazanego adresu

blednaDlugosc:  MOV     DX,offset errorDlugosci	; ustawiamy wskaznik na komunikat o bledzie
                MOV     AH,09h			; ladujemy funkcje, ktora wyswietla ciag znakow do ah
                INT     21h			; wywolanie przerwania
                JMP     koniec			; skaczemy do wskazanego adresu

obliczCzesto:	MOV     AX,obecnaNuta		; ladujemy do rejestru ax czestotliwosc nuty
                CMP     AX,1			; sprawdzamy czy nuta to pauza
                JE      zapiszPauze		; jesli tak to skaczemy do wskazanego adresu 

                XOR     CH,CH			; zerujemy rejestr ch
                MOV     CL,8			; do rejestru cl ladujemy 8
                SUB     CL,obecnaOktawa		; od maksymalnej oktawy odejmujemy oktawe naszej nuty
                MOV     AX,obecnaNuta		; do rejestru ax ladujemy czestotliwosc naszej nuty
                SHR     AX,CL			; przesowamy w zawartosc ax w prawo o zawartosc rejestru cl
                MOV     BX,AX			; przenosimy zawartosc z rejestru ax do rejestru bx

                XOR     DX,DX			; zerujemy zawartosc rejestru dx
                MOV     AX,BPM			; ladujemy zawartosc komorki pamieci do rejestru ax
                DIV     BX			; dzielimy czestotliwosc bazowa przez czestotliwosc naszej nuty
                MOV     BX,100			; ladujemy 100 do rejestru bx
                MUL     BX			; mnozymy zawartosc rejestru ax przez zawartosc rejestru bx
                JMP     graj			; skaczemy do wskazanego adresu

zapiszPauze:    MOV     AX,1			; ladujemy 1 do rejestru ax

graj:           MOV     obecnaNuta,AX		; zapisujemy czestotliwosc do komorki pamieci
                XOR     AH,AH			; zerujemy zawartosc rejestru ah
                MOV     AL,16			; ladujemy 16 do rejestru al
                XOR     DX,DX			; zerujemy zawartosc rejestru dx
                MOV     BX,obecnaDlugosc	; ladujemy dlugosc nuty z komorki pamieci do rejestru bx
                DIV     BX			; dzielimy dlugosc bazowa przez dlugosc naszej nuty
                MOV     obecnaDlugosc,AX	; zapisujemy otrzymana dlugosc do komorki pamieci

                MOV     AX,obecnaNuta		; ladujemy czestotliwosc z komorki pamieci do rejestru ax
                OUT     42h,AL			; wysyłamy zawartosc rejestru al na wyjscie do portu 42h
                MOV     AL,AH			; ladujemy zawartosc rejestru ah do rejestru al
                OUT     42h,AL			; wysylamy zawartosc rejestru al na wyjscie do portu 42h

                IN      AL,61h			; pobieramy stan portu 61h i zapisujemy go do rejestru al
                OR      AL,00000011b		; ustawiamy 2 najmlodsze bity portu 61h na 1, aby uruchomic glosnik i timer
                OUT     61h,AL			; wysylamy zawartosc rejestru al z uruchomionym glosnikiem i timerem do portu 61h

                MOV     CX,obecnaDlugosc	; ladujemy dlugosc nuty z komorki pamieci do rejestru cx
                MOV     AH,86h			; ladujemy funkcje do rejestru ah
                MOV     DX,0FFFFh		; ladujemy do rejestru dx maksymalna wartosc jaka mozna zapisac na 16 bitach
                INT     15h			; wywolujemy przerwanie, ktore wywoluje funkcje czakajaca (CX:DX)

                IN      AL,61h			; pobieramy stan portu 61h i zapisujemy go do rejestru al
                AND     AL,11111100b		; ustawiamy 2 najmlodsze bity al na 0, a reszte pozostawiamy bez zmian, aby wylaczyc glosnik
                OUT     61h,AL			; wysylamy zawartosc rejestru al do portu 61h

                XOR     CX,CX			; zerujemy zawartosc rejestru cx
                MOV     AH,86h			; ladujemy funkcje 86h do rejestru ah 
                MOV     DX,0FFFFh		; ladujemy do rejestru dx 0FFFFh
                INT     15h			; wywolujemy przerwanie, ktore wywoluje funkcje czekania

                XOR     AH,AH			; zerujemy zawartosc rejestru ah
                MOV     AL,endOfFile		; ladujemy zawartosc komorki pamieci do rejestru al
                CMP     AL,1			; sprawdzamy czy jest rowna 1
                JE      koniec			; jesli tak to skaczemy do wskazanego adresu, czyli konczymy program

                JMP     pobierzLinie		; jesli nie to skaczemy do wskazanego adresu aby pobrac kolejne nuty

koniec:         MOV     AH,4Ch
                XOR     AL,AL
                INT     21h
prog            ends

dane            segment
BPM             DW      11931 ;1193180 Hz/100
nut             DW      7040,7902,4186,4699,5274,5588,6272 ;A8, B8, C8, D8, E8, F8, G8 Hz
pauza           DW      1
plik          	DB      127     dup(?)
                DW      0
dolla           DB      10,13,'$'
idPliku         DW      ?
obecnaLinia     DB      5       dup(?)
obecnaNuta      DW      ?
obecnaOktawa    DB      ?
obecnaDlugosc   DW      ?
endOfFile       DB      0
obecnyUtwor     DB      "Obecny utwor to: $"
errorParametru  DB      "Nie podano pliku",10,13,'$'
errorNazwy      DB      "Taki plik nie istnieje",10,13,'$'
errorNuty       DB      "Blednie zapisana nuta",10,13,'$'
errorOktawy     DB      "Blednie zapisana oktawa",10,13,'$'
errorDlugosci   DB      "Bledna dlugosc nuty",10,13,'$'
dane            ends

stosik          segment
                DW      100h    dup(0)
szczyt          Label   WORD
stosik          ends
end             start