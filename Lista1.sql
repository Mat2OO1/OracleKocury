/* zadanie 1  */
SELECT imie_wroga AS "WROG", opis_incydentu AS "PRZEWINA"
FROM WROGOWIE_KOCUROW
WHERE EXTRACT(YEAR FROM data_incydentu) = 2009;

/* zadanie 2  */
alter session set nls_date_format='DD/MM/YYYY';
SELECT imie, funkcja, w_stadku_od AS "Z NAMI OD"
FROM Kocury
WHERE plec = 'D' AND w_stadku_od BETWEEN '01-09-2005' AND '31-07-2007';

/* zadanie 3  */
SELECT imie_wroga AS "WROG" , gatunek, stopien_wrogosci AS "STOPIEN WROGOSCI"
FROM Wrogowie
WHERE lapowka IS NULL
ORDER BY STOPIEN_WROGOSCI;

/* zadanie 4 */
SELECT imie || ' zwany ' || pseudo || ' (fun.' || funkcja || ') łowi myszki w bandzie ' || nr_bandy || ' od ' || w_stadku_od
FROM Kocury
WHERE plec='M'
ORDER BY W_STADKU_OD DESC, PSEUDO;

/* zadanie 5 */
SELECT pseudo, REGEXP_REPLACE(regexp_replace(pseudo,'A','#',1,1),'L','%',1,1) AS "Po wymianie A na # oraz L na %"
FROM Kocury
WHERE pseudo LIKE '%A%' AND pseudo LIKE '%L%';

/* zadanie 6 */
SELECT imie AS "IMIE", w_stadku_od AS "W stadku", CAST(przydzial_myszy/1.1 AS INTEGER) AS "Zjadal", ADD_MONTHS(w_stadku_od, 6) AS "Podwyzka", przydzial_myszy AS "Zjada"
FROM Kocury
WHERE months_between(SYSDATE,w_stadku_od)/12 > 13 AND EXTRACT(MONTH FROM W_STADKU_OD) BETWEEN 3 AND 9;

/* zadanie 7 */
SELECT imie AS IMIE, przydzial_myszy * 3 AS "MYSZY KWARTALNE", NVL(myszy_extra * 3,0) AS "KWARTALNE DODATKI"
FROM Kocury
WHERE przydzial_myszy > NVL(myszy_extra*2,0) AND przydzial_myszy >= 55;

/* zadanie 8 */
SELECT imie,
    CASE
        WHEN(przydzial_myszy + NVL(myszy_extra,0))*12 > 660 THEN CAST((przydzial_myszy + NVL(myszy_extra,0))*12 AS VARCHAR(10))
        WHEN (przydzial_myszy + NVL(myszy_extra,0))*12 = 660 THEN 'LIMIT'
        ELSE 'Ponizej 660'
    END AS "ZJADA ROCZNIE"
FROM Kocury
ORDER BY imie;

/* zadanie 9 */
SELECT pseudo, w_stadku_od AS "W stadku",
CASE
	WHEN EXTRACT(DAY FROM w_stadku_od) <= 15 AND NEXT_DAY(LAST_DAY('25-10-2022') - 7,3) >= '25-10-2022'
		THEN NEXT_DAY(LAST_DAY('25-10-2022') - 7,3)
	WHEN EXTRACT(DAY FROM w_stadku_od) > 15 AND NEXT_DAY(LAST_DAY('25-10-2022') - 7,3) >= '25-10-2022'
		THEN NEXT_DAY(LAST_DAY(ADD_MONTHS('25-10-2022',1)) - 7,3)
    ELSE NEXT_DAY(LAST_DAY(ADD_MONTHS('25-10-2022',1)) - 7, 3)
		END AS "WYPLATA"
FROM Kocury
ORDER BY W_STADKU_OD;

SELECT pseudo, w_stadku_od AS "W stadku",
CASE
    WHEN EXTRACT(DAY FROM w_stadku_od) <= 15 AND NEXT_DAY(LAST_DAY('27-10-2022') - 7,3) >= '27-10-2022'
		THEN NEXT_DAY(LAST_DAY('27-10-2022') - 7,3)
	WHEN EXTRACT(DAY FROM w_stadku_od) > 15 AND NEXT_DAY(LAST_DAY('27-10-2022') - 7,3) >= '27-10-2022'
		THEN NEXT_DAY(LAST_DAY(ADD_MONTHS('27-10-2022',1)) - 7,3)
    ELSE NEXT_DAY(LAST_DAY(ADD_MONTHS('27-10-2022',1)) - 7, 3)
		END AS "WYPLATA"
FROM Kocury
ORDER BY W_STADKU_OD;

/* zadanie 10 */

SELECT pseudo || ' - ' ||
        CASE
           WHEN COUNT(pseudo) = 1 THEN 'Unikalny'
            ELSE 'Nieunikalny'
        END AS"Unikalnosc atr. PSEUDO"
FROM Kocury
GROUP BY pseudo;

SELECT szef || ' - ' ||
        CASE
           WHEN COUNT(pseudo) = 1 THEN 'Unikalny'
            ELSE 'Nieunikalny'
        END AS"Unikalnosc atr. SZEF"
FROM Kocury
GROUP BY szef
HAVING szef IS NOT NULL;

/* zadanie 11 */
SELECT k.pseudo AS "Pseudonim", COUNT(w.imie_wroga) AS "Liczba wrogów"
FROM Kocury k
JOIN Wrogowie_kocurow w
ON k.pseudo = w.pseudo
GROUP BY k.pseudo
HAVING COUNT(w.imie_wroga) >=2;

/* zadanie 12 */
SELECT 'Liczba kotów = ' || COUNT(k.pseudo) || ' łowi jako ' || k.funkcja || ' i zjada max. ' || MAX(k.przydzial_myszy + NVL(k.myszy_extra,0)) || ' myszy miesiecznie' AS " "
FROM Kocury k
JOIN Funkcje f
ON k.funkcja = f.funkcja
WHERE k.funkcja != 'SZEFUNIO' AND k.plec!='M'
GROUP BY k.funkcja
HAVING AVG(k.przydzial_myszy + NVL(k.myszy_extra,0)) > 50;

/* zadanie 13 */
SELECT k.nr_bandy AS "Nr bandy", k.plec, MIN(k.PRZYDZIAL_MYSZY) AS "Minimalny przydział"
FROM Kocury k
JOIN Funkcje f
ON k.funkcja = f.funkcja
GROUP BY k.plec, k.nr_bandy;

/* zadanie 14 */
SELECT level AS "Poziom", pseudo AS "Pseudonim", funkcja AS "Funkcja",nr_bandy "Nr bandy"
FROM Kocury
WHERE plec = 'M'
CONNECT BY PRIOR pseudo = szef
START WITH funkcja = 'BANDZIOR'
ORDER BY level;

/* zadanie 15 */
SELECT RPAD('===>',(level-1)*LENGTH('===>'),'===>')|| (level-1)|| '           ' || imie AS "Hierarchia",
       NVL(szef,'Sam sobie panem') AS "Pseudo szefa", funkcja AS "Funkcja"
FROM KOCURY
WHERE MYSZY_EXTRA IS NOT NULL
CONNECT BY PRIOR pseudo = szef
START WITH szef IS NULL;

/* zadanie 16 */
SELECT RPAD('   ',(level-1)*LENGTH('   '),'   ') || pseudo AS "Droga sluzbowa"
FROM Kocury
CONNECT BY PRIOR szef = pseudo AND pseudo != 'LYSY'
START WITH months_between(SYSDATE,w_stadku_od)/12 > 13
    AND plec = 'M'
    AND myszy_extra IS NULL



