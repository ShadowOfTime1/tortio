---
layout: default
title: Privacy Policy
permalink: /privacy-policy/
---

# Privacy Policy — Tortio

**Effective:** April 28, 2026
**Developer:** Roman Karpenko ([roman.karpenk@gmail.com](mailto:roman.karpenk@gmail.com))

Tortio is a recipe scaling app for cake makers. This page describes what data the app handles and how.

## What we collect

**Nothing on our servers.** Tortio has no backend. We do not collect, transmit, or store any of your data on infrastructure we control.

All your recipes, photos, custom section types, settings and ratings live **on your device**, in the app's private storage.

## Third-party services Tortio talks to

### Google Drive (optional)

If you choose to enable cloud backup in Settings → Cloud backup, Tortio will:

- Ask you to sign in with your Google account.
- Upload an encrypted JSON snapshot of your recipes to **your own Google Drive**, in the hidden `appDataFolder` namespace.
- Read that snapshot back when you reinstall or sign in on another device.

Tortio uses the **`drive.appdata`** scope only. It cannot see, read, or modify any other files in your Drive — only the backup file it created. You can disable backup or delete the file from Drive at any time. Backups are not visible to anyone except you.

### GitHub Releases (for app updates)

Tortio checks GitHub Releases for new versions and downloads APKs from there when you tap the update banner. This means GitHub receives normal HTTPS request headers (your IP address, user-agent, etc.) — same as opening any web page. We do not see this traffic.

## What we don't do

- ❌ No analytics (Firebase, Google Analytics, Mixpanel, etc.)
- ❌ No advertising or ad networks
- ❌ No crash reporting or telemetry
- ❌ No tracking pixels or fingerprinting
- ❌ No accounts on our side
- ❌ No data sold or shared with third parties

## Camera and storage

If you add a photo to a recipe, Tortio uses standard Android camera/gallery pickers and stores the photo file in the app's private folder. Photos never leave your device unless you explicitly export the recipe (Share / PDF). We do not upload photos anywhere automatically.

## Children

Tortio is not directed at children under 13. We do not knowingly collect data from children.

## Your control

- **Delete everything**: Settings → Danger zone → Delete all recipes and custom types.
- **Disable cloud backup**: Settings → Cloud backup → Disconnect.
- **Uninstall**: removing the app removes all local data.
- **Delete cloud backup**: in Google Drive, see "Manage apps" and remove Tortio's data.

## Changes to this policy

If this policy changes, the new version will appear here and the **Effective** date above will be updated. Material changes (e.g., adding analytics, which we currently do not plan to do) would be announced in the app.

## Contact

Questions? Email [roman.karpenk@gmail.com](mailto:roman.karpenk@gmail.com) or open an issue at [github.com/ShadowOfTime1/tortio](https://github.com/ShadowOfTime1/tortio).
