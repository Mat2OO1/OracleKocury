/* zadanie 34  */
DECLARE
    fun Kocury.funkcja%TYPE := &funkcja;
BEGIN
    SELECT funkcja INTO fun FROM KOCURY WHERE funkcja = fun AND ROWNUM = 1;
    IF (SQL%FOUND) THEN
        DBMS_OUTPUT.PUT_LINE('ZNALEZIONO KOTA O FUNKCJI ' || fun);
    END IF;
    EXCEPTION
        WHEN OTHERS
            THEN DBMS_OUTPUT.PUT_LINE('BRAK TAKIEGO KOTA');
END;

/* zadanie 35  */
DECLARE
    kot KOCURY%ROWTYPE;
    bool BOOLEAN := TRUE;
BEGIN
    SELECT * INTO kot FROM Kocury WHERE pseudo= &pseudo;
    IF (kot.przydzial_myszy + NVL(kot.myszy_extra,0)) * 12 > 700
    THEN
        bool := FALSE;
        DBMS_OUTPUT.PUT_LINE('calkowity roczny przydzial myszy > 700');
    END IF;

    IF kot.imie LIKE '%A%' THEN
        bool := FALSE;
        DBMS_OUTPUT.PUT_LINE('imie zawiera litere A');
    END IF;

    IF EXTRACT(MONTH FROM kot.W_STADKU_OD) = 5 THEN
        bool := FALSE;
        DBMS_OUTPUT.PUT_LINE('maj jest miesiacem przystapienia do stada');
    END IF;

    IF bool THEN
        DBMS_OUTPUT.PUT_LINE('nie odpowiada kryteriom');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('BRAK TAKIEGO KOTA');
END;
/* zadanie 36  */
DECLARE
    CURSOR Koty IS
        SELECT pseudo,imie, PRZYDZIAL_MYSZY, MAX_MYSZY
        FROM Kocury k LEFT JOIN FUNKCJE F ON k.FUNKCJA = F.FUNKCJA
        ORDER BY PRZYDZIAL_MYSZY;
    suma NUMBER(4) := 0;
    zmiany NUMBER(2) :=0;
BEGIN
    LOOP
        SELECT SUM(przydzial_myszy) INTO suma FROM Kocury;
        EXIT WHEN suma > 1050;
        FOR kot IN Koty
        LOOP
            IF(kot.PRZYDZIAL_MYSZY * 1.1 > kot.MAX_MYSZY)
                THEN kot.PRZYDZIAL_MYSZY := kot.MAX_MYSZY;
            ELSE kot.PRZYDZIAL_MYSZY := (kot.PRZYDZIAL_MYSZY * 1.1);
                zmiany := zmiany + 1;
            END IF;
            suma := suma + kot.PRZYDZIAL_MYSZY;
            UPDATE KOCURY k
            SET k.PRZYDZIAL_MYSZY = kot.PRZYDZIAL_MYSZY
            WHERE k.pseudo = kot.pseudo;
            END LOOP;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Calk. przydzial w stadku ' || suma || ' Zmian - ' || zmiany);

end;


SELECT imie, PRZYDZIAL_MYSZY FROM KOCURY
ORDER BY PRZYDZIAL_MYSZY;
ROLLBACK;

/* zadanie 37  */
DECLARE
    CURSOR Koty IS
        SELECT ROWNUM nr, RPAD(pseudo, 9, ' ') pseudo, LPAD(przydzial,3,' ') przydzial
        FROM (SELECT pseudo, PRZYDZIAL_MYSZY + NVL(MYSZY_EXTRA,0) przydzial FROM KOCURY
                ORDER BY przydzial DESC)
        WHERE ROWNUM <= 5;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Nr Pseudonim Zjada');
    DBMS_OUTPUT.PUT_LINE('------------------');
    FOR kot IN Koty
    LOOP
        DBMS_OUTPUT.PUT_LINE(kot.nr || '  ' || kot.pseudo || '  ' || kot.przydzial);
    END LOOP;
END;

/* zadanie 38  */
DECLARE
    ilosc_przelozonych NUMBER(2):= &max_liczba_przelozonych;
    max_lvl NUMBER(2);
    sql_cmd VARCHAR(1000);
    sql_cmd2 VARCHAR(1000);
BEGIN
    SELECT MAX(lvl) INTO max_lvl
    FROM (SELECT imie szef, CONNECT_BY_ROOT imie "Imie", level lvl
          FROM Kocury k
          CONNECT BY pseudo = PRIOR szef
          START WITH funkcja IN ('MILUSIA', 'KOT'));
    IF ilosc_przelozonych < max_lvl THEN
        max_lvl := ilosc_przelozonych;
    END IF;

    DBMS_OUTPUT.PUT('Imie       ');
    FOR i in 1..max_lvl
    LOOP
        DBMS_OUTPUT.PUT('| Szef' || TO_CHAR(i) || '      ');
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('| ');

    sql_cmd:= 'SELECT RPAD(k.imie,10, '' '') imie, RPAD(k1.imie, 10, '' '') szef1';
    FOR i in 2..max_lvl
    LOOP
        sql_cmd := sql_cmd || ', RPAD(DECODE(k' || TO_CHAR(i) || '.imie, null, '' '', k' || TO_CHAR(i) || '.imie),10, '' '') szef' || TO_CHAR(i) ;
    END LOOP;
    sql_cmd := sql_cmd || ' FROM Kocury k JOIN Kocury k1 ON k.szef=k1.pseudo ';
    FOR i in 2..max_lvl
    LOOP
        sql_cmd := sql_cmd || 'LEFT JOIN Kocury k' || TO_CHAR(i) || ' ON k' || TO_CHAR(i-1) || '.szef=k' || TO_CHAR(i) || '.pseudo ';
    END LOOP;
    sql_cmd := sql_cmd || 'WHERE k.funkcja IN (''KOT'', ''MILUSIA'');';

    sql_cmd2:='DECLARE CURSOR szefowie IS ' || sql_cmd || '
            BEGIN
                FOR s IN szefowie
                LOOP
                    DBMS_OUTPUT.PUT_LINE(s.imie || '' | '' || s.szef1';
    FOR i in 2..max_lvl
    LOOP
        sql_cmd2:= sql_cmd2 || ' || '' | '' || s.szef' || TO_CHAR(i);
    END LOOP;
    sql_cmd2:= sql_cmd2 || ');
          END LOOP;
        END;';
    EXECUTE IMMEDIATE sql_cmd2;

end;

/* zadanie 39 */
DECLARE
    nrBandy Bandy.nr_bandy%TYPE;
    nazwaBandy Bandy.nazwa%TYPE;
    terenBandy Bandy.teren%TYPE;
    nr_mniejszy EXCEPTION;
    exist EXCEPTION;
    nr_correct BOOLEAN := false;
    nazwa_correct BOOLEAN := false;
    teren_correct BOOLEAN := false;
    komunikat VARCHAR(100);
    nr NUMBER(2);
BEGIN
    nrBandy := ?;
    nazwaBandy := ?;
    terenBandy := ?;
    IF nrBandy <=0 THEN raise nr_mniejszy;
    END IF;
    SELECT COUNT(*) INTO nr FROM Bandy b WHERE nrBandy=b.nr_bandy;
    IF nr =0 THEN nr_correct := true;
    END IF;
    SELECT COUNT(*) INTO nr FROM Bandy b WHERE nazwaBandy=b.NAZWA;
    IF nr =0 THEN nazwa_correct := true;
    END IF;
    SELECT COUNT(*) INTO nr FROM Bandy b WHERE terenBandy=b.TEREN;
    IF nr =0 THEN teren_correct := true;
    END IF;
    IF nr_correct AND nazwa_correct AND teren_correct THEN
        INSERT INTO Bandy(nr_bandy, nazwa, teren)
        VALUES(nrBandy, nazwaBandy, terenBandy);
    ELSE
        raise exist;
    END IF;

EXCEPTION
    WHEN nr_mniejszy THEN
        DBMS_OUTPUT.PUT_LINE('Numer bandy mniejszy od 0');
    WHEN exist THEN
        IF NOT nr_correct  THEN
            komunikat := TO_CHAR(nrBandy) || ' ';
        END IF;
        IF NOT nazwa_correct THEN
            komunikat := komunikat || nazwaBandy || ' ';
        END IF;
        IF NOT teren_correct THEN
            komunikat := komunikat || terenBandy || ' ';
        END IF;
        komunikat:= komunikat || ': juz istnieje';
        DBMS_OUTPUT.PUT_LINE(komunikat);

end;
ROLLBACK;

/* zadanie 40 */
CREATE OR REPLACE PROCEDURE dodaj_bande (nrBandy Bandy.nr_bandy%TYPE, nazwaBandy Bandy.nazwa%TYPE, terenBandy Bandy.teren%TYPE)
AS
    nr_mniejszy EXCEPTION;
    exist EXCEPTION;
    nr_correct BOOLEAN := false;
    nazwa_correct BOOLEAN := false;
    teren_correct BOOLEAN := false;
    komunikat VARCHAR(100);
    nr NUMBER(2);
BEGIN
    IF nrBandy <=0 THEN raise nr_mniejszy;
    END IF;
    SELECT COUNT(*) INTO nr FROM Bandy b WHERE nrBandy=b.nr_bandy;
    IF nr =0 THEN nr_correct := true;
    END IF;
    SELECT COUNT(*) INTO nr FROM Bandy b WHERE nazwaBandy=b.NAZWA;
    IF nr =0 THEN nazwa_correct := true;
    END IF;
    SELECT COUNT(*) INTO nr FROM Bandy b WHERE terenBandy=b.TEREN;
    IF nr =0 THEN teren_correct := true;
    END IF;
    IF nr_correct AND nazwa_correct AND teren_correct THEN
        INSERT INTO Bandy(nr_bandy, nazwa, teren)
        VALUES(nrBandy, nazwaBandy, terenBandy);
    ELSE
        raise exist;
    END IF;

EXCEPTION
    WHEN nr_mniejszy THEN
        DBMS_OUTPUT.PUT_LINE('Numer bandy mniejszy od 0');
    WHEN exist THEN
        IF NOT nr_correct  THEN
            komunikat := TO_CHAR(nrBandy) || ' ';
        END IF;
        IF NOT nazwa_correct THEN
            komunikat := komunikat || nazwaBandy || ' ';
        END IF;
        IF NOT teren_correct THEN
            komunikat := komunikat || terenBandy || ' ';
        END IF;
        komunikat:= komunikat || ': juz istnieje';
        DBMS_OUTPUT.PUT_LINE(komunikat);

end;

BEGIN
    dodaj_bande(&nr, &nazwa, &teren);
end;

ROLLBACK;

/* zadanie 41 */
CREATE OR REPLACE TRIGGER nr_bandy
BEFORE INSERT ON BANDY
FOR EACH ROW
DECLARE
    nr_bandy Bandy.nr_bandy%TYPE;
BEGIN
    SELECT MAX(nr_bandy) INTO nr_bandy FROM Bandy;
    :NEW.nr_bandy := nr_bandy+1;
END;
BEGIN
    dodaj_bande(50, 'Wilkolaki', 'Galeria');
end;
SELECT * FROM BANDY;
ROLLBACK;

/* zadanie 42A compound*/
CREATE OR REPLACE TRIGGER wirus
FOR UPDATE OF przydzial_myszy ON KOCURY
WHEN (OLD.funkcja = 'MILUSIA')
COMPOUND TRIGGER
TYPE updates_row IS RECORD (nice_increase BOOLEAN);
TYPE updates IS TABLE OF updates_row INDEX BY PLS_INTEGER;
increases updates;

BEFORE EACH ROW IS
BEGIN
    --nie ma mowy o zmniejszeniu przudzialu
    IF :NEW.PRZYDZIAL_MYSZY < :OLD.PRZYDZIAL_MYSZY THEN
        :NEW.PRZYDZIAL_MYSZY := :OLD.PRZYDZIAL_MYSZY;
    ELSE
        -- zwiekszenie przydzialu mniejsze niz 10% -> milusie dostaja 5 myszy ekstra
        IF :NEW.PRZYDZIAL_MYSZY < 1.1* :OLD.PRZYDZIAL_MYSZY THEN
            :NEW.MYSZY_EXTRA := :NEW.MYSZY_EXTRA + 5;
        END IF;
        --zapisujemy do tablicy czy zwiekszono satysfakcjonujaco czy nie
    IF :NEW.PRZYDZIAL_MYSZY < 1.1*:OLD.PRZYDZIAL_MYSZY THEN
        increases(increases.COUNT +1).nice_increase := false;
    ELSE
        increases(increases.COUNT +1).nice_increase :=true;
    END IF;
    END IF;
END BEFORE EACH ROW;
AFTER STATEMENT IS
BEGIN
    FOR i in 1..increases.COUNT
    LOOP
        -- jezeli niesatysfakcjoujaco to tygrysowi zmniejszamy o 10%
        IF NOT increases(i).nice_increase THEN
            UPDATE Kocury
                SET PRZYDZIAL_MYSZY=0.9*PRZYDZIAL_MYSZY
                WHERE pseudo = 'TYGRYS';
        -- jezeli satysfakcjonujaco to tygrys dostaje 5 myszy extra
        ELSE UPDATE KOCURY
            SET MYSZY_EXTRA = MYSZY_EXTRA + 5
            WHERE pseudo = 'TYGRYS';
        END IF;
        END LOOP;
END AFTER STATEMENT;
END wirus;

SELECT * FROM Kocury;
UPDATE kocury
SET przydzial_myszy=PRZYDZIAL_MYSZY*1.2
WHERE pseudo = 'MICKA';
SELECT * FROM Kocury;
ROLLBACK;
/* zadanie 42B klasyczne*/

CREATE OR REPLACE PACKAGE wirusy AS
    TYPE updates_row IS RECORD (increase BOOLEAN);
    TYPE updates IS TABLE OF updates_row INDEX BY PLS_INTEGER;
    increases updates;
    trigger1 BOOLEAN;
END wirusy;

CREATE OR REPLACE TRIGGER before_update
BEFORE UPDATE OF przydzial_myszy ON Kocury
FOR EACH ROW
WHEN (OLD.funkcja='MILUSIA')
BEGIN
    wirusy.trigger1:=true;
    IF :NEW.przydzial_myszy<:OLD.przydzial_myszy THEN
        :NEW.przydzial_myszy:= :OLD.przydzial_myszy;
    ELSE
        IF :NEW.przydzial_myszy< 1.1*:OLD.przydzial_myszy THEN
            :NEW.myszy_extra:= :NEW.myszy_extra + 5;
    END IF;
        IF :NEW.przydzial_myszy< 1.1*:OLD.przydzial_myszy THEN
           wirusy.increases(wirusy.increases.COUNT +1).increase := false;
        ELSE wirusy.increases(wirusy.increases.COUNT +1).increase := true;
        END IF;
    END IF;
END;

CREATE OR REPLACE TRIGGER after_update
AFTER UPDATE OF przydzial_myszy ON Kocury
BEGIN
IF wirusy.trigger1 THEN
    wirusy.trigger1:=false;
    FOR i in 1..wirusy.increases.COUNT
    LOOP
        IF NOT wirusy.increases(i).increase THEN
            UPDATE Kocury
                SET przydzial_myszy=0.9*przydzial_myszy
                WHERE pseudo='TYGRYS';
        ELSE UPDATE Kocury
            SET myszy_extra=myszy_extra +5
            WHERE pseudo='TYGRYS';
        END IF;
    END LOOP;
    wirusy.increases.delete;
    END IF;
END;


SELECT * FROM Kocury;
UPDATE kocury
SET przydzial_myszy=1.5*przydzial_myszy;
SELECT * FROM Kocury;
ROLLBACK;

/* zadanie 43 */
DECLARE
    sql_cmd VARCHAR2(10000);
    sql_cmd1 VARCHAR2(10000);
    header VARCHAR2(500);
    CURSOR funkcje IS SELECT funkcja FROM Funkcje;
BEGIN
    sql_cmd := 'SELECT * FROM
(SELECT RPAD(DECODE(k.plec, ''D'', b.nazwa, '' ''),17,'' '') NAZWA_BANDY,
        DECODE(k.plec, ''D'', ''Kotka'', ''Kocur'') plec, to_char(COUNT(k.pseudo)) ile';
    FOR f IN funkcje
    LOOP
        sql_cmd := sql_cmd || ',to_char(LPAD(SUM(DECODE(funkcja, ''' || f.funkcja || ''',(NVL(przydzial_myszy,0)+NVL(myszy_extra,0)),0)), 9,'' '')) '|| f.funkcja;
    END LOOP;
    sql_cmd := sql_cmd || ',to_char(SUM((NVL(przydzial_myszy,0)+NVL(myszy_extra,0)))) "SUMA"
FROM Kocury k JOIN Bandy b
ON k.nr_bandy = b.nr_bandy
GROUP BY b.nazwa, k.plec
ORDER BY b.nazwa
)
UNION ALL
(SELECT ''ZJADA RAZEM'', ''           '', ''  ''';
    FOR f IN funkcje
    LOOP
        sql_cmd := sql_cmd || ',to_char(LPAD(SUM(DECODE(funkcja, ''' || f.funkcja || ''',(NVL(przydzial_myszy,0)+NVL(myszy_extra,0)),0)), 9,'' '')) '|| f.funkcja;
    END LOOP;
     sql_cmd := sql_cmd || ', to_char(SUM((NVL(przydzial_myszy,0)+NVL(myszy_extra,0)))) "SUMA"
FROM Kocury)';
    header:= 'NAZWA BANDY      PLEC  ILE ';
    FOR f IN funkcje
    LOOP
        header:=header || LPAD(f.funkcja, 9, ' ');
    END LOOP;
    header:=header || '  SUMA';
    DBMS_OUTPUT.PUT_LINE(header);
    sql_cmd1:= 'DECLARE
    CURSOR raporty IS ' ||  sql_cmd ||  ';
        BEGIN
        FOR row in raporty
        LOOP
            DBMS_OUTPUT.PUT_LINE(row.nazwa_bandy || row.plec || LPAD(row.ile, 4, '' '') ';
        FOR f IN funkcje
    LOOP
        sql_cmd1 := sql_cmd1 || ' || LPAD(row.' || f.funkcja || ', 9, '' '')';
    END LOOP;
        sql_cmd1 := sql_cmd1 || ' || LPAD(row.suma,7, '' ''));
        END LOOP;
    END;';
    EXECUTE IMMEDIATE sql_cmd1;
END;

/* zadanie 44 */
-- myszy posiadajace myszy extra placa 2 myszy
CREATE OR REPLACE FUNCTION podatek(pseudonim VARCHAR2)
    RETURN NUMBER
    AS
    temp NUMBER;
    suma NUMBER := 0;
    BEGIN
        SELECT 0.05 * PRZYDZIAL_MYSZY INTO suma FROM Kocury WHERE PSEUDO = pseudonim;
        SELECT COUNT(*) INTO temp FROM KOCURY WHERE szef = pseudonim;
        IF temp <= 0 THEN
          suma := suma + 2;
        END IF;
        SELECT COUNT(*) INTO temp FROM WROGOWIE_KOCUROW WHERE PSEUDO = pseudonim;
        IF temp <= 0 THEN
          suma := suma +1;
        END IF;
        SELECT COUNT(*) INTO temp FROM KOCURY WHERE MYSZY_EXTRA IS NOT NULL AND PSEUDO = pseudonim;
        IF temp >=0 THEN
            suma := suma + 2;
        END IF;
        RETURN suma;
    end;

SELECT podatek('DAMA') FROM dual;

CREATE OR REPLACE PACKAGE funkcje_koty AS
    FUNCTION podatek(pseudonim VARCHAR2) RETURN NUMBER;
    PROCEDURE dodaj_bande (nrBandy Bandy.nr_bandy%TYPE, nazwaBandy Bandy.nazwa%TYPE, terenBandy Bandy.teren%TYPE);
END funkcje_koty;

CREATE OR REPLACE PACKAGE BODY funkcje_koty AS
    FUNCTION podatek(pseudonim VARCHAR2) RETURN NUMBER
    IS
    temp NUMBER;
    suma NUMBER := 0;
    BEGIN
        SELECT 0.05 * PRZYDZIAL_MYSZY INTO suma FROM Kocury WHERE PSEUDO = pseudonim;
        SELECT COUNT(*) INTO temp FROM KOCURY WHERE szef = pseudonim;
        IF temp <= 0 THEN
          suma := suma + 2;
        END IF;
        SELECT COUNT(*) INTO temp FROM WROGOWIE_KOCUROW WHERE PSEUDO = pseudonim;
        IF temp <= 0 THEN
          suma := suma +1;
        END IF;
        SELECT COUNT(*) INTO temp FROM KOCURY WHERE MYSZY_EXTRA IS NOT NULL AND PSEUDO = pseudonim;
        IF temp >=0 THEN
            suma := suma + 2;
        END IF;
        RETURN suma;
    END podatek;

    PROCEDURE dodaj_bande (nrBandy Bandy.nr_bandy%TYPE, nazwaBandy Bandy.nazwa%TYPE, terenBandy Bandy.teren%TYPE)
    IS
    nr_mniejszy EXCEPTION;
    exist EXCEPTION;
    nr_correct BOOLEAN := false;
    nazwa_correct BOOLEAN := false;
    teren_correct BOOLEAN := false;
    komunikat VARCHAR(100);
    nr NUMBER(2);
    BEGIN
    IF nrBandy <=0 THEN raise nr_mniejszy;
    END IF;
    SELECT COUNT(*) INTO nr FROM Bandy b WHERE nrBandy=b.nr_bandy;
    IF nr =0 THEN nr_correct := true;
    END IF;
    SELECT COUNT(*) INTO nr FROM Bandy b WHERE nazwaBandy=b.NAZWA;
    IF nr =0 THEN nazwa_correct := true;
    END IF;
    SELECT COUNT(*) INTO nr FROM Bandy b WHERE terenBandy=b.TEREN;
    IF nr =0 THEN teren_correct := true;
    END IF;
    IF nr_correct AND nazwa_correct AND teren_correct THEN
        INSERT INTO Bandy(nr_bandy, nazwa, teren)
        VALUES(nrBandy, nazwaBandy, terenBandy);
    ELSE
        raise exist;
    END IF;

    EXCEPTION
    WHEN nr_mniejszy THEN
        DBMS_OUTPUT.PUT_LINE('Numer bandy mniejszy od 0');
    WHEN exist THEN
        IF NOT nr_correct  THEN
            komunikat := TO_CHAR(nrBandy) || ' ';
        END IF;
        IF NOT nazwa_correct THEN
            komunikat := komunikat || nazwaBandy || ' ';
        END IF;
        IF NOT teren_correct THEN
            komunikat := komunikat || terenBandy || ' ';
        END IF;
        komunikat:= komunikat || ': juz istnieje';
        DBMS_OUTPUT.PUT_LINE(komunikat);
end;
END;

DECLARE
    CURSOR koty IS SELECT pseudo FROM Kocury;
BEGIN
 DBMS_OUTPUT.PUT_LINE('Podatki:');
    FOR kot in koty
    LOOP
    DBMS_OUTPUT.PUT_LINE(RPAD(kot.pseudo,10) || ' ' || funkcje_koty.podatek(kot.pseudo));
    END LOOP;
END;

/* zadanie 45 */
CREATE TABLE Dodatki_extra(
    pseudo VARCHAR2(15) CONSTRAINT de_ps_fk REFERENCES Kocury(pseudo),
    dodatek NUMBER(3));

CREATE OR REPLACE TRIGGER kara_milus
AFTER UPDATE OF przydzial_myszy ON KOCURY
FOR EACH ROW
WHEN (OLD.funkcja = 'MILUSIA' AND OLD.PRZYDZIAL_MYSZY < NEW.PRZYDZIAL_MYSZY)
BEGIN
    IF (SYS.LOGIN_USER != 'TYGRYS') THEN
        dbms_output.put('Zmian dokonal: ' || SYS.LOGIN_USER);
            EXECUTE IMMEDIATE '
            DECLARE
              CURSOR milusie IS SELECT PSEUDO FROM KOCURY WHERE FUNKCJA=''MILUSIA'';
            BEGIN
              FOR milusia IN milusie
                LOOP
                  INSERT INTO DODATKI_EXTRA(PSEUDO,DODATEK) VALUES (milusia.PSEUDO, -10);
              END LOOP;
            END;';
          COMMIT ;
        END IF;
END;

SELECT * FROM Kocury;
UPDATE kocury SET PRZYDZIAL_MYSZY = 1.9 * PRZYDZIAL_MYSZY;
SELECT * FROM Dodatki_extra;
SELECT * FROM KOCURY;
ROLLBACK

/* zadanie 46 */
CREATE TABLE Przekroczenia(
    kto VARCHAR(20),
    data DATE,
    kot VARCHAR(20),
    operacja VARCHAR(10)
);

CREATE OR REPLACE TRIGGER niepoprawny_przydzial_myszy
BEFORE INSERT OR UPDATE OF przydzial_myszy ON KOCURY
FOR EACH ROW
DECLARE
min_przydzial Funkcje.min_myszy%TYPE;
max_przydzial Funkcje.max_myszy%TYPE;
operacja1 Przekroczenia.operacja%TYPE;
BEGIN
    SELECT min_myszy, max_myszy INTO min_przydzial, max_przydzial
    FROM FUNKCJE
    WHERE funkcja =:NEW.funkcja;
    IF :NEW.przydzial_myszy > min_przydzial AND :NEW.przydzial_myszy < max_przydzial THEN null;
    ELSE
        IF INSERTING THEN operacja1 := 'INSERT';
        END IF;
        IF UPDATING THEN operacja1 := 'UPDATE';
        END IF;
        INSERT INTO Przekroczenia VALUES(SYS.LOGIN_USER, CURRENT_DATE,:NEW.pseudo,operacja1);

    IF :NEW.przydzial_myszy<min_przydzial THEN
        :NEW.przydzial_myszy:=min_przydzial;
        DBMS_OUTPUT.PUT_LINE('Przydzial myszy nie moze byc mniejszy niż minimum!');
    ELSIF :NEW.przydzial_myszy>max_przydzial THEN
        :NEW.przydzial_myszy:=max_przydzial;
        DBMS_OUTPUT.PUT_LINE('Przydzial myszy nie moze byc wiekszy od maximum!');
    END IF;
    END IF;
END;

UPDATE Kocury
SET przydzial_myszy=0
WHERE pseudo='RURA';
SELECT * FROM Kocury;
SELECT * FROM Przekroczenia;
ROLLBACK;
