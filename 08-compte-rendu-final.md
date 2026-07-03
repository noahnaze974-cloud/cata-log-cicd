# 08 - Compte rendu final

> Ce compte rendu est personnel : les sections marquées A_COMPLETER doivent être écrites avec tes propres mots et ton expérience réelle du projet. Le formateur vérifie la compréhension, pas le remplissage.

## 1. Synthèse

A_COMPLETER — Rédiger 5 à 10 lignes avec tes mots. Trame possible : ce que fait la chaîne de bout en bout (commit → build → test → publication GHCR → validation recette → promotion production simulée sans rebuild), ce qu'elle apporte à Catal-Log (fiabilité, suppression des opérations manuelles, preuves d'exécution), et ce que tu as réellement réalisé toi-même.

## 2. Fonctionnement technique

Le chemin complet d'une modification est le suivant :

1. **Commit** : la modification (site, Dockerfile, workflow ou documentation) est poussée sur le dépôt GitHub ; l'historique Git assure la traçabilité du code.
2. **Build + test (01-ci.yml)** : le push déclenche automatiquement la CI, qui vérifie les fichiers attendus, valide `compose.yml`, construit l'image, démarre le conteneur et exécute un test HTTP réel (page et `version.json`) plus un test de contenu. Un échec bloque la suite.
3. **Publication GHCR (02-publish-ghcr.yml)** : sur la branche principale, l'image est publiée dans GHCR avec des tags (`sha-<commit>`, `latest`) et un digest immuable.
4. **Validation recette (03-promote.yml, déclenchement manuel)** : l'image déjà publiée est téléchargée (aucun rebuild), démarrée dans l'environnement `recette`, et le test HTTP est rejoué ; le digest observé est affiché en preuve.
5. **Promotion production-simulee** : après approbation manuelle, le même artefact reçoit le tag `production-simulee` par simple `pull` / `tag` / `push`. Le digest identique entre la source et la cible prouve l'absence de reconstruction.

A_COMPLETER — Ajouter 2 ou 3 phrases personnelles : ce qui t'a semblé le plus important dans ce déroulé, ou un moment où la chaîne t'a réellement bloqué une erreur.

## 3. Conteneurisation C12

Le `Dockerfile` part d'une image de base **épinglée et minimale** (`nginx:1.27-alpine`) : l'épinglage garantit la reproductibilité (le build ne change pas silencieusement de version de base), et la variante alpine réduit la taille et la surface d'attaque. Le site statique (`site/`) est copié dans le répertoire servi par Nginx, les droits sont normalisés, le port 80 est déclaré, et un `HEALTHCHECK` interroge la page pour détecter un conteneur défaillant. Des labels OCI (titre, description, source) rendent l'image auto-documentée.

L'exécution conteneurisée est démontrée à trois niveaux : en CI (le conteneur est réellement démarré et testé en HTTP à chaque push), en local si l'environnement le permet (docs/03-fiche-tests.md), et en recette/promotion où c'est l'image publiée qui est exécutée.

Preuves : runs 01-ci.yml verts, page GHCR (docs/04-preuve-image.md), tests locaux (docs/03-fiche-tests.md).

## 4. Orchestration et scaling C13

Le `compose.yml` décrit deux services coordonnés : `web` (le site Nginx, construit depuis le Dockerfile) et `tester` (conteneur `curl` qui dépend de `web`, attend son démarrage puis vérifie en HTTP la page et `version.json`). Les deux communiquent sur un réseau dédié `cicd_net`. Compose joue ici le rôle d'**orchestration légère** : un seul fichier déclaratif décrit les services, leur réseau, leurs dépendances et leur cycle de vie.

La **simulation de scaling** utilise `docker compose up -d --scale web=2` : elle fonctionne sans conflit car `web` ne publie pas de port fixe sur l'hôte. Elle montre la multiplication de réplicas coordonnés, mais ses **limites** sont assumées : pas de répartition de charge réelle, pas de haute disponibilité (mono-hôte), pas de supervision ni d'élasticité (détail dans docs/03-fiche-tests.md). En production réelle, un orchestrateur comme Kubernetes apporterait ces fonctions ; le principe CI/CD resterait identique : ne déployer que des artefacts identifiés par tag et digest.

A_COMPLETER — Indiquer si tu as pu exécuter la simulation (avec le résultat observé) ou renvoyer vers ta justification.

## 5. Automatisation et sécurité C14

Trois workflows couvrent la chaîne : CI systématique à chaque push, publication GHCR sur la branche principale, promotion manuelle contrôlée. L'authentification vers GHCR repose exclusivement sur le **GITHUB_TOKEN** éphémère : aucun secret n'est stocké dans le code ni dans les workflows. Les permissions suivent le moindre privilège (`contents: read` partout, `packages: write` uniquement où la publication l'exige). L'environnement `production-simulee` impose une **validation manuelle** avant promotion.

Le **rollback** s'appuie sur l'immuabilité des digests : relancer la promotion avec un ancien tag sain redéploie un artefact déjà testé, sans rebuild. La **sauvegarde/restauration** couvre le dépôt (miroir Git), les images (copie des tags critiques et digests), et la configuration des environnements (détail complet dans docs/07-securite-minimale.md).

## 6. Production réelle

Les trois points obligatoires sont traités en détail dans docs/07-securite-minimale.md ; en synthèse :

- **Gestion des secrets** : rien dans le code (un secret commité vit dans l'historique Git et doit être considéré compromis) ; GITHUB_TOKEN éphémère pour GHCR ; en production réelle, GitHub Secrets pour les identifiants externes et, idéalement, un coffre dédié (Vault, AWS Secrets Manager) avec rotation et journalisation.
- **Rollback** : re-promotion d'un artefact antérieur identifié par tag/digest, sans reconstruction — rapide, fiable, traçable.
- **Sauvegarde/restauration** : miroir du dépôt (code + workflows + docs), copie des images critiques vers un registre secondaire avec leurs digests, documentation de la configuration des environnements et de la procédure de recréation des secrets ; restauration testée périodiquement.

Deux éléments complémentaires développés : **contrôle des vulnérabilités** (scan d'image type Trivy bloquant en CI) et **validation manuelle avant production** (relecteur requis sur l'environnement) — voir docs/07-securite-minimale.md.

## 7. Preuves

- Lien du dépôt : A_COMPLETER
- Run 01-ci.yml réussi : A_COMPLETER
- Run 02-publish-ghcr.yml réussi (résumé avec tags + digest) : A_COMPLETER
- Page du package GHCR (tags et digest visibles) : A_COMPLETER
- Run 03-promote.yml réussi (recette + promotion, avec approbation) : A_COMPLETER
- Preuve « sans rebuild » (digest identique source / production-simulee) : A_COMPLETER
- Captures : A_COMPLETER (lister les fichiers, par exemple déposés dans docs/captures/)

## 8. Difficultés et apprentissages

A_COMPLETER — Partie strictement personnelle, la plus lue par le formateur. Pistes de rédaction honnêtes : une erreur de workflow que tu as dû déboguer (et comment tu as lu les logs pour la corriger), la compréhension de la différence tag/digest, la découverte du déclenchement manuel et des environnements protégés, ce que tu ferais différemment avec plus de temps (scan de vulnérabilités, vrai reverse proxy devant les réplicas, etc.).
