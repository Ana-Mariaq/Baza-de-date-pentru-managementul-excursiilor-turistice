-- Construirea bazei de date - tabele, legaturi intre tabele si restrictii de integritate. Exemplificarea operatiilor LDD (CREATE, ALTER, DROP) asupra tabelelor.
CREATE TABLE excursii (
id_excursie NUMBER PRIMARY KEY,
id_logistica NUMBER,
destinatie VARCHAR2(100),
durata NUMBER CONSTRAINT durata_pozitiva CHECK (durata > 0),
nivel_dificultate VARCHAR2(50) CONSTRAINT dificultate_valida CHECK (nivel_dificultate IN ('Usor', 'Mediu', 'Dificil')),
potrivita_pt_copii CHAR(2) CONSTRAINT copii_valid CHECK (potrivita_pt_copii IN ('Da', 'Nu'))
);

CREATE TABLE logistica (
id_logistica NUMBER PRIMARY KEY,
id_excursie NUMBER,
tip_transport VARCHAR2(50),
mese_incluse CHAR(2) CONSTRAINT mese_valid CHECK (mese_incluse IN ('Da', 'Nu')),
tip_cazare VARCHAR2(50),
cost_total NUMBER CONSTRAINT cost_pozitiv CHECK (cost_total > 0)
);

CREATE TABLE participanti (
id_participant NUMBER PRIMARY KEY,
id_excursie NUMBER,
nume VARCHAR2(100),
nr_telefon VARCHAR2(15),
varsta NUMBER CONSTRAINT varsta_pozitiva CHECK (varsta > 0)
);

CREATE TABLE programari (
id_programare NUMBER PRIMARY KEY,
id_participant NUMBER,
id_excursie NUMBER,
data_programare DATE,
status_plata CHAR(8) CONSTRAINT plata_valida CHECK (status_plata IN ('Platit', 'Neplatit'))
);

CREATE TABLE participanti_temp
AS SELECT * FROM participanti;

ALTER TABLE excursii
ADD CONSTRAINT fk_excursii_logistica FOREIGN KEY (id_logistica) REFERENCES logistica(id_logistica);

ALTER TABLE participanti
ADD CONSTRAINT fk_participanti_excursii FOREIGN KEY (id_excursie) REFERENCES excursii(id_excursie);

ALTER TABLE programari
ADD CONSTRAINT fk_programari_participanti FOREIGN KEY (id_participant) REFERENCES participanti(id_participant);

ALTER TABLE programari
ADD CONSTRAINT fk_programari_excursii FOREIGN KEY (id_excursie) REFERENCES excursii(id_excursie);

ALTER TABLE participanti_temp
ADD CONSTRAINT pk_participanti_temp PRIMARY KEY (id_participant);

ALTER TABLE participanti_temp
ADD CONSTRAINT fk_participanti_temp_excursii FOREIGN KEY (id_excursie) REFERENCES excursii(id_excursie);

ALTER TABLE participanti_temp
ADD CONSTRAINT varsta_pozitiva_temp CHECK (varsta > 0);

ALTER TABLE logistica
ADD CONSTRAINT fk_logistica_excursii FOREIGN KEY(id_excursie) REFERENCES excursii(id_excursie);

DROP TABLE participanti_temp CASCADE CONSTRAINTS;

FLASHBACK TABLE participanti_temp TO BEFORE DROP;

--Exemple cu operatii de actualizare a datelor, LMD - INSERT, UPDATE, DELETE, MERGE.
INSERT INTO excursii (id_excursie, id_logistica, destinatie, durata, nivel_dificultate, potrivita_pt_copii) VALUES (1, 1, 'Roma', 3, 'Mediu', 'Da');
INSERT INTO excursii (id_excursie, id_logistica, destinatie, durata, nivel_dificultate, potrivita_pt_copii) VALUES (2, 2, 'Paris', 5, 'Mediu', 'Nu');
INSERT INTO excursii (id_excursie, id_logistica, destinatie, durata, nivel_dificultate, potrivita_pt_copii) VALUES (3, 3, 'Mykonos', 2, 'Dificil', 'Nu');
INSERT INTO excursii (id_excursie, id_logistica, destinatie, durata, nivel_dificultate, potrivita_pt_copii) VALUES (4, 4, 'Austria', 4, 'Usor', 'Da');
INSERT INTO excursii (id_excursie, id_logistica, destinatie, durata, nivel_dificultate, potrivita_pt_copii) VALUES (5, 5, 'Austria', 6, 'Mediu', 'Da');
INSERT INTO excursii (id_excursie, id_logistica, destinatie, durata, nivel_dificultate, potrivita_pt_copii) VALUES (6, 6, 'Paris', 3, 'Mediu', 'Nu');
INSERT INTO excursii (id_excursie, id_logistica, destinatie, durata, nivel_dificultate, potrivita_pt_copii) VALUES (7, 7, 'Egipt', 7, 'Dificil', 'Nu');
INSERT INTO excursii (id_excursie, id_logistica, destinatie, durata, nivel_dificultate, potrivita_pt_copii) VALUES (8, 8, 'Predeal', 5, 'Dificil', 'Nu');
INSERT INTO excursii (id_excursie, id_logistica, destinatie, durata, nivel_dificultate, potrivita_pt_copii) VALUES (9, 9, 'Navodari', 2, 'Usor', 'Da');
INSERT INTO excursii (id_excursie, id_logistica, destinatie, durata, nivel_dificultate, potrivita_pt_copii) VALUES (10, 10, 'Navodari', 6, 'Usor', 'Da');

INSERT INTO logistica (id_logistica, id_excursie, tip_transport, mese_incluse, tip_cazare, cost_total) VALUES (1, 1, 'Avion', 'Nu', 'Hotel', 500);
INSERT INTO logistica (id_logistica, id_excursie, tip_transport, mese_incluse, tip_cazare, cost_total) VALUES (2, 2, 'Avion', 'Nu', 'Hotel', 600);
INSERT INTO logistica (id_logistica, id_excursie, tip_transport, mese_incluse, tip_cazare, cost_total) VALUES (3, 3, 'Autocar', 'Da', 'Vila', 450);
INSERT INTO logistica (id_logistica, id_excursie, tip_transport, mese_incluse, tip_cazare, cost_total) VALUES (4, 4, 'Autocar', 'Nu', 'Cabana', 550);
INSERT INTO logistica (id_logistica, id_excursie, tip_transport, mese_incluse, tip_cazare, cost_total) VALUES (5, 5, 'Autocar', 'Da', 'Cabana', 650);
INSERT INTO logistica (id_logistica, id_excursie, tip_transport, mese_incluse, tip_cazare, cost_total) VALUES (6, 6, 'Tren', 'Nu', 'Pensiune', 400);
INSERT INTO logistica (id_logistica, id_excursie, tip_transport, mese_incluse, tip_cazare, cost_total) VALUES (7, 7, 'Avion', 'Da', 'Hotel', 550);
INSERT INTO logistica (id_logistica, id_excursie, tip_transport, mese_incluse, tip_cazare, cost_total) VALUES (8, 8, 'Tren', 'Nu', 'Vila', 200);
INSERT INTO logistica (id_logistica, id_excursie, tip_transport, mese_incluse, tip_cazare, cost_total) VALUES (9, 9, 'Tren', 'Nu', 'Hotel', 600);
INSERT INTO logistica (id_logistica, id_excursie, tip_transport, mese_incluse, tip_cazare, cost_total) VALUES (10, 10, 'Autocar', 'Nu', 'Pensiune', 500);

INSERT INTO participanti (id_participant, id_excursie, nume, varsta) VALUES (1, 1, 'Androne Ana-Maria',20);
INSERT INTO participanti (id_participant, id_excursie, nume, nr_telefon, varsta) VALUES (2, 2, 'Ana Ionescu', '0722000002', 18);
INSERT INTO participanti (id_participant, id_excursie, nume, nr_telefon, varsta) VALUES (3, 3, 'Vasile Dumitru', '0722000003', 50);
INSERT INTO participanti (id_participant, id_excursie, nume, nr_telefon, varsta) VALUES (4, 4, 'Maria Popa', '0722000004', 32);
INSERT INTO participanti (id_participant, id_excursie, nume, nr_telefon, varsta) VALUES (5, 5, 'Elena Vasilescu', '0722000005', 40);
INSERT INTO participanti (id_participant, id_excursie, nume, nr_telefon, varsta) VALUES (6, 6, 'Mihai Radu', '0722000006', 16);
INSERT INTO participanti (id_participant, id_excursie, nume, nr_telefon, varsta) VALUES (7, 7, 'Gabriela Mihai', '0722000007', 10);
INSERT INTO participanti (id_participant, id_excursie, nume, nr_telefon, varsta) VALUES (8, 8, 'Andrei Georgescu', '0722000008', 25);
INSERT INTO participanti (id_participant, id_excursie, nume, nr_telefon, varsta) VALUES (9, 9, 'Ioana Marin', '0722000009', 29);
INSERT INTO participanti (id_participant, id_excursie, nume, nr_telefon, varsta) VALUES (10, 10, 'Cristian Stoica', '0722000010', 30);

INSERT INTO participanti_temp (id_participant, id_excursie, nume, nr_telefon, varsta) VALUES (1, 1, 'Androne Ana-Maria', '0722000001', 20);
INSERT INTO participanti_temp (id_participant, id_excursie, nume, nr_telefon, varsta) VALUES (2, 2, 'Ana Ionescu', '0722000002', 18);
INSERT INTO participanti_temp (id_participant, id_excursie, nume, nr_telefon, varsta) VALUES (11, 3, 'George Enescu', '0722000011', 31);
INSERT INTO participanti_temp (id_participant, id_excursie, nume, nr_telefon, varsta) VALUES (12, 4, 'Mihai Eminescu', '0722000012', 32);
INSERT INTO participanti_temp (id_participant, id_excursie, nume, nr_telefon, varsta) VALUES (13, 5, 'Constantin Brancusi', '0722000013', 33);

INSERT INTO programari (id_programare, id_participant, id_excursie, data_programare, status_plata) VALUES (1, 1, 1, TO_DATE('2024-01-01','YYYY-MM-DD'), 'Platit');
INSERT INTO programari (id_programare, id_participant, id_excursie, data_programare, status_plata) VALUES (2, 2, 2, TO_DATE('2024-01-02','YYYY-MM-DD'), 'Platit');
INSERT INTO programari (id_programare, id_participant, id_excursie, data_programare, status_plata) VALUES (3, 3, 3, TO_DATE('2024-05-03','YYYY-MM-DD'), 'Neplatit');
INSERT INTO programari (id_programare, id_participant, id_excursie, data_programare, status_plata) VALUES (4, 4, 4, TO_DATE('2024-05-04','YYYY-MM-DD'), 'Platit');
INSERT INTO programari (id_programare, id_participant, id_excursie, data_programare, status_plata) VALUES (5, 5, 5, TO_DATE('2024-05-05','YYYY-MM-DD'), 'Neplatit');
INSERT INTO programari (id_programare, id_participant, id_excursie, data_programare, status_plata) VALUES (6, 6, 6, TO_DATE('2024-11-06','YYYY-MM-DD'), 'Platit');
INSERT INTO programari (id_programare, id_participant, id_excursie, data_programare, status_plata) VALUES (7, 7, 7, TO_DATE('2024-12-07','YYYY-MM-DD'), 'Platit');
INSERT INTO programari (id_programare, id_participant, id_excursie, data_programare, status_plata) VALUES (8, 8, 8, TO_DATE('2024-01-08','YYYY-MM-DD'), 'Neplatit');
INSERT INTO programari (id_programare, id_participant, id_excursie, data_programare, status_plata) VALUES (9, 9, 9, TO_DATE('2024-08-01','YYYY-MM-DD'), 'Platit');
INSERT INTO programari (id_programare, id_participant, id_excursie, data_programare, status_plata) VALUES (10, 10, 10, TO_DATE('2024-08-07','YYYY-MM-DD'), 'Neplatit');

UPDATE excursii SET durata = 4 WHERE id_excursie = 1;

UPDATE logistica SET cost_total = 600 WHERE id_logistica = 1;

UPDATE participanti SET nr_telefon = '0722111111' WHERE id_participant = 1;

UPDATE programari SET status_plata = 'Platit' WHERE id_programare = 10;

-- Actualizeaza costul total al logisticii pentru excursiile cu un cost total mai mare de 500
UPDATE logistica
SET cost_total = cost_total * 0.8
WHERE id_excursie IN (
SELECT id_excursie
FROM excursii
WHERE cost_total > 500
);

DELETE FROM programari WHERE status_plata = 'Neplatit';

-- Combina datele din tabelul participanti_temp in tabelul participanti
MERGE INTO participanti p
USING participanti_temp pt
ON (p.id_participant = pt.id_participant)
WHEN NOT MATCHED THEN
INSERT (id_participant, id_excursie, nume, nr_telefon, varsta)
VALUES (pt.id_participant, pt.id_excursie, pt.nume, pt.nr_telefon, pt.varsta);

--Exemple de interogari cat mai variate si relevante pentru tema aleasa.

-- Numara participantii pentru fiecare destinatie de excursie
SELECT E.destinatie, COUNT(P.id_participant) AS numar_participanti
FROM excursii E, programari PR, participanti P
WHERE E.id_excursie = PR.id_excursie AND PR.id_participant = P.id_participant
GROUP BY E.destinatie;

-- Afiseaza costul minim pentru fiecare excursie
SELECT E.id_excursie, E.destinatie, MIN(L.cost_total) AS cost_minim
FROM excursii E, logistica L
WHERE E.id_logistica = L.id_logistica
GROUP BY E.id_excursie, E.destinatie;

-- Afiseaza excursiile potrivite pentru copii si detaliile logistice aferente
SELECT E.id_excursie, E.destinatie, L.tip_transport, L.cost_total
FROM excursii E, logistica L
WHERE E.id_logistica = L.id_logistica AND E.potrivita_pt_copii = 'Da';

-- Numara locurile disponibile pentru fiecare destinatie de excursie cu plata neefectuata in urmatoarele 30 de zile
SELECT E.destinatie, COUNT(P.id_participant) AS locuri_disponibile
FROM excursii E, programari PR, participanti P
WHERE E.id_excursie = PR.id_excursie AND PR.id_participant = P.id_participant AND PR.status_plata = 'Neplatit' AND PR.data_programare BETWEEN SYSDATE AND SYSDATE + 30
GROUP BY E.destinatie
ORDER BY locuri_disponibile DESC;

-- Afiseaza detaliile logistice pentru costurile cuprinse intre 400 si 600
SELECT * FROM logistica
WHERE cost_total BETWEEN 400 AND 600;

-- Afiseaza participantii fara numar de telefon
SELECT id_participant, nume
FROM participanti
WHERE nr_telefon IS NULL;

-- Afiseaza excursiile potrivite pentru copii si lunile programarii pentru acestea
SELECT E.id_excursie, E.destinatie, TO_CHAR(PR.data_programare, 'Month') AS luna
FROM excursii E, programari PR
WHERE E.id_excursie = PR.id_excursie AND E.destinatie LIKE '%Destinatie%' AND TO_CHAR(PR.data_programare, 'Month') = 'Luna'
AND E.id_excursie IN (SELECT id_excursie FROM excursii WHERE potrivita_pt_copii = 'Da');

-- Afiseaza starea platii pentru excursiile potrivite pentru copii in weekend
SELECT E.destinatie, CASE WHEN PR.status_plata IS NULL THEN 'Neplatit' ELSE 'Platit' END AS status_plata
FROM excursii E, logistica L, programari PR
WHERE E.id_excursie = PR.id_excursie AND E.id_logistica = L.id_logistica
AND E.potrivita_pt_copii = 'Da' AND TO_CHAR(PR.data_programare, 'DY') IN ('SAT', 'SUN');

-- Afiseaza tipul de transport pentru fiecare excursie
SELECT destinatie,
(SELECT NVL(tip_transport, 'N/A')
FROM logistica L
WHERE E.id_logistica = L.id_logistica) AS tip_transport
FROM excursii E;

-- Afiseaza excursiile in luna iulie cu plata efectuata
SELECT E.destinatie, L.tip_transport
FROM excursii E, logistica L, programari PR
WHERE E.id_excursie = PR.id_excursie AND E.id_logistica = L.id_logistica
AND EXTRACT(MONTH FROM PR.data_programare) = 7 AND PR.status_plata != 'neplatit';

-- Afiseaza destinatiile si costurile totale ale excursiilor fara participant
SELECT E.destinatie, L.cost_total
FROM excursii E
LEFT JOIN programari PR ON E.id_excursie = PR.id_excursie
LEFT JOIN logistica L ON E.id_logistica = L.id_logistica
WHERE PR.id_excursie IS NULL;

-- Afiseaza excursiile potrivite pentru copii sau cu nivel de dificultate mic
SELECT E.id_excursie, E.destinatie
FROM excursii E
WHERE E.potrivita_pt_copii = 'Da'
UNION
SELECT E.id_excursie, E.destinatie
FROM excursii E
WHERE E.nivel_dificultate = 'Mic';

-- Afiseaza excursiile cu mai mult de 10 participanti
SELECT E.id_excursie, COUNT(P.id_participant) AS numar_participanti
FROM excursii E
LEFT JOIN programari PR ON E.id_excursie = PR.id_excursie
LEFT JOIN participanti P ON PR.id_participant = P.id_participant
GROUP BY E.id_excursie
HAVING COUNT(P.id_participant) > 10;

-- Afiseaza nivelul de dificultate pentru excursiile catre Predeal
SELECT E.id_excursie, SUBSTR(E.nivel_dificultate, 1, 7) AS nivel_dificultate
FROM excursii E
WHERE E.destinatie = 'Predeal';

-- Afiseaza excursiile cu durata mai mica de 7 zile
SELECT E.id_excursie, E.destinatie
FROM excursii E
WHERE E.durata < 7;

-- Afiseaza participanti sub 18 ani
SELECT P.id_participant, P.nume
FROM participanti P
WHERE P.varsta <= 18;

-- Afiseaza participanti cu varsta de 18 ani sau mai mult, care au platit si participa la excursii neplatite
SELECT id_participant, nume
FROM participanti
WHERE id_participant IN (
SELECT id_participant
FROM programari
WHERE status_plata = 'Neplatit'
)
INTERSECT
SELECT id_participant, nume
FROM participanti
WHERE varsta >= 18;

-- Afiseaza excursiile cu cazare la hotel si mese incluse, programate dupa 1 august 2023, pentru care plata nu este efectuata
SELECT E.id_excursie
FROM excursii E
JOIN logistica L ON E.id_logistica = L.id_logistica
LEFT JOIN programari PR ON E.id_excursie = PR.id_excursie AND PR.status_plata = 'Platit'
WHERE L.tip_cazare = 'Hotel' AND L.mese_incluse = 'Da' AND PR.id_excursie IS NULL AND PR.data_programare > TO_DATE('2023-08-01', 'YYYY-MM-DD');

-- Construirea si utilizarea altor obiecte ale bazei de date: tabele virtuale, indecsi, sinonime.

-- Crearea unei vederi pentru excursiile potrivite pentru copii
CREATE VIEW ExcursiiPentruCopii AS
SELECT E.id_excursie, E.destinatie, E.durata,
L.tip_transport, L.tip_cazare
FROM excursii E
JOIN logistica L ON E.id_logistica = L.id_logistica
WHERE E.potrivita_pt_copii = 'Da';
SELECT * FROM ExcursiiPentruCopii;

-- Crearea unui index pentru coloana "nume" din tabelul participanti
CREATE INDEX IndiceNumeParticipant ON participanti(nume);
SELECT *
FROM participanti
WHERE nume LIKE 'M%' AND varsta > 30
ORDER BY nume DESC;

-- Crearea unui sinonim pentru tabelul participanti_temp
CREATE SYNONYM PT FOR participanti_temp;
SELECT nume, varsta FROM participanti
UNION
SELECT nume, varsta FROM participanti_temp;
