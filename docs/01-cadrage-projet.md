# 01 - Cadrage du projet

## Identité

- Nom et prénom : Anonymous
- Dépôt GitHub : https://github.com/noahnaze974-cloud/cata-log-cicd:sha-01ce24c
- Date de démarrage : 03/07/2026

## Objectif

Mettre en place une chaîne CI/CD permettant de construire, tester, publier et promouvoir une image Docker Nginx contenant un site web statique pour le scénario Catal-Log.

La chaîne doit être simple, lisible et traçable : chaque étape laisse une preuve vérifiable (run GitHub Actions, tag et digest GHCR, environnements GitHub).

## Contraintes du projet

- Travail individuel.
- Aucune infrastructure fournie, préparée, administrée ou maintenue par le formateur.
- Pas de serveur distant, pas de SSH, pas de cloud provider imposé.
- Les traitements principaux sont exécutés dans GitHub Actions (runners hébergés par GitHub).
- Docker local ou Docker Compose sont utilisés si l'environnement personnel le permet ; sinon la limitation doit être justifiée.
- Une VM personnelle peut être utilisée si disponible ; sinon la non-utilisation doit être justifiée.

## Choix personnels

- **Visibilité du dépôt** : dépôt public, afin que les preuves (runs Actions, package GHCR) soient directement consultables par le formateur sans autorisation particulière.
- **Nommage** : dépôt en minuscules pour respecter la contrainte de nommage de GHCR (les noms d'images doivent être en minuscules).
- **Stratégie de tags** :
  - `sha-<commit>` : chaque image publiée est identifiée par le commit qui l'a produite → traçabilité exacte entre le code source et l'artefact ;
  - `latest` : pointe vers la dernière image de la branche principale ;
  - `production-simulee` : appliqué uniquement par le workflow de promotion, après validation en recette, sans reconstruction.
- **Environnement local** : A_COMPLETER — indiquer si tu as utilisé Docker/Docker Compose en local (voir docs/03-fiche-tests.md), ou justifier pourquoi non.
- **VM personnelle** : A_COMPLETER — indiquer si tu as utilisé une VM personnelle, ou justifier la non-utilisation (exemple de justification valable : « Les traitements du projet s'exécutent intégralement sur les runners GitHub Actions, qui fournissent des environnements Ubuntu temporaires et reproductibles ; une VM personnelle n'apporterait pas de valeur supplémentaire pour ce périmètre. »).
