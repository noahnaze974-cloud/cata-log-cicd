# 04 - Preuve image GHCR

## Image publiée

- Nom de l'image : ghcr.io/A_COMPLETER/A_COMPLETER
- Tag principal : A_COMPLETER (exemple : `latest` et `sha-abc1234`)
- Digest : A_COMPLETER (exemple : `sha256:...` — visible dans le résumé du run 02 et sur la page du package GHCR)
- Lien GHCR ou capture : A_COMPLETER (Profil GitHub → onglet Packages → cliquer sur le package)

## Explication

Le **tag** est une étiquette lisible par un humain (`latest`, `sha-abc1234`, `production-simulee`). Il est pratique mais **déplaçable** : le même tag peut pointer vers des images différentes au fil du temps (c'est le cas de `latest`, réécrit à chaque publication).

Le **digest** (`sha256:...`) est l'empreinte cryptographique du contenu de l'image. Il est **immuable** : le moindre changement dans l'image produit un digest différent, et un digest donné désigne toujours exactement le même artefact.

La combinaison des deux sert directement la traçabilité et le rollback :

- **Traçabilité** : le tag `sha-<commit>` relie chaque image publiée au commit précis qui l'a produite. On sait toujours quel code a généré quel artefact, et le digest permet de vérifier qu'aucune substitution n'a eu lieu.
- **Rollback** : pour revenir en arrière, il suffit de promouvoir à nouveau une image antérieure, identifiée par son tag ou, de manière encore plus sûre, par son digest. Aucune reconstruction n'est nécessaire : on redéploie un artefact **déjà construit et déjà testé**, ce qui rend le retour arrière rapide et fiable (voir docs/07-securite-minimale.md, section Rollback).
