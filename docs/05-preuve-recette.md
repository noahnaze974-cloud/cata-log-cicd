# 05 - Preuve recette simulée

## Workflow de validation recette

- Workflow concerné : 03-promote.yml (job `validate-recette`)
- Environnement GitHub : recette
- Tag source validé : A_COMPLETER (celui saisi au lancement du workflow, par exemple `latest`)
- Digest observé : A_COMPLETER (affiché dans le résumé du job « Validation recette simulée »)
- Lien du run : A_COMPLETER

## Résultat

Décrire ici le résultat effectivement observé, par exemple :

Le job `validate-recette` a téléchargé l'image `ghcr.io/.../:latest` **sans la reconstruire** (`docker pull` uniquement), l'a démarrée, puis a exécuté deux requêtes HTTP avec `curl -fsS` :

- `http://127.0.0.1:8080/` → réponse HTTP réussie, contenu HTML de la page Catal-Log retourné ;
- `http://127.0.0.1:8080/version.json` → réponse HTTP réussie, JSON de version retourné.

L'option `-f` de curl fait échouer l'étape (et donc le workflow) si le serveur répond par une erreur HTTP : le succès du job constitue donc la preuve du test.

Le digest affiché dans le résumé identifie précisément l'artefact validé en recette : c'est **ce digest-là**, et aucun autre, qui sera ensuite promu en production simulée (voir docs/06-preuve-promotion.md).

Preuves à joindre : capture du run vert (les deux jobs), capture du résumé montrant le digest observé.
