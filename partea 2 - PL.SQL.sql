SET SERVEROUTPUT ON
SET VERIFY OFF
--Acest bloc PL/SQL permite clientului sa vizualizeze opțiunile de excursii disponibile în funcție de locația dorită: România sau străinătate. După introducerea locației, programul va afișa excursiile disponibile si detalii despre acestea.
ACCEPT p_locatie PROMPT 'Unde doriti sa calatoriti? Introduceti Romania sau strainatate.'
DECLARE
    v_locatie VARCHAR2(100);
    v_id_excursie excursii.id_excursie%TYPE;
    v_destinatie excursii.destinatie%TYPE;
    v_durata excursii.durata%TYPE;
    v_nivel_dif excursii.nivel_dificultate%TYPE;
    v_pot_pt_copii excursii.potrivita_pt_copii%TYPE;
    v_pret logistica.cost_total%TYPE;
    CURSOR c_excursii IS
        SELECT id_excursie, destinatie, durata, nivel_dificultate, potrivita_pt_copii
        FROM excursii 
        WHERE (v_locatie = 'Romania' AND destinatie IN ('Predeal', 'Navodari')) 
        OR (v_locatie = 'strainatate' AND destinatie NOT IN ('Predeal', 'Navodari'));
    CURSOR c_logistica(p_excursie_id excursii.id_excursie%TYPE) IS
        SELECT cost_total
        FROM logistica
        WHERE id_excursie = p_excursie_id;
BEGIN
    v_locatie := '&p_locatie';
    OPEN c_excursii;
    LOOP
        FETCH c_excursii INTO v_id_excursie, v_destinatie, v_durata, v_nivel_dif, v_pot_pt_copii;
        EXIT WHEN c_excursii%NOTFOUND;
        OPEN c_logistica(v_id_excursie);
        FETCH c_logistica INTO v_pret;
        CLOSE c_logistica;
        DBMS_OUTPUT.PUT_LINE('---------------------------- ');
        DBMS_OUTPUT.PUT_LINE('Destinatie: ' || v_destinatie);
        DBMS_OUTPUT.PUT_LINE('Durata: ' || v_durata || ' zile');
        DBMS_OUTPUT.PUT_LINE('Nivel dificultate: ' || v_nivel_dif);
        DBMS_OUTPUT.PUT_LINE('Potrivita pentru copii: ' || v_pot_pt_copii);
        DBMS_OUTPUT.PUT_LINE('Pret pentru o persoana: ' || v_pret || ' EURO');
    END LOOP;
    CLOSE c_excursii;
END;
/
 
--Acest bloc PL/SQL  permite utilizatorului să introducă o destinație și numărul de participanți la o excursie. După aceea, programul caută în baza de date informații despre excursii care au destinația specificată de utilizator și calculează costul total al excursiei pentru numărul specificat de participanți.
ACCEPT p_destinatie CHAR PROMPT 'Introduceti destinatia: '
ACCEPT p_nr_participanti NUMBER PROMPT 'Introduceti numarul de participanti: '
DECLARE
    v_destinatie VARCHAR2(100) := '&p_destinatie';
    v_nr_participanti NUMBER := '&p_nr_participanti';
    v_cost_persoana logistica.cost_total%TYPE;
    v_cost_total NUMBER;
    CURSOR c_excursii IS
        SELECT e.destinatie, l.cost_total
        FROM excursii e, logistica l
        WHERE e.id_logistica = l.id_logistica AND e.destinatie = v_destinatie;
BEGIN
    OPEN c_excursii;
    FETCH c_excursii INTO v_destinatie, v_cost_persoana;
    IF c_excursii%FOUND THEN
        v_cost_total := v_cost_persoana * v_nr_participanti;
        DBMS_OUTPUT.PUT_LINE('Destinatia ' || v_destinatie); 
        DBMS_OUTPUT.PUT_LINE('---------------------');
        DBMS_OUTPUT.PUT_LINE('Pret pentru o persoana: ' || v_cost_persoana || ' euro.');
         DBMS_OUTPUT.PUT_LINE('Pret pentru ' || v_nr_participanti || ' persoane: ' || v_cost_total || ' euro.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Nu am putut gasi destinatia specificata.');
    END IF;
    CLOSE c_excursii;
END;
/
 

-- Acest bloc PL/SQL permite utilizatorului să vadă, în funcție de destinația și prețul maxim alese de acesta, facilitățile excursiilor disponibile, cum ar fi tipul de cazare, dacă sunt incluse mese etc.
ACCEPT p_destinatie PROMPT 'Introduceti destinatia: ';
ACCEPT p_pret_maxim PROMPT 'Introduceti pretul maxim: ';
DECLARE
    v_destinatie excursii.destinatie%TYPE := '&p_destinatie';
    v_pret_maxim NUMBER := '&p_pret_maxim';
    v_id_excursie excursii.id_excursie%TYPE;
    v_durata excursii.durata%TYPE;
    v_pret_total logistica.cost_total%TYPE;
    v_tip_transport logistica.tip_transport%TYPE;
    v_tip_cazare logistica.tip_cazare%TYPE;
    v_mese_incluse logistica.mese_incluse%TYPE;
    CURSOR c_excursii IS
        SELECT E.id_excursie, E.durata, L.cost_total, L.tip_transport, L.tip_cazare, L.mese_incluse
        FROM excursii E
        JOIN logistica L ON E.id_excursie = L.id_excursie
        WHERE E.destinatie = v_destinatie AND L.cost_total <= v_pret_maxim;
BEGIN
    OPEN c_excursii;
    LOOP
        FETCH c_excursii INTO v_id_excursie, v_durata, v_pret_total, v_tip_transport, v_tip_cazare, v_mese_incluse;
        EXIT WHEN c_excursii%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('---------------------------- ');
        DBMS_OUTPUT.PUT_LINE('ID excursie: ' || v_id_excursie);
        DBMS_OUTPUT.PUT_LINE('Durata: ' || v_durata || ' zile');
        DBMS_OUTPUT.PUT_LINE('Mijloc de transport: ' || v_tip_transport);
        DBMS_OUTPUT.PUT_LINE('Cazare: ' || v_tip_cazare);
        DBMS_OUTPUT.PUT_LINE('Mese incluse: ' || v_mese_incluse);
        DBMS_OUTPUT.PUT_LINE('Pret pentru o persoana: ' || v_pret_total || ' EURO');
    END LOOP;
    CLOSE c_excursii;
END;
/
 
--Acest bloc PL/SQL permite utilizatorului sa vizualizeze vanzarile si numarul de programari dintr-o luna introdusa de acesta de la tastatura.
ACCEPT p_luna PROMPT 'Introduceti luna (YYYY-MM): ';
DECLARE
    v_data_inceput DATE := TO_DATE('&p_luna', 'YYYY-MM');
    v_data_sfarsit DATE := ADD_MONTHS(v_data_inceput, 1);
    v_numar_excursii NUMBER := 0;
    v_vanzari_totale NUMBER := 0;
BEGIN
    FOR excursie_rec IN (
        SELECT pr.id_excursie, l.cost_total
        FROM programari pr
        JOIN logistica l ON pr.id_excursie = l.id_excursie
        WHERE TRUNC(pr.data_programare) >= v_data_inceput AND TRUNC(pr.data_programare) < v_data_sfarsit
    ) LOOP
        v_numar_excursii := v_numar_excursii + 1;
        v_vanzari_totale := v_vanzari_totale + excursie_rec.cost_total;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Numarul de excursii programate pentru luna ' || TO_CHAR(v_data_inceput, 'MM/YYYY') || ': ' || v_numar_excursii);
    DBMS_OUTPUT.PUT_LINE('Vanzari totale pentru luna ' || TO_CHAR(v_data_inceput, 'MM/YYYY') || ': ' || v_vanzari_totale || ' EURO');
END;
/
 

--Urmatorul bloc PL/SQL permite utilizatorului sa adauge un discount la o excursie, introducand id-ul excursiei pe care doreste sa o modifice. Valoarea discountului va fi aleasa si introdusa tot de utilizator.
ACCEPT p_id_excursie PROMPT 'Introduceti ID-ul excursiei pentru care doriti sa aplicati discount: ';
ACCEPT p_discount PROMPT 'Introduceti valoarea discountului (sub forma de procent, ex: 15): ';
DECLARE
    v_id_excursie excursii.id_excursie%TYPE;
    v_discount NUMBER := TO_NUMBER('&p_discount') / 100; 
    v_cost_total logistica.cost_total%TYPE;
BEGIN
    v_id_excursie := TO_NUMBER('&p_id_excursie');
    FOR excursie_rec IN (
        SELECT l.cost_total
        FROM logistica l
        WHERE L.id_excursie = v_id_excursie
    ) LOOP
        v_cost_total := excursie_rec.cost_total;
        v_cost_total := v_cost_total * (1 - v_discount);
        UPDATE logistica
        SET cost_total = v_cost_total
        WHERE id_excursie = v_id_excursie;
        DBMS_OUTPUT.PUT_LINE('Discount aplicat cu succes pentru excursia cu ID-ul ' || v_id_excursie);
        EXIT;
    END LOOP;
    IF SQL%NOTFOUND THEN
        DBMS_OUTPUT.PUT_LINE('Excursia cu ID-ul ' || v_id_excursie || ' nu a fost gasita.');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('A intervenit o eroare. Discountul nu a putut fi aplicat.');
END;
/

SELECT*FROM logistica;

--Urmatorul bloc PL/SQL anuleaza excursiile neplatite al caror id este introdus de la tastatura, de asemenea in cazul in care exista exceptii, adica nu exista programare cu acel id sau e deja platita, le trateaza. (exceptii definite de utilizator)
ACCEPT id_p PROMPT 'Introduceți ID-ul programarii pe care doriți sa o anulati: ';

DECLARE
    excursie_anulata EXCEPTION;
    PRAGMA EXCEPTION_INIT(excursie_anulata, -20003);
    v_id_p programari.id_programare%TYPE;
    v_status_plata programari.status_plata%TYPE;
    
BEGIN
    v_id_p := &id_p;
    SELECT status_plata, id_programare
    INTO v_status_plata, v_id_p
    FROM programari
    WHERE id_programare = v_id_p;

    IF v_status_plata = 'Neplatit' THEN
        UPDATE programari
        SET status_plata = 'Anulat'
        WHERE id_programare = v_id_p;
        DBMS_OUTPUT.PUT_LINE('Programarea cu ID ' || v_id_p || ' a fost anulata.');
    ELSE
        RAISE excursie_anulata;
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Nu exista o programare cu ID-ul specificat.');
    WHEN excursie_anulata THEN
        DBMS_OUTPUT.PUT_LINE('Programarea nu poate fi anulata deoarece excursia este deja platita.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('A intervenit o eroare in procesul de anulare a programarii: ' || SQLERRM);
        DBMS_OUTPUT.PUT_LINE('Codul de eroare: ' || SQLERRM);
END;
/
id = 3
 
id = 1
 
--Acest bloc PL/SQL permite utilizatorului sa actualizeze statusul programarilor neplatite in ‘Platit’, introducand de la tastatura id-ul, de asemenea utilizeaza exceptii pentru cazul in care nu exista inregistrari neplatite cu id-ul introdus (exceptii de sistem).
ACCEPT id_programare PROMPT 'Introduceti ID-ul programarii: ';
DECLARE
    v_id_programare programari.id_programare%TYPE := &id_programare;
    v_count NUMBER := 0;
    CURSOR c_programari IS
        SELECT id_programare
        FROM programari
        WHERE id_programare = v_id_programare
        AND status_plata = 'Neplatit';
BEGIN
    FOR programare_rec IN c_programari LOOP
        v_count := v_count + 1;
        UPDATE programari
        SET status_plata = 'Platit'
        WHERE id_programare = v_id_programare;
    END LOOP;
    IF v_count > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Statusul programarii cu id-ul ' || v_id_programare || ' a fost actualizat la "Platit".');
    ELSE
        RAISE NO_DATA_FOUND;
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Nu exista o programare neplatita cu id-ul ' || v_id_programare || '.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('A intervenit o eroare in procesul de actualizare a programarii.');
END;
/
 
--Acest bloc PL/SQL permite utilizatorului sa vizualizeze excursii disponibile in functie de nivelul de dificultate introdus de la tastatura, iar in cazul in care acesta nu este valid trateaza exceptia(exceptii de sistem).
ACCEPT nivel_dificultate PROMPT 'Introduceti nivelul de dificultate al excursiilor (Usor/Mediu/Dificil): ';
DECLARE
    v_nivel_dif excursii.nivel_dificultate%TYPE := UPPER('&nivel_dificultate');
    v_destinatie excursii.destinatie%TYPE;
    v_durata excursii.durata%TYPE;
    v_excursii_existente NUMBER := 0;
    CURSOR c_excursii IS
        SELECT destinatie, durata
        FROM excursii
        WHERE UPPER(nivel_dificultate) = v_nivel_dif
        AND v_nivel_dif IN('USOR', 'MEDIU', 'DIFICIL');
BEGIN
    FOR excursie_rec IN c_excursii LOOP
        v_destinatie := excursie_rec.destinatie;
        v_durata := excursie_rec.durata;
        v_excursii_existente := v_excursii_existente + 1;
        DBMS_OUTPUT.PUT_LINE('Destinatie: ' || v_destinatie);
        DBMS_OUTPUT.PUT_LINE('Durata: ' || v_durata || ' zile');
        DBMS_OUTPUT.PUT_LINE('------------------');
    END LOOP;
    IF v_excursii_existente = 0 THEN
        RAISE NO_DATA_FOUND;
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Nivelul de dificultate introdus nu este valid. Introduceti "Usor", "Mediu" sau "Dificil".');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('A intervenit o eroare in procesul de afisare a excursiilor.');
END;
/

--Acest bloc PL/SQL permite adaugarea unui nou participant, iar daca participantul are acelasi id-ul cu al unui participant deja inregistrat se va trata exceptia in mod corespunzator(exceptie definita de utilizator).
ACCEPT id_participant PROMPT 'Introduceti ID-ul participantului: ';
ACCEPT nume PROMPT 'Introduceti numele participantului: ';
ACCEPT nr_telefon PROMPT 'Introduceti numarul de telefon: ';
ACCEPT varsta PROMPT 'Introduceti varsta participantului: ';
DECLARE
    v_id_participant participanti.id_participant%TYPE := '&id_participant';
    v_nume participanti.nume%TYPE := '&nume';
    v_nr_telefon participanti.nr_telefon%TYPE := '&nr_telefon';
    v_varsta participanti.varsta%TYPE := '&varsta';
    v_count NUMBER := 0;
    participant_exista EXCEPTION;
    PRAGMA EXCEPTION_INIT(participant_exista, -20001);
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM participanti
    WHERE id_participant = v_id_participant;
    IF v_count = 0 THEN 
        INSERT INTO participanti (id_participant, nume, nr_telefon, varsta)
        VALUES (v_id_participant, v_nume, v_nr_telefon, v_varsta);
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Participantul a fost adaugat cu succes in baza de date.');
    ELSE
        RAISE participant_exista;
    END IF;
EXCEPTION
    WHEN participant_exista THEN
        DBMS_OUTPUT.PUT_LINE('Participantul cu ID-ul specificat exista deja in baza de date.');
    WHEN OTHERS THEN  
        DBMS_OUTPUT.PUT_LINE('A intervenit o eroare in procesul de adaugare a participantului: ' || SQLERRM);
END;
/
/*Pachetul gestionare_excursii este un pachet PL/SQL care contine proceduri si functii pentru gestionarea excursiilor intr-o baza de date. Acesta include urmatoarele subprograme:
 - Procedura adauga_excursie: Aceasta procedura primeste detalii despre o excursie si incearca sa o adauge in baza de date. Daca exista deja o excursie cu acelasi ID, procedura va genera o exceptie si va afisa un mesaj corespunzator.
 - Procedura sterge_excursie: Aceasta procedura primeste un ID de excursie si incearca sa stearga excursia corespunzatoare din baza de date. Daca nu exista nicio excursie cu ID-ul specificat, procedura va genera o exceptie si va afisa un mesaj corespunzator.
 - Functia calcul_nr_participanti: Aceasta functie primeste un ID de excursie si returneaza numarul de participanti la acea excursie. Daca nu exista nicio excursie cu ID-ul specificat, functia va genera o exceptie si va returna NULL.
 - Functia verifica_disponibilitate: Aceasta functie primeste o data si verifica daca exista excursii disponibile pentru acea data. Daca exista, functia returneaza ID-ul primei excursii disponibile. Daca nu exista nicio excursie disponibila pentru data specificata, functia returneaza 0.*/

CREATE OR REPLACE PACKAGE gestiune_excursii AS
PROCEDURE adauga_excursie(
        id_excursie IN excursii.id_excursie%TYPE,
        id_logistica IN logistica.id_logistica%TYPE,
        destinatie IN excursii.destinatie%TYPE,
        durata IN excursii.durata%TYPE,
        nivel_dificultate IN excursii.nivel_dificultate%TYPE,
        potrivita_pt_copii IN excursii.potrivita_pt_copii%TYPE
        );
PROCEDURE sterge_excursie(
        id_excursie IN excursii.id_excursie%TYPE
    );
FUNCTION calcul_nr_participanti(p_id_excursie IN excursii.id_excursie%TYPE) RETURN NUMBER;
  FUNCTION verifica_disponibilitate(data_input IN DATE) RETURN NUMBER;
END gestiune_excursii;
/
 
CREATE OR REPLACE PACKAGE BODY gestiune_excursii AS
    PROCEDURE adauga_excursie (
        id_excursie IN excursii.id_excursie%TYPE,
        id_logistica IN logistica.id_logistica%TYPE,
        destinatie IN excursii.destinatie%TYPE,
        durata IN excursii.durata%TYPE,
        nivel_dificultate IN excursii.nivel_dificultate%TYPE,
        potrivita_pt_copii IN excursii.potrivita_pt_copii%TYPE
    ) IS
        excursie_exista EXCEPTION;
        PRAGMA EXCEPTION_INIT(excursie_exista, -20001);
        v_count_excursie NUMBER := 0;
    BEGIN
        SELECT COUNT(*)
        INTO v_count_excursie
        FROM excursii
        WHERE id_excursie = adauga_excursie.id_excursie;
        IF v_count_excursie > 0 THEN
            RAISE excursie_exista;
        END IF;
        INSERT INTO excursii (id_excursie, id_logistica, destinatie, durata, nivel_dificultate, potrivita_pt_copii)
        VALUES (id_excursie, id_logistica, destinatie, durata, nivel_dificultate, potrivita_pt_copii);
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Excursia a fost adaugata cu succes in baza de date.');
    EXCEPTION
        WHEN excursie_exista THEN
            DBMS_OUTPUT.PUT_LINE('Excursia cu ID-ul specificat exista deja in baza de date.');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('A intervenit o eroare în procesul de adăugare a excursiei: ' || SQLERRM);
    END adauga_excursie;

    PROCEDURE sterge_excursie(
        id_excursie IN excursii.id_excursie%TYPE
    ) IS
        excursie_negasita EXCEPTION;
        PRAGMA EXCEPTION_INIT(excursie_negasita, -20001);
        v_count NUMBER:=0;
    BEGIN
        SELECT COUNT(*)
        INTO v_count
        FROM excursii
        WHERE id_excursie = sterge_excursie.id_excursie;
        IF v_count = 0 THEN
            RAISE excursie_negasita;
        END IF;
        DELETE FROM excursii WHERE id_excursie = sterge_excursie.id_excursie;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Excursia a fost stearsa cu succes din baza de date.');
    EXCEPTION
        WHEN excursie_negasita THEN
            DBMS_OUTPUT.PUT_LINE('Excursia cu ID-ul specificat nu a fost gasita in baza de date.');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('A intervenit o eroare in procesul de stergere a excursiei: ' || SQLERRM);
    END sterge_excursie;
FUNCTION calcul_nr_participanti(
        p_id_excursie IN excursii.id_excursie%TYPE
    ) RETURN NUMBER IS
        v_nr_participanti NUMBER := 0;
        v_nr_excursii NUMBER := 0;
    BEGIN
        SELECT COUNT(*)
        INTO v_nr_excursii
        FROM excursii
        WHERE id_excursie = p_id_excursie;
        IF v_nr_excursii = 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Excursia cu ID-ul specificat nu exista.');
        END IF;
        FOR participant_rec IN (SELECT id_participant FROM participanti WHERE id_excursie = p_id_excursie) LOOP
            v_nr_participanti := v_nr_participanti + 1;
        END LOOP;
        RETURN v_nr_participanti;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Excursia cu ID-ul specificat nu exista.');
            RETURN NULL;
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('A intervenit o eroare in procesul de calculare a numarului de participanti: ' || SQLERRM);
            RETURN NULL; 
    END calcul_nr_participanti;
    FUNCTION verifica_disponibilitate(data_input IN DATE) RETURN NUMBER IS
        v_id_excursie excursii.id_excursie%TYPE;
        v_nr_excursii NUMBER := 0;
    BEGIN
        v_id_excursie := 0;
        FOR programare_rec IN (SELECT id_excursie FROM programari WHERE TRUNC(data_programare) = TRUNC(data_input)) LOOP
            v_id_excursie := programare_rec.id_excursie; 
            v_nr_excursii := v_nr_excursii + 1; 
        END LOOP;
        IF v_nr_excursii > 0 THEN
            RETURN v_id_excursie;
        ELSE
            RETURN 0;
        END IF;
    END verifica_disponibilitate;
END gestiune_excursii;
/
 
--apelul procedurii adauga_excursie
ACCEPT id_excursie PROMPT 'Introduceți ID-ul excursiei: ';
ACCEPT id_logistica PROMPT 'Introduceți ID-ul logistică: ';
ACCEPT destinatie PROMPT 'Introduceți destinația excursiei: ';
ACCEPT durata PROMPT 'Introduceți durata excursiei (în zile): ';
ACCEPT nivel_dificultate PROMPT 'Introduceți nivelul de dificultate (Usor/Mediu/Dificil): ';
ACCEPT potrivita_pt_copii PROMPT 'Este potrivită pentru copii? (Da/Nu): ';
BEGIN
    gestiune_excursii.adauga_excursie(
        &id_excursie,
        &id_logistica,
        '&destinatie',
        &durata,
        '&nivel_dificultate',
        '&potrivita_pt_copii'
    );
END;
/
SELECT *FROM excursii;
/
 
 
--apelul procedurii sterge_excursie
ACCEPT id_excursie PROMPT 'Introduceți ID-ul excursiei pe care doriți să o ștergeți: ';
BEGIN
    gestiune_excursii.sterge_excursie(&id_excursie);
END; 
/
                           
--apelul functiei calcul_nr_participanti
ACCEPT id_excursie PROMPT 'Introduceți ID-ul excursiei: ';
DECLARE
    v_nr_participanti NUMBER;
BEGIN
    v_nr_participanti := gestiune_excursii.calcul_nr_participanti(&id_excursie);
    IF v_nr_participanti IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('Numarul de participanti la excursia data este: ' || v_nr_participanti);
    END IF;
END;
/
 
--apelul functiei verifica_disponibilitate
ACCEPT data_input PROMPT 'Introduceți data (YYYY-MM-DD): ';
DECLARE
    v_data_input DATE := TO_DATE('&data_input', 'YYYY-MM-DD');
    v_id_excursie_disponibila excursii.id_excursie%TYPE;
BEGIN
    v_id_excursie_disponibila := gestiune_excursii.verifica_disponibilitate(v_data_input);
    IF v_id_excursie_disponibila > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Exista excursii disponibile pentru data de ' || TO_CHAR(v_data_input, 'DD-MON-YYYY') || '.');
        DBMS_OUTPUT.PUT_LINE('ID-ul primei excursii disponibile este: ' || v_id_excursie_disponibila);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Nu exista excursii disponibile pentru data de ' || TO_CHAR(v_data_input, 'DD-MON-YYYY') || '.');
    END IF;
END;
/
 
/*Pachetul gestionare_logistica este un pachet PL/SQL care contine proceduri si functii pentru gestionarea informatiilor legate de logistica intr-o baza de date. Acesta include urmatoarele subprograme:
 - Procedura modifica_pret: Procedura primeste un ID de logistica si un nou pret, iar apoi incearca sa actualizeze pretul corespunzator in baza de date. Daca pretul nou este mai mic sau egal cu 0, procedura va afisa un mesaj de eroare. Daca pretul nou este identic cu pretul existent, nu se va face nicio modificare.
 - Procedura adauga_logistica: Procedura primeste detalii despre o noua inregistrare logistica si incearca sa o adauge in baza de date. Daca exista deja o inregistrare logistica cu acelasi ID, procedura va afisa un mesaj de eroare.
 - Functia numara_excursii_dupa_transport: Functia primeste un tip de transport si returneaza numarul de excursii disponibile pentru acel tip de transport.
 - Functia cea_mai_ieftina_excursie: Functia primeste o destinatie si returneaza ID-ul celei mai ieftine excursii disponibile pentru acea destinatie, avand mese incluse.
 - Functia pret_mediu_excursii: Functia primeste o destinatie si returneaza pretul mediu al excursiilor disponibile pentru acea destinatie. */
CREATE OR REPLACE PACKAGE gestiune_logistica AS
   PROCEDURE modifica_pret(
        id_logistica IN logistica.id_logistica%TYPE,
        nou_pret IN logistica.cost_total%TYPE
    );
PROCEDURE adauga_logistica(
        id_logistica IN logistica.id_logistica%TYPE,
        id_excursie IN logistica.id_excursie%TYPE,
        tip_transport IN logistica.tip_transport%TYPE,
        mese_incluse IN logistica.mese_incluse%TYPE,
        tip_cazare IN logistica.tip_cazare%TYPE,
        cost_total IN logistica.cost_total%TYPE
    );
FUNCTION numara_excursii_dupa_transport(
        v_tip_transport IN logistica.tip_transport%TYPE 
    ) RETURN NUMBER;
    FUNCTION cea_mai_ieftina_excursie(v_destinatie IN excursii.destinatie%TYPE) RETURN NUMBER;
FUNCTION pret_mediu_excursii(v_destinatie IN excursii.destinatie%TYPE) RETURN NUMBER;
END gestiune_logistica;
/
 
CREATE OR REPLACE PACKAGE BODY gestiune_logistica AS
PROCEDURE modifica_pret(
    id_logistica IN logistica.id_logistica%TYPE,
    nou_pret IN logistica.cost_total%TYPE
) IS
    v_pret_existenta NUMBER;
BEGIN
    SELECT cost_total
    INTO v_pret_existenta
    FROM logistica
    WHERE id_logistica = modifica_pret.id_logistica;
    IF nou_pret <= 0 THEN
        DBMS_OUTPUT.PUT_LINE('Noul pret trebuie sa fie mai mare de 0.');
        RETURN;
    END IF;
    IF v_pret_existenta <> nou_pret THEN
        UPDATE logistica
        SET cost_total = nou_pret
        WHERE id_logistica = modifica_pret.id_logistica;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Pretul a fost modificat cu succes.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Noul pret este identic cu pretul existent. Nu este necesara nicio modificare.');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Logistica cu ID-ul specificat nu a fost gasita.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('A intervenit o eroare în procesul de modificare a pretului: ' || SQLERRM);
END modifica_pret;
    PROCEDURE adauga_logistica (
        id_logistica IN logistica.id_logistica%TYPE,
        id_excursie IN logistica.id_excursie%TYPE,
        tip_transport IN logistica.tip_transport%TYPE,
        mese_incluse IN logistica.mese_incluse%TYPE,
        tip_cazare IN logistica.tip_cazare%TYPE,
        cost_total IN logistica.cost_total%TYPE
    ) IS
        logistica_exista EXCEPTION;
        PRAGMA EXCEPTION_INIT(logistica_exista, -20001);
        v_count_logistica NUMBER := 0;
    BEGIN
        SELECT COUNT(*)
        INTO v_count_logistica
        FROM logistica
        WHERE id_logistica = adauga_logistica.id_logistica;
        IF v_count_logistica > 0 THEN
            RAISE logistica_exista;
        END IF;
        INSERT INTO logistica (id_logistica, id_excursie, tip_transport, mese_incluse, tip_cazare, cost_total)
        VALUES (id_logistica, id_excursie, tip_transport, mese_incluse, tip_cazare, cost_total);
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Logistica a fost adaugata cu succes in baza de date.');
    EXCEPTION
        WHEN logistica_exista THEN
            DBMS_OUTPUT.PUT_LINE('Logistica cu ID-ul specificat exista deja in baza de date.');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('A intervenit o eroare in procesul de adaugare a logisticii: ' || SQLERRM);
    END adauga_logistica;
FUNCTION numara_excursii_dupa_transport(
        v_tip_transport IN logistica.tip_transport%TYPE
    ) RETURN NUMBER IS
        v_numar_excursii NUMBER := 0;
    BEGIN
        SELECT COUNT(*)
        INTO v_numar_excursii
        FROM logistica
        WHERE tip_transport = v_tip_transport;
        RETURN v_numar_excursii;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 0;
        WHEN OTHERS THEN
            RETURN NULL;
    END numara_excursii_dupa_transport;
FUNCTION cea_mai_ieftina_excursie(
    v_destinatie IN excursii.destinatie%TYPE
) RETURN NUMBER IS
    v_id_excursie logistica.id_excursie%TYPE;
BEGIN
    SELECT id_excursie
    INTO v_id_excursie
    FROM (
        SELECT id_excursie
        FROM logistica
        WHERE id_excursie IN (
            SELECT id_excursie
            FROM excursii
            WHERE destinatie = v_destinatie
        )
        AND mese_incluse = 'Da'
        ORDER BY cost_total ASC
    )
    FETCH FIRST 1 ROWS ONLY;

    RETURN v_id_excursie;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Nu exista excursii disponibile cu mese incluse pentru destinatia specificata.');
        RETURN NULL;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('A intervenit o eroare in procesul de gasire a celei mai ieftine excursii: ' || SQLERRM);
        RETURN NULL;
END cea_mai_ieftina_excursie;
    FUNCTION pret_mediu_excursii(
        v_destinatie IN excursii.destinatie%TYPE
    ) RETURN NUMBER IS
        v_pret_mediu NUMBER;
    BEGIN
        SELECT AVG(cost_total)
        INTO v_pret_mediu
        FROM logistica
        WHERE id_excursie IN (SELECT id_excursie FROM excursii WHERE destinatie = v_destinatie);
        RETURN v_pret_mediu;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
        WHEN OTHERS THEN
            RETURN NULL;
    END pret_mediu_excursii;
END gestiune_logistica;
/
 
--apelul procedurii modifica_pret
ACCEPT v_id_logistica PROMPT 'Introduceți ID-ul logistică: ';
ACCEPT v_nou_pret PROMPT 'Introduceți noul preț: ';
BEGIN
    gestiune_logistica.modifica_pret(
        &v_id_logistica,
        &v_nou_pret
    );
END;
/
 
--apelul procedurii adauga_logistica
ACCEPT id_logistica PROMPT 'Introduceți ID-ul logistică: ';
ACCEPT id_excursie PROMPT 'Introduceți ID-ul excursiei: ';
ACCEPT tip_transport PROMPT 'Introduceți tipul de transport: ';
ACCEPT mese_incluse PROMPT 'Introduceți tipul de mese incluse: ';
ACCEPT tip_cazare PROMPT 'Introduceți tipul de cazare: ';
ACCEPT cost_total PROMPT 'Introduceți costul total: ';
BEGIN
    gestiune_logistica.adauga_logistica(
        &id_logistica,
        &id_excursie,
        '&tip_transport',
        '&mese_incluse',
        '&tip_cazare',
        &cost_total
    );
END;
/
 
--apelul functiei numara_excursii_dupa_transport
ACCEPT v_transport CHAR PROMPT 'Introduceți mijlocul de transport (Avion/Autocar/Tren): ';
DECLARE
    v_nr_excursii NUMBER;
    v_transport logistica.tip_transport%TYPE;
BEGIN
    v_transport := TRIM('&v_transport');
    v_nr_excursii := gestiune_logistica.numara_excursii_dupa_transport(v_transport);
    IF v_nr_excursii > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Sunt disponibile ' || v_nr_excursii|| ' care au ca mijloc de transport ' || v_transport || '.');
    END IF;
END;
/
 
ACCEPT v_destinatie PROMPT 'Introduceți destinația pentru căutarea celei mai ieftine excursii cu mese incluse: ';
DECLARE
    v_id_excursie NUMBER;
    v_destinatie VARCHAR2(100);
BEGIN
    v_destinatie := TO_CHAR('&v_destinatie');
    v_id_excursie := gestiune_logistica.cea_mai_ieftina_excursie(v_destinatie);
    IF v_id_excursie IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('Cea mai ieftina excursie cu destinatia ' || v_destinatie || ' si mese incluse are ID-ul ' || v_id_excursie || '.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Nu exista excursii disponibile pentru destinatia introdusa.');
    END IF;
END;
/
 
--apelul functiei pret_mediu_excursii
ACCEPT v_destinatie PROMPT 'Introduceți destinația pentru calcularea prețului mediu al excursiilor: ';

DECLARE
    v_pret_mediu NUMBER;
BEGIN
    v_pret_mediu := gestiune_logistica.pret_mediu_excursii('&v_destinatie');
    IF v_pret_mediu IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('Pretul mediu al excursiilor pentru destinatia introdusa este: ' || v_pret_mediu || ' euro. ');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Nu exista excursii disponibile pentru destinatia introdusa.');
    END IF;
END;
/
