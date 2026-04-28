---
layout: default
title: Release Signing Guide
permalink: /signing/
---

# Tortio — Release Signing Guide

Документ для maintainer'а — как создать и хранить keystore для подписи Tortio для Google Play и совместимых GitHub-релизов.

## ⚠️ Перед началом — ВАЖНО

- **Keystore нельзя терять.** Если потерян пароль или сам файл — Google Play **не позволит обновлять приложение**. Придётся публиковать новое приложение с нуля (новый package id, потеря всех существующих установок и отзывов).
- Делайте 2-3 бэкапа keystore'а в **разные места** (например: 1Password / физический USB / зашифрованный архив на втором облаке).
- Пароль храните в менеджере паролей, **не в репозитории**.

## 1. Создание keystore

```bash
mkdir -p ~/.tortio-keys
keytool -genkey -v \
  -keystore ~/.tortio-keys/tortio-release.jks \
  -keyalg RSA -keysize 2048 \
  -validity 27300 \
  -alias tortio \
  -storetype JKS
```

Команда спросит:
- Пароль keystore (запомнить!)
- Distinguished Name (CN, O, OU, L, ST, C) — введите свои реальные данные.
- Пароль ключа (можно тот же, что и keystore — Play это допускает).

После выполнения keystore лежит в `~/.tortio-keys/tortio-release.jks`.

## 2. Создание `key.properties`

В корне репо создайте `key.properties` (он в `.gitignore` — не закоммитится):

```properties
storePassword=ВАШ_ПАРОЛЬ
keyPassword=ВАШ_ПАРОЛЬ
keyAlias=tortio
storeFile=/home/USER/.tortio-keys/tortio-release.jks
```

Замените `USER` на ваш юзернейм. Путь — абсолютный.

## 3. Сборка signed APK / AAB

```bash
# Signed APK (для GitHub Releases)
flutter build apk --release

# Signed AAB (для Google Play Console)
flutter build appbundle --release
```

Артефакты:
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`

Проверка подписи APK:
```bash
~/android-sdk/build-tools/34.0.0/apksigner verify --verbose build/app/outputs/flutter-apk/app-release.apk
```

Должен вывести fingerprint вашего ключа (SHA-256). Этот fingerprint позже будет нужен в Play Console.

## 4. Бэкап keystore

**ОБЯЗАТЕЛЬНО** сразу после создания:

```bash
# 1. Сохранить копию в зашифрованный архив
tar czf - -C ~ .tortio-keys | gpg -c > tortio-keys-backup.tar.gz.gpg

# 2. Положить tortio-keys-backup.tar.gz.gpg в:
#    - 1Password как attachment
#    - Физический USB (хранить отдельно от компьютера)
#    - Опционально: второе облако (Drive/Dropbox), но только зашифрованный
```

Восстановление при потере основного:
```bash
gpg -d tortio-keys-backup.tar.gz.gpg | tar xzf - -C ~
```

## 5. GitHub Actions — опционально

Чтобы Actions сам собирал signed APK/AAB:

1. Закодировать keystore в base64:
   ```bash
   base64 -w 0 ~/.tortio-keys/tortio-release.jks > /tmp/ks.b64
   ```
2. В GitHub repo → Settings → Secrets and variables → Actions → New repository secret:
   - `KEYSTORE_BASE64` — содержимое `/tmp/ks.b64`
   - `KEYSTORE_PASSWORD` — пароль keystore
   - `KEY_ALIAS` — `tortio`
   - `KEY_PASSWORD` — пароль ключа
3. В `.github/workflows/release.yml` перед `flutter build` добавить:
   ```yaml
   - name: Decode keystore
     env:
       KEYSTORE_BASE64: ${{ secrets.KEYSTORE_BASE64 }}
     run: |
       echo "$KEYSTORE_BASE64" | base64 -d > $RUNNER_TEMP/release.jks
   - name: Create key.properties
     env:
       KSP: ${{ secrets.KEYSTORE_PASSWORD }}
       KP: ${{ secrets.KEY_PASSWORD }}
       KA: ${{ secrets.KEY_ALIAS }}
     run: |
       cat > key.properties <<EOF
       storePassword=$KSP
       keyPassword=$KP
       keyAlias=$KA
       storeFile=$RUNNER_TEMP/release.jks
       EOF
   ```

После этого `flutter build apk --release` и `flutter build appbundle --release` в Actions подпишутся правильно.
