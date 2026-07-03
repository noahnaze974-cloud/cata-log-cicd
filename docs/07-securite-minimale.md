# 07 - Sécurité minimale

## Permissions GitHub Actions

Les workflows appliquent le **principe du moindre privilège** : chaque workflow ne reçoit que les droits strictement nécessaires à sa mission, ce qui limite l'impact d'une éventuelle compromission ou d'une erreur.

- **01-ci.yml : `contents: read`** — le workflow ne fait que lire le code pour le construire et le tester ; il n'a besoin d'écrire nulle part.
- **02-publish-ghcr.yml : `contents: read, packages: write`** — lecture du code pour construire l'image, et écriture uniquement vers le registre de packages (GHCR) pour publier.
- **03-promote.yml : `contents: read, packages: write`** — lecture, plus écriture vers GHCR pour pousser le tag `production-simulee`. Le job de recette n'a besoin que de lire le package, mais la permission est déclarée au niveau du workflow pour couvrir le job de promotion.

## Gestion des secrets

**Pourquoi aucun secret ne doit être stocké dans le code** : un secret écrit dans un fichier versionné reste dans l'**historique Git** même après sa suppression ; toute personne qui clone ou forke le dépôt (public ou fuité) le récupère. Un secret commité doit être considéré comme compromis et révoqué immédiatement. Dans ce projet, aucun mot de passe, jeton ou clé n'apparaît dans les fichiers du dépôt ni dans les workflows.

**Usage du GITHUB_TOKEN dans ce projet** : l'authentification vers GHCR utilise `secrets.GITHUB_TOKEN`. Ce jeton est **généré automatiquement par GitHub pour chaque run**, injecté au moment de l'exécution, **limité au dépôt** et aux permissions déclarées dans le workflow, puis **expiré à la fin du run**. Il n'est jamais écrit dans le code, jamais affiché dans les logs (GitHub le masque), et il n'y a rien à créer ni à gérer manuellement.

**Ce qui devrait être placé dans GitHub Secrets ou dans un coffre en production réelle** : identifiants d'un registre d'images privé externe, clés d'API de services tiers, identifiants de base de données, certificats et clés privées TLS, jetons de déploiement vers les serveurs. Dans une production exigeante, on préférerait un **coffre de secrets dédié** (HashiCorp Vault, AWS Secrets Manager, Azure Key Vault) : rotation automatique, secrets à durée de vie courte, journalisation des accès et politique d'accès fine, capacités que GitHub Secrets ne couvre que partiellement.

## Rollback

Revenir à une version précédente s'appuie sur les artefacts immuables déjà publiés :

1. **Identifier** la dernière version saine dans GHCR : chaque publication porte un tag `sha-<commit>` et un digest `sha256:...` immuable.
2. **Relancer le workflow 03-promote.yml** (`workflow_dispatch`) en donnant comme tag source l'ancien tag sain (par exemple `sha-abc1234`).
3. Le workflow **re-valide** cet artefact en recette puis **re-tague** `production-simulee` vers lui — sans aucune reconstruction.

Avantages : le rollback est **rapide** (pas de build), **fiable** (on redéploie un artefact déjà testé, bit à bit identique) et **traçable** (le run de promotion et les digests GHCR gardent la trace du retour arrière). C'est la conséquence directe de la stratégie « un artefact = un digest immuable ».

## Sauvegarde / restauration

**Ce qu'il faudrait sauvegarder :**

- le **dépôt GitHub** : code, historique des commits, branches — un `git clone --mirror` régulier vers un stockage indépendant suffit à capturer l'intégralité ;
- les **workflows** (`.github/workflows/`) : ils font partie du dépôt, donc couverts par la même sauvegarde ;
- la **documentation et les preuves** (`docs/`, captures) : également versionnées dans le dépôt ;
- les **images publiées** dans GHCR : les tags importants (au minimum `production-simulee` et les derniers `sha-*`) peuvent être copiés vers un second registre (`docker pull` puis `docker push` vers le registre de secours), en conservant la liste des digests ;
- la **configuration non versionnée** : réglages du dépôt, environnements (`recette`, `production-simulee`), règles de protection et relecteurs requis, liste des secrets (leurs **noms** et leur procédure de recréation — jamais leurs valeurs en clair, qui vivent dans le coffre).

**Comment restaurer :** recréer un dépôt à partir du miroir Git (code + workflows + docs restaurés en une opération), repousser les images sauvegardées vers le registre (les digests permettent de vérifier l'intégrité), puis réappliquer la configuration documentée (environnements, protections, secrets recréés depuis le coffre). Un test de restauration devrait être réalisé périodiquement : une sauvegarde jamais testée n'est pas une sauvegarde.

## Deux éléments complémentaires

**1. Contrôle des vulnérabilités** : en production réelle, chaque image construite devrait être **scannée automatiquement** (par exemple avec Trivy ou Grype) dans la CI, avant publication. Le scan détecte les CVE connues dans l'image de base et les paquets installés ; une politique de blocage (échec du workflow en cas de vulnérabilité critique) empêche la publication d'une image dangereuse. Le choix d'une image de base **minimale et épinglée** (`nginx:1.27-alpine`) va déjà dans ce sens : surface d'attaque réduite et pas de dérive silencieuse de version.

**2. Validation manuelle avant production** : l'environnement GitHub `production-simulee` est configuré avec un **relecteur requis** (« Required reviewers »). Le job de promotion reste en attente tant qu'un humain n'a pas approuvé le déploiement. Cela reproduit une pratique standard de production : aucun artefact n'atteint la production sans décision humaine explicite, tracée (qui a approuvé, quand) dans l'historique du run. Combinée à la séparation des environnements (`recette` puis `production-simulee`), cette barrière réduit le risque de mise en production accidentelle.
