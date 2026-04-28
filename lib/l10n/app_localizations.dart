import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ru, this message translates to:
  /// **'Tortio'**
  String get appTitle;

  /// No description provided for @common_save.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get common_save;

  /// No description provided for @common_cancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get common_cancel;

  /// No description provided for @common_delete.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get common_delete;

  /// No description provided for @common_edit.
  ///
  /// In ru, this message translates to:
  /// **'Редактировать'**
  String get common_edit;

  /// No description provided for @common_close.
  ///
  /// In ru, this message translates to:
  /// **'Закрыть'**
  String get common_close;

  /// No description provided for @common_confirm.
  ///
  /// In ru, this message translates to:
  /// **'Подтвердить'**
  String get common_confirm;

  /// No description provided for @common_yes.
  ///
  /// In ru, this message translates to:
  /// **'Да'**
  String get common_yes;

  /// No description provided for @common_no.
  ///
  /// In ru, this message translates to:
  /// **'Нет'**
  String get common_no;

  /// No description provided for @common_ok.
  ///
  /// In ru, this message translates to:
  /// **'ОК'**
  String get common_ok;

  /// No description provided for @common_back.
  ///
  /// In ru, this message translates to:
  /// **'Назад'**
  String get common_back;

  /// No description provided for @common_done.
  ///
  /// In ru, this message translates to:
  /// **'Готово'**
  String get common_done;

  /// No description provided for @common_optional.
  ///
  /// In ru, this message translates to:
  /// **'необязательно'**
  String get common_optional;

  /// No description provided for @common_undo.
  ///
  /// In ru, this message translates to:
  /// **'Отменить'**
  String get common_undo;

  /// No description provided for @common_retry.
  ///
  /// In ru, this message translates to:
  /// **'Повторить'**
  String get common_retry;

  /// No description provided for @common_loading.
  ///
  /// In ru, this message translates to:
  /// **'Загрузка…'**
  String get common_loading;

  /// No description provided for @common_error.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка'**
  String get common_error;

  /// No description provided for @common_continue.
  ///
  /// In ru, this message translates to:
  /// **'Продолжить'**
  String get common_continue;

  /// No description provided for @common_skip.
  ///
  /// In ru, this message translates to:
  /// **'Пропустить'**
  String get common_skip;

  /// No description provided for @common_open.
  ///
  /// In ru, this message translates to:
  /// **'Открыть'**
  String get common_open;

  /// No description provided for @common_share.
  ///
  /// In ru, this message translates to:
  /// **'Поделиться'**
  String get common_share;

  /// No description provided for @unit_grams_short.
  ///
  /// In ru, this message translates to:
  /// **'г'**
  String get unit_grams_short;

  /// No description provided for @unit_kilograms_short.
  ///
  /// In ru, this message translates to:
  /// **'кг'**
  String get unit_kilograms_short;

  /// No description provided for @unit_centimeters_short.
  ///
  /// In ru, this message translates to:
  /// **'см'**
  String get unit_centimeters_short;

  /// No description provided for @unit_pieces_short.
  ///
  /// In ru, this message translates to:
  /// **'шт'**
  String get unit_pieces_short;

  /// No description provided for @unit_diameter_symbol.
  ///
  /// In ru, this message translates to:
  /// **'⌀'**
  String get unit_diameter_symbol;

  /// No description provided for @list_title.
  ///
  /// In ru, this message translates to:
  /// **'Рецепты'**
  String get list_title;

  /// No description provided for @list_search_hint.
  ///
  /// In ru, this message translates to:
  /// **'Поиск по названию или ингредиенту'**
  String get list_search_hint;

  /// No description provided for @list_empty_title.
  ///
  /// In ru, this message translates to:
  /// **'Пока ни одного торта'**
  String get list_empty_title;

  /// No description provided for @list_empty_subtitle.
  ///
  /// In ru, this message translates to:
  /// **'Добавьте свой первый торт!'**
  String get list_empty_subtitle;

  /// No description provided for @list_empty_demo_button.
  ///
  /// In ru, this message translates to:
  /// **'Создать примерные рецепты'**
  String get list_empty_demo_button;

  /// No description provided for @list_no_results_title.
  ///
  /// In ru, this message translates to:
  /// **'Ничего не найдено'**
  String get list_no_results_title;

  /// No description provided for @list_no_results_reset.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить фильтры'**
  String get list_no_results_reset;

  /// No description provided for @list_filter_all_tags.
  ///
  /// In ru, this message translates to:
  /// **'Все'**
  String get list_filter_all_tags;

  /// No description provided for @list_fab_new_recipe.
  ///
  /// In ru, this message translates to:
  /// **'Рецепт'**
  String get list_fab_new_recipe;

  /// No description provided for @list_section_count.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} секц.} few{{count} секц.} other{{count} секц.}}'**
  String list_section_count(int count);

  /// No description provided for @list_ingredient_count.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} ингр.} few{{count} ингр.} other{{count} ингр.}}'**
  String list_ingredient_count(int count);

  /// No description provided for @list_tier_count.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} ярус} few{{count} яруса} other{{count} ярусов}}'**
  String list_tier_count(int count);

  /// No description provided for @list_cooked_times.
  ///
  /// In ru, this message translates to:
  /// **'Готовили {count, plural, one{{count} раз} few{{count} раза} other{{count} раз}}'**
  String list_cooked_times(int count);

  /// No description provided for @list_cooked_days_ago.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, =0{сегодня} one{{count} дн. назад} few{{count} дн. назад} other{{count} дн. назад}}'**
  String list_cooked_days_ago(int count);

  /// No description provided for @list_badge_new.
  ///
  /// In ru, this message translates to:
  /// **'NEW'**
  String get list_badge_new;

  /// No description provided for @list_menu_edit.
  ///
  /// In ru, this message translates to:
  /// **'Редактировать'**
  String get list_menu_edit;

  /// No description provided for @list_menu_duplicate.
  ///
  /// In ru, this message translates to:
  /// **'Дублировать'**
  String get list_menu_duplicate;

  /// No description provided for @list_menu_pin.
  ///
  /// In ru, this message translates to:
  /// **'Закрепить'**
  String get list_menu_pin;

  /// No description provided for @list_menu_unpin.
  ///
  /// In ru, this message translates to:
  /// **'Открепить'**
  String get list_menu_unpin;

  /// No description provided for @list_menu_delete.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get list_menu_delete;

  /// No description provided for @list_menu_select_bulk.
  ///
  /// In ru, this message translates to:
  /// **'Выбрать (массовое удаление)'**
  String get list_menu_select_bulk;

  /// No description provided for @list_selection_count.
  ///
  /// In ru, this message translates to:
  /// **'Выбрано: {count}'**
  String list_selection_count(int count);

  /// No description provided for @list_recipe_deleted.
  ///
  /// In ru, this message translates to:
  /// **'Рецепт удалён'**
  String get list_recipe_deleted;

  /// No description provided for @list_recipe_named_deleted.
  ///
  /// In ru, this message translates to:
  /// **'«{title}» удалён'**
  String list_recipe_named_deleted(String title);

  /// No description provided for @list_bulk_delete_title.
  ///
  /// In ru, this message translates to:
  /// **'Удалить {count} рецепт(ов)?'**
  String list_bulk_delete_title(int count);

  /// No description provided for @list_bulk_delete_body.
  ///
  /// In ru, this message translates to:
  /// **'Все выбранные рецепты будут удалены безвозвратно.'**
  String get list_bulk_delete_body;

  /// No description provided for @list_bulk_deleted.
  ///
  /// In ru, this message translates to:
  /// **'Удалено: {count}'**
  String list_bulk_deleted(int count);

  /// No description provided for @list_tooltip_sort.
  ///
  /// In ru, this message translates to:
  /// **'Сортировка: {label}'**
  String list_tooltip_sort(String label);

  /// No description provided for @list_tooltip_settings.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get list_tooltip_settings;

  /// No description provided for @list_tooltip_cancel_selection.
  ///
  /// In ru, this message translates to:
  /// **'Отменить выбор'**
  String get list_tooltip_cancel_selection;

  /// No description provided for @list_tooltip_delete_selected.
  ///
  /// In ru, this message translates to:
  /// **'Удалить выбранные'**
  String get list_tooltip_delete_selected;

  /// No description provided for @list_no_results_filtered.
  ///
  /// In ru, this message translates to:
  /// **'нет рецептов {filters}'**
  String list_no_results_filtered(String filters);

  /// No description provided for @list_no_results_empty.
  ///
  /// In ru, this message translates to:
  /// **'ничего не найдено'**
  String get list_no_results_empty;

  /// No description provided for @list_filter_by_query.
  ///
  /// In ru, this message translates to:
  /// **'по запросу «{q}»'**
  String list_filter_by_query(String q);

  /// No description provided for @list_filter_by_tag.
  ///
  /// In ru, this message translates to:
  /// **'с тегом «{t}»'**
  String list_filter_by_tag(String t);

  /// No description provided for @time_today.
  ///
  /// In ru, this message translates to:
  /// **'сегодня'**
  String get time_today;

  /// No description provided for @time_yesterday.
  ///
  /// In ru, this message translates to:
  /// **'вчера'**
  String get time_yesterday;

  /// No description provided for @time_days_ago.
  ///
  /// In ru, this message translates to:
  /// **'{n} дн. назад'**
  String time_days_ago(int n);

  /// No description provided for @time_weeks_ago.
  ///
  /// In ru, this message translates to:
  /// **'{n} нед. назад'**
  String time_weeks_ago(int n);

  /// No description provided for @time_months_ago.
  ///
  /// In ru, this message translates to:
  /// **'{n} мес. назад'**
  String time_months_ago(int n);

  /// No description provided for @time_years_ago.
  ///
  /// In ru, this message translates to:
  /// **'{n} г. назад'**
  String time_years_ago(int n);

  /// No description provided for @list_card_summary.
  ///
  /// In ru, this message translates to:
  /// **'{diameter_sym} {diameter} {cm} • {sections} секц. • {ingredients} ингр.'**
  String list_card_summary(
    String diameter_sym,
    int diameter,
    String cm,
    int sections,
    int ingredients,
  );

  /// No description provided for @list_card_cooked.
  ///
  /// In ru, this message translates to:
  /// **'Готовили {count} раз{suffix}'**
  String list_card_cooked(int count, String suffix);

  /// No description provided for @list_recipe_duplicate_suffix.
  ///
  /// In ru, this message translates to:
  /// **'(копия)'**
  String get list_recipe_duplicate_suffix;

  /// No description provided for @list_sort_label.
  ///
  /// In ru, this message translates to:
  /// **'Сортировка'**
  String get list_sort_label;

  /// No description provided for @list_sort_manual.
  ///
  /// In ru, this message translates to:
  /// **'Вручную'**
  String get list_sort_manual;

  /// No description provided for @list_sort_newest.
  ///
  /// In ru, this message translates to:
  /// **'Новые сначала'**
  String get list_sort_newest;

  /// No description provided for @list_sort_oldest.
  ///
  /// In ru, this message translates to:
  /// **'Старые сначала'**
  String get list_sort_oldest;

  /// No description provided for @list_sort_alpha.
  ///
  /// In ru, this message translates to:
  /// **'По алфавиту'**
  String get list_sort_alpha;

  /// No description provided for @list_sort_rating.
  ///
  /// In ru, this message translates to:
  /// **'По рейтингу'**
  String get list_sort_rating;

  /// No description provided for @list_sort_cook_count.
  ///
  /// In ru, this message translates to:
  /// **'Чаще готовлю'**
  String get list_sort_cook_count;

  /// No description provided for @list_sort_recently_cooked.
  ///
  /// In ru, this message translates to:
  /// **'Недавно готовил'**
  String get list_sort_recently_cooked;

  /// No description provided for @list_menu_stats.
  ///
  /// In ru, this message translates to:
  /// **'Статистика'**
  String get list_menu_stats;

  /// No description provided for @form_title_new.
  ///
  /// In ru, this message translates to:
  /// **'Новый рецепт'**
  String get form_title_new;

  /// No description provided for @form_title_edit.
  ///
  /// In ru, this message translates to:
  /// **'Редактирование рецепта'**
  String get form_title_edit;

  /// No description provided for @form_field_title.
  ///
  /// In ru, this message translates to:
  /// **'Название'**
  String get form_field_title;

  /// No description provided for @form_field_diameter.
  ///
  /// In ru, this message translates to:
  /// **'Диаметр'**
  String get form_field_diameter;

  /// No description provided for @form_field_height.
  ///
  /// In ru, this message translates to:
  /// **'Высота'**
  String get form_field_height;

  /// No description provided for @form_field_weight.
  ///
  /// In ru, this message translates to:
  /// **'Вес'**
  String get form_field_weight;

  /// No description provided for @form_field_notes.
  ///
  /// In ru, this message translates to:
  /// **'Заметки'**
  String get form_field_notes;

  /// No description provided for @form_field_tags.
  ///
  /// In ru, this message translates to:
  /// **'Теги'**
  String get form_field_tags;

  /// No description provided for @form_field_tags_hint.
  ///
  /// In ru, this message translates to:
  /// **'через запятую'**
  String get form_field_tags_hint;

  /// No description provided for @form_field_ingredient.
  ///
  /// In ru, this message translates to:
  /// **'Ингредиент'**
  String get form_field_ingredient;

  /// No description provided for @form_field_amount.
  ///
  /// In ru, this message translates to:
  /// **'Кол-во'**
  String get form_field_amount;

  /// No description provided for @form_section_size_header.
  ///
  /// In ru, this message translates to:
  /// **'Размеры формы'**
  String get form_section_size_header;

  /// No description provided for @form_section_size_subtitle.
  ///
  /// In ru, this message translates to:
  /// **'(высота — опционально)'**
  String get form_section_size_subtitle;

  /// No description provided for @form_section_extras_header.
  ///
  /// In ru, this message translates to:
  /// **'Дополнительно'**
  String get form_section_extras_header;

  /// No description provided for @form_section_composition_header.
  ///
  /// In ru, this message translates to:
  /// **'Состав'**
  String get form_section_composition_header;

  /// No description provided for @form_add_section.
  ///
  /// In ru, this message translates to:
  /// **'Добавить секцию'**
  String get form_add_section;

  /// No description provided for @form_add_ingredient.
  ///
  /// In ru, this message translates to:
  /// **'Добавить ингредиент'**
  String get form_add_ingredient;

  /// No description provided for @form_add_tier.
  ///
  /// In ru, this message translates to:
  /// **'Добавить ярус'**
  String get form_add_tier;

  /// No description provided for @form_remove_tier.
  ///
  /// In ru, this message translates to:
  /// **'Удалить ярус'**
  String get form_remove_tier;

  /// No description provided for @form_tier_label.
  ///
  /// In ru, this message translates to:
  /// **'Ярус {n}'**
  String form_tier_label(int n);

  /// No description provided for @form_tier_name_optional.
  ///
  /// In ru, this message translates to:
  /// **'Название (опц)'**
  String get form_tier_name_optional;

  /// No description provided for @form_section_note_label.
  ///
  /// In ru, this message translates to:
  /// **'Заметка к секции'**
  String get form_section_note_label;

  /// No description provided for @form_rating_label.
  ///
  /// In ru, this message translates to:
  /// **'Личная оценка'**
  String get form_rating_label;

  /// No description provided for @form_rating_clear.
  ///
  /// In ru, this message translates to:
  /// **'Снять'**
  String get form_rating_clear;

  /// No description provided for @form_unsaved_dialog_title.
  ///
  /// In ru, this message translates to:
  /// **'Несохранённые изменения'**
  String get form_unsaved_dialog_title;

  /// No description provided for @form_unsaved_dialog_body.
  ///
  /// In ru, this message translates to:
  /// **'Вы внесли изменения. Выйти без сохранения?'**
  String get form_unsaved_dialog_body;

  /// No description provided for @form_unsaved_stay.
  ///
  /// In ru, this message translates to:
  /// **'Остаться'**
  String get form_unsaved_stay;

  /// No description provided for @form_unsaved_leave.
  ///
  /// In ru, this message translates to:
  /// **'Выйти'**
  String get form_unsaved_leave;

  /// No description provided for @form_error_title_required.
  ///
  /// In ru, this message translates to:
  /// **'Введите название рецепта'**
  String get form_error_title_required;

  /// No description provided for @form_error_diameter_required.
  ///
  /// In ru, this message translates to:
  /// **'Введите диаметр'**
  String get form_error_diameter_required;

  /// No description provided for @form_error_no_sections.
  ///
  /// In ru, this message translates to:
  /// **'Добавьте хотя бы одну секцию с ингредиентами'**
  String get form_error_no_sections;

  /// No description provided for @form_error_tiers_skipped.
  ///
  /// In ru, this message translates to:
  /// **'Ярус(ы) {numbers} пропущены: нет ингредиентов с весом > 0'**
  String form_error_tiers_skipped(String numbers);

  /// No description provided for @form_photo_pick.
  ///
  /// In ru, this message translates to:
  /// **'Из галереи'**
  String get form_photo_pick;

  /// No description provided for @form_photo_camera.
  ///
  /// In ru, this message translates to:
  /// **'Сделать фото'**
  String get form_photo_camera;

  /// No description provided for @form_photo_remove.
  ///
  /// In ru, this message translates to:
  /// **'Убрать фото'**
  String get form_photo_remove;

  /// No description provided for @form_photo_error_camera.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось открыть камеру: {err}'**
  String form_photo_error_camera(String err);

  /// No description provided for @form_photo_error_gallery.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось выбрать фото: {err}'**
  String form_photo_error_gallery(String err);

  /// No description provided for @form_photo_label.
  ///
  /// In ru, this message translates to:
  /// **'Фото'**
  String get form_photo_label;

  /// No description provided for @form_field_title_hint.
  ///
  /// In ru, this message translates to:
  /// **'Например: Шоколадный торт'**
  String get form_field_title_hint;

  /// No description provided for @form_field_diameter_short.
  ///
  /// In ru, this message translates to:
  /// **'Диаметр'**
  String get form_field_diameter_short;

  /// No description provided for @form_field_height_optional.
  ///
  /// In ru, this message translates to:
  /// **'опц.'**
  String get form_field_height_optional;

  /// No description provided for @form_field_weight_optional_label.
  ///
  /// In ru, this message translates to:
  /// **'Вес (необязательно)'**
  String get form_field_weight_optional_label;

  /// No description provided for @form_field_notes_label.
  ///
  /// In ru, this message translates to:
  /// **'Заметки / шаги (необязательно)'**
  String get form_field_notes_label;

  /// No description provided for @form_field_notes_hint.
  ///
  /// In ru, this message translates to:
  /// **'Например: испечь при 170°C 35 мин. Бисквит — за день до сборки.'**
  String get form_field_notes_hint;

  /// No description provided for @form_field_rating_label.
  ///
  /// In ru, this message translates to:
  /// **'Оценка'**
  String get form_field_rating_label;

  /// No description provided for @form_field_tags_label_optional.
  ///
  /// In ru, this message translates to:
  /// **'Теги (необязательно)'**
  String get form_field_tags_label_optional;

  /// No description provided for @form_field_tags_input_hint.
  ///
  /// In ru, this message translates to:
  /// **'шоколадный, без глютена'**
  String get form_field_tags_input_hint;

  /// No description provided for @form_field_tags_helper.
  ///
  /// In ru, this message translates to:
  /// **'Введи тег и нажми Enter (или через запятую)'**
  String get form_field_tags_helper;

  /// No description provided for @form_section_extras_subtitle.
  ///
  /// In ru, this message translates to:
  /// **'вес, заметки, оценка, теги'**
  String get form_section_extras_subtitle;

  /// No description provided for @form_tier_composition.
  ///
  /// In ru, this message translates to:
  /// **'Состав яруса'**
  String get form_tier_composition;

  /// No description provided for @form_section_button.
  ///
  /// In ru, this message translates to:
  /// **'Секция'**
  String get form_section_button;

  /// No description provided for @form_section_empty_title.
  ///
  /// In ru, this message translates to:
  /// **'Добавьте секцию'**
  String get form_section_empty_title;

  /// No description provided for @form_section_empty_hint.
  ///
  /// In ru, this message translates to:
  /// **'Бисквит, крем, начинка...'**
  String get form_section_empty_hint;

  /// No description provided for @form_section_note_hint.
  ///
  /// In ru, this message translates to:
  /// **'Заметка к секции (опционально)'**
  String get form_section_note_hint;

  /// No description provided for @form_section_scale_label.
  ///
  /// In ru, this message translates to:
  /// **'пересчёт: {label}'**
  String form_section_scale_label(String label);

  /// No description provided for @form_ingredient_hint.
  ///
  /// In ru, this message translates to:
  /// **'Ингредиент'**
  String get form_ingredient_hint;

  /// No description provided for @form_add_tier_first.
  ///
  /// In ru, this message translates to:
  /// **'Добавить ещё один ярус'**
  String get form_add_tier_first;

  /// No description provided for @form_add_tier_more.
  ///
  /// In ru, this message translates to:
  /// **'Ещё один ярус'**
  String get form_add_tier_more;

  /// No description provided for @form_error_no_ingredients.
  ///
  /// In ru, this message translates to:
  /// **'Заполните хотя бы один ингредиент с весом > 0'**
  String get form_error_no_ingredients;

  /// No description provided for @form_error_tiers_skipped_full.
  ///
  /// In ru, this message translates to:
  /// **'Ярус(ы) {numbers} пропущены: нет ингредиентов с весом > 0 или не заполнены размеры'**
  String form_error_tiers_skipped_full(String numbers);

  /// No description provided for @form_section_picker_title.
  ///
  /// In ru, this message translates to:
  /// **'Выберите секцию'**
  String get form_section_picker_title;

  /// No description provided for @form_section_picker_create_custom.
  ///
  /// In ru, this message translates to:
  /// **'Создать свой тип'**
  String get form_section_picker_create_custom;

  /// No description provided for @form_section_picker_custom_group.
  ///
  /// In ru, this message translates to:
  /// **'Свои типы'**
  String get form_section_picker_custom_group;

  /// No description provided for @form_section_picker_cat_base.
  ///
  /// In ru, this message translates to:
  /// **'Основа'**
  String get form_section_picker_cat_base;

  /// No description provided for @form_section_picker_cat_creams.
  ///
  /// In ru, this message translates to:
  /// **'Кремы и начинки'**
  String get form_section_picker_cat_creams;

  /// No description provided for @form_section_picker_cat_coatings.
  ///
  /// In ru, this message translates to:
  /// **'Покрытия и пропитки'**
  String get form_section_picker_cat_coatings;

  /// No description provided for @form_section_picker_cat_decor.
  ///
  /// In ru, this message translates to:
  /// **'Декор'**
  String get form_section_picker_cat_decor;

  /// No description provided for @form_custom_type_actions_title.
  ///
  /// In ru, this message translates to:
  /// **'Кастомный тип секции'**
  String get form_custom_type_actions_title;

  /// No description provided for @scaler_title_size.
  ///
  /// In ru, this message translates to:
  /// **'По размеру'**
  String get scaler_title_size;

  /// No description provided for @scaler_title_weight.
  ///
  /// In ru, this message translates to:
  /// **'По весу'**
  String get scaler_title_weight;

  /// No description provided for @scaler_target_diameter.
  ///
  /// In ru, this message translates to:
  /// **'Целевой диаметр'**
  String get scaler_target_diameter;

  /// No description provided for @scaler_target_height.
  ///
  /// In ru, this message translates to:
  /// **'Целевая высота'**
  String get scaler_target_height;

  /// No description provided for @scaler_target_weight.
  ///
  /// In ru, this message translates to:
  /// **'Целевой вес'**
  String get scaler_target_weight;

  /// No description provided for @scaler_total_weight.
  ///
  /// In ru, this message translates to:
  /// **'итого ≈ {grams}'**
  String scaler_total_weight(String grams);

  /// No description provided for @scaler_height_label_short.
  ///
  /// In ru, this message translates to:
  /// **'В'**
  String get scaler_height_label_short;

  /// No description provided for @scaler_height_label_full.
  ///
  /// In ru, this message translates to:
  /// **'Высота'**
  String get scaler_height_label_full;

  /// No description provided for @scaler_cooked_today.
  ///
  /// In ru, this message translates to:
  /// **'Записал! Готовите {n}-й раз'**
  String scaler_cooked_today(int n);

  /// No description provided for @scaler_cooked_button.
  ///
  /// In ru, this message translates to:
  /// **'Я приготовил'**
  String get scaler_cooked_button;

  /// No description provided for @scaler_share_text.
  ///
  /// In ru, this message translates to:
  /// **'Поделиться текстом'**
  String get scaler_share_text;

  /// No description provided for @scaler_share_pdf.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить как PDF'**
  String get scaler_share_pdf;

  /// No description provided for @scaler_shopping_list.
  ///
  /// In ru, this message translates to:
  /// **'Список покупок'**
  String get scaler_shopping_list;

  /// No description provided for @scaler_shopping_list_title.
  ///
  /// In ru, this message translates to:
  /// **'Список покупок'**
  String get scaler_shopping_list_title;

  /// No description provided for @scaler_shopping_list_total.
  ///
  /// In ru, this message translates to:
  /// **'итого {grams}'**
  String scaler_shopping_list_total(String grams);

  /// No description provided for @scaler_shopping_list_empty.
  ///
  /// In ru, this message translates to:
  /// **'Ингредиентов нет'**
  String get scaler_shopping_list_empty;

  /// No description provided for @scaler_total_label.
  ///
  /// In ru, this message translates to:
  /// **'пересчёт'**
  String get scaler_total_label;

  /// No description provided for @scaler_export_tooltip.
  ///
  /// In ru, this message translates to:
  /// **'Экспорт'**
  String get scaler_export_tooltip;

  /// No description provided for @scaler_export_share_text.
  ///
  /// In ru, this message translates to:
  /// **'Поделиться текстом'**
  String get scaler_export_share_text;

  /// No description provided for @scaler_export_save_pdf.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить как PDF'**
  String get scaler_export_save_pdf;

  /// No description provided for @scaler_pdf_error.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка PDF: {err}'**
  String scaler_pdf_error(String err);

  /// No description provided for @scaler_cooked_first.
  ///
  /// In ru, this message translates to:
  /// **'Записал! Первый раз 🎂'**
  String get scaler_cooked_first;

  /// No description provided for @scaler_original_size.
  ///
  /// In ru, this message translates to:
  /// **'Оригинал: {sym} {d} {cm}'**
  String scaler_original_size(String sym, int d, String cm);

  /// No description provided for @scaler_original_size_with_height.
  ///
  /// In ru, this message translates to:
  /// **'Оригинал: {sym} {d}×{h} {cm}'**
  String scaler_original_size_with_height(String sym, int d, int h, String cm);

  /// No description provided for @scaler_original_size_with_height_weight.
  ///
  /// In ru, this message translates to:
  /// **'Оригинал: {sym} {d}×{h} {cm} • {weight}'**
  String scaler_original_size_with_height_weight(
    String sym,
    int d,
    int h,
    String cm,
    String weight,
  );

  /// No description provided for @scaler_original_size_weight.
  ///
  /// In ru, this message translates to:
  /// **'Оригинал: {sym} {d} {cm} • {weight}'**
  String scaler_original_size_weight(
    String sym,
    int d,
    String cm,
    String weight,
  );

  /// No description provided for @scaler_original_weight.
  ///
  /// In ru, this message translates to:
  /// **'Оригинал: {weight}'**
  String scaler_original_weight(String weight);

  /// No description provided for @scaler_tier_label_named.
  ///
  /// In ru, this message translates to:
  /// **'Ярус {n}: {label}'**
  String scaler_tier_label_named(int n, String label);

  /// No description provided for @scaler_tier_label.
  ///
  /// In ru, this message translates to:
  /// **'Ярус {n}'**
  String scaler_tier_label(int n);

  /// No description provided for @scaler_tiers_total.
  ///
  /// In ru, this message translates to:
  /// **'{tiers} ярус(ов) • итого {weight}'**
  String scaler_tiers_total(int tiers, String weight);

  /// No description provided for @share_diameter.
  ///
  /// In ru, this message translates to:
  /// **'{sym} {d} {cm}'**
  String share_diameter(String sym, int d, String cm);

  /// No description provided for @share_height.
  ///
  /// In ru, this message translates to:
  /// **'высота {h} {cm}'**
  String share_height(int h, String cm);

  /// No description provided for @share_notes_header.
  ///
  /// In ru, this message translates to:
  /// **'📝 Заметки'**
  String get share_notes_header;

  /// No description provided for @share_total_approx.
  ///
  /// In ru, this message translates to:
  /// **'~{weight}'**
  String share_total_approx(String weight);

  /// No description provided for @pdf_subtitle_multitier.
  ///
  /// In ru, this message translates to:
  /// **'{tiers} ярус(ов) • итого ≈ {weight}'**
  String pdf_subtitle_multitier(int tiers, String weight);

  /// No description provided for @pdf_subtitle_size_h.
  ///
  /// In ru, this message translates to:
  /// **'⌀ {d}×{h} {cm} • итого ≈ {weight}'**
  String pdf_subtitle_size_h(int d, int h, String cm, String weight);

  /// No description provided for @pdf_subtitle_size.
  ///
  /// In ru, this message translates to:
  /// **'⌀ {d} {cm} • итого ≈ {weight}'**
  String pdf_subtitle_size(int d, String cm, String weight);

  /// No description provided for @pdf_tier_summary_h.
  ///
  /// In ru, this message translates to:
  /// **'{label} • ⌀ {d}×{h} {cm} • {weight}'**
  String pdf_tier_summary_h(
    String label,
    int d,
    int h,
    String cm,
    String weight,
  );

  /// No description provided for @pdf_tier_summary.
  ///
  /// In ru, this message translates to:
  /// **'{label} • ⌀ {d} {cm} • {weight}'**
  String pdf_tier_summary(String label, int d, String cm, String weight);

  /// No description provided for @settings_title.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get settings_title;

  /// No description provided for @settings_group_appearance.
  ///
  /// In ru, this message translates to:
  /// **'Внешний вид'**
  String get settings_group_appearance;

  /// No description provided for @settings_group_behavior.
  ///
  /// In ru, this message translates to:
  /// **'Поведение'**
  String get settings_group_behavior;

  /// No description provided for @settings_group_cloud.
  ///
  /// In ru, this message translates to:
  /// **'Облачный бэкап'**
  String get settings_group_cloud;

  /// No description provided for @settings_group_backup.
  ///
  /// In ru, this message translates to:
  /// **'Резервные копии'**
  String get settings_group_backup;

  /// No description provided for @settings_group_data.
  ///
  /// In ru, this message translates to:
  /// **'Данные'**
  String get settings_group_data;

  /// No description provided for @settings_group_danger.
  ///
  /// In ru, this message translates to:
  /// **'Опасная зона'**
  String get settings_group_danger;

  /// No description provided for @settings_group_about.
  ///
  /// In ru, this message translates to:
  /// **'О приложении'**
  String get settings_group_about;

  /// No description provided for @settings_theme.
  ///
  /// In ru, this message translates to:
  /// **'Тема'**
  String get settings_theme;

  /// No description provided for @settings_theme_auto.
  ///
  /// In ru, this message translates to:
  /// **'Авто (день — светлая, вечер — тёмная)'**
  String get settings_theme_auto;

  /// No description provided for @settings_theme_light.
  ///
  /// In ru, this message translates to:
  /// **'Светлая'**
  String get settings_theme_light;

  /// No description provided for @settings_theme_dark.
  ///
  /// In ru, this message translates to:
  /// **'Тёмная'**
  String get settings_theme_dark;

  /// No description provided for @settings_language.
  ///
  /// In ru, this message translates to:
  /// **'Язык'**
  String get settings_language;

  /// No description provided for @settings_language_system.
  ///
  /// In ru, this message translates to:
  /// **'Системный'**
  String get settings_language_system;

  /// No description provided for @settings_language_ru.
  ///
  /// In ru, this message translates to:
  /// **'Русский'**
  String get settings_language_ru;

  /// No description provided for @settings_language_en.
  ///
  /// In ru, this message translates to:
  /// **'English'**
  String get settings_language_en;

  /// No description provided for @settings_quick_diameters.
  ///
  /// In ru, this message translates to:
  /// **'Быстрые диаметры'**
  String get settings_quick_diameters;

  /// No description provided for @settings_quick_diameters_hint.
  ///
  /// In ru, this message translates to:
  /// **'Через запятую, см'**
  String get settings_quick_diameters_hint;

  /// No description provided for @settings_quick_diameters_helper.
  ///
  /// In ru, this message translates to:
  /// **'Эти числа показываются как кнопки-чипы под слайдером диаметра на экране пересчёта.'**
  String get settings_quick_diameters_helper;

  /// No description provided for @settings_quick_diameters_saved.
  ///
  /// In ru, this message translates to:
  /// **'Быстрые диаметры сохранены'**
  String get settings_quick_diameters_saved;

  /// No description provided for @settings_default_mode_size_title.
  ///
  /// In ru, this message translates to:
  /// **'По умолчанию: По размеру'**
  String get settings_default_mode_size_title;

  /// No description provided for @settings_default_mode_weight_title.
  ///
  /// In ru, this message translates to:
  /// **'По умолчанию: По весу'**
  String get settings_default_mode_weight_title;

  /// No description provided for @settings_default_mode_weight_subtitle.
  ///
  /// In ru, this message translates to:
  /// **'Только если у рецепта указан вес'**
  String get settings_default_mode_weight_subtitle;

  /// No description provided for @settings_auto_update_subtitle.
  ///
  /// In ru, this message translates to:
  /// **'При запуске приложение спрашивает GitHub о новой версии'**
  String get settings_auto_update_subtitle;

  /// No description provided for @settings_export_done.
  ///
  /// In ru, this message translates to:
  /// **'Экспортировано'**
  String get settings_export_done;

  /// No description provided for @settings_export_empty.
  ///
  /// In ru, this message translates to:
  /// **'Нечего экспортировать — список пустой'**
  String get settings_export_empty;

  /// No description provided for @settings_export_error.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка экспорта: {err}'**
  String settings_export_error(String err);

  /// No description provided for @settings_import_nothing.
  ///
  /// In ru, this message translates to:
  /// **'Ничего не импортировано'**
  String get settings_import_nothing;

  /// No description provided for @settings_import_count.
  ///
  /// In ru, this message translates to:
  /// **'Импортировано: {count}'**
  String settings_import_count(int count);

  /// No description provided for @settings_import_error_with.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка импорта: {err}'**
  String settings_import_error_with(String err);

  /// No description provided for @settings_open_link_failed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось открыть ссылку'**
  String get settings_open_link_failed;

  /// No description provided for @settings_no_custom_types.
  ///
  /// In ru, this message translates to:
  /// **'Нет кастомных типов'**
  String get settings_no_custom_types;

  /// No description provided for @settings_custom_type_scale_label.
  ///
  /// In ru, this message translates to:
  /// **'масштаб: {name}'**
  String settings_custom_type_scale_label(String name);

  /// No description provided for @settings_reset_dialog_title.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить настройки?'**
  String get settings_reset_dialog_title;

  /// No description provided for @settings_reset_dialog_body.
  ///
  /// In ru, this message translates to:
  /// **'Тема, сортировка, авто-проверка обновлений, default-режим пересчёта и быстрые диаметры вернутся к дефолтам. Рецепты и кастомные типы секций НЕ затронутся.'**
  String get settings_reset_dialog_body;

  /// No description provided for @settings_reset_action.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить'**
  String get settings_reset_action;

  /// No description provided for @settings_reset_subtitle.
  ///
  /// In ru, this message translates to:
  /// **'Тема, сортировка, авто-обновление, default режим, быстрые диаметры. Рецепты не трогаются.'**
  String get settings_reset_subtitle;

  /// No description provided for @settings_delete_all_action.
  ///
  /// In ru, this message translates to:
  /// **'Удалить всё'**
  String get settings_delete_all_action;

  /// No description provided for @settings_delete_all_full_body.
  ///
  /// In ru, this message translates to:
  /// **'Все рецепты, кастомные типы секций и snapshot импорта будут удалены безвозвратно. Резервная копия предыдущего сохранения тоже исчезнет. Уверен?'**
  String get settings_delete_all_full_body;

  /// No description provided for @settings_check_update_done.
  ///
  /// In ru, this message translates to:
  /// **'Установлена последняя версия'**
  String get settings_check_update_done;

  /// No description provided for @settings_check_update_available.
  ///
  /// In ru, this message translates to:
  /// **'Доступна v{version}. Открой приложение заново — появится баннер с обновлением.'**
  String settings_check_update_available(String version);

  /// No description provided for @settings_show_welcome_again_subtitle.
  ///
  /// In ru, this message translates to:
  /// **'Краткий тур по приложению'**
  String get settings_show_welcome_again_subtitle;

  /// No description provided for @settings_version_label.
  ///
  /// In ru, this message translates to:
  /// **'Версия'**
  String get settings_version_label;

  /// No description provided for @settings_license_label.
  ///
  /// In ru, this message translates to:
  /// **'Лицензия'**
  String get settings_license_label;

  /// No description provided for @settings_license_value.
  ///
  /// In ru, this message translates to:
  /// **'MIT'**
  String get settings_license_value;

  /// No description provided for @settings_github_source.
  ///
  /// In ru, this message translates to:
  /// **'Исходники на GitHub'**
  String get settings_github_source;

  /// No description provided for @settings_show_stats.
  ///
  /// In ru, this message translates to:
  /// **'Показать статистику'**
  String get settings_show_stats;

  /// No description provided for @settings_import_undo_action.
  ///
  /// In ru, this message translates to:
  /// **'Откатить последний импорт'**
  String get settings_import_undo_action;

  /// No description provided for @settings_save_action.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get settings_save_action;

  /// No description provided for @stats_title.
  ///
  /// In ru, this message translates to:
  /// **'Статистика'**
  String get stats_title;

  /// No description provided for @stats_recipes.
  ///
  /// In ru, this message translates to:
  /// **'Рецептов'**
  String get stats_recipes;

  /// No description provided for @stats_ingredients.
  ///
  /// In ru, this message translates to:
  /// **'Ингредиентов всего'**
  String get stats_ingredients;

  /// No description provided for @stats_total_recipe_weights.
  ///
  /// In ru, this message translates to:
  /// **'Сумма весов рецептов'**
  String get stats_total_recipe_weights;

  /// No description provided for @stats_top_ingredients_header.
  ///
  /// In ru, this message translates to:
  /// **'ТОП ИНГРЕДИЕНТОВ'**
  String get stats_top_ingredients_header;

  /// No description provided for @stats_top_tags_header.
  ///
  /// In ru, this message translates to:
  /// **'ТОП ТЕГОВ'**
  String get stats_top_tags_header;

  /// No description provided for @custom_type_dialog_new.
  ///
  /// In ru, this message translates to:
  /// **'Новый тип секции'**
  String get custom_type_dialog_new;

  /// No description provided for @custom_type_dialog_edit.
  ///
  /// In ru, this message translates to:
  /// **'Изменить тип секции'**
  String get custom_type_dialog_edit;

  /// No description provided for @custom_type_field_name.
  ///
  /// In ru, this message translates to:
  /// **'Название'**
  String get custom_type_field_name;

  /// No description provided for @custom_type_field_name_hint.
  ///
  /// In ru, this message translates to:
  /// **'Например, Маршмеллоу'**
  String get custom_type_field_name_hint;

  /// No description provided for @custom_type_field_icon.
  ///
  /// In ru, this message translates to:
  /// **'Иконка (эмодзи)'**
  String get custom_type_field_icon;

  /// No description provided for @custom_type_field_scale_label.
  ///
  /// In ru, this message translates to:
  /// **'Как масштабировать'**
  String get custom_type_field_scale_label;

  /// No description provided for @custom_type_scale_volume.
  ///
  /// In ru, this message translates to:
  /// **'По объёму (d² × h)'**
  String get custom_type_scale_volume;

  /// No description provided for @custom_type_scale_area.
  ///
  /// In ru, this message translates to:
  /// **'По площади (d²)'**
  String get custom_type_scale_area;

  /// No description provided for @custom_type_scale_fixed.
  ///
  /// In ru, this message translates to:
  /// **'Фикс (не меняется)'**
  String get custom_type_scale_fixed;

  /// No description provided for @scale_label_volume.
  ///
  /// In ru, this message translates to:
  /// **'объём'**
  String get scale_label_volume;

  /// No description provided for @scale_label_area.
  ///
  /// In ru, this message translates to:
  /// **'площадь'**
  String get scale_label_area;

  /// No description provided for @scale_label_fixed.
  ///
  /// In ru, this message translates to:
  /// **'фикс'**
  String get scale_label_fixed;

  /// No description provided for @preset_sponge.
  ///
  /// In ru, this message translates to:
  /// **'Бисквит'**
  String get preset_sponge;

  /// No description provided for @preset_cream.
  ///
  /// In ru, this message translates to:
  /// **'Крем'**
  String get preset_cream;

  /// No description provided for @preset_filling.
  ///
  /// In ru, this message translates to:
  /// **'Начинка'**
  String get preset_filling;

  /// No description provided for @preset_coating.
  ///
  /// In ru, this message translates to:
  /// **'Покрытие'**
  String get preset_coating;

  /// No description provided for @preset_ganache.
  ///
  /// In ru, this message translates to:
  /// **'Ганаш'**
  String get preset_ganache;

  /// No description provided for @preset_syrup.
  ///
  /// In ru, this message translates to:
  /// **'Пропитка'**
  String get preset_syrup;

  /// No description provided for @preset_mousse.
  ///
  /// In ru, this message translates to:
  /// **'Мусс'**
  String get preset_mousse;

  /// No description provided for @preset_meringue.
  ///
  /// In ru, this message translates to:
  /// **'Безе'**
  String get preset_meringue;

  /// No description provided for @preset_glaze.
  ///
  /// In ru, this message translates to:
  /// **'Глазурь'**
  String get preset_glaze;

  /// No description provided for @preset_decor.
  ///
  /// In ru, this message translates to:
  /// **'Декор'**
  String get preset_decor;

  /// No description provided for @custom_type_create.
  ///
  /// In ru, this message translates to:
  /// **'Создать'**
  String get custom_type_create;

  /// No description provided for @custom_type_used_dialog_title.
  ///
  /// In ru, this message translates to:
  /// **'Удалить тип «{name}»?'**
  String custom_type_used_dialog_title(String name);

  /// No description provided for @custom_type_used_dialog_body.
  ///
  /// In ru, this message translates to:
  /// **'Этот тип используется в {count} рецепте(ах):\n\n{names}\n\nУже сохранённые секции продолжат работать как есть. Но добавить новые секции этого типа будет нельзя.'**
  String custom_type_used_dialog_body(int count, String names);

  /// No description provided for @custom_type_more.
  ///
  /// In ru, this message translates to:
  /// **'... и ещё {n}'**
  String custom_type_more(int n);

  /// No description provided for @custom_type_force_delete.
  ///
  /// In ru, this message translates to:
  /// **'Всё равно удалить'**
  String get custom_type_force_delete;

  /// No description provided for @settings_default_scale_mode.
  ///
  /// In ru, this message translates to:
  /// **'Режим пересчёта по умолчанию'**
  String get settings_default_scale_mode;

  /// No description provided for @settings_default_scale_mode_size.
  ///
  /// In ru, this message translates to:
  /// **'По размеру'**
  String get settings_default_scale_mode_size;

  /// No description provided for @settings_default_scale_mode_weight.
  ///
  /// In ru, this message translates to:
  /// **'По весу'**
  String get settings_default_scale_mode_weight;

  /// No description provided for @settings_custom_types.
  ///
  /// In ru, this message translates to:
  /// **'Кастомные типы секций'**
  String get settings_custom_types;

  /// No description provided for @settings_custom_types_add.
  ///
  /// In ru, this message translates to:
  /// **'Добавить тип'**
  String get settings_custom_types_add;

  /// No description provided for @settings_custom_type_in_use_title.
  ///
  /// In ru, this message translates to:
  /// **'Тип используется'**
  String get settings_custom_type_in_use_title;

  /// No description provided for @settings_custom_type_in_use_body.
  ///
  /// In ru, this message translates to:
  /// **'Этот тип используется в {count} рецепт(ах). Уже сохранённые секции продолжат работать, но добавить новые будет нельзя.'**
  String settings_custom_type_in_use_body(int count);

  /// No description provided for @settings_auto_update.
  ///
  /// In ru, this message translates to:
  /// **'Автоматически проверять обновления'**
  String get settings_auto_update;

  /// No description provided for @settings_check_update_now.
  ///
  /// In ru, this message translates to:
  /// **'Проверить обновление сейчас'**
  String get settings_check_update_now;

  /// No description provided for @settings_update_no_new.
  ///
  /// In ru, this message translates to:
  /// **'У вас актуальная версия'**
  String get settings_update_no_new;

  /// No description provided for @settings_update_found.
  ///
  /// In ru, this message translates to:
  /// **'Доступна версия {version}'**
  String settings_update_found(String version);

  /// No description provided for @settings_cloud_connect.
  ///
  /// In ru, this message translates to:
  /// **'Подключить Google Drive'**
  String get settings_cloud_connect;

  /// No description provided for @settings_cloud_connect_subtitle.
  ///
  /// In ru, this message translates to:
  /// **'Автоматический бэкап рецептов'**
  String get settings_cloud_connect_subtitle;

  /// No description provided for @settings_cloud_connected.
  ///
  /// In ru, this message translates to:
  /// **'Подключено'**
  String get settings_cloud_connected;

  /// No description provided for @settings_cloud_email.
  ///
  /// In ru, this message translates to:
  /// **'Аккаунт'**
  String get settings_cloud_email;

  /// No description provided for @settings_cloud_last_sync.
  ///
  /// In ru, this message translates to:
  /// **'Последняя синхронизация: {when}'**
  String settings_cloud_last_sync(String when);

  /// No description provided for @settings_cloud_never_synced.
  ///
  /// In ru, this message translates to:
  /// **'Ещё не синхронизировано'**
  String get settings_cloud_never_synced;

  /// No description provided for @settings_cloud_sync_now.
  ///
  /// In ru, this message translates to:
  /// **'Синхронизировать сейчас'**
  String get settings_cloud_sync_now;

  /// No description provided for @settings_cloud_restore.
  ///
  /// In ru, this message translates to:
  /// **'Восстановить из облака'**
  String get settings_cloud_restore;

  /// No description provided for @settings_cloud_sign_out.
  ///
  /// In ru, this message translates to:
  /// **'Выйти'**
  String get settings_cloud_sign_out;

  /// No description provided for @settings_cloud_busy.
  ///
  /// In ru, this message translates to:
  /// **'Подождите…'**
  String get settings_cloud_busy;

  /// No description provided for @settings_cloud_restore_prompt_title.
  ///
  /// In ru, this message translates to:
  /// **'Восстановить из бэкапа?'**
  String get settings_cloud_restore_prompt_title;

  /// No description provided for @settings_cloud_restore_prompt_body.
  ///
  /// In ru, this message translates to:
  /// **'Найден бэкап от {when}. Восстановить?'**
  String settings_cloud_restore_prompt_body(String when);

  /// No description provided for @settings_cloud_restore_keep_local.
  ///
  /// In ru, this message translates to:
  /// **'Нет, оставить локальные'**
  String get settings_cloud_restore_keep_local;

  /// No description provided for @settings_cloud_restore_replace.
  ///
  /// In ru, this message translates to:
  /// **'Восстановить'**
  String get settings_cloud_restore_replace;

  /// No description provided for @settings_cloud_restore_done.
  ///
  /// In ru, this message translates to:
  /// **'Восстановлено {count} рецепт(ов)'**
  String settings_cloud_restore_done(int count);

  /// No description provided for @settings_export.
  ///
  /// In ru, this message translates to:
  /// **'Экспортировать в JSON'**
  String get settings_export;

  /// No description provided for @settings_import.
  ///
  /// In ru, this message translates to:
  /// **'Импортировать из JSON'**
  String get settings_import;

  /// No description provided for @settings_import_undo.
  ///
  /// In ru, this message translates to:
  /// **'Откатить последний импорт'**
  String get settings_import_undo;

  /// No description provided for @settings_import_done.
  ///
  /// In ru, this message translates to:
  /// **'Импортировано {count} рецепт(ов)'**
  String settings_import_done(int count);

  /// No description provided for @settings_import_undone.
  ///
  /// In ru, this message translates to:
  /// **'Импорт отменён'**
  String get settings_import_undone;

  /// No description provided for @settings_import_error.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось прочитать файл'**
  String get settings_import_error;

  /// No description provided for @settings_stats.
  ///
  /// In ru, this message translates to:
  /// **'Статистика'**
  String get settings_stats;

  /// No description provided for @settings_show_welcome_again.
  ///
  /// In ru, this message translates to:
  /// **'Показать приветствие снова'**
  String get settings_show_welcome_again;

  /// No description provided for @settings_reset_settings.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить настройки до дефолтов'**
  String get settings_reset_settings;

  /// No description provided for @settings_reset_settings_done.
  ///
  /// In ru, this message translates to:
  /// **'Настройки сброшены'**
  String get settings_reset_settings_done;

  /// No description provided for @settings_delete_all.
  ///
  /// In ru, this message translates to:
  /// **'Удалить все рецепты и кастомные типы'**
  String get settings_delete_all;

  /// No description provided for @settings_delete_all_confirm_title.
  ///
  /// In ru, this message translates to:
  /// **'Удалить всё?'**
  String get settings_delete_all_confirm_title;

  /// No description provided for @settings_delete_all_confirm_body.
  ///
  /// In ru, this message translates to:
  /// **'Будут удалены все рецепты и кастомные типы. Действие необратимо.'**
  String get settings_delete_all_confirm_body;

  /// No description provided for @settings_delete_all_done.
  ///
  /// In ru, this message translates to:
  /// **'Всё удалено'**
  String get settings_delete_all_done;

  /// No description provided for @about_version.
  ///
  /// In ru, this message translates to:
  /// **'Версия {v}'**
  String about_version(String v);

  /// No description provided for @about_repo.
  ///
  /// In ru, this message translates to:
  /// **'Исходный код на GitHub'**
  String get about_repo;

  /// No description provided for @about_license.
  ///
  /// In ru, this message translates to:
  /// **'Лицензия: MIT'**
  String get about_license;

  /// No description provided for @stats_recipes_total.
  ///
  /// In ru, this message translates to:
  /// **'Всего рецептов'**
  String get stats_recipes_total;

  /// No description provided for @stats_ingredients_total.
  ///
  /// In ru, this message translates to:
  /// **'Всего ингредиентов'**
  String get stats_ingredients_total;

  /// No description provided for @stats_total_weight.
  ///
  /// In ru, this message translates to:
  /// **'Сумма весов рецептов'**
  String get stats_total_weight;

  /// No description provided for @stats_top_ingredients.
  ///
  /// In ru, this message translates to:
  /// **'Топ-5 ингредиентов'**
  String get stats_top_ingredients;

  /// No description provided for @stats_top_tags.
  ///
  /// In ru, this message translates to:
  /// **'Топ-5 тегов'**
  String get stats_top_tags;

  /// No description provided for @welcome_title.
  ///
  /// In ru, this message translates to:
  /// **'Привет, кондитер!'**
  String get welcome_title;

  /// No description provided for @welcome_subtitle.
  ///
  /// In ru, this message translates to:
  /// **'Tortio пересчитает ингредиенты под нужный размер торта.'**
  String get welcome_subtitle;

  /// No description provided for @welcome_bullet_add.
  ///
  /// In ru, this message translates to:
  /// **'Кнопка «+ Рецепт» снизу — добавить новый. Можно начать с готового примера.'**
  String get welcome_bullet_add;

  /// No description provided for @welcome_bullet_scale.
  ///
  /// In ru, this message translates to:
  /// **'Открыл рецепт → меняй диаметр или вес → ингредиенты пересчитываются автоматически.'**
  String get welcome_bullet_scale;

  /// No description provided for @welcome_bullet_tiers.
  ///
  /// In ru, this message translates to:
  /// **'Многоярусный торт? Добавь ярус прямо в форме рецепта — у каждого свой размер.'**
  String get welcome_bullet_tiers;

  /// No description provided for @welcome_bullet_sort.
  ///
  /// In ru, this message translates to:
  /// **'↕ — сортировка списка. ⚙ — настройки (тема, бэкапы, статистика).'**
  String get welcome_bullet_sort;

  /// No description provided for @welcome_bullet_inside.
  ///
  /// In ru, this message translates to:
  /// **'Внутри рецепта: ✓ «Я приготовил», ↗ «Экспорт» (PDF / шаринг), 🛒 «Список покупок».'**
  String get welcome_bullet_inside;

  /// No description provided for @welcome_button_start.
  ///
  /// In ru, this message translates to:
  /// **'Начать!'**
  String get welcome_button_start;

  /// No description provided for @snack_recipe_saved.
  ///
  /// In ru, this message translates to:
  /// **'Рецепт сохранён'**
  String get snack_recipe_saved;

  /// No description provided for @snack_export_done.
  ///
  /// In ru, this message translates to:
  /// **'Экспортировано'**
  String get snack_export_done;

  /// No description provided for @snack_no_internet.
  ///
  /// In ru, this message translates to:
  /// **'Нет интернета'**
  String get snack_no_internet;

  /// No description provided for @snack_drive_connected.
  ///
  /// In ru, this message translates to:
  /// **'Google Drive подключён'**
  String get snack_drive_connected;

  /// No description provided for @snack_drive_uploaded.
  ///
  /// In ru, this message translates to:
  /// **'Загружено в облако'**
  String get snack_drive_uploaded;

  /// No description provided for @snack_drive_failed.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка облака. Попробуйте позже'**
  String get snack_drive_failed;

  /// No description provided for @update_banner_available.
  ///
  /// In ru, this message translates to:
  /// **'Версия {version} доступна'**
  String update_banner_available(String version);

  /// No description provided for @update_banner_tap.
  ///
  /// In ru, this message translates to:
  /// **'Нажмите чтобы обновить'**
  String get update_banner_tap;

  /// No description provided for @update_banner_downloading.
  ///
  /// In ru, this message translates to:
  /// **'Скачивание... {percent}%'**
  String update_banner_downloading(int percent);

  /// No description provided for @update_error_generic.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка обновления. Проверьте интернет.'**
  String get update_error_generic;

  /// No description provided for @update_error_no_internet.
  ///
  /// In ru, this message translates to:
  /// **'Нет интернета. Проверьте подключение.'**
  String get update_error_no_internet;

  /// No description provided for @update_error_install_permission.
  ///
  /// In ru, this message translates to:
  /// **'Нужно разрешить установку из неизвестных источников в настройках Android.'**
  String get update_error_install_permission;

  /// No description provided for @sample_title.
  ///
  /// In ru, this message translates to:
  /// **'Шоколадный торт (пример)'**
  String get sample_title;

  /// No description provided for @sample_notes.
  ///
  /// In ru, this message translates to:
  /// **'Печь бисквит при 180°C 35–40 мин. Дать остыть, разрезать на 2 коржа. Прослоить кремом, покрыть глазурью.'**
  String get sample_notes;

  /// No description provided for @sample_sponge_notes.
  ///
  /// In ru, this message translates to:
  /// **'Просеять муку с какао перед смешиванием'**
  String get sample_sponge_notes;

  /// No description provided for @sample_tag_chocolate.
  ///
  /// In ru, this message translates to:
  /// **'шоколадный'**
  String get sample_tag_chocolate;

  /// No description provided for @sample_tag_sample.
  ///
  /// In ru, this message translates to:
  /// **'пример'**
  String get sample_tag_sample;

  /// No description provided for @sample_ing_flour.
  ///
  /// In ru, this message translates to:
  /// **'Мука'**
  String get sample_ing_flour;

  /// No description provided for @sample_ing_cocoa.
  ///
  /// In ru, this message translates to:
  /// **'Какао'**
  String get sample_ing_cocoa;

  /// No description provided for @sample_ing_sugar.
  ///
  /// In ru, this message translates to:
  /// **'Сахар'**
  String get sample_ing_sugar;

  /// No description provided for @sample_ing_eggs.
  ///
  /// In ru, this message translates to:
  /// **'Яйца'**
  String get sample_ing_eggs;

  /// No description provided for @sample_ing_butter.
  ///
  /// In ru, this message translates to:
  /// **'Сливочное масло'**
  String get sample_ing_butter;

  /// No description provided for @sample_ing_cream33.
  ///
  /// In ru, this message translates to:
  /// **'Сливки 33%'**
  String get sample_ing_cream33;

  /// No description provided for @sample_ing_powdered_sugar.
  ///
  /// In ru, this message translates to:
  /// **'Сахарная пудра'**
  String get sample_ing_powdered_sugar;

  /// No description provided for @sample_ing_dark_chocolate.
  ///
  /// In ru, this message translates to:
  /// **'Тёмный шоколад'**
  String get sample_ing_dark_chocolate;

  /// No description provided for @sample_simple_title.
  ///
  /// In ru, this message translates to:
  /// **'Лёгкий бисквит (пример)'**
  String get sample_simple_title;

  /// No description provided for @sample_simple_notes.
  ///
  /// In ru, this message translates to:
  /// **'Взбить яйца с сахаром до пышной пены. Аккуратно вмешать просеянную муку с разрыхлителем. Выпекать при 175°C 25 мин. Прослоить взбитыми сливками.'**
  String get sample_simple_notes;

  /// No description provided for @sample_simple_tag_easy.
  ///
  /// In ru, this message translates to:
  /// **'простой'**
  String get sample_simple_tag_easy;

  /// No description provided for @sample_simple_tag_birthday.
  ///
  /// In ru, this message translates to:
  /// **'день рождения'**
  String get sample_simple_tag_birthday;

  /// No description provided for @sample_wedding_title.
  ///
  /// In ru, this message translates to:
  /// **'Свадебный торт (пример)'**
  String get sample_wedding_title;

  /// No description provided for @sample_wedding_notes.
  ///
  /// In ru, this message translates to:
  /// **'Печь каждый ярус отдельно. В нижний ярус перед сборкой вставить 4 шпильки для опоры верхнего. Сахарные фигурки ставить в самом конце.'**
  String get sample_wedding_notes;

  /// No description provided for @sample_wedding_tier_bottom.
  ///
  /// In ru, this message translates to:
  /// **'Низ'**
  String get sample_wedding_tier_bottom;

  /// No description provided for @sample_wedding_tier_top.
  ///
  /// In ru, this message translates to:
  /// **'Верх'**
  String get sample_wedding_tier_top;

  /// No description provided for @sample_wedding_tag_wedding.
  ///
  /// In ru, this message translates to:
  /// **'свадебный'**
  String get sample_wedding_tag_wedding;

  /// No description provided for @sample_wedding_tag_tiered.
  ///
  /// In ru, this message translates to:
  /// **'ярусный'**
  String get sample_wedding_tag_tiered;

  /// No description provided for @sample_wedding_tag_celebration.
  ///
  /// In ru, this message translates to:
  /// **'торжество'**
  String get sample_wedding_tag_celebration;

  /// No description provided for @sample_ing_baking_powder.
  ///
  /// In ru, this message translates to:
  /// **'Разрыхлитель'**
  String get sample_ing_baking_powder;

  /// No description provided for @sample_ing_vanilla.
  ///
  /// In ru, this message translates to:
  /// **'Ваниль'**
  String get sample_ing_vanilla;

  /// No description provided for @sample_ing_sugar_figures.
  ///
  /// In ru, this message translates to:
  /// **'Сахарные фигурки'**
  String get sample_ing_sugar_figures;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
