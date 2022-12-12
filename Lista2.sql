/* zadanie 17  */

SELECT k.pseudo AS "POLUJE W POLU", k.przydzial_myszy AS "PRZYDZIAL MYSZY", b.nazwa AS "BANDA"
FROM Kocury k
JOIN BANDY b
ON k.NR_BANDY = b.NR_BANDY
WHERE b.teren IN ('POLE', 'CALOSC') AND k.przydzial_myszy > 50
ORDER BY k.PRZYDZIAL_MYSZY DESC;

/* zadanie 18 */
SELECT k1.imie AS "IMIE", k1.w_stadku_od AS "POLUJE OD"
FROM Kocury k1, Kocury k2
WHERE k2.imie = 'JACEK' AND k1.w_stadku_od < k2.w_stadku_od
ORDER BY k1.w_stadku_od DESC;

/* zadanie 19 */
--a
SELECT k1.imie,k1.funkcja,k2.imie AS "Szef 1", k3.imie AS "Szef 2",k4.imie AS "Szef 3"
FROM Kocury k1 LEFT JOIN
    (Kocury k2 LEFT JOIN
        (Kocury k3 LEFT JOIN Kocury k4
            ON k3.SZEF = k4.PSEUDO)
        ON k2.SZEF = k3.pseudo)
    ON k1.SZEF = k2.PSEUDO
WHERE k1.funkcja IN('KOT', 'MILUSIA');

--b
SELECT *
FROM (SELECT CONNECT_BY_ROOT imie AS "Imie", imie, CONNECT_BY_ROOT funkcja AS "FUNKCJA", LEVEL AS "L"
      FROM KOCURY
      CONNECT BY PRIOR szef = PSEUDO
      START WITH funkcja IN ('KOT', 'MILUSIA'))
PIVOT (
    MIN(imie) FOR L IN (2 "Szef 1", 3 "Szef 2", 4 "Szef 3")
    );

--c
SELECT imie, funkcja, RTRIM(REVERSE(RTRIM(SYS_CONNECT_BY_PATH(REVERSE(imie), '   |   '), imie)), '   |   ') "IMIONA KOLEJNYCH SZEFOW"
FROM Kocury
WHERE funkcja IN ('KOT', 'MILUSIA')
CONNECT BY PRIOR pseudo=szef
START WITH szef IS NULL;


/* zadanie 20 */

SELECT imie AS "Imie kotki", NAZWA AS "Nazwa bandy", IMIE_WROGA AS "Imie wroga", STOPIEN_WROGOSCI AS "Ocena wroga", DATA_INCYDENTU AS "Data inc."
FROM Kocury k
LEFT JOIN Bandy b USING(NR_BANDY)
LEFT JOIN WROGOWIE_KOCUROW wk USING(PSEUDO)
LEFT JOIN WROGOWIE w USING(IMIE_WROGA)
WHERE wk.DATA_INCYDENTU > '01-01-2007' AND k.plec = 'D'
ORDER BY k.imie;

/* zadanie 21 */
SELECT b.NAZWA AS "Nazwa bandy", COUNT(DISTINCT wk.pseudo) AS "Koty z wrogami"
FROM Kocury k
LEFT JOIN Bandy b USING (NR_BANDY)
LEFT JOIN Wrogowie_kocurow wk ON k.PSEUDO = wk.PSEUDO
GROUP BY(b.NAZWA);

/* zadanie 22 */
SELECT k.funkcja AS "Funkcja", k.pseudo AS "Pseudonim", COUNT(wk.pseudo) AS "Liczba wrogow"
FROM Kocury k
LEFT JOIN Wrogowie_kocurow wk
    ON k.PSEUDO = wk.PSEUDO
GROUP BY k.pseudo, k.funkcja
HAVING COUNT(wk.pseudo) > 1;

/* zadanie 23 */
SELECT imie AS "IMIE", (przydzial_myszy*12 + myszy_extra*12) AS "DAWKA ROCZNA", 'Powyzej 864' AS "Dawka"
FROM KOCURY
WHERE przydzial_myszy*12 + myszy_extra*12 > 864 AND myszy_extra IS NOT NULL
UNION
SELECT imie AS "IMIE", (przydzial_myszy*12 + myszy_extra*12) AS "DAWKA ROCZNA", '864' AS "Dawka"
FROM KOCURY
WHERE przydzial_myszy*12 + myszy_extra*12 = 864 AND myszy_extra IS NOT NULL
UNION
SELECT imie AS "IMIE", (przydzial_myszy*12 + myszy_extra*12) AS "DAWKA ROCZNA", 'Ponizej 864' AS "Dawka"
FROM KOCURY
WHERE przydzial_myszy*12 + myszy_extra*12 <864 AND myszy_extra IS NOT NULL
ORDER BY "DAWKA ROCZNA" DESC;

/* zadanie 24 */
SELECT b.nr_bandy AS "NR BANDY", b.nazwa, b.teren
FROM BANDY b
LEFT JOIN Kocury k
ON k.NR_BANDY = b.NR_BANDY
WHERE k.PSEUDO IS NULL;

SELECT b.nr_bandy AS "NR BANDY", b.nazwa, b.teren
FROM BANDY b
MINUS
SELECT DISTINCT k.nr_bandy, b.nazwa, b.teren
FROM Bandy b LEFT JOIN Kocury k
ON B.NR_BANDY = k.NR_BANDY;

/* zadanie 25 */
SELECT imie AS "IMIE", funkcja AS "FUNKCJA", przydzial_myszy AS "PRZYDZIAL MYSZY"
FROM Kocury
WHERE przydzial_myszy >= 3 *(SELECT przydzial_myszy
                         FROM  (SELECT przydzial_myszy
                                FROM Kocury k
                                LEFT JOIN Bandy b USING (nr_bandy)
                                WHERE b.TEREN IN('SAD','CALOSC') AND k.funkcja = 'MILUSIA'
                                ORDER BY k.przydzial_myszy DESC)
                         WHERE ROWNUM = 1)
ORDER BY przydzial_myszy;

/* zadanie 26 */

SELECT funkcja, ROUND(AVG(przydzial_myszy + NVL(myszy_extra,0))) AS "Srednio najw. i najm. myszy"
FROM Kocury
WHERE funkcja != 'SZEFUNIO'
GROUP BY funkcja
/* gdzie wartosc jest w max albo w min*/
HAVING ROUND(AVG(przydzial_myszy + NVL(myszy_extra,0))) IN (
    (SELECT MAX(ROUND(AVG(przydzial_myszy + NVL(myszy_extra,0))))
    FROM Kocury
    WHERE funkcja != 'SZEFUNIO'
    GROUP BY funkcja),
    (SELECT MIN(ROUND(AVG(przydzial_myszy + NVL(myszy_extra,0))))
FROM Kocury
WHERE funkcja != 'SZEFUNIO'
GROUP BY funkcja)
    );

/* zadanie 27 */
--a
SELECT pseudo, (przydzial_myszy + NVL(myszy_extra,0)) AS "ZJADA"
FROM Kocury k1
WHERE $(n) > (SELECT COUNT(DISTINCT (przydzial_myszy + NVL(myszy_extra,0)))
              FROM Kocury k2
              WHERE (k1.PRZYDZIAL_MYSZY + NVL(k1.MYSZY_EXTRA,0)) <
                    (k2.PRZYDZIAL_MYSZY + NVL(k2.MYSZY_EXTRA,0)))
ORDER BY "ZJADA" DESC;

--b
SELECT pseudo, (przydzial_myszy + NVL(myszy_extra,0)) AS "ZJADA"
FROM Kocury k1
WHERE (przydzial_myszy + NVL(myszy_extra,0)) IN
      (SELECT * FROM
                (SELECT DISTINCT (przydzial_myszy + NVL(myszy_extra,0)) AS "ZJADA"
                 FROM Kocury k2
                 ORDER BY "ZJADA" DESC)
        WHERE ROWNUM <= $(n));

--c
SELECT k1.pseudo, MAX(k1.przydzial_myszy + NVL(k1.myszy_extra,0)) AS "ZJADA"
FROM Kocury k1, Kocury k2
WHERE (k1.przydzial_myszy + NVL(k1.myszy_extra,0)) <=
      (k2.przydzial_myszy + NVL(k2.myszy_extra,0))
GROUP BY k1.pseudo
HAVING COUNT(DISTINCT k2.przydzial_myszy + NVL(k2.myszy_extra,0)) <= $(n)
ORDER BY "ZJADA" DESC;

--d
SELECT pseudo, "ZJADA"
FROM (SELECT pseudo,
     (przydzial_myszy + NVL(myszy_extra,0)) AS "ZJADA",
     DENSE_RANK() over (ORDER BY przydzial_myszy + NVL(myszy_extra,0) DESC) pozycja
      FROM Kocury)
WHERE pozycja <= $(n);


/* zadanie 28 */
SELECT TO_CHAR(EXTRACT(YEAR FROM w_stadku_od)) AS "ROK", COUNT(*) AS "LICZBA WSTAPIEN"
FROM Kocury
GROUP BY EXTRACT(YEAR FROM W_STADKU_OD)
HAVING COUNT(*) IN(
    (SELECT * FROM
        (SELECT DISTINCT COUNT(pseudo)
         FROM Kocury
         GROUP BY EXTRACT(YEAR FROM w_stadku_od)
         HAVING COUNT(pseudo) > -- wystapienia wieksza niz srednia
                (SELECT AVG(COUNT(EXTRACT(YEAR FROM w_stadku_od)))
                 FROM KOCURY
                 GROUP BY EXTRACT(YEAR FROM W_STADKU_OD))
         ORDER BY COUNT(pseudo))
     WHERE ROWNUM=1),
    --pierwsza najmniejsza
    (SELECT * FROM
        (SELECT DISTINCT COUNT(pseudo)
         FROM Kocury
         GROUP BY EXTRACT(YEAR FROM w_stadku_od)
         HAVING COUNT(pseudo) < -- wystapienia mniejsza niz srednia
                (SELECT AVG(COUNT(EXTRACT(YEAR FROM w_stadku_od)))
                 FROM KOCURY
                 GROUP BY EXTRACT(YEAR FROM W_STADKU_OD))
         ORDER BY COUNT(pseudo) DESC)
     WHERE ROWNUM=1))
    --pierwsza najwieksza
UNION ALL
SELECT 'Srednia', ROUND(AVG(COUNT(*)),7)
FROM KOCURY
GROUP BY EXTRACT(YEAR FROM W_STADKU_OD)
ORDER BY "LICZBA WSTAPIEN";

/* zadanie 29 */
--a
SELECT k1.imie, MIN(k1.PRZYDZIAL_MYSZY + NVL(k1.MYSZY_EXTRA,0)) AS "ZJADA", MIN(k1.NR_BANDY),  AVG(k2.PRZYDZIAL_MYSZY + NVL(k2.MYSZY_EXTRA,0)) AS "SREDNIA BANDY"
FROM Kocury k1
JOIN KOCURY k2
ON k1.NR_BANDY = k2.NR_BANDY
WHERE k1.plec = 'M'
GROUP BY k1.imie
HAVING AVG((k1.PRZYDZIAL_MYSZY + NVL(k1.MYSZY_EXTRA,0))) <= AVG(k2.PRZYDZIAL_MYSZY + NVL(k2.MYSZY_EXTRA,0));

--b
SELECT imie, (PRZYDZIAL_MYSZY + NVL(MYSZY_EXTRA,0)) AS "ZJADA", NR_BANDY, SREDNIA AS "SREDNIA BANDY"
FROM (SELECT NR_BANDY, AVG(PRZYDZIAL_MYSZY + NVL(MYSZY_EXTRA,0)) AS "SREDNIA"
      FROM KOCURY
      GROUP BY NR_BANDY)
JOIN KOCURY USING (NR_BANDY)
WHERE SREDNIA >= (PRZYDZIAL_MYSZY + NVL(MYSZY_EXTRA,0)) AND PLEC = 'M'
GROUP BY imie, (PRZYDZIAL_MYSZY + NVL(MYSZY_EXTRA,0)), NR_BANDY, SREDNIA;
--c
SELECT imie, (PRZYDZIAL_MYSZY + NVL(MYSZY_EXTRA,0)) AS "ZJADA", NR_BANDY,
    (SELECT AVG(PRZYDZIAL_MYSZY + NVL(MYSZY_EXTRA,0))
     FROM KOCURY k2
     WHERE k1.NR_BANDY = k2.NR_BANDY)
     AS "SREDNIA BANDY"
FROM KOCURY k1
WHERE PLEC = 'M' AND (PRZYDZIAL_MYSZY + NVL(MYSZY_EXTRA,0)) <=
    (SELECT AVG(PRZYDZIAL_MYSZY + NVL(MYSZY_EXTRA,0))
     FROM KOCURY K2
     WHERE K1.NR_BANDY = K2.NR_BANDY
     );

/* zadanie 30 */

SELECT IMIE, W_STADKU_OD AS "WSTAPIL DO STADKA", '<--- NAJMLODSZY STAZEM W BANDZIE ' || NAZWA
FROM Kocury k1
JOIN BANDY B on k1.NR_BANDY = B.NR_BANDY
WHERE W_STADKU_OD = (SELECT MIN(W_STADKU_OD)
                     FROM KOCURY
                     WHERE k1.NR_BANDY = NR_BANDY)
GROUP BY IMIE, W_STADKU_OD, NAZWA
UNION ALL
SELECT IMIE, W_STADKU_OD AS "WSTAPIL DO STADKA", '<--- NAJSTARSZY STAZEM W BANDZIE ' || NAZWA
FROM Kocury k1
JOIN BANDY B on k1.NR_BANDY = B.NR_BANDY
WHERE W_STADKU_OD = (SELECT MAX(W_STADKU_OD)
                     FROM KOCURY
                     WHERE k1.NR_BANDY = NR_BANDY)
GROUP BY IMIE, W_STADKU_OD, NAZWA
UNION ALL
SELECT IMIE, W_STADKU_OD AS "WSTAPIL DO STADKA", ' '
FROM Kocury k1
WHERE W_STADKU_OD NOT IN ((SELECT MIN(W_STADKU_OD)
                           FROM KOCURY
                           WHERE k1.NR_BANDY = NR_BANDY),
                          (SELECT MAX(W_STADKU_OD)
                           FROM KOCURY
                           WHERE k1.NR_BANDY = NR_BANDY))
ORDER BY imie;

/* zadanie 31 */

CREATE OR REPLACE VIEW Bandy1(nazwa, avg,max,min,koty, koty_z_premia)
AS
    SELECT nazwa, AVG(PRZYDZIAL_MYSZY),
           MAX(PRZYDZIAL_MYSZY), MIN(PRZYDZIAL_MYSZY),
           COUNT(pseudo),COUNT(MYSZY_EXTRA)
    FROM BANDY b
    JOIN KOCURY k on b.NR_BANDY = k.NR_BANDY
    GROUP BY nazwa;
SELECT * FROM Bandy1;

SELECT pseudo AS "PSEUDONIM", imie, funkcja, przydzial_myszy AS "ZJADA",
       'OD ' || min || ' DO ' || max AS "GRANICE SPOZYCIA", w_stadku_od AS "LOWI OD"
FROM BANDY1
RIGHT JOIN BANDY B on Bandy1.nazwa = B.NAZWA
RIGHT JOIN KOCURY K on B.NR_BANDY = K.NR_BANDY
WHERE pseudo =  $(Pseudonim);

/* zadanie 32 */
-- PRZED
SELECT pseudo AS "Pseudonim", plec AS "Plec", PRZYDZIAL_MYSZY AS "Myszy przed podw.",
       NVL(MYSZY_EXTRA,0) AS "Extra przed podw."
FROM KOCURY
LEFT JOIN BANDY USING(NR_BANDY)
WHERE PSEUDO IN (SELECT * FROM
                        (SELECT PSEUDO
                         FROM KOCURY
                         LEFT JOIN BANDY USING (NR_BANDY)
                         WHERE NAZWA = 'CZARNI RYCERZE'
                         ORDER BY W_STADKU_OD)
                 WHERE ROWNUM <=3
                UNION ALL
                SELECT * FROM
                        (SELECT PSEUDO
                         FROM KOCURY
                         LEFT JOIN BANDY USING (NR_BANDY)
                         WHERE NAZWA = 'LACIACI MYSLIWI'
                         ORDER BY W_STADKU_OD)
                 WHERE ROWNUM <=3);
--PODWYZKA
UPDATE KOCURY
SET PRZYDZIAL_MYSZY = CASE plec
                            WHEN 'D' THEN PRZYDZIAL_MYSZY + (SELECT MIN(PRZYDZIAL_MYSZY)
                                                                   FROM KOCURY) * 0.1
                            WHEN 'M' THEN PRZYDZIAL_MYSZY + 10
                       END,
    MYSZY_EXTRA = NVL(MYSZY_EXTRA,0) + (SELECT AVG(NVL(MYSZY_EXTRA,0))
                                              FROM KOCURY k1
                                              WHERE k1.NR_BANDY = KOCURY.NR_BANDY) * 0.15
WHERE PSEUDO IN (SELECT * FROM
                        (SELECT PSEUDO
                         FROM KOCURY
                         LEFT JOIN BANDY USING (NR_BANDY)
                         WHERE NAZWA = 'CZARNI RYCERZE'
                         ORDER BY W_STADKU_OD)
                 WHERE ROWNUM <=3
                UNION ALL
                SELECT * FROM
                        (SELECT PSEUDO
                         FROM KOCURY
                         LEFT JOIN BANDY USING (NR_BANDY)
                         WHERE NAZWA = 'LACIACI MYSLIWI'
                         ORDER BY W_STADKU_OD)
                 WHERE ROWNUM <=3);

--PO
SELECT pseudo AS "Pseudonim", plec AS "Plec", PRZYDZIAL_MYSZY AS "Myszy po podw.",
       NVL(MYSZY_EXTRA,0) AS "Extra po podw."
FROM KOCURY
LEFT JOIN BANDY USING(NR_BANDY)
WHERE PSEUDO IN (SELECT * FROM
                        (SELECT PSEUDO
                         FROM KOCURY
                         LEFT JOIN BANDY USING (NR_BANDY)
                         WHERE NAZWA = 'CZARNI RYCERZE'
                         ORDER BY W_STADKU_OD)
                 WHERE ROWNUM <=3
                UNION ALL
                SELECT * FROM
                        (SELECT PSEUDO
                         FROM KOCURY
                         LEFT JOIN BANDY USING (NR_BANDY)
                         WHERE NAZWA = 'LACIACI MYSLIWI'
                         ORDER BY W_STADKU_OD)
                 WHERE ROWNUM <=3);
ROLLBACK;

/* zadanie 33 */
--a
SELECT DECODE(plec, 'Kocur', nazwa, '') nazwa, plec, ile, szefunio, bandzior,
       lowczy, lapacz, kot, milusia, dzielczy, suma
FROM (SELECT nazwa,
             decode(PLEC, 'D', 'Kotka', 'Kocur') plec,
             to_char(count(pseudo)) ile,
             to_char(sum(decode(FUNKCJA,'SZEFUNIO', NVL(PRZYDZIAL_MYSZY,0)+NVL(MYSZY_EXTRA,0),0))) szefunio,
             to_char(sum(decode(FUNKCJA, 'BANDZIOR', NVL(PRZYDZIAL_MYSZY,0)+NVL(MYSZY_EXTRA,0),0))) bandzior,
             to_char(sum(decode(FUNKCJA, 'LOWCZY', NVL(PRZYDZIAL_MYSZY,0)+NVL(MYSZY_EXTRA,0),0))) lowczy,
             to_char(sum(decode(FUNKCJA, 'LAPACZ', NVL(PRZYDZIAL_MYSZY,0)+NVL(MYSZY_EXTRA,0),0))) lapacz,
             to_char(sum(decode(FUNKCJA, 'KOT', NVL(PRZYDZIAL_MYSZY,0)+NVL(MYSZY_EXTRA,0),0))) kot,
             to_char(sum(decode(FUNKCJA, 'MILUSIA', NVL(PRZYDZIAL_MYSZY,0)+NVL(MYSZY_EXTRA,0),0))) milusia,
             to_char(sum(decode(FUNKCJA, 'DZIELCZY', NVL(PRZYDZIAL_MYSZY,0)+NVL(MYSZY_EXTRA,0),0))) dzielczy,
             to_char(sum(NVL(PRZYDZIAL_MYSZY,0)+NVL(MYSZY_EXTRA,0))) suma
      FROM KOCURY
          JOIN BANDY ON KOCURY.NR_BANDY = BANDY.NR_BANDY
      GROUP BY nazwa, plec
      UNION
      select 'Z----------------', '--------', '----------',
             '-----------', '-----------', '----------',
             '----------', '----------', '----------',
             '----------', '----------'
      FROM DUAL
      UNION
      SELECT 'ZJADA RAZEM' nazwa, ' ' plec, ' ' ile,
             to_char(sum(decode(FUNKCJA, 'SZEFUNIO', NVL(PRZYDZIAL_MYSZY,0)+NVL(MYSZY_EXTRA,0),0))) szefunio,
             to_char(sum(decode(FUNKCJA, 'BANDZIOR', NVL(PRZYDZIAL_MYSZY,0)+NVL(MYSZY_EXTRA,0),0))) bandzior,
             to_char(sum(decode(FUNKCJA, 'LOWCZY', NVL(PRZYDZIAL_MYSZY,0)+NVL(MYSZY_EXTRA,0),0))) lowczy,
             to_char(sum(decode(FUNKCJA, 'LAPACZ', NVL(PRZYDZIAL_MYSZY,0)+NVL(MYSZY_EXTRA,0),0))) lapacz,
             to_char(sum(decode(FUNKCJA, 'KOT', NVL(PRZYDZIAL_MYSZY,0)+NVL(MYSZY_EXTRA,0),0))) kot,
             to_char(sum(decode(FUNKCJA, 'MILUSIA', NVL(PRZYDZIAL_MYSZY,0)+NVL(MYSZY_EXTRA,0),0))) milusia,
             to_char(sum(decode(FUNKCJA, 'DZIELCZY', NVL(PRZYDZIAL_MYSZY,0)+NVL(MYSZY_EXTRA,0),0))) dzielczy,
             to_char(sum(NVL(PRZYDZIAL_MYSZY,0)+NVL(MYSZY_EXTRA,0))) suma
      FROM KOCURY JOIN BANDY B on KOCURY.NR_BANDY = B.NR_BANDY
      ORDER BY 1,2);
--b

SELECT *
FROM (
    SELECT nazwa, decode(PLEC, 'D', 'Kotka', 'Kocur') AS "PLEC", funkcja,
           NVL(PRZYDZIAL_MYSZY,0) + NVL(MYSZY_EXTRA,0) przydzial
    FROM KOCURY JOIN BANDY B on KOCURY.NR_BANDY = B.NR_BANDY
     )
PIVOT (
    SUM(przydzial)
    for FUNKCJA
    IN ('SZEFUNIO', 'BANDZIOR', 'LOWCZY', 'LAPACZ', 'KOT', 'MILUSIA', 'DZIELCZY')
    )
UNION ALL
SELECT *
FROM (
    SELECT 'Zjada razem ', ' ', funkcja,
           (NVL(PRZYDZIAL_MYSZY,0) + nvl(MYSZY_EXTRA, 0)) przydzial
    FROM KOCURY JOIN BANDY B on KOCURY.NR_BANDY = B.NR_BANDY
     )
PIVOT (
    SUM(NVL(przydzial, 0))
    for FUNKCJA
    IN ('SZEFUNIO', 'BANDZIOR', 'LOWCZY', 'LAPACZ', 'KOT', 'MILUSIA', 'DZIELCZY')
    );
