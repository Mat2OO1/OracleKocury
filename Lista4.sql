-- zadanie 47
-- creating objects and types
CREATE OR REPLACE TYPE KOCURY_O AS OBJECT
(imie VARCHAR2(15),
   plec VARCHAR2(1),
   pseudo VARCHAR2(15),
   funkcja VARCHAR2(10),
   w_stadku_od DATE,
   przydzial_myszy NUMBER(3),
   myszy_extra NUMBER(3),
   nr_bandy NUMBER(2),
   szef REF KOCURY_O,
   MAP MEMBER FUNCTION GET_INFO RETURN VARCHAR2,
   MEMBER FUNCTION myszy_dochod RETURN NUMBER)
	NOT FINAL;
/
CREATE OR REPLACE TYPE BODY KOCURY_O AS
    MAP MEMBER FUNCTION GET_INFO RETURN VARCHAR2 IS
    BEGIN
        RETURN imie || ', ' || plec || ', pseudo:' || pseudo || ' funkcja:'||funkcja ||', zjada:'||SELF.myszy_dochod();
    END;
    MEMBER FUNCTION myszy_dochod RETURN NUMBER IS
    BEGIN
        RETURN NVL(przydzial_myszy,0) + NVL(myszy_extra, 0);
    END;
END;
/
CREATE OR REPLACE TYPE PLEBS_O AS OBJECT
(kot REF KOCURY_O,
 pseudo VARCHAR2(15),
 MAP MEMBER FUNCTION GET_INFO RETURN VARCHAR2)
FINAL;
/
CREATE OR REPLACE TYPE BODY PLEBS_O AS
MAP MEMBER FUNCTION GET_INFO RETURN VARCHAR2 IS
    kot KOCURY_O;
    BEGIN
        SELECT DEREF(SELF.kot) INTO kot from dual;
        RETURN kot.GET_INFO();
    END;
END;
/
CREATE OR REPLACE TYPE ELITA_O AS OBJECT
( kot REF KOCURY_O,
 sluga REF PLEBS_O,
 pseudo VARCHAR2(20),
 MAP MEMBER FUNCTION GET_INFO RETURN VARCHAR2)
FINAL;
/
CREATE OR REPLACE TYPE BODY ELITA_O AS
MAP MEMBER FUNCTION GET_INFO RETURN VARCHAR2 IS
    kot KOCURY_O;
    slug PLEBS_O;
    kots KOCURY_O;
    BEGIN
        SELECT DEREF(SELF.kot) INTO kot from DUAL;
        SELECT DEREF(SELF.sluga) INTO slug from DUAL;
        SELECT DEREF(slug.kot) INTO kots from DUAL;
        RETURN kot.GET_INFO() || ' sluga: ' || kots.PSEUDO;
    END;
END;
/

CREATE OR REPLACE TYPE KONTO_MYSZY_O AS OBJECT
(nr_myszy NUMBER(5),
 data_wprowadzenia DATE,
 data_usuniecia DATE,
 wlasciciel REF Elita_o,
 MAP MEMBER FUNCTION GET_INFO RETURN VARCHAR2);

CREATE OR REPLACE TYPE BODY KONTO_MYSZY_O AS
MAP MEMBER FUNCTION GET_INFO RETURN VARCHAR2 IS
    wl ELITA_O;
    kot KOCURY_O;
    BEGIN
        SELECT DEREF(wlasciciel) INTO wl FROM DUAL;
        SELECT DEREF(wl.kot) INTO kot FROM DUAL;
        RETURN TO_CHAR(data_wprowadzenia) || ' ' || kot.PSEUDO || TO_CHAR(data_usuniecia);
    END;
END;

CREATE OR REPLACE TYPE INCYDENTY_O AS OBJECT
( pseudo VARCHAR2(15),
   kot REF Kocury_o,
   imie_wroga VARCHAR2(15),
   data_incydentu  DATE,
   opis_incydentu VARCHAR2(50),
   MAP MEMBER FUNCTION GET_INFO RETURN VARCHAR2);

CREATE OR REPLACE TYPE BODY INCYDENTY_O AS
MAP MEMBER FUNCTION GET_INFO RETURN VARCHAR2 IS
    kocur KOCURY_O;
    BEGIN
        SELECT DEREF(kot) INTO kocur from DUAL;
        RETURN kocur.PSEUDO || ' wrog: ' || imie_wroga || ' ' || TO_CHAR(data_incydentu) || ' ' || opis_incydentu;
    END;
END;


--creating tables
CREATE TABLE Kocury2 OF KOCURY_O
(imie NOT NULL,
 CONSTRAINT koc2_pk PRIMARY KEY (pseudo),
 CONSTRAINT koc2_plec_ch CHECK (plec IN ('M', 'D')));

CREATE TABLE Plebs OF PLEBS_O
(kot SCOPE IS Kocury2,
 CONSTRAINT plebs_fk PRIMARY KEY (pseudo) REFERENCES Kocury2(pseudo),
 CONSTRAINT plebs_pk PRIMARY KEY (psuedo));

CREATE TABLE Elita OF ELITA_O
(kot SCOPE IS Kocury2,
 CONSTRAINT elita_fk FOREIGN KEY (pseudo) REFERENCES Kocury2(pseudo),
 CONSTRAINT elita_pk PRIMARY KEY (psuedo));

CREATE TABLE Konto OF KONTO_MYSZY_O
(data_wprowadzenia NOT NULL,
 wlasciciel SCOPE IS Elita,
 CONSTRAINT konto_pk PRIMARY KEY(nr_myszy));

CREATE SEQUENCE nr_myszy;

CREATE TABLE Incydenty OF INCYDENTY_O
(data_incydentu NOT NULL,
 pseudo REFERENCES Kocury2(pseudo),
 CONSTRAINT incyd_pk PRIMARY KEY (pseudo, imie_wroga));

--dodawanie danych kocurow
DECLARE
CURSOR koty IS SELECT * FROM Kocury
                CONNECT BY PRIOR pseudo=szef
                START WITH szef IS NULL;
dyn_sql VARCHAR2(10000);
BEGIN
    FOR kot IN koty
    LOOP
      dyn_sql:='DECLARE
            szef REF Kocury_o;
            cnt NUMBER(2);
        BEGIN
            szef:=NULL;
            SELECT COUNT(*) INTO cnt FROM Kocury2 P WHERE P.pseudo='''|| kot.szef||''';
            IF (cnt>0) THEN
                SELECT REF(P) INTO szef FROM Kocury2 P WHERE P.pseudo='''|| kot.szef||''';
            END IF;
            INSERT INTO Kocury2 VALUES
                    (Kocury_O(''' || kot.imie || ''', ''' || kot.plec || ''', ''' || kot.pseudo || ''', ''' || kot.funkcja
                    || ''',''' ||kot.w_stadku_od || ''',''' || kot.przydzial_myszy ||''',''' || kot.myszy_extra ||
                        ''',''' || kot.nr_bandy || ''', ' || 'szef' || '));
            END;';
       EXECUTE IMMEDIATE  dyn_sql;
    END LOOP;
SELECT K.imie, K.plec, K.pseudo, K.funkcja, K.w_stadku_od, K.przydzial_myszy, K.myszy_extra, K.nr_bandy, K.szef.GET_INFO() szef FROM Kocury2 K;

--dod. danych o incydentach
DECLARE
CURSOR zdarzenia IS SELECT * FROM Wrogowie_kocurow;
dyn_sql VARCHAR2(1000);
BEGIN
    FOR zdarzenie IN zdarzenia
    LOOP
      dyn_sql:='DECLARE
            kot REF Kocury_o;
        BEGIN
            SELECT REF(K) INTO kot FROM Kocury2 K WHERE K.pseudo='''|| zdarzenie.pseudo||''';
            INSERT INTO Incydenty VALUES
                    (Incydenty_O(''' || zdarzenie.pseudo || ''',  kot , ''' || zdarzenie.imie_wroga || ''', ''' || zdarzenie.data_incydentu
                    || ''',''' || zdarzenie.opis_incydentu|| '''));
            END;';
       DBMS_OUTPUT.PUT_LINE(dyn_sql);
       EXECUTE IMMEDIATE  dyn_sql;
    END LOOP;
END;
SELECT * FROM Incydenty;

--plebs
DECLARE
CURSOR koty IS SELECT  pseudo
                    FROM (SELECT K.pseudo pseudo FROM Kocury2 K ORDER BY K.myszy_dochod() ASC)
                    WHERE ROWNUM<= (SELECT COUNT(*) FROM Kocury2)/2;
dyn_sql VARCHAR2(1000);
BEGIN
    FOR plebs IN koty
    LOOP
      dyn_sql:='DECLARE
            kot REF Kocury_o;
        BEGIN
            SELECT REF(K) INTO kot FROM Kocury2 K WHERE K.pseudo='''|| plebs.pseudo||''';
            INSERT INTO Plebs VALUES
                    (Plebs_O(kot, '''|| plebs.pseudo || '''));
            END;';
       EXECUTE IMMEDIATE  dyn_sql;
    END LOOP;
END;
/
SELECT P.pseudo, P.kot.GET_INFO() FROM Plebs P;

--elita
DECLARE
CURSOR koty IS SELECT  pseudo
                    FROM (SELECT K.pseudo pseudo FROM Kocury2 K ORDER BY K.myszy_dochod() DESC)
                    WHERE ROWNUM<= (SELECT COUNT(*) FROM Kocury2)/2;
dyn_sql VARCHAR2(1000);
num NUMBER:=1;
BEGIN
    FOR plebs IN koty
    LOOP
      dyn_sql:='DECLARE
            kot REF Kocury_o;
            sluga REF Plebs_o;
        BEGIN
            SELECT REF(K) INTO kot FROM Kocury2 K WHERE K.pseudo='''|| plebs.pseudo||''';
            SELECT plebs INTO sluga FROM (SELECT REF(P) plebs, rownum num  FROM Plebs P ) WHERE NUM='||num||';
            INSERT INTO Elita VALUES
                    (Elita_O(kot, sluga,'''|| plebs.pseudo || '''));
        END;';
       EXECUTE IMMEDIATE  dyn_sql;
       num:=num+1;
    END LOOP;
END;

SELECT E.kot.pseudo, E.sluga.pseudo, E.pseudo, E.kot.MYSZY_DOCHOD() FROM Elita E;

--konto
DECLARE
CURSOR koty IS SELECT pseudo FROM Elita;
dyn_sql VARCHAR2(1000);
BEGIN
    FOR plebs IN koty
    LOOP
      dyn_sql:='DECLARE
            kot REF Elita_o;
            dataw DATE:=SYSDATE;
        BEGIN
            SELECT REF(E) INTO kot FROM Elita E WHERE E.pseudo='''|| plebs.pseudo||''';
            INSERT INTO Konto VALUES
                    (Konto_myszy_O(nr_myszy.NEXTVAL, dataw, NULL, kot));
        END;';
       DBMS_OUTPUT.PUT_LINE(dyn_sql);
       EXECUTE IMMEDIATE  dyn_sql;
    END LOOP;
END;
SELECT * FROM Elita;

DECLARE
CURSOR koty IS SELECT E.pseudo FROM Elita E WHERE E.kot.myszy_dochod()>80 ;
dyn_sql VARCHAR2(1000);
BEGIN
    FOR plebs IN koty
    LOOP
      dyn_sql:='DECLARE
            kot REF Elita_o;
            dataw DATE:=SYSDATE;
        BEGIN
            SELECT REF(E) INTO kot FROM Elita E WHERE E.pseudo='''|| plebs.pseudo||''';
            INSERT INTO Konto VALUES
                    (Konto_myszy_O(nr_myszy.NEXTVAL, dataw, NULL, kot));
        END;';
       EXECUTE IMMEDIATE  dyn_sql;
    END LOOP;
END;


SELECT K.nr_myszy, K.data_wprowadzenia, K.data_usuniecia, K.wlasciciel.pseudo FROM Konto K;
 --referencja
 SELECT K.IMIE, K.PLEC, K.PRZYDZIAL_MYSZY FROM Kocury2 K WHERE K.PRZYDZIAL_MYSZY > 70;
--podzapytanie
SELECT pseudo, plec FROM (SELECT K.pseudo pseudo, K.plec plec FROM Kocury2 K WHERE K.PLEC = 'M');
--grupowanie
SELECT COUNT(K.pseudo) as liczba_kotow, K.nr_bandy FROM Kocury2 K GROUP BY K.nr_bandy;

--lista2 zad 18

SELECT k1.imie AS "IMIE", k1.w_stadku_od AS "POLUJE OD"
FROM Kocury2 k1, Kocury2 k2
WHERE k2.imie = 'JACEK' AND k1.w_stadku_od < k2.w_stadku_od
ORDER BY k1.w_stadku_od DESC;

--lista2 zad22
SELECT k.funkcja, k.pseudo, inc.lw "Liczba wrogow"
FROM Kocury2 k JOIN
(SELECT COUNT(i.pseudo) lw, i.pseudo FROM INCYDENTY i GROUP BY i.pseudo) inc
    ON k.PSEUDO = inc.PSEUDO
WHERE inc.lw > 1;

--lista3 zad34

DECLARE
    fun Kocury2.funkcja%TYPE := &funkcja;
BEGIN
    SELECT k.funkcja INTO fun FROM KOCURY2 k WHERE k.funkcja = fun AND ROWNUM = 1;
    IF (SQL%FOUND) THEN
        DBMS_OUTPUT.PUT_LINE('ZNALEZIONO KOTA O FUNKCJI ' || fun);
    END IF;
    EXCEPTION
        WHEN OTHERS
            THEN DBMS_OUTPUT.PUT_LINE('BRAK TAKIEGO KOTA');
END;

--lista3 zad35
DECLARE
    przydzial Kocury2.PRZYDZIAL_MYSZY%type;
    imie Kocury2.imie%TYPE;
    miesiac NUMBER(3);
    bool BOOLEAN := TRUE;
BEGIN
    SELECT k.myszy_dochod(),
           imie,
           EXTRACT(MONTH FROM W_STADKU_OD)
    INTO przydzial,imie,miesiac
    FROM Kocury2 k
    WHERE k.pseudo= &pseudo;
    IF (12* przydzial > 700)
    THEN
        bool := FALSE;
        DBMS_OUTPUT.PUT_LINE('calkowity roczny przydzial myszy > 700');
    END IF;
    IF imie LIKE '%A%' THEN
        bool := FALSE;
        DBMS_OUTPUT.PUT_LINE('imie zawiera litere A');
    END IF;
    IF miesiac = 5 THEN
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

--zadanie 48
