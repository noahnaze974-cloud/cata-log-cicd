# 06 - Preuve promotion production-simulee

## Promotion

- Workflow concerné : 03-promote.yml (job `promote-production-simulee`)
- Environnement GitHub : production-simulee
- Tag source : A_COMPLETER (par exemple `latest` ou `sha-abc1234`)
- Tag cible : production-simulee
- Lien du run : A_COMPLETER

## Point essentiel

La promotion doit réutiliser une image existante. Elle ne doit pas reconstruire l'image.

C'est exactement ce que fait le job : il enchaîne `docker pull` (récupération de l'artefact déjà publié), `docker tag` (ajout de l'étiquette `production-simulee` sur **la même image**) et `docker push` (publication du nouveau tag). **Aucune commande `docker build` n'apparaît dans ce job** : l'artefact promu est, à l'octet près, celui qui a été construit par le workflow 02 et validé en recette.

C'est le principe *« build once, promote many »* : on construit une seule fois, puis on fait circuler le même artefact identifié entre les environnements. Cela garantit que ce qui arrive en production est exactement ce qui a été testé.

## Preuve

Indiquer ici l'élément qui prouve que la promotion s'est faite sans rebuild :

1. **La preuve la plus forte — l'égalité des digests** : sur la page du package GHCR, le tag `production-simulee` et le tag source (par exemple `sha-abc1234`) pointent vers le **même digest** `sha256:...`. Deux builds séparés, même à partir du même code, produiraient des digests différents ; un digest identique démontre qu'il s'agit du même artefact.
   - Digest du tag source : A_COMPLETER
   - Digest du tag production-simulee : A_COMPLETER (doit être identique)
   - Capture GHCR à joindre : A_COMPLETER
2. **Les logs du job** : le log de l'étape « Promouvoir le même artefact » ne contient que `pull`, `tag`, `push` — aucun build. Lien/capture : A_COMPLETER
3. **La validation manuelle** : l'environnement `production-simulee` étant protégé par un relecteur requis, le run montre l'étape d'approbation (« Review deployments ») avant la promotion. Capture à joindre : A_COMPLETER
