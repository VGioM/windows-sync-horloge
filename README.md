# Synchronisation auto de l'horloge Windows

Petit script pour PC en **dual boot Linux / Windows**.

## Le problème

Linux stocke l'heure de l'horloge matérielle (BIOS/RTC) en **UTC**, alors que Windows la considère comme de l'**heure locale**.
Résultat : après avoir démarré sous Linux, Windows affiche une heure décalée (de 1 ou 2 h en France selon l'heure d'été/hiver) jusqu'à ce qu'il se resynchronise — ce qui peut prendre longtemps.

## Ce que fait le script

`sync_horloge_demarrage.bat` crée une **tâche planifiée Windows** qui resynchronise l'horloge sur Internet à chaque démarrage :

1. Se relance automatiquement **en administrateur** si nécessaire (une fenêtre UAC s'affiche).
2. Met le **service de temps Windows** (`w32time`) en démarrage automatique.
3. Crée la tâche planifiée **`ResyncHorloge`** qui, **1 minute après chaque démarrage** (le temps que le réseau soit prêt), lance :
   ```
   net start w32time & w32tm /resync /force
   ```
   La tâche tourne sous le compte `SYSTEM`, sans fenêtre, sans avoir besoin d'être connecté.

Le script n'est à lancer **qu'une seule fois** : la tâche reste ensuite en place.

## Installation

1. Copier `sync_horloge_demarrage.bat` sur le PC Windows.
2. Double-cliquer dessus et accepter la demande d'élévation (UAC).
3. Vérifier que le message `SUCCÈS : la tâche planifiée "ResyncHorloge" a été créée` s'affiche.

Relancer le script plus tard ne pose pas de problème : la tâche existante est remplacée (`/F`).

## Vérifier / tester

```bat
:: Voir la tâche
schtasks /Query /TN "ResyncHorloge" /V /FO LIST

:: La lancer tout de suite sans redémarrer
schtasks /Run /TN "ResyncHorloge"

:: Voir l'état de la synchronisation
w32tm /query /status
```

On peut aussi la retrouver dans le **Planificateur de tâches** (`taskschd.msc`).

## Désinstaller

Dans une invite de commandes **administrateur** :

```bat
schtasks /Delete /TN "ResyncHorloge" /F
```

## Alternative

Une autre approche consiste à dire à Windows que l'horloge matérielle est en UTC (comme Linux), via la clé de registre
`HKLM\SYSTEM\CurrentControlSet\Control\TimeZoneInformation\RealTimeIsUniversal` (DWORD = 1),
ou inversement à configurer Linux en heure locale (`timedatectl set-local-rtc 1`).
Ce script choisit plutôt une resynchronisation réseau, qui ne touche ni au registre ni à la config Linux.
