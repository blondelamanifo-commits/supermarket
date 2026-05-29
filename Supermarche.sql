CREATE DATABASE supermarche;

use supermarche;

CREATE TABLE categories (
    id int auto_increment PRIMARY KEY,
    nom VARCHAR(100)
);

insert into categories(nom)
values('alimentation'),
('hygienne_et_beaute'),
('electromenager_et_electronique'),
('vetement_et_accessoire'),
('papeterie_et_fournisseur'),
('pharmacie_parapharmacie'),
('entretien_menager'),
('produit_surgeles'),
('boucherie_et_poissonerie'),
('bebe');

CREATE TABLE produits (
    id int auto_increment PRIMARY KEY,
    nom VARCHAR(100),
    prix DECIMAL(10,2),
    categorie_id INT,
    FOREIGN KEY (categorie_id) 
    REFERENCES categories(id)
);

insert into produits(nom,prix,categorie_id)
values('riz_parfumer_5kg',8500,1),
('savon_de_toilette',750,2),
('mixeur_electrique',25000,3),
('robe_chanel',10000,4),
('cahier_200pages',500,5),
('dolipranne',1500,6),
('eau_de_javel_1l',1000,7),
('poulet_congele',4500,8),
('viande_de_boeuf_1kg',3500,9),
('lait_doudou',5000,10),
('machine_a_laver',21000,3),
('climatiseur',32000,3),
('micro_ondeur',65000,3),
('lait_en_poudre',4500,1),
('couche_bebe',8500,10),
('riz_50kg',22500,1),
('sac_a_main',10000,4),
('t-shirt_home',5000,4),
('gel_antiseptique',2500,6),
('paracetamol',1500,6),
('spagetti',1200,1),
('creme_hydratante',4200,2),
('vitamine_c',3800,6),
('tomate_conserve',5000,1),
('detergent_en_poudre',2500,7),
('fruit_surgele',3500,8),
('thermometre',4500,6),
('huile_de_tournesol',3500,1),
('deodorant,',2800,2),
('poisson_maquereau',4200,9);

CREATE TABLE clients (
    id int auto_increment PRIMARY KEY,
    nom VARCHAR(100)
);

insert into clients(nom)
values('jean_mbappe'),
('marie_ndzie'),
('alain_tchoua'),
('sandrine_ekedi'),
('patrick_ndzie'),
('brigitte_toko'),
('daryl_emani'),
('carine_bella'),
('emanuel_fokou'),
('kevin_yondo'),
('nadia_fomekou'),
('boris_manifo'),
('donald_kamko'),
('herve_kobotchou'),
('franck_etoa'),
('jaurel_tchouala'),
('jordan_nvondo'),
('cynthia_tchinda'),
('david_kadji'),
('jessica_talla');


CREATE TABLE ventes (
    id int auto_increment PRIMARY KEY,
    produit_id INT,
    client_id INT,
    date DATE,
    quantite INT,
    statut VARCHAR(20) DEFAULT 'valide',
    FOREIGN KEY (produit_id) REFERENCES produits(id),
    FOREIGN KEY (client_id) REFERENCES clients(id)
);

insert into ventes(produit_id,client_id,date,quantite,statut)
values (1,7,'2025-12-01',2,'valide'),
 (3,7,'2025-12-01',2,'valide'),
(5,7,'2025-12-01',6,'valide'),
(1,7,'2025-12-01',19,'valide'),
(9,2,'2025-08-01',3,'valide'),
(1,7,'2025-09-01',12,'valide'),
(4,7,'2025-12-07', 8,'valide'),
(8,9,'2025-12-01',2,'annuler'),
(1,7,'2025-12-01',2,'valide'),
(2,7,'2025-12-01',9,'valide'),
(4,9,'2025-12-01',7,'annuler'),
(3,7,'2025-12-01',2,'valide'),
(4,18,'2025-12-01',6,'valide'),
(9,7,'2025-12-05',7,'valide'),
(5,7,'2025-12-02',4,'valide'),
(26,5,'2021-08-05',56,'valide'),
(26,15,'2025-12-01',9,'valide'),
(13,18,'2026-10-03',6,'valide'),
(2,4,'2022-07-05',8,'valide'),
(17,8,'2007-05-03',20,'valide'),
(17,3,'2004-10-06',19,'valide'),
(1,7,'2025-12-01',35,'valide'),
(12,9,'2026-12-08',19,'valide'),
(9,5,'2025-09-08',21,'valide'),
(11,15,'2000-11-07',08,'valide'),
(10,8,'2021-05-10',29,'valide'),
(8,18,'2020-07-03',34,'valide'),
(20,10,'2022-06-01',24,'valide'),
(7,4,'2023-10-04',23,'valide');

DELIMITER &&
CREATE FUNCTION fn_ca_produit(p_produit_id INT)
RETURNS DECIMAL(10,2) 
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(10,2);
    SELECT SUM(v.quantite * p.prix)
    INTO total
    FROM ventes v JOIN produits p ON v.produit_id = p.id
    WHERE p.id = p_produit_id;
    RETURN total;
END &&
DELIMITER &&;


CREATE VIEW vue_ca_par_categorie as
(SELECT
    c.id,
    c.nom AS categorie,
    SUM(v.quantite * p.prix) AS chiffre_affaires
FROM ventes v
JOIN produits p ON v.produit_id = p.id
JOIN categories c ON p.categorie_id = c.id
GROUP BY c.id, c.nom);

CREATE VIEW vue_top_10_clients_fideles AS
(SELECT
    cl.id,
    cl.nom,
    COUNT(v.id) AS nombre_achats
FROM clients cl
JOIN ventes v ON cl.id = v.client_id
GROUP BY cl.id, cl.nom
ORDER BY nombre_achats DESC
LIMIT 10);


CREATE VIEW vue_produit_plus_vendu_trimestre AS
(SELECT *
FROM (
    SELECT
        EXTRACT(YEAR FROM v.date) AS annee,
        EXTRACT(QUARTER FROM v.date) AS trimestre,
        p.nom AS produit,
        SUM(v.quantite) AS total_vendu,
        RANK() OVER(
            PARTITION BY EXTRACT(YEAR FROM v.date),
                         EXTRACT(QUARTER FROM v.date)
            ORDER BY SUM(v.quantite) DESC
        ) AS rang
    FROM ventes v
    JOIN produits p ON v.produit_id = p.id
    GROUP BY annee, trimestre, p.nom
) t
WHERE rang = 1);

CREATE VIEW vue_ca_total_par_client AS
(SELECT
    cl.id,
    cl.nom,
    SUM(v.quantite * p.prix) AS chiffre_affaires
FROM clients cl
JOIN ventes v ON cl.id = v.client_id
JOIN produits p ON v.produit_id = p.id
GROUP BY cl.id, cl.nom);

CREATE VIEW vue_moyenne_ventes_par_jour AS
(SELECT
    date,
    AVG(quantite) AS moyenne_ventes
FROM ventes
GROUP BY date);


CREATE VIEW vue_produit_plus_vendu_2025 AS
(SELECT
    p.nom,
    SUM(v.quantite) AS total_vendu
FROM ventes v
JOIN produits p ON v.produit_id = p.id
WHERE EXTRACT(YEAR FROM v.date) = 2025
GROUP BY p.nom
ORDER BY total_vendu DESC
LIMIT 1);


CREATE VIEW vue_ca_par_trimestre AS
(SELECT
    EXTRACT(YEAR FROM v.date) AS annee,
    EXTRACT(QUARTER FROM v.date) AS trimestre,
    SUM(v.quantite * p.prix) AS chiffre_affaires
FROM ventes v
JOIN produits p ON v.produit_id = p.id
GROUP BY annee, trimestre);


CREATE VIEW vue_nombre_ventes_par_categorie AS
(SELECT
    c.nom AS categories,
    COUNT(v.id) AS nombre_ventes
FROM ventes v
JOIN produits p ON v.produit_id = p.id
JOIN categories c ON p.categorie_id = c.id
GROUP BY c.nom);


CREATE VIEW vue_client_plus_produits_differents AS
(SELECT
    cl.nom,
    COUNT(DISTINCT v.produit_id) AS nb_produits_differents
FROM clients cl
JOIN ventes v ON cl.id = v.client_id
GROUP BY cl.nom
ORDER BY nb_produits_differents DESC
LIMIT 1);


CREATE VIEW vue_ca_moyen_par_client AS
(SELECT
    AVG(total_ca) AS ca_moyen
FROM (
    SELECT
        cl.id,
        SUM(v.quantite * p.prix) AS total_ca
    FROM clients cl
    JOIN ventes v ON cl.id = v.client_id
    JOIN produits p ON v.produit_id = p.id
    GROUP BY cl.id
)t );



CREATE VIEW vue_produit_plus_forte_croissance AS
(SELECT
    produit,
    croissance
FROM (
    SELECT
        p.nom AS produit,
        (
            SUM(CASE WHEN EXTRACT(YEAR FROM v.date)=2025 THEN v.quantite ELSE 0 END)
            -
            SUM(CASE WHEN EXTRACT(YEAR FROM v.date)=2024 THEN v.quantite ELSE 0 END)
        ) AS croissance
    FROM ventes v
    JOIN produits p ON v.produit_id = p.id
    GROUP BY p.nom
) t
ORDER BY croissance DESC
LIMIT 1);



CREATE VIEW vue_nombre_ventes_annulees AS
(SELECT
    COUNT(*) AS ventes_annulees
FROM ventes
WHERE statut = 'annule');



CREATE VIEW vue_ca_par_mois AS
(SELECT
    EXTRACT(YEAR FROM v.date) AS annee,
    EXTRACT(MONTH FROM v.date) AS mois,
    SUM(v.quantite * p.prix) AS chiffre_affaires
FROM ventes v
JOIN produits p ON v.produit_id = p.id
GROUP BY annee, mois
ORDER BY annee, mois);



CREATE VIEW vue_produit_plus_vendu_par_categorie AS
(SELECT *
FROM (
    SELECT
        c.nom AS categorie,
        p.nom AS produit,
        SUM(v.quantite) AS total_vendu,
        RANK() OVER(
            PARTITION BY c.nom
            ORDER BY SUM(v.quantite) DESC
        ) AS rang
    FROM ventes v
    JOIN produits p ON v.produit_id = p.id
    JOIN categories c ON p.categorie_id = c.id
    GROUP BY c.nom, p.nom
) t
WHERE rang = 1);



CREATE VIEW vue_distribution_ventes_par_client AS
(SELECT
    cl.nom,
    COUNT(v.id) AS nombre_ventes,
    SUM(v.quantite) AS total_quantite
FROM clients cl
JOIN ventes v ON cl.id = v.client_id
GROUP BY cl.nom);
