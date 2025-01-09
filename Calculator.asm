	 ORG 800H  
START  
	 LXI H,LICZBA1  ; ładujemy wiadomość o wprowadzeniu pierwszej liczby do pary rejestrów HL
	 RST 3  ; wyświetlamy zawartośc HL na ekran
	 CALL PODAJZNAK  ; wywołujemy podprogram odpowiedzialny za wprowadzanie liczby
	 STA TMPNUMBER  ; wpisujemy wartosc z akumulatora, czyli pierwsza liczbe podanej komorki w pamieci
	 LDA ZNAK1  ; wpisujemy wartosc z podanej komorki w pamieci do akumulatora (znak pierwszej liczby)
	 STA ZNAK2  ; wpisujemy wartosc z akumulatora do podanej komorki w pamieci, poniewaz gdy bedziemy wprowadzac druga liczbe zastapilibysmy znak pierwszej liczby, wiec musimy go przeniesc aby go nie utracic
	 LXI H,LICZBA2  ; wpisujemy do pary rejestrow HL wiadomosc zawarta pod podanym adresem
	 RST 3  ; drukujemy lancuch znakow z pary rejestrow HL do @
	 CALL PODAJZNAK  ; wywolujemy podprogram odpowiedzialny za wprowadzenie liczby
	 LDA TMPNUMBER  ; wpisujemy wartosc z podanej komorki do akumulatora (pierwsza liczbe)
	 MOV E,A  ; przenosimy wartosc z akumulatora do rejestru E (pierwsza liczba)
	 MOV L,B  ; przenosimy wartosc z rejestru B do rejestru L (druga liczba)
	 CALL STARTMNOZ  ; wywolujemy podprogram odpowiedzialny za mnozenie dwoch liczb
	 MOV B,H  ; przenosimy wartosc z rejestru H do rejestru B (starszy bajt wyniku mnozenia)
	 MOV C,L  ; przenosimy wartosc z rejestru L do rejestru C (mlodszy bajt wyniku mnozenia)
	 LXI H,WYNIK  ; wpisujemy do pary rejestrow HL lancuch znakow wskazywany przez podany adres 
	 RST 3  ; drukujemy lancuch znakow z pary rejestrow HL do @
	 LDA ZNAK1  ; wpisujemy wartosc z podanej komorki do akumulatora (znak drugiej liczby)
	 MOV H,A  ; przenosimy wartosc z akumulatora do rejestru H 
	 LDA ZNAK2  ; wpisujemy wartosc z podanej komorki do akumulatora (znak pierwszej liczby)
	 ADD H  ; dodajemy do wartosci akumulatora wartosci z rejestru H
	 CPI 01H  ; sprawdzamy czy wartosc akumulatora jest rowna 1, aby sprawdzic jaki znak powinien miec wynik mnozenia
	 JZ WRMINUS  ; jezeli jest rowna 1 skaczemu do podanego adresu (mamy minus)
	 JMP WRPLUS  ; jezeli nie jest rowna 1 to wykonujemy skok bezwarunkowy do podanego adresu (mamy plus)
BACK  
	 LXI H,WYNIKBIN  ; wpisujemy do pary rejestrow HL adres podanej etykiety
	 MOV M,C  ; wartosc z rejestru C zostaje zapisana pod adresem wskazywanym przez HL
	 INX H  ; inkrementujemy wartosc rejestrow HL o 1, co przesuwa wskaznik na nastpena komorke pamiecia 
	 MOV M,B  ; wartosc z rejestru B zostaje zapisana pod adresem wskazywanym przez HL
	 MVI D,16  ; wpisujemy podana wartosc do rejestru D (licznik dla petli)
KONWERSJA  
	 MVI B,5  ; ladujemy wartosc 5 do rejestru B (licznik wewnetrznej petli)
	 LXI H,WYNIKDEC  ; wpisujemy do pary rejestrow HL adres podanej etykiety 
BINTODEC  
	 MOV A,M  ; zapisujemy wartosc ktora znajduje sie pod adresem wskazywanym przez pare rejestrow HL do akumulatora
	 ADD M  ; dodajemy wartosc z komorki pamieci wskazywanej przez HL do akumulatora
	 MOV M,A  ; zapisujemy wartosc akumulatora do komorki pamieci wskazywanej przez adres HL
	 INX H  ; inkrementujemy pare rejestrów HL, przesuwając wskaznik na kolejna komorke pamieci
	 DCR B  ; dekrementujemy wartosc rejestru B (licznik wewnetrznej petli)
	 JNZ BINTODEC  ; jesli wartosc rejestru B nie jest 0 skaczemy do wskazanego adresu
	 MVI C,0  ; ustawiamy wartosc rejestru C na 0
	 LXI H,WYNIKBIN  ; wpisujemy do pary rejestrow HL adres podanej etykiety
	 MOV A,D  ; zapisujemy wartosc rejestru D do akumulatora (D zawiera liczbe iteracji petli)
	 CPI 9  ; sprawdzamy czy zawartosc akumulatora jest rowna 9
	 JM NOCARRY  ; jesli zawartosc akumulatora jest mniejsza skaczemy do wskazanego adresu
	 INX H  ; inkrementujemy rejestr HL, ktory teraz bedzie wskazywal na kolejna komorke pamieci (poniewaz w jednej komorce pomiescimy tylko 8 bitow czyli 1 bajt)
NOCARRY  
	 MOV A,M ; zapisujemy wartosc ktora znajduje sie pod wskazywanym adresem przez pare rejestrow do akumulatora
	 RAL  ; przesuwa bity w akumulatorze o jeden w lewo (uwzględnia flage przeniesienia jesli wystąpi)
	 JNC SETSKIP  ; jesli nie wystapilo przeniesienie skaczemy do wskazanego adresu
	 MVI C,1  ; jesli wystpailo przeniesienie ustawiamy wartosc rejestru C na 1
SETSKIP  
	 MOV M,A  ; zapisujemy wartosc akumulatora do komorki pamieci wskazywanej przez pare rejestrow HL
	 MVI B,5  ; zapisujemy wartosc 5 do rejestru B
	 LXI H,WYNIKDEC  ; wpisuje do pary rejestrow HL adres podanej etykiety
CARRY  
	 MOV A,M  ; zapisuje wartosc ktora znajduje sie pod wskazywanym adresem przez pare rejestrow do akumulatora
	 ADD C  ; dodaje zawartosc rejestru C do akumulatora (przeniesienie jesli wystepuje)
	 MVI C,0  ; czyszcze zawartosc rejestru C
	 CPI 10  ; sprawdzamy czy wartosc akumulatora jest rowna 10
	 JM SKIPCARRY  ; jesli jest mniejsza to skaczemy do wskazanego adresu
	 SUI 10  ; odejmujemy od zawartosci akumulatora 10 (przeniesienie do nastepeniej cyfry)
	 MVI C,1  ; ustawiamy zawartosc rejestru C na 1 (oznaczamy przeniesienie)
SKIPCARRY  
	 MOV M,A  ; zapisujemy wartosc z akumulatora do komorki wskazywanej przez pare rejestrow
	 INX H  ; inkrementujemy H, aby przesunac wskaznik do nastepnej komorki pamieci
	 DCR B  ; dekrementujemy wartosc rejestru B (liczba petli)
	 JNZ CARRY  ; jesli wartosc rejestru B nie jest zerem wracmy do poczatku petli
	 DCR D  ; dekrementujemy wartosc rejestru D (licznik petli glownej)
	 JNZ KONWERSJA  ; jesli licznik petli glownej nie jest zerem wracamy do wskazanego adresu
	 MVI B,4  ; zapisujemy wartosc 4 do rejestru B
	 LXI H,WYNIKDEC  ; wpisuje do pary rejestrow HL
ZWIEPETLA  
	 INX H  ; zwiększa wskaźnik w rejestrach HL, wskazując na następną komórkę pamięci
	 DCR B  ; zmniejsza wartość w rejestrze B
	 JNZ ZWIEPETLA  ; jeśli B nie jest zerem, wraca do początku pętli, by kontynuować operację
	 MVI B,5  ; ustawia wartość rejestru B na 5
WYPISZLICZB  
	 MOV A,M  ; kopiuje wartość z komórki pamięci wskazywanej przez HL do rejestru A.
	 ADI 30H  ; dodaje wartosc 30H do akumulatora
	 RST 1  ; wydruk znaku z akumulatora na monitor
	 DCX H  ; dekrementacja pary rejestrow HL
	 DCR B  ; dekrementacja rejestru B
	 JNZ WYPISZLICZB  ; jesli nie zero to skocz do podanego adresu
	 MVI B,2  ; ustawi wartosc rejestru B na 2
	 LXI H,WYNIKBIN  ; laduje adres etykiety do rejestrow HL
CLEARBIN  
	 MVI M,0  ; zerujemy wartosc w komorce pamieci HL
	 INX H  ; ikrementujemy pare rejestrow HL
	 DCR B  ; dekrementujemy rejestr B
	 JNZ CLEARBIN  ; jesli nie zero to skocz do wskazanego adresu
	 MVI B,5  ; ustawia wartosc rejestru B na 5
	 LXI H,WYNIKDEC  ; laduje adres etykiety do rejestrow HL
CLEARBCD  
	 MVI M,0 ; ustawia wartosc pary rejestrow HL na 0  
	 INX H  ; inkrementuje pare rejestrow HL
	 DCR B  ; dekrementuje rejestr B
	 JNZ CLEARBCD    ; jesli nie zero to skaczemy do adresu wskazanego etykieta
	 HLT ; koniec programu
WRMINUS  
	 LXI H,WRMINUSW  ; wpisujemy do pary rejestrow HL wartosc znajdujaca sie pod wskazanym adresem
	 RST 3  ; drukujemy lancuch znakow z pary rejestrow HL do @
	 CALL BACK  ; wywolujemy podprogram 
WRPLUS  
	 LXI H,WRPLUSW   ; wpisujemy do pary rejestrow HL wartosc znajdujaca sie pod wskazanym adresem
	 RST 3  ; drukujemy lancuch znakow z pary rejestrow HL do @
	 CALL BACK  ; wywolujemy podprogram
PODAJZNAK  
	 RST 2  ; użytkownik podaje znak liczby
	 CPI 2BH  ; sprawdzamy czy znak jest + poprzez kod ASCI
	 JZ PLUS  ; jeżeli porównanie jest równe 0 to przeskakujemy do PLUS
	 CPI 2DH  ; sprawdzamy czy znak jest - poprzez kod ASCI
	 JZ MINUS  ; jeżeli porównanie jest równe 0 to przeskakujemy do MINUS
	 JMP BLAD  ; jeżeli oba porównania nie były równe wykonujemy obsługę niepoprawnej liczby
PLUS  
	 MVI A,00H  ; zapisujemy w akumulatorze wartość 00H, ponieważ tak chcemy oznaczyć +
	 STA ZNAK1  ; zapisujemy zawartość akumulatora do miejsca w pamięci oznaczonego etykietą ZNAK1 (pod wskazany adres)
	 JMP SETPOSNUMBER  ; bezwarunkowy skok do adresu pod etykietą SETPOSNUMBER
MINUS  
	 MVI A,01H  ; zapisujemy w akumulatorze wartość 01H, ponieważ tak oznaczamy -
	 STA ZNAK1  ; zapisujemy zawartość akumulatora do miejsca w pamięci oznaczonego etykietą ZNAK1 (pod wskazany adres)
	 JMP SETNEGNUMBER  ; bezwarunkowy skok do adresu pod etykietą SETNEGNUMBER
BLAD  
	 LXI H,ERROR2  ; ładujemy komunikat, który znajduje się pod adresem etykiety ERROR2 do pary rejestrów
	 RST 3  ; wyświetlamy zawartośc pary rejestrów na ekran
	 JMP PODAJZNAK  ; wracamy do miejsca, w którym użytkownik od początku będzie mógł wproawdzić liczbę
SETPOSNUMBER  
	 RST 2  ; użytkownik wprowadza cyfre 
	 CALL SPRASCIIP  ; wywołujemy podprogram sprawdzający poprawnośc cyfry
	 MOV B,A  ; zapisujemy zawartosc akumulatora do rejestru B (czyli pierwsza cyfre, u nas setki)
	 RST 2  ; uzytkownik wprowadza druga cyfre
	 CALL SPRENTERP  ; wywolujemy podpogram 
	 MOV C,A  ; zapisujemy zawartosc akumulatora do rejestru C (czyli druga cyfre, u nas dziesiatki)
	 CPI 0DH  ; sprawdzamy czy podana cyfra jest enterem
	 JZ JEDNOSCIP  ; jezeli tak to wykonujemy OBSLJEDNOCYFR
	 RST 2  ; uzytkownik wprowadza trzecia cyfre
	 CALL SPRENTERP  ; wywolujemy podprogram sprawdzajacy czy uzytkownik nie wprowadzil entera
	 MOV D,A  ; zapisujemy zawartosc akumulatora do rejestru D (czyli trzecia cyfre, u nas jednosci)
	 CPI 0DH  ; sprawdzamy czy podana cyfra jest enterem
	 JZ DZIESIATKIP  ; jezeli tak to wykonujemy DZIESIATKIP
	 JMP CHECKRANGEP  ; skaczemy do miejsca gdzie sprawdzimy czy liczba jest w odpowiednim zakresie
SPRENTERP  
	 CPI 0DH  ; sprawdzamy czy podana cyfra jest enterem
	 RZ  ; jeżeli jest enterem to wychodzimy z podprogramu odpowiedzialnego za wrowadzanie liczby, a jeżeli nie to kontynujemy podprogram, czyli wykonujemy kolejne rozkazu podprogramu
SPRASCIIP  
	 CPI 30H  ; sprawdzamy czy podaną cyfre jest mniejsca od 0 za pomocą ASCI
	 JM BLAD2  ; jeżeli mniejsza skaczemy do BLAD2
	 CPI 3AH  ; sprawdzamy czy cyfra jest rowna ':' czyli znakowi o 1 wiekszy w kodzie ASCI od 9
	 JP BLAD2  ; jeżeli większa lub rowna skaczemy do BLAD2
	 SUI 30H  ; odejmujemy od zawartosci akumulatora wartosc 30H, aby cyfry bylo w kodzie dziesietnym a nie ASCI
	 RET  ; wychodzimy z podprogramu
JEDNOSCIP  
	 MOV D,B  ; zapisujemy zawartosc rejestry B do rejestru D (poniewaz w rejestrze D chcemy przechowywac cyfyry jednosci)
	 MVI B,0  ; czyscimy rejestr B
	 MVI C,0  ; czyscimy rejestr C
	 JMP CHECKRANGEP  ; przeskakujemy do sprawdzania czy liczba jest w odpowiednim zakresie
DZIESIATKIP  
	 MOV D,C  ; zapisujemy zawartosc rejestru C do rejestru D (poniewaz w rejestrze D przechowujemy jednosci)
	 MOV C,B  ; zapisujemy zawartosc rejestru B do rejestru C (poniewaz w rejestrze C przechowujemy dziesiatki)
	 MVI B,0  ; czyscimy rejestr B
CHECKRANGEP  
	 MOV A,B  ; zapisujemy zawartosc rejestru B do akumulatora, ponieważ bedziemy sprawdzac czy setki sa w dobrym zakresie
	 CPI 2    ; sprawdzamy czy cyfra setek jest rowna 2 
	 JP BLAD3  ; jesli cyfra rowna lub wieksza skocz do wskazanego adresu
	 CPI 1  ; sprawdzamy czy cyfra setek jest rowna 1
	 JNZ SKIPCHECK  ; jesli nie jest rowna 1 to skaczemy do wskazanego adresu
	 MOV A,C  ; zapisujemy zawartosc rejestru C do akumulatora, poniewaz bedziemy sprawdzac czy dziesiatki sa w dobrym zakresie
	 CPI 3  ; sprawdzamy czy liczba dziesiatek jest rowna 3 
	 JP BLAD3  ; jesli cyfra jest rowna lub skocz do wskazanego adresu
	 CPI 2  ; sprawdzamy czy liczba dziesiatek jest rowna 2
	 JNZ SKIPCHECK  ; jesli nie jest rowna 2 to skaczemy do wskazanego adresu
	 MOV A,D  ; zapisujemy zawartosc rejestru D do akumulatora, poniewaz bedziemy sprawdzac czy jednosci sa w dobrym zakresie
	 CPI 8 ; sprawdzamy czy liczba JEDNOSCIP jest rowna 8 
	 JP BLAD3  ; jesli jest wieksza skaczemy do wskazanego adresu
	 JMP SKIPCHECK  ; jesli wszystkie warunku zostaly spelnione skaczemy do wskazanego adresu
SETNEGNUMBER  
	 RST 2  ; użytkownik wprowadza pierwsza cyfre
	 CALL SPRASCIIN  ; wywołujemy podprogram sprawdzającay poprwnosc cyfry
	 MOV B,A  ; zapisujemy wartosc akumulatora do rejestru B (u nas setki)
	 RST 2  ; uzytwkonik wprowadza druga cyfre
	 CALL SPRENTERN  ; wywolanie podprogramu sprawdzajacego czy uzytkownik nie podal entera
	 MOV C,A  ; zapisujemy zawartosc akumulatora do rejestru C (u nas dziesiatki)
	 CPI 0DH  ; sprawdzamy czy podana cyfra jest enterem
	 JZ JEDNOSCIN  ; jezeli tak to skaczemy do wskazanego adresu
	 RST 2  ; uzytkownik wprowadza 3 cyfre
	 CALL SPRENTERN  ; wywolanie podprogramu sprawdzajacego czy uzytkownik nie podal entera
	 MOV D,A  ; zapisujemy zawartosc akumulatora do rejestru D (u nas jednosci)
	 CPI 0DH  ; sprawdzamy czy podana cyfra nie jest enterem

	 JZ DZIESIATKIN  ; jeseli jest enterem to skaczemy do wskazanego adresu
	 JMP CHECKRANGEN  ; skaczemy do wskazanego adresu aby sprawdzic czy liczba jest w dobrym zakresie
SPRENTERN  
	 CPI 0DH  ; sprawdzamy czy podana cyfra jest rowna znakowi ASCI reprezentujacemu ENTER
	 RZ  ; jezeli jest enterem to wychodzimy z tego podprogramu, a jezeli nie jest to wykonujemy ponizsze rozkazy
SPRASCIIN  
	 CPI 30H  ; sprawdzamy czy podana cyfra jest rowna 0 za pomoca ASCI
	 JM BLAD2  ; jezeli jest mniejsza to cyfra jest niepoprawna i skaczemy do podanego adresu
	 CPI 3AH  ; sprawdzamy czy cyfra jest rowna ':' czyli znakowi o 1 wiekszy w kodzie ASCI od 9
	 JP BLAD2  ; jezeli jest rowna lub wieksza to skaczemy do wskazanego adresu
	 SUI 30H  ; odejmujemy od zawartosci akumulatora wartosc 30H aby miec cyfre w zapisie dziesietnym a nie ASCI
	 RET  ; wychodzimy z podprogramu
JEDNOSCIN  
	 MOV D,B  ; zapisujemy zawartosc z rejestru B do rejestru D (bo w rejestrze D przechowujemy cyfry jednosci)
	 MVI B,0  ; czyscimy rejestr B (nie mamy setek)
	 MVI C,0  ; czyscimy rejestr C (nie mamy dziesiatek)
	 JMP CHECKRANGEN  ; skaczemy do wskazanego adresu aby sprawdzic czy liczba jest w dobrym zakresie
DZIESIATKIN  
	 MOV D,C  ; zapisujemy zawartosc z rejestru C do rejestru D (bo w rejestrze D przechowujemy cyfry jednosci)
	 MOV C,B  ; zapisujemy zawartosc z rejestru B do rejestru C (bo w rejestrze C przechowujemy cyfry dziesiatek)
	 MVI B,0  ; czyscimy rejestr B (nie mamy setek)
CHECKRANGEN  
	 MOV A,B  ; zapisujemy zawartosc z rejestru B do akumulatora (sprawdzamy setki)
	 CPI 2  ; sprawdzamy czy cyfra setek jest rowna 2
	 JP BLAD3  ; jezeli jest rowna lub wieksza przeskakujemy do wskazanego adresu
	 CPI 1  ; sprawdzamy czy cyfra setek jest rowna 1
	 JNZ SKIPCHECK  ; jezeli jest rozna od 1 to skaczemy do wskazanego adresu, bo nie musimy sprawdzac dalej dziesiatek i jednosci
	 MOV A,C  ; zapisujemy zawartosc rejestru C do akuulatora (sprawdzamy dziesiatki)
	 CPI 3  ; sprawdzamy czy cyfra dziesiatek jest rowna 3
	 JP BLAD3  ; jezeli jest rowna lub wieksza to skaczemy do wskazanego adresu
	 CPI 2  ; sprawdzamy czy cyfra dziesiatek jest rowna 2
	 JNZ SKIPCHECK  ; jesli nie jest rowna 2 to skaczemy do wskazanego adresu
	 MOV A,D  ; zapisujemy zawartosc rejestru D do akumulatora (sprawdzamy jednosci)
	 CPI 9  ; sprawdzamy czy cyfra jednosci jest rowna 9
	 JP BLAD3  ; jezeli jest wieksza to skaczemy do wskazanego adresu
SKIPCHECK  
	 MOV A,C  ; zapisujemy zawartosc rejestru C do akumulatora (dziesiatki)
	 CPI 0  ; sprawdzamy czy cyfra jest rowna 0
	 JZ SKIPDZIES  ; jesli jest rowna 0 to skaczemy do wskazanego adresu, gdyz mozemy pominac mnozenie przez 10
	 MVI E,10  ; wpisujemy wartosc 10 do rejestru E, poniewaz musimy wykonac mnoozenie przez 10
	 MOV L,C  ; zapisujemy cyfre dziesiatek do rejestru L
	 CALL STARTMNOZ  ; wywolujemy program znajdujacy sie pod wskazanym adresem aby wykonac mnozenie
	 MOV C,L  ; otrzymany wynik zapisujemy z rejestru L do rejestru C (czyli jezeli podalismy 4 jako cyfre dziesiatek to mamy teraz 40)
SKIPDZIES  
	 MOV A,B  ; zapisujemy do akumulatora zawartosc rejestru B (setki)
	 CPI 0  ; sprawdzamy czy cyfra setek jest rowna 0
	 JZ SKIPSETEK  ; jesli jest rowna 0 to skaczemy do wskazanego adresu, bo mozemy pominac mnozenie przez 100
	 MVI E,100  ; wpisujemy wartosc 100 do rejestru E, poniewaz musimy wykonac mnozenie przez 100
	 MOV L,B  ; cyfre setek zapisujemy z rejestru B do rejestru L
	 CALL STARTMNOZ  ; wywolujemy podprogram znajdujacy sie pod podanym adresem aby wykonac mnozenie
	 MOV B,L  ; otrzymany wynik zapisujemy z rejestru L do rejestru B (czyli jezeli podalismy 3 jako cyfre setek to mamy tam teraz 300)
SKIPSETEK  
	 MOV A,B  ; zapisujemy zawartosc rejestru B do akumulatora (setki)
	 ADD C  ; dodajemy do zawartosci akumulatora zawartosc rejestru C (dziesiatki)
	 ADD D  ; dodajemy do zawartosci akumulatora zawartosc rejestru D (jednosci)
	 MOV B,A  ; otrzymany wynik zapisujemy z akumulatora do rejestru B
	 RET  ; wychodzimy z podprogramu
STARTMNOZ  
	 MVI H,0  ; czyscimy rejestr H, aby miec miejsce do przechowywani liczby ktora zajmuje wiecej miejsca niz 8 bitow
	 MVI A,0  ; czyscimy akumulator, bo bedziemy tam dodawac w petli liczbe (czyli bedziemy tak przechowywac wynik mnozenia)
MNOZENIE  
	 ADD L  ; do wartosci akumulatora dodajemy wartosc rejestru L
	 JNC SMALLNUMBER  ; jezeli liczba zajmuje mniej miejsca niz 8 bitow to skaczemy do wskazanego adresu
	 INR H  ; inkrementujemy wartosc rejestru H, poniewaz wystapilo przeniesienie, czyli liczba nie miesci sie w 8 bitach
SMALLNUMBER  
	 DCR E  ; dekrementujemy wartosc rejestru E, ktory jest u nas licznikiem petli, czyli ile razy musimy dodac do akumulaotra liczbe
	 JNZ MNOZENIE  ; jezeli licznik petli sie nie wyzerowal to skaczemy do wskazanego adresu
	 MOV L,A  ; gdy licznik petli sie wyzeruje zapisujemy zawartosc akumulatora do rejestru L (czyli wynik mnozenia)
	 RET  ; wychodzimy z podprogramu
BLAD2  
	 INX SP  ; inkrementujemy stack pointer
	 INX SP  ; inkrementujemy stack pointer
	 JP BLAD3  ; jeżeli flaga znaku = 0 skaczemu do BLAD3
BLAD3  
	 LXI H,ERROR ; ładujemy do pary rejestrów HL komunikat ktory znajduje sie pod adresem etykiety WPROWDZPON  
	 RST 3  ; wyswietlamy zawartosc pary rejestrow HL na ekran
	 MVI H,0  ; czyscimy pare rejestrow HL
	 JMP PODAJZNAK  ; skaczemu do adresu pod etykieta PODAJZNAK
          
ERROR  
	 DB 10,13,'Liczba musi byc z przedzialu (-128 do 127): @' 
ERROR2  
	 DB 10,13,'Podano nieprawidlowy znak, podaj +/-: @' 
LICZBA1  
	 DB 'Podaj liczbe z przedzialu (-128 do 127): @'           
LICZBA2  
	 DB 10,13,'Podaj liczbe z przedzialu (-128 do 127): @' 
WYNIKDEC  
	 DB 0,0,0,0,0           
WYNIKBIN  
	 DB 0,0           
WYNIK  
	 DB 10,13,'Wynik z mnozenia wynosi: @'           
WRMINUSW  
	 DB '-@'           
WRPLUSW  
	 DB '+@'           
TMPNUMBER  
	 DB 0                     
ZNAK1  
	 DB 0           
ZNAK2  
	 DB 0           
        
