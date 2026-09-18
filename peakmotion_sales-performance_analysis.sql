-- =========================================================
-- PEAKMOTION - SALES PERFORMANCE ANALYSIS
-- Analyse YTD réalisée le 18 septembre 2026 
-- =========================================================

-- Période couverte par les données : 01/01/2025 - 30/09/2026
-- Période analysée : 01/01/2026 au 18/09/2026


-- 0. EXPLORATION DES DONNÉES

SELECT *
FROM `portfolio-508912.PeakMotion.sales`
LIMIT 10;


SELECT
  MIN(sale_date) AS date_debut,
  MAX(sale_date) AS date_fin
FROM `portfolio-508912.PeakMotion.sales`;




-- 1. PERFORMANCE GLOBALE DES VENTES
-- Quelle est la performance commerciale depuis le début de l'année ?
-- YTD 2026


SELECT 
  COUNT(DISTINCT sale_id) AS nb_commande,
  SUM(quantity) AS nb_quantites_vendues,
  ROUND(SUM(amount),2) AS CA,
  ROUND(SUM(cost),2) AS cout_ventes,
  ROUND(SUM(amount) - SUM(cost),2) AS marge_brute,
  ROUND(SAFE_DIVIDE(SUM(amount) - SUM(cost), SUM(amount)) * 100,2) AS taux_de_marge,
  ROUND(SAFE_DIVIDE(SUM(amount), COUNT(DISTINCT sale_id)),2) AS panier_moyen,
  COUNT(DISTINCT customer_id) AS nb_client,
  ROUND(SAFE_DIVIDE(SUM(amount), COUNT(DISTINCT customer_id)),2) AS ca_par_client

FROM `portfolio-508912.PeakMotion.sales`

WHERE sale_date >= DATE_TRUNC(CURRENT_DATE(), YEAR)
  AND sale_date < CURRENT_DATE() + 1;



-- 2. ÉVOLUTION ET CROISSANCE DES VENTES
-- Comment évolue la performance commerciale par rapport à l'année passée ?
-- YTD 2026 vs YTD 2025


WITH annee_en_cours AS (
  SELECT
    COUNT(DISTINCT sale_id) AS nb_commande,
    ROUND(SUM(amount),2) AS CA,
    ROUND(SUM(cost),2) AS cout_ventes,
    ROUND(SUM(amount) - SUM(cost),2) AS marge_brute,
    ROUND(SAFE_DIVIDE(SUM(amount) - SUM(cost), SUM(amount)) * 100,2) AS taux_de_marge,
    COUNT(DISTINCT customer_id) AS nb_client
  FROM `portfolio-508912.PeakMotion.sales`
  WHERE sale_date >= DATE_TRUNC(CURRENT_DATE(), YEAR)
    AND sale_date < CURRENT_DATE() + 1
),
annee_passee AS (
  SELECT
    COUNT(DISTINCT sale_id) AS nb_commande,
    ROUND(SUM(amount),2) AS CA,
    ROUND(SUM(cost),2) AS cout_ventes,
    ROUND(SUM(amount) - SUM(cost),2) AS marge_brute,
    ROUND(SAFE_DIVIDE(SUM(amount) - SUM(cost), SUM(amount)) * 100,2) AS taux_de_marge,
    COUNT(DISTINCT customer_id) AS nb_client
  FROM `portfolio-508912.PeakMotion.sales`
  WHERE sale_date >= DATE_SUB(DATE_TRUNC(CURRENT_DATE(), YEAR), INTERVAL 1 YEAR)
    AND sale_date < DATE_SUB(CURRENT_DATE(), INTERVAL 1 YEAR) + 1
)

SELECT 
  ROUND(SAFE_DIVIDE(c.nb_commande - p.nb_commande, p.nb_commande) * 100,2) AS evol_yoy_nbcommande_perc,
  ROUND(SAFE_DIVIDE(c.CA - p.CA, p.CA) * 100,2) AS evol_yoy_ca_perc,
  ROUND(c.taux_de_marge - p.taux_de_marge,2) AS diff_marge_yoy_pts,
  ROUND(SAFE_DIVIDE(c.nb_client - p.nb_client, p.nb_client) * 100,2) AS evol_yoy_nbclient_perc
FROM annee_en_cours AS c
CROSS JOIN annee_passee AS p;



-- 3. PERFORMANCE PAR RÉGION
-- Quelles régions contribuent le plus à la performance commerciale ?
-- YTD 2026 vs YTD 2025


WITH performances_region AS (

  SELECT
    region,
    COUNT(DISTINCT sale_id) AS nb_commande,
    ROUND(SUM(amount),2) AS CA,
    ROUND(SUM(cost),2) AS cout_ventes,
    ROUND(SUM(amount) - SUM(cost),2) AS marge_brute,
    ROUND(SAFE_DIVIDE(SUM(amount) - SUM(cost), SUM(amount)) * 100,2) AS taux_de_marge,
    COUNT(DISTINCT customer_id) AS nb_client

  FROM `portfolio-508912.PeakMotion.sales`
  WHERE sale_date >= DATE_TRUNC(CURRENT_DATE(), YEAR)
    AND sale_date < CURRENT_DATE() + 1
  GROUP BY region

),

annee_passee AS (

  SELECT
    region,
    COUNT(DISTINCT sale_id) AS nb_commande,
    ROUND(SUM(amount),2) AS CA,
    ROUND(SUM(cost),2) AS cout_ventes,
    ROUND(SUM(amount) - SUM(cost),2) AS marge_brute,
    ROUND(SAFE_DIVIDE(SUM(amount) - SUM(cost), SUM(amount)) * 100,2) AS taux_de_marge,
    COUNT(DISTINCT customer_id) AS nb_client

  FROM `portfolio-508912.PeakMotion.sales`
  WHERE sale_date >= DATE_SUB(DATE_TRUNC(CURRENT_DATE(), YEAR), INTERVAL 1 YEAR)
    AND sale_date < DATE_SUB(CURRENT_DATE(), INTERVAL 1 YEAR) + 1
  GROUP BY region

)

SELECT 
  r.region,
  r.nb_commande,
  ROUND(SAFE_DIVIDE(r.nb_commande - p.nb_commande, p.nb_commande) * 100,2) AS evol_nb_commande_yoy_perc,
  r.CA,
  ROUND(SAFE_DIVIDE(r.CA - p.CA, p.CA) * 100,2) AS evol_CA_yoy_perc,
  r.taux_de_marge,
  ROUND(r.taux_de_marge - p.taux_de_marge,2) AS evol_tauxmarge_yoy_pts,
  r.nb_client,
  ROUND(SAFE_DIVIDE(r.nb_client - p.nb_client, p.nb_client) * 100,2) AS evol_nb_client_yoy_perc,
  ROUND(SAFE_DIVIDE(r.CA, SUM(r.CA) OVER ()) * 100,2) AS part_CA_perc

FROM performances_region AS r
LEFT JOIN annee_passee AS p ON r.region = p.region

ORDER BY r.CA DESC;



-- 4. PERFORMANCE DES COMMERCIAUX
-- Comment se répartit la performance entre les sales reps ?
-- YTD 2026 vs YTD 2025


WITH performances_commerciaux AS (

  SELECT
    sales_rep,
    COUNT(DISTINCT sale_id) AS nb_commande,
    ROUND(SUM(amount),2) AS CA,
    ROUND(SUM(cost),2) AS cout_ventes,
    ROUND(SUM(amount) - SUM(cost),2) AS marge_brute,
    ROUND(SAFE_DIVIDE(SUM(amount) - SUM(cost), SUM(amount)) * 100,2) AS taux_de_marge,
    COUNT(DISTINCT customer_id) AS nb_client

  FROM `portfolio-508912.PeakMotion.sales`
  WHERE sale_date >= DATE_TRUNC(CURRENT_DATE(), YEAR)
    AND sale_date < CURRENT_DATE() + 1
  GROUP BY sales_rep

),

annee_passee AS (

  SELECT
    sales_rep,
    COUNT(DISTINCT sale_id) AS nb_commande,
    ROUND(SUM(amount),2) AS CA,
    ROUND(SUM(cost),2) AS cout_ventes,
    ROUND(SUM(amount) - SUM(cost),2) AS marge_brute,
    ROUND(SAFE_DIVIDE(SUM(amount) - SUM(cost), SUM(amount)) * 100,2) AS taux_de_marge,
    COUNT(DISTINCT customer_id) AS nb_client

  FROM `portfolio-508912.PeakMotion.sales`
  WHERE sale_date >= DATE_SUB(DATE_TRUNC(CURRENT_DATE(), YEAR), INTERVAL 1 YEAR)
    AND sale_date < DATE_SUB(CURRENT_DATE(), INTERVAL 1 YEAR) + 1
  GROUP BY sales_rep

)

SELECT 
  RANK() OVER (ORDER BY c.CA DESC) AS Rang_CA,
  c.sales_rep,
  c.nb_commande,
  ROUND(SAFE_DIVIDE(c.nb_commande - p.nb_commande, p.nb_commande) * 100,2) AS evol_nb_commande_yoy_perc,
  c.CA,
  ROUND(SAFE_DIVIDE(c.CA - p.CA, p.CA) * 100,2) AS evol_CA_yoy_perc,
  c.taux_de_marge,
  ROUND(c.taux_de_marge - p.taux_de_marge,2) AS evol_tauxmarge_yoy_pts,
  c.nb_client,
  ROUND(SAFE_DIVIDE(c.nb_client - p.nb_client, p.nb_client) * 100,2) AS evol_nb_client_yoy_perc,
  ROUND(SAFE_DIVIDE(c.CA, SUM(c.CA) OVER ()) * 100,2) AS part_CA_global_perc,
  ROUND(SAFE_DIVIDE(c.CA, c.nb_commande),2) AS panier_moyen

FROM performances_commerciaux AS c
LEFT JOIN annee_passee AS p ON c.sales_rep = p.sales_rep

ORDER BY c.CA DESC;



-- 5. PERFORMANCE PRODUITS / CATÉGORIES
-- Quels produits et catégories génèrent le plus de CA et de rentabilité ?
-- YTD 2026 vs YTD 2025


-- 5A. Performance des produits

WITH performances_produits AS (

  SELECT
    product_id,
    SUM(quantity) AS quantite,
    ROUND(SUM(amount),2) AS CA,
    ROUND(SUM(cost),2) AS cout_ventes,
    ROUND(SUM(amount) - SUM(cost),2) AS marge_brute,
    ROUND(SAFE_DIVIDE(SUM(amount) - SUM(cost), SUM(amount)) * 100,2) AS taux_de_marge

  FROM `portfolio-508912.PeakMotion.sales`
  WHERE sale_date >= DATE_TRUNC(CURRENT_DATE(), YEAR)
    AND sale_date < CURRENT_DATE() + 1
  GROUP BY product_id

),

annee_passee AS (

  SELECT
    product_id,
    SUM(quantity) AS quantite,
    ROUND(SUM(amount),2) AS CA,
    ROUND(SUM(cost),2) AS cout_ventes,
    ROUND(SUM(amount) - SUM(cost),2) AS marge_brute,
    ROUND(SAFE_DIVIDE(SUM(amount) - SUM(cost), SUM(amount)) * 100,2) AS taux_de_marge

  FROM `portfolio-508912.PeakMotion.sales`
  WHERE sale_date >= DATE_SUB(DATE_TRUNC(CURRENT_DATE(), YEAR), INTERVAL 1 YEAR)
    AND sale_date < DATE_SUB(CURRENT_DATE(), INTERVAL 1 YEAR) + 1
  GROUP BY product_id

)

SELECT 
  RANK() OVER (ORDER BY c.CA DESC) AS Rang_CA,
  b.product_name,
  c.quantite,
  ROUND(SAFE_DIVIDE(c.quantite - p.quantite, p.quantite) * 100,2) AS evol_quantite_yoy_perc,
  c.CA,
  ROUND(SAFE_DIVIDE(c.CA - p.CA, p.CA) * 100,2) AS evol_CA_yoy_perc,
  c.taux_de_marge,
  ROUND(c.taux_de_marge - p.taux_de_marge,2) AS evol_tauxmarge_yoy_pts,
  ROUND(SAFE_DIVIDE(c.CA, SUM(c.CA) OVER ()) * 100,2) AS part_CA_perc

FROM performances_produits AS c
LEFT JOIN annee_passee AS p ON c.product_id = p.product_id
LEFT JOIN `portfolio-508912.PeakMotion.products` AS b ON c.product_id = b.product_id

ORDER BY c.CA DESC;


-- 5B. Performance des catégories

WITH performances_categories AS (

  SELECT
    p.category,
    SUM(s.quantity) AS quantite,
    ROUND(SUM(s.amount),2) AS CA,
    ROUND(SUM(s.cost),2) AS cout_ventes,
    ROUND(SUM(s.amount) - SUM(s.cost),2) AS marge_brute,
    ROUND(SAFE_DIVIDE(SUM(s.amount) - SUM(s.cost), SUM(s.amount)) * 100,2) AS taux_de_marge

  FROM `portfolio-508912.PeakMotion.sales` AS s
  LEFT JOIN `portfolio-508912.PeakMotion.products` AS p 
    ON s.product_id = p.product_id

  WHERE sale_date >= DATE_TRUNC(CURRENT_DATE(), YEAR)
    AND sale_date < CURRENT_DATE() + 1

  GROUP BY p.category

),

annee_passee AS (

  SELECT
    p.category,
    SUM(s.quantity) AS quantite,
    ROUND(SUM(s.amount),2) AS CA,
    ROUND(SUM(s.cost),2) AS cout_ventes,
    ROUND(SUM(s.amount) - SUM(s.cost),2) AS marge_brute,
    ROUND(SAFE_DIVIDE(SUM(s.amount) - SUM(s.cost), SUM(s.amount)) * 100,2) AS taux_de_marge

  FROM `portfolio-508912.PeakMotion.sales` AS s
  LEFT JOIN `portfolio-508912.PeakMotion.products` AS p 
    ON s.product_id = p.product_id

  WHERE sale_date >= DATE_SUB(DATE_TRUNC(CURRENT_DATE(), YEAR), INTERVAL 1 YEAR)
    AND sale_date < DATE_SUB(CURRENT_DATE(), INTERVAL 1 YEAR) + 1

  GROUP BY p.category

)

SELECT
  c.category,
  c.quantite,
  ROUND(SAFE_DIVIDE(c.quantite - p.quantite, p.quantite) * 100,2) AS evol_quantite_yoy_perc,
  c.CA,
  ROUND(SAFE_DIVIDE(c.CA - p.CA, p.CA) * 100,2) AS evol_CA_yoy_perc,
  c.taux_de_marge,
  ROUND(c.taux_de_marge - p.taux_de_marge,2) AS evol_tauxmarge_yoy_pts,
  ROUND(SAFE_DIVIDE(c.CA, SUM(c.CA) OVER ()) * 100,2) AS part_CA_perc

FROM performances_categories AS c
LEFT JOIN annee_passee AS p 
  ON c.category = p.category

ORDER BY c.CA DESC;



-- 6. IMPACT DES REMISES
-- Quel est l'impact des réductions sur la performance ?
-- YTD 2026 


-- 6A. Impact des remises par commercial

WITH base_remises AS (
  SELECT
    s.sales_rep,
    s.amount,
    s.cost,
    SAFE_DIVIDE(s.unit_price * s.quantity, 1 - s.discount_pct) AS CA_avant_remise
  FROM `portfolio-508912.PeakMotion.sales` AS s
  WHERE s.sale_date >= DATE_TRUNC(CURRENT_DATE(), YEAR)
    AND s.sale_date < CURRENT_DATE() + 1
)

SELECT
  sales_rep,
  ROUND(SUM(CA_avant_remise),2) AS CA_avant_remise,
  ROUND(SUM(CA_avant_remise - amount),2) AS montant_remise,
  ROUND(SUM(amount),2) AS CA_apres_remise,
  ROUND(SAFE_DIVIDE(SUM(CA_avant_remise - amount), SUM(CA_avant_remise)) * 100,2) AS taux_remise_global,
  ROUND(SUM(CA_avant_remise) - SUM(cost),2) AS marge_avant_remise,
  ROUND(SUM(amount) - SUM(cost),2) AS marge_apres_remise,
  ROUND(SAFE_DIVIDE(SUM(CA_avant_remise) - SUM(cost), SUM(CA_avant_remise)) * 100,2) AS taux_marge_avant_remise,
  ROUND(SAFE_DIVIDE(SUM(amount) - SUM(cost), SUM(amount)) * 100,2) AS taux_marge_apres_remise,
  ROUND(
    (
      SAFE_DIVIDE(SUM(amount) - SUM(cost), SUM(amount))
      - SAFE_DIVIDE(SUM(CA_avant_remise) - SUM(cost), SUM(CA_avant_remise))
    ) * 100,
    2
  ) AS impact_taux_marge_pts
FROM base_remises
GROUP BY sales_rep
ORDER BY taux_remise_global;


-- 6B. Impact des remises par catégorie

WITH base_remises AS (
  SELECT
    p.category,
    s.amount,
    s.cost,
    SAFE_DIVIDE(s.unit_price * s.quantity, 1 - s.discount_pct) AS CA_avant_remise
  FROM `portfolio-508912.PeakMotion.sales` AS s
  LEFT JOIN `portfolio-508912.PeakMotion.products` AS p
    ON s.product_id = p.product_id
  WHERE s.sale_date >= DATE_TRUNC(CURRENT_DATE(), YEAR)
    AND s.sale_date < CURRENT_DATE() + 1
)

SELECT
  category,
  ROUND(SUM(CA_avant_remise),2) AS CA_avant_remise,
  ROUND(SUM(CA_avant_remise - amount),2) AS montant_remise,
  ROUND(SUM(amount),2) AS CA_apres_remise,
  ROUND(SAFE_DIVIDE(SUM(CA_avant_remise - amount), SUM(CA_avant_remise)) * 100,2) AS taux_remise_global,
  ROUND(SUM(CA_avant_remise) - SUM(cost),2) AS marge_avant_remise,
  ROUND(SUM(amount) - SUM(cost),2) AS marge_apres_remise,
  ROUND(SAFE_DIVIDE(SUM(CA_avant_remise) - SUM(cost), SUM(CA_avant_remise)) * 100,2) AS taux_marge_avant_remise,
  ROUND(SAFE_DIVIDE(SUM(amount) - SUM(cost), SUM(amount)) * 100,2) AS taux_marge_apres_remise,
  ROUND(
    (
      SAFE_DIVIDE(SUM(amount) - SUM(cost), SUM(amount))
      - SAFE_DIVIDE(SUM(CA_avant_remise) - SUM(cost), SUM(CA_avant_remise))
    ) * 100,
    2
  ) AS impact_taux_marge_pts
FROM base_remises
GROUP BY category
ORDER BY montant_remise DESC;

