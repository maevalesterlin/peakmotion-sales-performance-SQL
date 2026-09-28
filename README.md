# 📊 PeakMotion – Analyse des performances commerciales

Projet d'analyse de données réalisé en **SQL avec BigQuery**, à partir des données fictives de PeakMotion, une entreprise européenne spécialisée dans la vente d'articles de sport.

L'objectif est d'analyser les performances commerciales de l'entreprise et d'identifier les principaux leviers de croissance et de rentabilité.

> 📅 Analyse réalisée le 18 septembre 2026  
> 📊 Données disponibles : janvier 2025 à septembre 2026

---

## 🎯 Objectifs

Cette analyse vise à répondre aux principales questions suivantes :

- Comment évoluent les performances commerciales de PeakMotion ?
- Quelles régions contribuent le plus au chiffre d'affaires ?
- Comment évoluent les performances des commerciaux ?
- Quels produits et catégories génèrent le plus de chiffre d'affaires ?
- Quel est l'impact des remises sur la marge ?

---

## 🗂️ Données

Le projet utilise deux tables :

### `sales`

Données transactionnelles contenant notamment les ventes, les clients, les commerciaux, les régions, les quantités, le chiffre d'affaires, les coûts et les remises.

### `products`

Catalogue produits contenant notamment le nom du produit, sa catégorie, son prix catalogue et son coût unitaire.

Les données couvrent **5 régions européennes** et **7 catégories de produits**.

---

## 🔎 Analyses

### 1. Performance globale
Analyse de la performance commerciale globale de PeakMotion.

### 2. Évolution des ventes
Analyse de l'évolution des ventes entre 2025 et 2026.

### 3. Performance par région
Comparaison des performances commerciales entre les 5 régions.

### 4. Performance des commerciaux
Analyse des performances des 15 commerciaux.

### 5. Performance des produits et catégories
Analyse des performances et de l'évolution des produits.
Comparaison des performances entre les différentes catégories de produits.

### 6. Impact des remises
Analyse de l'impact des remises sur le chiffre d'affaires et la marge.

---

## 💡 Principaux insights

L'analyse met en évidence une croissance de **21,6 % du chiffre d'affaires** sur la période janvier–septembre 2026, portée par une hausse de **20,6 % des commandes** alors que le nombre de clients ne progresse que de **6 %**. Le taux de marge reste quasiment stable, à **46,62 %**.

La **France** reste le principal marché avec **43,4 % du CA** (+23,9 %), mais la croissance est généralisée aux 5 régions, à l'exception d'une progression plus modérée en **Italie** (+12,5 %). Les **15 commerciaux** affichent tous une hausse de leur chiffre d'affaires.

La catégorie **Running** constitue le principal moteur de l'activité avec **39,2 % du CA**, une croissance de 21,3 % et un taux de marge supérieur à la moyenne (**48,2 %**).
À l'inverse, **Outdoor** progresse fortement (+23,9 %), mais présente le taux de marge le plus faible (**41,5 %**).

Enfin, les remises réduisent systématiquement le taux de marge, de **1,9 à 2,8 points** selon les catégories et les commerciaux.

Les résultats détaillés et les recommandations business sont disponibles dans le fichier [`business_insights.md`](business_insights.md).

---

## 🛠️ Outils & technologies

- SQL
- Google BigQuery
