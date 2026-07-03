# 03 - Fiche tests

## Test automatisé GitHub Actions

- Workflow concerné : 01-ci.yml
- Lien vers le run réussi : A_COMPLETER (onglet Actions → run vert → copier l'URL)
- Ce qui est testé :
  1. **Présence des fichiers attendus** : `Dockerfile`, `compose.yml`, `site/index.html`, `site/version.json`, `docs/08-compte-rendu-final.md` ;
  2. **Validité du compose.yml** : `docker compose config` vérifie la syntaxe ;
  3. **Construction de l'image** : `docker build --pull` avec un tag lié au commit (`projet-cicd:<sha>`) ;
  4. **Test HTTP réel** : le conteneur est démarré, puis `curl` vérifie que la page d'accueil et `version.json` répondent (échec du workflow si le code HTTP n'est pas un succès) ;
  5. **Test de contenu** : `grep -i "Projet CICD"` vérifie que la page servie est bien la bonne.
- Résultat : A_COMPLETER (exemple : « Run vert du JJ/MM/AAAA, toutes les étapes passées, test HTTP OK »).

## Test local Docker ou Docker Compose

Renseigner l'une des deux situations, puis supprimer l'autre.

### Situation A - Test réalisé

Commandes utilisées :

```bash
docker build -t projet-cicd-nginx:local .
docker run --rm -p 8080:80 projet-cicd-nginx:local
```

ou :

```bash
docker compose up --build
```

Résultat observé : A_COMPLETER
(exemple attendu avec Compose : le service `web` démarre, puis le service `tester` affiche le HTML de la page et le contenu de `version.json` avant de se terminer avec le code 0 — capture du terminal à joindre.)

### Situation B - Test local impossible

Justification : A_COMPLETER
(exemple de justification recevable : « Mon poste personnel ne permet pas l'installation de Docker Desktop (droits administrateur / configuration matérielle). Les tests équivalents sont exécutés à chaque push par le workflow 01-ci.yml sur les runners GitHub Actions, qui construisent l'image et effectuent le même test HTTP dans un environnement Ubuntu propre. Les preuves sont les runs verts référencés ci-dessus. »)

## Simulation de scaling

Si l'environnement le permet :

```bash
docker compose up -d --scale web=2
docker compose ps
```

Résultat observé : A_COMPLETER
(attendu : deux conteneurs `web` listés, par exemple `xxx-web-1` et `xxx-web-2`, tous deux `Up`. Le scaling fonctionne sans conflit car le service `web` ne publie pas de port fixe sur l'hôte.)

Pour vérifier que les deux réplicas répondent, on peut relancer le testeur :

```bash
docker compose run --rm tester
```

## Limites de la simulation

- **Pas de répartition de charge réelle** : les réplicas existent, mais rien ne distribue intelligemment le trafic entre eux (pas de load balancer avec health checks, pondération ou retrait automatique d'un réplica défaillant).
- **Pas de haute disponibilité** : tout s'exécute sur une seule machine ; si l'hôte tombe, tous les conteneurs tombent.
- **Pas de supervision** : aucune métrique, aucune alerte, aucun redémarrage piloté par l'état de santé au niveau de la flotte.
- **Dépendance à l'environnement local** : le résultat dépend du poste (versions de Docker, ressources disponibles), contrairement aux runners CI qui sont reproductibles.
- **Pas d'élasticité** : le nombre de réplicas est fixé à la main ; il ne s'adapte pas à la charge.

Cette simulation montre donc la **coordination** de conteneurs (le rôle de Compose), mais ne remplace pas une orchestration de production — voir la comparaison avec Kubernetes dans docs/02-schema-chaine-cicd.md.
