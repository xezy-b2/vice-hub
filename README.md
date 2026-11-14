# VICE HUB — Le QG GTA 6

Site de fans (non officiel) dédié à Grand Theft Auto VI : actualités sourcées mises à jour automatiquement, lecteur Twitch/YouTube intégré, vidéos officielles, profil joueur, suivi des missions, badges, classement communauté et guide de lancement.

En ligne : https://xezy-b2.github.io/vice-hub/

## Fonctionnalités

| | Sans Supabase | Avec Supabase |
|---|---|---|
| Actus (`news.json`, mises à jour toutes les heures) | ✅ | ✅ |
| Lecteur Twitch (live + chat) et YouTube intégrés | ✅ | ✅ |
| Profil, missions, watchlist | Navigateur uniquement | ✅ Compte en ligne, multi-appareils |
| Classement communauté | — | ✅ |

## Activer les comptes joueurs (Supabase, gratuit)

1. Crée un projet sur https://supabase.com (offre gratuite).
2. **SQL Editor → New query** : colle le contenu de [`supabase/schema.sql`](supabase/schema.sql) puis **Run**.
3. **Authentication → URL Configuration** :
   - *Site URL* : `https://xezy-b2.github.io/vice-hub/`
   - *Redirect URLs* : ajoute `https://xezy-b2.github.io/vice-hub/`
4. **Project Settings → API** : copie la *Project URL* et la clé *anon public*.
5. Dans `index.html`, renseigne-les dans le bloc `CFG` en haut du script :
   ```js
   const CFG = { supabaseUrl: "https://xxxx.supabase.co", supabaseAnonKey: "eyJ..." };
   ```
   La clé *anon* est faite pour être publique : la sécurité repose sur les règles RLS du schéma (chacun ne lit/écrit que ses propres données ; le classement est lisible par tous).

La connexion se fait par lien magique envoyé par e-mail (aucun mot de passe).

## Actualités

`news.json` est un tableau d'objets :
```json
{ "d": "2026-11-14", "ts": "2026-11-14T16:10:00Z", "c": "Lancement", "t": "Titre", "s": "Résumé", "sn": "Média", "su": "https://…" }
```
Il est complété automatiquement toutes les heures. Les actus de base restent intégrées dans `index.html`.

## Développement

Page unique, sans build : ouvre `index.html` via un petit serveur local (`python3 -m http.server`) pour que `news.json` et les lecteurs intégrés fonctionnent.

---

Site de fans non affilié à Rockstar Games ni à Take-Two Interactive. Grand Theft Auto est une marque de Take-Two Interactive.
