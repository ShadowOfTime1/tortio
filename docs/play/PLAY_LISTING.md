# Tortio — Google Play Listing Assets

Всё, что нужно для заполнения страницы приложения в Google Play Console. Тексты — драфты, ты можешь править.

## Базовая инфа

| Поле | Значение |
|---|---|
| App name (English) | `Tortio` |
| App name (Russian) | `Tortio` (название приложения не переводится) |
| Package name | `com.tortio.app` |
| Default language | English (US) |
| Дополнительные языки | Russian |
| Application category | Food & Drink |
| Content rating | Everyone (заполнишь опросник в Console — у нас всё «нет») |
| Privacy Policy URL | `https://shadowoftime1.github.io/tortio/privacy-policy/` |
| Tags | Recipe, Cooking, Baking, Cake, Calculator |
| Контакт-email (публичный) | `roman.karpenk@gmail.com` |
| Website (опционально) | `https://shadowoftime1.github.io/tortio/` |

---

## Иконка приложения (Hi-res icon)

Поле в Console: **Store listing → App icon**

Файл: **`docs/play/icon-512.png`** (512×512 PNG, ~14 KB)

---

## Feature graphic

Поле: **Store listing → Feature graphic**

Файл: **`docs/play/feature-graphic-1024x500.png`** (1024×500 PNG, ~30 KB)

---

## Screenshots (телефон)

Минимум 2, максимум 8 на язык. У нас по 5-6 на каждый.

### English

Папка: **`docs/play/screenshots-en/`**

1. `01_welcome.png` — onboarding (опционально)
2. `03_list.png` — список с 3 sample-рецептами
3. `04_wedding.png` — multi-tier scaler (Wedding cake)
4. `05_scaler.png` — single-tier scaler (Chocolate cake)
5. `06_ingredients.png` — таблица пересчитанных ингредиентов

Рекомендуемый порядок загрузки в Play: **03_list → 04_wedding → 05_scaler → 06_ingredients → 01_welcome**.

### Russian

Папка: **`docs/play/screenshots-ru/`**

Те же 5 файлов (без welcome — она на английском, для ru загружай 4 без welcome).

---

## Short description (краткое — 80 chars max)

### English (78 chars)

```
Recipe scaling for cake makers — by size, weight, or tier. Local & private.
```

### Russian (74 chars)

```
Пересчёт рецептов тортов — по размеру, весу, ярусам. Локально и приватно.
```

---

## Full description (полное — 4000 chars max)

### English (~ 1700 chars)

```
Tortio is a recipe scaling app built specifically for cake makers — amateur or pro. Open a recipe, change the diameter or target weight, and every ingredient rescales automatically.

Key features:

• THREE SCALE MODES — Sponge & cream scale by volume (d²×h), icing & syrup by area (d²), decor stays fixed. Mathematically correct, not just × ratio.

• MULTI-TIER CAKES — Each tier has its own size and ingredients. Perfect for weddings, anniversaries, big celebrations.

• PRESET SECTIONS — Sponge, cream, filling, coating, ganache, syrup, mousse, meringue, glaze, decor. Add your own custom types.

• SHOPPING LIST — One tap, all ingredients summed up. Take it to the store.

• PDF EXPORT & SHARE — Send a clean technological card to a colleague or print it out.

• COOK COUNTER — Track how many times you've baked each recipe.

• PHOTOS, RATINGS, TAGS, NOTES — Organize your recipe collection.

• OPTIONAL CLOUD BACKUP — Sync via your own Google Drive (private, only you can see it). Or stay 100% offline.

• FREE — No ads, no subscriptions, no in-app purchases, no analytics, no tracking.

Privacy first: all your recipes live on your device. Cloud backup uses Google Drive's app-private folder — invisible even to other apps. We have no servers and never see your data.

Built by a confectioner-friendly developer for real kitchen use. Open source on GitHub.

Tortio is for you if:
- You scale recipes from 22 cm to 18 cm and need new gram amounts
- You bake tiered cakes and hate doing math twice
- You want a fast offline-first tool, not yet another bloated recipe app
- You care about ingredient ratios, not generic "1 cup of X"

Open to feedback — write to roman.karpenk@gmail.com or open an issue on github.com/ShadowOfTime1/tortio.
```

### Russian (~ 1900 chars)

```
Tortio — приложение для пересчёта рецептов тортов. Создано специально для кондитеров — любителей и профессионалов. Открой рецепт, поменяй диаметр или целевой вес — все ингредиенты пересчитаются автоматически.

Ключевые возможности:

• ТРИ РЕЖИМА МАСШТАБИРОВАНИЯ — Бисквит и крем масштабируются по объёму (d²×h), глазурь и пропитка по площади (d²), декор остаётся фиксированным. Математически правильно, а не просто × коэффициент.

• МНОГОЯРУСНЫЕ ТОРТЫ — У каждого яруса свой размер и состав. Идеально для свадеб, юбилеев, торжеств.

• ГОТОВЫЕ СЕКЦИИ — Бисквит, крем, начинка, покрытие, ганаш, пропитка, мусс, безе, глазурь, декор. Можно добавлять свои.

• СПИСОК ПОКУПОК — Одно касание — все ингредиенты сложены. Берёшь и идёшь в магазин.

• ЭКСПОРТ В PDF И ОТПРАВКА — Отправь технологическую карту коллеге или распечатай.

• СЧЁТЧИК ВЫПЕЧКИ — Отслеживай, сколько раз пекла каждый рецепт.

• ФОТО, РЕЙТИНГ, ТЕГИ, ЗАМЕТКИ — Организуй коллекцию рецептов.

• ОБЛАЧНЫЙ БЭКАП (опционально) — Синхронизация через твой собственный Google Drive (приватно, видно только тебе). Или работай 100% оффлайн.

• БЕСПЛАТНО — Без рекламы, подписок, встроенных покупок, аналитики, трекинга.

Приватность важна: все рецепты хранятся на твоём устройстве. Облачный бэкап использует приватную папку Google Drive — невидимую даже другим приложениям. У нас нет серверов и мы никогда не видим твои данные.

Сделано разработчиком для реальной кухни. Открытый исходный код на GitHub.

Tortio для тебя, если:
- Ты пересчитываешь рецепты с 22 см на 18 см и хочешь точные граммы
- Ты печёшь ярусные торты и не хочешь делать математику дважды
- Ты хочешь быстрый оффлайн-инструмент, а не очередное раздутое recipe-приложение
- Тебе важны пропорции ингредиентов, а не «1 стакан того-то»

Жду фидбек — пиши на roman.karpenk@gmail.com или открывай issue на github.com/ShadowOfTime1/tortio.
```

---

## Categorization

| Поле в Console | Значение |
|---|---|
| App or game | App |
| Category | Food & Drink |
| Tags | Recipes, Baking, Cooking |

## Content Rating questionnaire (примерные ответы)

Все вопросы → **No** (нет насилия, нет sexual, нет drugs, нет gambling, нет user-generated content публикуемого, нет шифрования специфического и т.п.).

Результат: **Everyone** / **3+**.

## Data Safety section (примерные ответы)

| Категория данных | Собирается? | Где? | Целевая группа |
|---|---|---|---|
| Personal info | Yes (Email — только если включён cloud backup) | Google Drive (юзеру) | App functionality |
| Photos | Yes (фото рецептов) | Только на устройстве + Google Drive (если backup) | App functionality |
| Files | Yes (рецепты) | Только на устройстве + Google Drive (если backup) | App functionality |
| App activity | No | — | — |
| Device IDs | No | — | — |

| Other questions | Answer |
|---|---|
| Is data collected? | Yes (Email + Photos + Files если cloud backup, иначе No) |
| Is data shared with 3rd parties? | **No** |
| Is data encrypted in transit? | **Yes** (HTTPS to Google Drive) |
| Can user request deletion? | **Yes** (uninstall + Google Drive → Manage apps) |

## App content
| Поле | Значение |
|---|---|
| Privacy Policy | https://shadowoftime1.github.io/tortio/privacy-policy/ |
| App access | All functionality available without restrictions |
| Ads | No |
| Content guidelines compliance | Yes |
| US Export laws compliance | Yes |
| Target audience | 18+ (Confectioners; not designed for children) |

---

## Release track — рекомендация

1. **Internal testing** (1-3 дня): загрузи AAB, добавь себя как тестера (по email), проверь установку из Play.
2. **Closed testing — Alpha** (опционально, 3-7 дней): пригласи 5-10 знакомых кондитеров, собери первый фидбек.
3. **Production** (после всех проверок): публикуешь, доступно всем.

## AAB файл

Готовый AAB лежит на GitHub Releases:
https://github.com/ShadowOfTime1/tortio/releases/tag/v0.1.0

Файл: **`app-release.aab`** (47.7 MB).

Скачай и грузи в Console через **Production / Internal testing → Create new release → Upload app bundle**.
