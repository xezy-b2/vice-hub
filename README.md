<img src="logo.svg" width="96" alt="VICE HUB">

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

## Comptes joueurs (Supabase)

Le site est branché sur le projet Supabase **vice-hub** (`saulgajlglwqmpehytlm`, région Paris).

- Inscription avec **pseudo unique**, e-mail et mot de passe (indicateur de robustesse), connexion, mot de passe oublié, connexion par lien e-mail
- Espace **Compte** : avatar, couleur, bio, changement de pseudo / e-mail / mot de passe, déconnexion (ou de tous les appareils), **suppression du compte**
- **Profils publics** consultables depuis le classement
- Connexion Discord / Twitch / Google prête : active le fournisseur dans Supabase puis ajoute-le dans `CFG.oauth`

### Mise en place (une seule fois)

1. **SQL Editor → New query** : colle [`supabase/schema.sql`](supabase/schema.sql) puis **Run**.
2. **Authentication → URL Configuration** : *Site URL* et *Redirect URLs* = `https://xezy-b2.github.io/vice-hub/`
3. **E-mails** : le service d'e-mail inclus dans Supabase n'envoie qu'aux membres de l'équipe du projet. Pour un site public :
   - soit **Authentication → Sign In / Providers → Email → désactive « Confirm email »** (inscription immédiate) ;
   - soit configure un SMTP (ex. [Resend](https://resend.com/docs/send-with-supabase-smtp)) dans **Authentication → Emails → SMTP Settings** — nécessaire aussi pour « mot de passe oublié » et la connexion par lien.

La clé `sb_publishable_…` présente dans `index.html` est publique par conception : la sécurité repose sur les règles RLS du schéma.


### Lives Twitch (Edge Function `twitch-live`)

1. Crée une application sur https://dev.twitch.tv/console/apps (catégorie *Website Integration*, URL de redirection : `https://saulgajlglwqmpehytlm.supabase.co/auth/v1/callback`).
2. Dans Supabase → **Edge Functions → Secrets**, ajoute `TWITCH_CLIENT_ID` et `TWITCH_CLIENT_SECRET`.
3. La section « En direct sur GTA VI » et les badges « EN DIRECT » des favoris s'activent automatiquement.

### Connexion Discord / Twitch

Active le fournisseur dans **Authentication → Sign In / Providers** (même URL de redirection que ci-dessus), puis ajoute-le dans `CFG.oauth` (`["discord","twitch"]`).

## Actualités

Les actus sont dans la table Supabase `news` (remplie toutes les heures). `news.json` reste lu en complément, au format :
```json
{ "d": "2026-11-14", "ts": "2026-11-14T16:10:00Z", "c": "Lancement", "t": "Titre", "s": "Résumé", "sn": "Média", "su": "https://…" }
```
Il est complété automatiquement toutes les heures. Les actus de base restent intégrées dans `index.html`.

## Développement

Page unique, sans build : ouvre `index.html` via un petit serveur local (`python3 -m http.server`) pour que `news.json` et les lecteurs intégrés fonctionnent.

---

Site de fans non affilié à Rockstar Games ni à Take-Two Interactive. Grand Theft Auto est une marque de Take-Two Interactive.
