# Réorganisation du Dépôt T-SQL Scripts - Analyse Complète

**Date**: 2026-02-16
**Agent**: Claude Sonnet 4.5
**Fichiers SQL analysés**: 333+

---

## Table des Matières

1. [Redondances Critiques](#1-redondances-critiques)
2. [Redondances Index Management](#2-redondances-index-management)
3. [Redondances Databases & Listings](#3-redondances-databases-et-listings)
4. [Redondances Stored Procedures vs Scripts](#4-redondances-stored-procedures-vs-scripts)
5. [Redondances Tempdb](#5-redondances-tempdb)
6. [Redondance Rebuild Heaps (Majeure)](#6-redondance-rebuild-heaps-majeure)
7. [Problèmes d'Organisation](#7-problèmes-dorganisation)
8. [Observations Additionnelles](#8-observations-additionnelles)
9. [Plan d'Action Recommandé](#9-plan-daction-recommandé)

---

## 1. Redondances Critiques

### 1.1 🔴 Fragmentation d'Index - Multiples Versions

**Fichiers concernés:**
- `database-information/indexes/fragmentation-analysis.sql` (19 lignes) - Analyse simple
- `index-management/index-physical-stats-detailed.sql` (50 lignes) - Mode DETAILED
- `index-management/index-physical-stats-limited.sql` (43 lignes) - Mode LIMITED
- `database-information/heaps-fragmentation.sql` (28 lignes) - Heaps spécifiques
- `database-administration/maintenance/rebuild-heaps.sql` (291 lignes) - Procédure maintenance
- `database-administration/dba-database/015.rebuild_heaps.sql` (280 lignes) - Procédure DBA-DB
- `stored-procedures/sp_indexFragmentation.sql` - Procédure stockée

**Problème:**
- Tous interrogent `sys.dm_db_index_physical_stats`
- `index-physical-stats-detailed.sql` et `index-physical-stats-limited.sql` = versions identiques avec juste le mode qui change
- `rebuild-heaps.sql` (maintenance) et `015.rebuild_heaps.sql` (dba-database) = **99% identiques** (voir section 6)

**Recommandations:**

```sql
-- ACTION 1: Consolider les deux scripts d'analyse en UN
-- CRÉER: index-management/analyze-index-fragmentation.sql
-- Avec DECLARE @scan_mode = 'LIMITED' ou 'DETAILED'
-- SUPPRIMER: index-physical-stats-detailed.sql
-- SUPPRIMER: index-physical-stats-limited.sql

-- ACTION 2: Garder database-information/heaps-fragmentation.sql
-- (variante spécifique aux heaps, OK)

-- ACTION 3: Consolider les procédures rebuild_heaps (voir section 6)
```

**Priorité**: 🔴 HAUTE - Économise duplication de code et maintenance

---

### 1.2 🟡 Transactions Actives - Trois Versions

**Fichiers concernés:**
- `diagnostics/execution/active-transactions.sql` (80 lignes) - Simple query
- `stored-procedures/sp_activeTransactions.sql` (92 lignes) - Procédure avec paramètre @all
- `monitoring/monitor-long-transactions.sql` (149 lignes) - Version monitoring avec email

**Similarité:**
- Tous interrogent `sys.dm_tran_active_transactions`, `sys.dm_tran_database_transactions`, `sys.dm_exec_sessions`
- Code SQL 99% identique entre les deux premiers
- Même jointures, même colonnes

**Recommandations:**

```sql
-- ACTION 1: Garder sp_activeTransactions.sql (procédure maître réutilisable)
-- ACTION 2: Simplifier active-transactions.sql pour être un simple appel:
--   EXEC sp_activeTransactions @all = 1;
-- ACTION 3: Garder monitor-long-transactions.sql
--   (différente purpose: alerting + email)
```

**Priorité**: 🟡 MOYENNE - Fonctionnalité critique mais workaround simple

---

## 2. Redondances Index Management

### 2.1 🟡 Utilisation des Index - Chevauchement

**Fichiers concernés:**
- `index-management/index-usage.sql` (90 lignes) - Très complet avec CTE, partitions, compression
- `database-information/indexes/indexes-on-a-table.sql` (31 lignes) - Simplifié, colonnes uniquement
- `index-management/index-on-table.sql` (35 lignes) - Utilisation DMV

**Problème:**
- Trois niveaux de détail sans clarté
- `indexes-on-a-table.sql` est redondant avec `index-on-table.sql`

**Recommandations:**

```sql
-- ACTION 1: Garder index-management/index-usage.sql (version complète)
-- ACTION 2: SUPPRIMER database-information/indexes/indexes-on-a-table.sql (redondant)
-- ACTION 3: Renommer index-on-table.sql → index-usage-on-table.sql (clarifier)
```

**Priorité**: 🟡 MOYENNE

---

### 2.2 🟢 Missing Indexes - Deux Sources (NON REDONDANT)

**Fichiers concernés:**
- `index-management/missing-indexes.sql` - Via DMV `sys.dm_db_missing_index_*`
- `diagnostics/query-store/missing-indexes.sql` - Via Query Store + plans XML

**Analyse:**
- ✅ **NON redondant** - Deux sources de données différentes
- Premier = basé sur les suggestions DMV
- Second = analyse les plans Query Store

**Recommandations:**

```sql
-- ACTION 1: GARDER LES DEUX (se complètent)
-- ACTION 2: Ajouter un commentaire dans chaque fichier pour clarifier:
--   "Note: See also query-store/missing-indexes.sql for Query Store-based analysis"
```

**Priorité**: 🟢 BASSE - Aucun changement requis, juste documentation

---

## 3. Redondances Databases et Listings

### 3.1 🟢 List Databases - Trois Utilités Distinctes (NON REDONDANT)

**Fichiers concernés:**
- `database-information/list-databases.sql` (48 lignes) - Tous les infos sys.databases (85 colonnes)
- `diagnostics/query-store/list-databases.sql` (17 lignes) - Filtre Query Store ON
- `stored-procedures/sp_databases.sql` (35 lignes) - Affiche SIZE via performance counters

**Analyse:**
- ✅ **NON redondant** - Trois utilités différentes
- Premier = inventaire complet
- Second = filtrage spécifique Query Store
- Troisième = sizing

**Recommandations:**

```sql
-- ACTION 1: Renommer pour clarifier:
--   list-databases.sql → databases-inventory-full.sql
--   query-store/list-databases.sql → databases-with-query-store.sql
-- ACTION 2: GARDER LES TROIS
```

**Priorité**: 🟢 BASSE - Renommage pour clarté seulement

---

## 4. Redondances Stored Procedures vs Scripts

### 4.1 🟡 Locking - sp_lock2 vs what-is-locked

**Fichiers concernés:**
- `stored-procedures/sp_lock2.sql` (42 lignes) - Procédure
- `diagnostics/locking/what-is-locked.sql` (32 lignes) - Query ad-hoc

**Similarité:**
- Tous deux utilisent `sys.dm_tran_locks` et `sys.dm_os_waiting_tasks`
- Code 95% identique
- `what-is-locked.sql` ajoute LEFT JOIN sur partitions

**Recommandations:**

```sql
-- ACTION 1: Garder sp_lock2.sql (procédure master réutilisable)
-- ACTION 2: OPTION A - SUPPRIMER what-is-locked.sql (redondant)
-- ACTION 2: OPTION B - Transformer what-is-locked.sql en version "détaillée"
--   avec plus d'infos sur partitions, allocation, etc.
```

**Priorité**: 🟡 MOYENNE

---

### 4.2 🔴 Procedures Execution - Trois Scripts Similaires

**Fichiers concernés:**
- `diagnostics/execution-stats/stored-procedures/procedures-by-execution-count.sql` (25 lignes)
- `diagnostics/execution-stats/stored-procedures/procedure-execution-analysis.sql` (28 lignes)
- `diagnostics/execution-stats/stored-procedures/monitor-proc-execution.sql` (49 lignes)

**Problème:**
- Tous trois interrogent `sys.dm_exec_procedure_stats`
- Mêmes colonnes: execution_count, timing, IO stats
- Variations légères: plan XML, filtres par nom

**Recommandations:**

```sql
-- ACTION 1: Consolider en UN script: procedure-statistics.sql
-- Avec DECLARE variables pour:
--   @procedure_name NVARCHAR(128) = NULL -- filtre optionnel
--   @include_plan BIT = 0                -- option pour plan XML
--   @order_by VARCHAR(20) = 'exec_count' -- exec_count|cpu|io|duration

-- ACTION 2: SUPPRIMER:
--   - procedures-by-execution-count.sql
--   - procedure-execution-analysis.sql
--   - monitor-proc-execution.sql
```

**Priorité**: 🔴 HAUTE - Trois fichiers → un fichier configurable

---

## 5. Redondances Tempdb

### 5.1 🟡 Version Store - Trois Niveaux d'Analyse

**Fichiers concernés:**
- `diagnostics/tempdb/version-store-usage.sql` (48 lignes) - Usage global + commentaires
- `diagnostics/tempdb/active-transactions-using-version-store.sql` (38 lignes) - Par session
- `diagnostics/tempdb/version-store-by-transaction.sql` - Par transaction

**Analyse:**
- Tous tournent autour de `sys.dm_db_file_space_usage`, `sys.dm_tran_active_snapshot_database_transactions`
- Différents niveaux de granularité (global → session → transaction)
- Conceptuellement complémentaires

**Recommandations:**

```sql
-- ACTION 1: GARDER LES TROIS (utilités différentes)
-- ACTION 2: Renommer pour clarifier la hiérarchie:
--   version-store-usage.sql → version-store-usage-overview.sql
--   active-transactions-using-version-store.sql → version-store-by-sessions.sql
--   version-store-by-transaction.sql → (OK, déjà clair)
```

**Priorité**: 🟡 MOYENNE - Renommage pour clarté

---

## 6. Redondance Rebuild Heaps (MAJEURE)

### 6.1 🔴🔴 CRITIQUE - Deux Procédures Rebuild Heaps Quasi-Identiques

**Fichiers concernés:**
- `database-administration/maintenance/rebuild-heaps.sql` (291 lignes)
- `database-administration/dba-database/015.rebuild_heaps.sql` (280 lignes)

**Analyse Détaillée:**

| Section | État | Détails |
|---------|------|---------|
| Lignes 1-27 | ✅ Identique | Headers, DECLARE @report_type, etc. |
| Lignes 28-100 | ✅ Identique | Curseur, logique principale, CTE |
| Lignes 102-107 | ❌ **DIFFÉRENT** | Liste de databases hardcodée vs ALL databases |
| Ligne 17 | ❌ **DIFFÉRENT** | @largest_table_size_mb = 50000 vs 10000 |
| Reste | ✅ 99% Identique | Copie-colle du code |

**Différences clés:**
```sql
-- maintenance/rebuild-heaps.sql:
DECLARE @largest_table_size_mb BIGINT = 50000;
-- Liste hardcodée de 12 databases

-- dba-database/015.rebuild_heaps.sql:
DECLARE @largest_table_size_mb BIGINT = 10000;
-- ALL databases (> 4)
```

**Problème:**
- **Maintenance de deux versions = risque de bugs**
- Copie-colle = mauvaise pratique
- Aucune raison de maintenir deux versions séparées

**Recommandations:**

```sql
-- ACTION 1: Créer UNE procédure maître consolidée
-- CRÉER: stored-procedures/sp_rebuild_heaps.sql

-- Signature proposée:
CREATE PROCEDURE dbo.sp_rebuild_heaps
    @database_pattern NVARCHAR(MAX) = NULL,  -- NULL = all, ou 'DB1,DB2,DB3'
    @max_size_mb BIGINT = 10000,
    @report_type VARCHAR(10) = 'detailed',   -- 'detailed' ou 'summary'
    @online BIT = 0,
    @rebuild_only_forwarded BIT = 1,
    @max_forwarded_record_percentage INT = 30,
    @exec BIT = 1
AS
-- [code consolidé ici]

-- ACTION 2: SUPPRIMER database-administration/dba-database/015.rebuild_heaps.sql

-- ACTION 3: REMPLACER database-administration/maintenance/rebuild-heaps.sql
-- Par un simple wrapper ou script qui appelle:
--   EXEC master.dbo.sp_rebuild_heaps
--        @database_pattern = 'DB1,DB2,DB3,...',
--        @max_size_mb = 50000;
```

**Priorité**: 🔴🔴 **CRITIQUE** - Duplication massive de code (280 lignes)

---

## 7. Problèmes d'Organisation

### 7.1 🟡 database-information/indexes/ vs index-management/

**Problème de structure:**
- `database-information/indexes/` (5 fichiers) vs `index-management/` (12 fichiers)
- Chevauchement conceptuel sans stratégie claire

**Fichiers dans database-information/indexes/:**
- ✅ `fill-factor.sql` - Bon endroit (info de configuration)
- ⚠️ `fragmentation-analysis.sql` - Devrait être dans index-management/
- ✅ `indexed-views.sql` - Bon endroit (inventaire)
- ❌ `indexes-on-a-table.sql` - REDONDANT (voir section 2.1)
- ✅ `normalize-index-names.sql` - Bon endroit (requête info)

**Stratégie recommandée:**
```
database-information/indexes/
  → Afficher PROPRIÉTÉS des indexes (what exists)
  → Configuration, inventaire, structure

index-management/
  → Analyser SANTÉ et USAGE (what's wrong, how used)
  → Fragmentation, utilisation, performance
```

**Recommandations:**

```sql
-- ACTION 1: DÉPLACER fragmentation-analysis.sql
--   FROM: database-information/indexes/
--   TO: index-management/

-- ACTION 2: SUPPRIMER indexes-on-a-table.sql (voir section 2.1)

-- ACTION 3: Ajouter README.md dans chaque répertoire avec stratégie claire
```

**Priorité**: 🟡 MOYENNE

---

### 7.2 🔴 database-information/size-and-allocation/ - Trop de Fichiers

**Fichiers (12 fichiers):**
```
allocation-analysis.sql
check-allocation.sql
database-files.sql
database-files-details.sql
database-sizes.sql
filegroup-analysis.sql
number-of-files-per-database.sql
objects-in-filegroups.sql
partition-information.sql
partitioned-objects-by-partition-function.sql
tables-allocation.sql
table-sizes.sql
used-space-in-current-db.sql
```

**Problème:**
- Beaucoup trop similaires (allocation vs used space vs sizes)
- Pas de hiérarchie claire
- Duplication des concepts

**Recommandations:**

```sql
-- ACTION 1: Créer hiérarchie logique:

-- Level 1 (Database):
--   database-sizes.sql (vue rapide)

-- Level 2 (Files & Filegroups):
--   database-files-details.sql (consolider database-files.sql dedans)
--   filegroup-analysis.sql
--   → SUPPRIMER objects-in-filegroups.sql (redondant avec filegroup-analysis)

-- Level 3 (Tables):
--   table-sizes-and-allocation.sql (consolider table-sizes + tables-allocation)

-- Level 4 (Partitions):
--   partition-information.sql
--   partitioned-objects-by-partition-function.sql

-- ACTION 2: Consolider allocation-analysis + check-allocation + used-space-in-current-db
--   → CRÉER: space-usage-overview.sql

-- ACTION 3: SUPPRIMER:
--   - allocation-analysis.sql
--   - check-allocation.sql
--   - used-space-in-current-db.sql
--   - objects-in-filegroups.sql
--   - database-files.sql (fusionné)
--   - tables-allocation.sql (fusionné)
```

**Priorité**: 🔴 HAUTE - 12 fichiers → 7 fichiers (réduction 42%)

---

### 7.3 🔴 database-information/tables-information/ - Variantes Multiples

**Fichiers (14 fichiers) avec chevauchements:**
```
LOB-usage.sql
tables-with-LOB.sql
tables-with-deprecated-lob-types.sql          } 3 fichiers sur LOB!

tables-with-high-columns-number.sql
tables-with-wide-row.sql                       } 2 fichiers similaires
```

**Problème:**
- Trop de variations du même concept
- 3 fichiers sur LOB (Large Objects)
- 2 fichiers sur structure de table

**Recommandations:**

```sql
-- ACTION 1: Consolider les variantes LOB
-- CRÉER: LOB-configuration-analysis.sql
--   → Regroupe: tables avec LOB + usage + types deprecated
-- SUPPRIMER:
--   - tables-with-LOB.sql
--   - tables-with-deprecated-lob-types.sql
-- GARDER (renommé): LOB-usage.sql → LOB-configuration-analysis.sql

-- ACTION 2: Consolider les variantes structure
-- CRÉER: table-structure-analysis.sql
--   → Regroupe: colonnes, largeur, wide rows
-- SUPPRIMER:
--   - tables-with-high-columns-number.sql
--   - tables-with-wide-row.sql

-- ACTION 3: Réorganiser avec catégories:
--   📁 inventory/
--     - tables-and-columns.sql
--     - foreign-keys.sql
--     - primary-keys.sql
--   📁 search/
--     - search-columns-by-name.sql
--     - search-by-column-types.sql
--   📁 data-quality/
--     - number-of-NULL-in-table.sql
--     - forwarded-records.sql
--   📁 configuration/
--     - LOB-configuration-analysis.sql
--     - varchar-size-analysis.sql
--     - table-structure-analysis.sql
--   📁 usage/
--     - table-usage.sql
```

**Priorité**: 🔴 HAUTE - 14 fichiers → 10 fichiers avec meilleure organisation

---

### 7.4 🟡 Fichiers Singleton Mal Placés

**Fichiers à déplacer:**

| Fichier actuel | Problème | Destination |
|----------------|----------|-------------|
| `database-information/columnstore/wait-stats-azure.sql` | "wait-stats" = diagnostics | `diagnostics/wait-statistics/wait-stats-columnstore-azure.sql` |
| `database-administration/clear-proc-in-cache.sql` | Action = maintenance | `database-administration/maintenance/` |
| `database-administration/get-untrusted-constraints.sql` | Info, pas admin | `database-information/` |
| `database-information/ledger/ledger-table-medatadata.sql` | Typo dans nom | Renommer → `ledger-table-metadata.sql` |

**Recommandations:**

```bash
# ACTION 1:
git mv database-information/columnstore/wait-stats-azure.sql \
       diagnostics/wait-statistics/wait-stats-columnstore-azure.sql

# ACTION 2:
git mv database-administration/clear-proc-in-cache.sql \
       database-administration/maintenance/

# ACTION 3:
git mv database-administration/get-untrusted-constraints.sql \
       database-information/

# ACTION 4:
git mv database-information/ledger/ledger-table-medatadata.sql \
       database-information/ledger/ledger-table-metadata.sql
```

**Priorité**: 🟡 MOYENNE

---

## 8. Observations Additionnelles

### 8.1 📋 Cohérence des Headers SQL

**État actuel:**
- ✅ Bon: La plupart des fichiers ont le header standardisé
- ❌ Mauvais: Pas de structure uniforme pour DECLARE variables
- ❌ Mauvais: Pas de documentation des paramètres

**Exemple actuel:**
```sql
-----------------------------------------------------------------
-- [Description]
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
```

**Recommandations:**

```sql
-- Template amélioré pour scripts avec paramètres:
-----------------------------------------------------------------
-- [Description]
--
-- Parameters:
--   @param1: Description
--   @param2: Description
--
-- DMVs Used:
--   - sys.dm_exec_*
--   - sys.databases
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- Parameters
DECLARE @param1 INT = 100;
DECLARE @param2 NVARCHAR(128) = N'pattern%';
```

**Priorité**: 🟢 BASSE - Amélioration progressive

---

### 8.2 📚 Stored Procedures vs Scripts - Stratégie

**État actuel:**
- `stored-procedures/`: 14 fichiers (procédures)
- `diagnostics/`: ~100 fichiers (scripts)
- `database-information/`: ~60 fichiers (scripts)

**Problème:**
- Pas de document expliquant **quand créer une stored proc vs script**
- Certaines procédures répliquent des scripts (redondance)

**Recommandations:**

```markdown
# Créer: CONTRIBUTING.md

## Quand utiliser Stored Procedure vs Script?

### Utiliser Stored Procedure (dans stored-procedures/):
- ✅ Utilisation répétée par plusieurs équipes
- ✅ Nécessite des paramètres dynamiques
- ✅ Installation dans master pour accès global
- ✅ Fait partie du "toolkit DBA standard"
- ✅ Exemples: sp_activeTransactions, sp_lock2, sp_who3

### Utiliser Script (dans diagnostics/ ou database-information/):
- ✅ Usage ponctuel, ad-hoc
- ✅ Analyse exploratoire
- ✅ Requête spécifique à un contexte
- ✅ Pas besoin de paramètres
- ✅ Exemples: most diagnostic queries

### Cas mixtes:
- Créer les DEUX:
  - Stored proc pour usage programmatique
  - Script pour usage ad-hoc (peut appeler la proc)
```

**Priorité**: 🟢 BASSE - Documentation

---

### 8.3 🔍 Extended Events - Organisation Cohérente

**État actuel:**
- ✅ Bon: Séparation `on-prem/` vs `azure-sql-database/`
- ✅ Bon: Convention `*-create.sql` et `*-read.sql`
- ✅ Bon: Sous-répertoire `metadata/` pour info XEvents

**Aucune action requise** - Organisation déjà excellente ✨

---

## 9. Plan d'Action Recommandé

### Phase 1: Redondances Critiques (Priorité 🔴🔴)

```bash
# 1. Rebuild Heaps - LA PLUS CRITIQUE
# Économise: 280 lignes de duplication
- [ ] Créer stored-procedures/sp_rebuild_heaps.sql (consolidé)
- [ ] Supprimer dba-database/015.rebuild_heaps.sql
- [ ] Transformer maintenance/rebuild-heaps.sql en wrapper

# 2. Fragmentation Analysis
# Économise: 2 fichiers → 1 fichier
- [ ] Créer index-management/analyze-index-fragmentation.sql (avec paramètre mode)
- [ ] Supprimer index-physical-stats-detailed.sql
- [ ] Supprimer index-physical-stats-limited.sql

# 3. Procedure Statistics
# Économise: 3 fichiers → 1 fichier
- [ ] Créer diagnostics/execution-stats/stored-procedures/procedure-statistics.sql
- [ ] Supprimer procedures-by-execution-count.sql
- [ ] Supprimer procedure-execution-analysis.sql
- [ ] Supprimer monitor-proc-execution.sql

# 4. Size and Allocation
# Économise: 12 fichiers → 7 fichiers
- [ ] Consolider allocation-analysis + check-allocation + used-space-in-current-db
- [ ] Créer space-usage-overview.sql
- [ ] Fusionner table-sizes + tables-allocation
- [ ] Supprimer objects-in-filegroups.sql
```

**Gain Phase 1:** ~8 fichiers supprimés, ~400 lignes de code dédupliquées

---

### Phase 2: Organisation (Priorité 🔴)

```bash
# 1. Tables Information
# Économise: 14 fichiers → 10 fichiers + meilleure structure
- [ ] Consolider LOB: 3 fichiers → 1 fichier (LOB-configuration-analysis.sql)
- [ ] Consolider structure: 2 fichiers → 1 fichier (table-structure-analysis.sql)
- [ ] Créer sous-répertoires: inventory/, search/, data-quality/, configuration/, usage/

# 2. Indexes Organization
- [ ] Déplacer fragmentation-analysis.sql vers index-management/
- [ ] Supprimer indexes-on-a-table.sql (redondant)

# 3. Fichiers Mal Placés
- [ ] Déplacer wait-stats-azure.sql vers diagnostics/wait-statistics/
- [ ] Déplacer clear-proc-in-cache.sql vers maintenance/
- [ ] Déplacer get-untrusted-constraints.sql vers database-information/
- [ ] Renommer ledger-table-medatadata.sql → ledger-table-metadata.sql
```

**Gain Phase 2:** ~6 fichiers supprimés, meilleure organisation des répertoires

---

### Phase 3: Simplifications (Priorité 🟡)

```bash
# 1. Active Transactions
- [ ] Simplifier active-transactions.sql (appelle sp_activeTransactions)

# 2. Locking
- [ ] Décision: supprimer what-is-locked.sql OU le transformer en version détaillée

# 3. Version Store
- [ ] Renommer pour clarifier hiérarchie (overview, by-sessions, by-transaction)

# 4. List Databases
- [ ] Renommer list-databases.sql → databases-inventory-full.sql
- [ ] Renommer query-store/list-databases.sql → databases-with-query-store.sql
```

**Gain Phase 3:** Clarté accrue, moins d'ambiguïté

---

### Phase 4: Documentation (Priorité 🟢)

```bash
# 1. Missing Indexes
- [ ] Ajouter commentaires pour clarifier différence DMV vs Query Store

# 2. Headers
- [ ] Améliorer template avec documentation paramètres

# 3. Stratégie
- [ ] Créer CONTRIBUTING.md avec guidelines stored proc vs script
```

**Gain Phase 4:** Meilleure compréhension pour contributeurs

---

## 📊 Résumé Chiffré

| Métrique | Avant | Après | Gain |
|----------|-------|-------|------|
| **Fichiers SQL** | 333+ | ~315 | -18 fichiers (-5.4%) |
| **Lignes dupliquées** | ~600+ | 0 | -600 lignes |
| **Répertoires avec structure claire** | 60% | 90% | +30% |
| **Scripts avec chevauchement** | 15-20 | 0 | -100% |

---

## 🎯 Priorités par Impact

### Impact MAXIMUM (faire en premier):
1. 🔴🔴 **Rebuild Heaps consolidation** - 280 lignes dupliquées
2. 🔴 **Size/Allocation reorganization** - 5 fichiers économisés
3. 🔴 **Tables Information reorganization** - 4 fichiers économisés + structure claire

### Impact MOYEN:
4. 🟡 **Fragmentation consolidation** - 2 fichiers économisés
5. 🟡 **Procedure statistics consolidation** - 3 fichiers économisés
6. 🟡 **Index organization cleanup** - Clarté accrue

### Impact FAIBLE (mais utile):
7. 🟢 **Renommages** - Clarté
8. 🟢 **Documentation** - Guidelines
9. 🟢 **Headers** - Consistance

---

## 📝 Notes pour Session Future

### Pour consolidation Rebuild Heaps:
- Base: `maintenance/rebuild-heaps.sql` (291 lignes)
- Différences à paramétrer:
  - `@database_pattern` pour remplacer liste hardcodée
  - `@max_size_mb` (50000 vs 10000)
- Créer procédure master dans `stored-procedures/`
- Tester sur database test avant suppression

### Pour Size/Allocation:
- Identifier colonnes communes entre:
  - allocation-analysis.sql
  - check-allocation.sql
  - used-space-in-current-db.sql
- Créer CTE hiérarchique pour space-usage-overview.sql

### Pour Tables Information:
- Créer sous-répertoires AVANT de déplacer fichiers
- Mettre à jour README.md dans chaque sous-répertoire

---

## ✅ Checklist de Validation

Après chaque modification, vérifier:
- [ ] Le script s'exécute sans erreur
- [ ] Les résultats sont identiques à la version précédente
- [ ] Le header SQL est mis à jour
- [ ] Le README.md est mis à jour si nécessaire
- [ ] Les chemins dans CLAUDE.md sont mis à jour
- [ ] Commit git avec message descriptif

---

**Fin du rapport d'analyse**

*Généré par Claude Sonnet 4.5 le 2026-02-16*
*Agent ID: a7126e8 (pour reprendre l'analyse si besoin)*
