# Audit de réorganisation SQL

Contexte pris en compte: `CLAUDE.md`.

Périmètre: tous les fichiers `*.sql` du dépôt, avec détection automatique de similarité puis vérification manuelle.

## Doublons quasi certains (à consolider en priorité)

- `database-information/size-and-allocation/objects-in-filegroups.sql` et `database-information/size-and-allocation/tables-allocation.sql`
  - Même requête (différences mineures de header/`GO`).
  - Suggestion: garder un seul fichier (`tables-allocation.sql` semble mieux nommé) et transformer l’autre en alias dans README uniquement.

- `database-administration/dba-database/015.rebuild_heaps.sql` et `database-administration/maintenance/rebuild-heaps.sql`
  - Même procédure de base (`rebuild_heaps`) mais variante locale dans `maintenance` (liste de bases codée en dur, seuil max différent).
  - Suggestion: conserver une version canonique (idéalement `dba-database/015...`) et déplacer la variante locale dans un dossier d’exemples/surcharges.

- `extended-events/on-prem/errors-read.sql` et `extended-events/on-prem/errors-read-procedure.sql`
  - Même logique de lecture de session XEvent `errors`; l’un est script direct, l’autre procédure.
  - Suggestion: garder une version source unique et générer/maintenir la variante procédure à partir de cette source.

- `extended-events/azure-sql-database/read-exended-event.sql` et `extended-events/azure-sql-database/trace-procedure-read.sql`
  - Requêtes très proches (même pipeline XML ring buffer, paramètres/session différents).
  - Suggestion: fusionner en une version paramétrable (`@ExtendedEventsSessionName`, fenêtre temporelle, tri).

## Redondances fonctionnelles (pas strictement des doublons)

- `diagnostics/execution/active-transactions.sql` et `stored-procedures/sp_activeTransactions.sql`
  - Même socle de requête DMV; la procédure ajoute un filtre `@all` et des adaptations.
  - Suggestion: définir la procédure comme version canonique et faire du script diagnostics une variante "ad hoc" minimale documentée.

- `cloud/azure/azure-sql-database/disk-usage-by-top-tables.sql` et `database-information/size-and-allocation/table-sizes.sql`
  - Même logique de taille de table; variante Azure plus simple.
  - Suggestion: mutualiser via un script commun + variante Azure explicite (différences documentées).

- `diagnostics/query-store/global-runtime-stats.sql` et `diagnostics/query-store/global-runtime-stats-in-period.sql`
  - Même requête, l’un ajoute une fenêtre temporelle.
  - Suggestion: unifier avec paramètres `@interval_start_time`, `@interval_end_time` optionnels.

- `hadr/secondary-synchronization-lag.sql` et `stored-procedures/sp_HadrState.sql`
  - `sp_HadrState` reprend la logique de lag + enrichissements.
  - Suggestion: garder `sp_HadrState` comme version complète et alléger le script HADR en vue simplifiée, ou l’inverse mais documenté.

- `database-administration/maintenance/get-backups.sql` et `stored-procedures/sp_CheckBackups.sql`
  - Même thématique `msdb..backupset`, niveaux de détail différents.
  - Suggestion: définir un tronc commun (CTE/VIEW/proc) et décliner les sorties.

- `monitoring/monitor-backup-operations.sql` et `database-administration/maintenance/running-backups.sql`
  - Même objectif (backups en cours), mais l’un est ultra minimal.
  - Suggestion: garder la version détaillée et retirer/ranger la version minimale comme snippet.

## Fichiers probablement mal placés

- `cloud/azure/azure-sql-database/temp.sql`
  - Script ad hoc de test (`dbo.CCI` hardcodé), nom non descriptif.
  - Suggestion: déplacer vers `howto/` ou `database-information/columnstore/` avec renommage explicite.

- `monitoring/monitor-long-transactions.sql`
  - Contient `ALTER PROCEDURE` et logique d’alerte mail; c’est plus un artefact d’administration/proc qu’un simple script monitoring ponctuel.
  - Suggestion: déplacer vers `stored-procedures/` ou `database-administration/alerts/` selon usage cible.

- `monitoring/queries-for-dashboards/transaction-logs.sql`
  - Crée une procédure (`dbo.monitor_transaction_logs`) dans un dossier "queries-for-dashboards".
  - Suggestion: déplacer la proc vers `stored-procedures/` et garder ici uniquement la requête d’appel/consommation dashboard.

- `extended-events/on-prem/errors-read-procedure.sql`
  - Script de création de procédure dans un dossier de scripts XE.
  - Suggestion: soit le déplacer vers `stored-procedures/`, soit créer un sous-dossier clair `extended-events/on-prem/procedures/`.

## Nommage et cohérence

- `extended-events/azure-sql-database/read-exended-event.sql`
  - Typo dans le nom (`exended`).
  - Suggestion: renommer en `read-extended-event.sql`.

- `hadr/alwayson-statuts.sql`
  - Typo probable (`statuts`).
  - Suggestion: renommer en `alwayson-status.sql`.

- `diagnostics/execution/running-plans-using-ligthweight-profile.sql`
  - Typo probable (`ligthweight`).
  - Suggestion: renommer en `running-plans-using-lightweight-profile.sql`.

## Collisions de noms de fichiers (à clarifier)

- `database-information/list-databases.sql` vs `diagnostics/query-store/list-databases.sql`
  - Suggestion: expliciter le scope dans le nom (ex: `list-databases-query-store-enabled.sql`).

- `index-management/missing-indexes.sql` vs `diagnostics/query-store/missing-indexes.sql`
  - Suggestion: distinguer `missing-indexes-dmvs.sql` vs `missing-indexes-query-store.sql`.

- `database-information/transaction-log/transaction-logs.sql` vs `monitoring/queries-for-dashboards/transaction-logs.sql`
  - Suggestion: suffixer `-details` / `-dashboard` selon l’usage.

## TODO proposé (ordre conseillé)

1. Éliminer les doublons quasi certains dans `size-and-allocation`, `rebuild_heaps`, `extended-events/*read*`.
2. Définir une "source canonique" pour les couples script ad hoc / procédure (`active-transactions`, `hadr lag`, `backups`, `global-runtime-stats`).
3. Déplacer/renommer les fichiers mal classés (`temp.sql`, procédures dans `monitoring`, typo filenames).
4. Uniformiser les noms ambigus en ajoutant un suffixe de contexte (`-query-store`, `-dmvs`, `-dashboard`).
5. Mettre à jour tous les `README.md` impactés après déplacement/consolidation.

## Remarques

- Aucune modification de script n’a été faite dans cet audit, uniquement ce document de recommandations.
- Certaines redondances sont volontaires (version "proc" + version "requête directe"). Le point critique est surtout d’identifier un fichier maître pour éviter la divergence.
