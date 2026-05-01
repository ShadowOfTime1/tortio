// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Tortio';

  @override
  String get common_save => 'Сохранить';

  @override
  String get common_cancel => 'Отмена';

  @override
  String get common_delete => 'Удалить';

  @override
  String get common_edit => 'Редактировать';

  @override
  String get common_close => 'Закрыть';

  @override
  String get common_confirm => 'Подтвердить';

  @override
  String get common_yes => 'Да';

  @override
  String get common_no => 'Нет';

  @override
  String get common_ok => 'ОК';

  @override
  String get common_back => 'Назад';

  @override
  String get common_done => 'Готово';

  @override
  String get common_optional => 'необязательно';

  @override
  String get common_undo => 'Отменить';

  @override
  String get common_retry => 'Повторить';

  @override
  String get common_loading => 'Загрузка…';

  @override
  String get common_error => 'Ошибка';

  @override
  String get common_continue => 'Продолжить';

  @override
  String get common_skip => 'Пропустить';

  @override
  String get common_open => 'Открыть';

  @override
  String get common_share => 'Поделиться';

  @override
  String get unit_grams_short => 'г';

  @override
  String get unit_kilograms_short => 'кг';

  @override
  String get unit_centimeters_short => 'см';

  @override
  String get unit_pieces_short => 'шт';

  @override
  String get unit_diameter_symbol => '⌀';

  @override
  String get list_title => 'Рецепты';

  @override
  String get list_search_hint => 'Поиск по названию или ингредиенту';

  @override
  String get list_empty_title => 'Пока ни одного торта';

  @override
  String get list_empty_subtitle => 'Добавьте свой первый торт!';

  @override
  String get list_empty_demo_button => 'Создать примерные рецепты';

  @override
  String get list_no_results_title => 'Ничего не найдено';

  @override
  String get list_no_results_reset => 'Сбросить фильтры';

  @override
  String get list_filter_all_tags => 'Все';

  @override
  String get list_fab_new_recipe => 'Рецепт';

  @override
  String list_section_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count секц.',
      few: '$count секц.',
      one: '$count секц.',
    );
    return '$_temp0';
  }

  @override
  String list_ingredient_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ингр.',
      few: '$count ингр.',
      one: '$count ингр.',
    );
    return '$_temp0';
  }

  @override
  String list_tier_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ярусов',
      few: '$count яруса',
      one: '$count ярус',
    );
    return '$_temp0';
  }

  @override
  String list_cooked_times(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count раз',
      few: '$count раза',
      one: '$count раз',
    );
    return 'Готовили $_temp0';
  }

  @override
  String list_cooked_days_ago(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дн. назад',
      few: '$count дн. назад',
      one: '$count дн. назад',
      zero: 'сегодня',
    );
    return '$_temp0';
  }

  @override
  String get list_badge_new => 'NEW';

  @override
  String get list_menu_edit => 'Редактировать';

  @override
  String get list_menu_duplicate => 'Дублировать';

  @override
  String get list_menu_pin => 'Закрепить';

  @override
  String get list_menu_unpin => 'Открепить';

  @override
  String get list_menu_delete => 'Удалить';

  @override
  String get list_menu_select_bulk => 'Выбрать (массовое удаление)';

  @override
  String list_selection_count(int count) {
    return 'Выбрано: $count';
  }

  @override
  String get list_recipe_deleted => 'Рецепт удалён';

  @override
  String list_recipe_named_deleted(String title) {
    return '«$title» удалён';
  }

  @override
  String list_bulk_delete_title(int count) {
    return 'Удалить $count рецепт(ов)?';
  }

  @override
  String get list_bulk_delete_body =>
      'Все выбранные рецепты будут удалены безвозвратно.';

  @override
  String list_bulk_deleted(int count) {
    return 'Удалено: $count';
  }

  @override
  String list_tooltip_sort(String label) {
    return 'Сортировка: $label';
  }

  @override
  String get list_tooltip_settings => 'Настройки';

  @override
  String get list_tooltip_cancel_selection => 'Отменить выбор';

  @override
  String get list_tooltip_delete_selected => 'Удалить выбранные';

  @override
  String list_no_results_filtered(String filters) {
    return 'нет рецептов $filters';
  }

  @override
  String get list_no_results_empty => 'ничего не найдено';

  @override
  String list_filter_by_query(String q) {
    return 'по запросу «$q»';
  }

  @override
  String list_filter_by_tag(String t) {
    return 'с тегом «$t»';
  }

  @override
  String get time_today => 'сегодня';

  @override
  String get time_yesterday => 'вчера';

  @override
  String time_days_ago(int n) {
    return '$n дн. назад';
  }

  @override
  String time_weeks_ago(int n) {
    return '$n нед. назад';
  }

  @override
  String time_months_ago(int n) {
    return '$n мес. назад';
  }

  @override
  String time_years_ago(int n) {
    return '$n г. назад';
  }

  @override
  String list_card_summary(
    String diameter_sym,
    int diameter,
    String cm,
    int sections,
    int ingredients,
  ) {
    return '$diameter_sym $diameter $cm • $sections секц. • $ingredients ингр.';
  }

  @override
  String list_card_cooked(int count, String suffix) {
    return 'Готовили $count раз$suffix';
  }

  @override
  String get list_recipe_duplicate_suffix => '(копия)';

  @override
  String get list_sort_label => 'Сортировка';

  @override
  String get list_sort_manual => 'Вручную';

  @override
  String get list_sort_newest => 'Новые сначала';

  @override
  String get list_sort_oldest => 'Старые сначала';

  @override
  String get list_sort_alpha => 'По алфавиту';

  @override
  String get list_sort_rating => 'По рейтингу';

  @override
  String get list_sort_cook_count => 'Чаще готовлю';

  @override
  String get list_sort_recently_cooked => 'Недавно готовил';

  @override
  String get list_menu_stats => 'Статистика';

  @override
  String get form_title_new => 'Новый рецепт';

  @override
  String get form_title_edit => 'Редактирование рецепта';

  @override
  String get form_field_title => 'Название';

  @override
  String get form_field_diameter => 'Диаметр';

  @override
  String get form_field_height => 'Высота';

  @override
  String get form_field_weight => 'Вес';

  @override
  String get form_field_notes => 'Заметки';

  @override
  String get form_field_tags => 'Теги';

  @override
  String get form_field_tags_hint => 'через запятую';

  @override
  String get form_field_ingredient => 'Ингредиент';

  @override
  String get form_field_amount => 'Кол-во';

  @override
  String get form_section_size_header => 'Размеры формы';

  @override
  String get form_section_size_subtitle => '(высота — опционально)';

  @override
  String get form_section_extras_header => 'Дополнительно';

  @override
  String get form_section_composition_header => 'Состав';

  @override
  String get form_add_section => 'Добавить секцию';

  @override
  String get form_add_ingredient => 'Добавить ингредиент';

  @override
  String get form_add_tier => 'Добавить ярус';

  @override
  String get form_remove_tier => 'Удалить ярус';

  @override
  String form_tier_label(int n) {
    return 'Ярус $n';
  }

  @override
  String get form_tier_name_optional => 'Название (опц)';

  @override
  String get form_section_note_label => 'Заметка к секции';

  @override
  String get form_rating_label => 'Личная оценка';

  @override
  String get form_rating_clear => 'Снять';

  @override
  String get form_unsaved_dialog_title => 'Несохранённые изменения';

  @override
  String get form_unsaved_dialog_body =>
      'Вы внесли изменения. Выйти без сохранения?';

  @override
  String get form_unsaved_stay => 'Остаться';

  @override
  String get form_unsaved_leave => 'Выйти';

  @override
  String get form_error_title_required => 'Введите название рецепта';

  @override
  String get form_error_diameter_required => 'Введите диаметр';

  @override
  String get form_error_no_sections =>
      'Добавьте хотя бы одну секцию с ингредиентами';

  @override
  String form_error_tiers_skipped(String numbers) {
    return 'Ярус(ы) $numbers пропущены: нет ингредиентов с весом > 0';
  }

  @override
  String get form_photo_pick => 'Из галереи';

  @override
  String get form_photo_camera => 'Сделать фото';

  @override
  String get form_photo_remove => 'Убрать фото';

  @override
  String form_photo_error_camera(String err) {
    return 'Не удалось открыть камеру: $err';
  }

  @override
  String form_photo_error_gallery(String err) {
    return 'Не удалось выбрать фото: $err';
  }

  @override
  String get form_photo_label => 'Фото';

  @override
  String get form_field_title_hint => 'Например: Шоколадный торт';

  @override
  String get form_field_diameter_short => 'Диаметр';

  @override
  String get form_field_height_optional => 'опц.';

  @override
  String get form_field_weight_optional_label => 'Вес (необязательно)';

  @override
  String get form_field_notes_label => 'Заметки / шаги (необязательно)';

  @override
  String get form_field_notes_hint =>
      'Например: испечь при 170°C 35 мин. Бисквит — за день до сборки.';

  @override
  String get form_field_rating_label => 'Оценка';

  @override
  String get form_field_tags_label_optional => 'Теги (необязательно)';

  @override
  String get form_field_tags_input_hint => 'шоколадный, без глютена';

  @override
  String get form_field_tags_helper =>
      'Введи тег и нажми Enter (или через запятую)';

  @override
  String get form_section_extras_subtitle => 'вес, заметки, оценка, теги';

  @override
  String get form_tier_composition => 'Состав яруса';

  @override
  String get form_section_button => 'Секция';

  @override
  String get form_section_empty_title => 'Добавьте секцию';

  @override
  String get form_section_empty_hint => 'Бисквит, крем, начинка...';

  @override
  String get form_section_note_hint => 'Заметка к секции (опционально)';

  @override
  String form_section_scale_label(String label) {
    return 'пересчёт: $label';
  }

  @override
  String get form_ingredient_hint => 'Ингредиент';

  @override
  String get form_add_tier_first => 'Добавить ещё один ярус';

  @override
  String get form_add_tier_more => 'Ещё один ярус';

  @override
  String get form_error_no_ingredients =>
      'Заполните хотя бы один ингредиент с весом > 0';

  @override
  String form_error_tiers_skipped_full(String numbers) {
    return 'Ярус(ы) $numbers пропущены: нет ингредиентов с весом > 0 или не заполнены размеры';
  }

  @override
  String get form_section_picker_title => 'Выберите секцию';

  @override
  String get form_section_picker_create_custom => 'Создать свой тип';

  @override
  String get form_section_picker_custom_group => 'Свои типы';

  @override
  String get form_section_picker_cat_base => 'Основа';

  @override
  String get form_section_picker_cat_creams => 'Кремы и начинки';

  @override
  String get form_section_picker_cat_coatings => 'Покрытия и пропитки';

  @override
  String get form_section_picker_cat_decor => 'Декор';

  @override
  String get form_custom_type_actions_title => 'Кастомный тип секции';

  @override
  String get scaler_title_size => 'По размеру';

  @override
  String get scaler_title_weight => 'По весу';

  @override
  String get scaler_target_diameter => 'Целевой диаметр';

  @override
  String get scaler_target_height => 'Целевая высота';

  @override
  String get scaler_target_weight => 'Целевой вес';

  @override
  String scaler_total_weight(String grams) {
    return 'итого ≈ $grams';
  }

  @override
  String get scaler_height_label_short => 'В';

  @override
  String get scaler_height_label_full => 'Высота';

  @override
  String scaler_cooked_today(int n) {
    return 'Записал! Готовите $n-й раз';
  }

  @override
  String get scaler_cooked_button => 'Я приготовил';

  @override
  String get scaler_share_text => 'Поделиться текстом';

  @override
  String get scaler_share_pdf => 'Сохранить как PDF';

  @override
  String get scaler_shopping_list => 'Список покупок';

  @override
  String get scaler_shopping_list_title => 'Список покупок';

  @override
  String scaler_shopping_list_total(String grams) {
    return 'итого $grams';
  }

  @override
  String get scaler_shopping_list_empty => 'Ингредиентов нет';

  @override
  String get scaler_total_label => 'пересчёт';

  @override
  String get scaler_export_tooltip => 'Экспорт';

  @override
  String get scaler_export_share_text => 'Поделиться текстом';

  @override
  String get scaler_export_save_pdf => 'Сохранить как PDF';

  @override
  String scaler_pdf_error(String err) {
    return 'Ошибка PDF: $err';
  }

  @override
  String get scaler_cooked_first => 'Записал! Первый раз 🎂';

  @override
  String scaler_original_size(String sym, int d, String cm) {
    return 'Оригинал: $sym $d $cm';
  }

  @override
  String scaler_original_size_with_height(String sym, int d, int h, String cm) {
    return 'Оригинал: $sym $d×$h $cm';
  }

  @override
  String scaler_original_size_with_height_weight(
    String sym,
    int d,
    int h,
    String cm,
    String weight,
  ) {
    return 'Оригинал: $sym $d×$h $cm • $weight';
  }

  @override
  String scaler_original_size_weight(
    String sym,
    int d,
    String cm,
    String weight,
  ) {
    return 'Оригинал: $sym $d $cm • $weight';
  }

  @override
  String scaler_original_weight(String weight) {
    return 'Оригинал: $weight';
  }

  @override
  String scaler_tier_label_named(int n, String label) {
    return 'Ярус $n: $label';
  }

  @override
  String scaler_tier_label(int n) {
    return 'Ярус $n';
  }

  @override
  String scaler_tiers_total(int tiers, String weight) {
    return '$tiers ярус(ов) • итого $weight';
  }

  @override
  String share_diameter(String sym, int d, String cm) {
    return '$sym $d $cm';
  }

  @override
  String share_height(int h, String cm) {
    return 'высота $h $cm';
  }

  @override
  String get share_notes_header => '📝 Заметки';

  @override
  String share_total_approx(String weight) {
    return '~$weight';
  }

  @override
  String pdf_subtitle_multitier(int tiers, String weight) {
    return '$tiers ярус(ов) • итого ≈ $weight';
  }

  @override
  String pdf_subtitle_size_h(int d, int h, String cm, String weight) {
    return '⌀ $d×$h $cm • итого ≈ $weight';
  }

  @override
  String pdf_subtitle_size(int d, String cm, String weight) {
    return '⌀ $d $cm • итого ≈ $weight';
  }

  @override
  String pdf_tier_summary_h(
    String label,
    int d,
    int h,
    String cm,
    String weight,
  ) {
    return '$label • ⌀ $d×$h $cm • $weight';
  }

  @override
  String pdf_tier_summary(String label, int d, String cm, String weight) {
    return '$label • ⌀ $d $cm • $weight';
  }

  @override
  String get settings_title => 'Настройки';

  @override
  String get settings_group_appearance => 'Внешний вид';

  @override
  String get settings_group_behavior => 'Поведение';

  @override
  String get settings_group_cloud => 'Облачный бэкап';

  @override
  String get settings_group_backup => 'Резервные копии';

  @override
  String get settings_group_data => 'Данные';

  @override
  String get settings_group_danger => 'Опасная зона';

  @override
  String get settings_group_about => 'О приложении';

  @override
  String get settings_theme => 'Тема';

  @override
  String get settings_theme_auto => 'Авто (день — светлая, вечер — тёмная)';

  @override
  String get settings_theme_light => 'Светлая';

  @override
  String get settings_theme_dark => 'Тёмная';

  @override
  String get settings_language => 'Язык';

  @override
  String get settings_language_system => 'Системный';

  @override
  String get settings_language_ru => 'Русский';

  @override
  String get settings_language_en => 'English';

  @override
  String get settings_quick_diameters => 'Быстрые диаметры';

  @override
  String get settings_quick_diameters_hint => 'Через запятую, см';

  @override
  String get settings_quick_diameters_helper =>
      'Эти числа показываются как кнопки-чипы под слайдером диаметра на экране пересчёта.';

  @override
  String get settings_quick_diameters_saved => 'Быстрые диаметры сохранены';

  @override
  String get settings_default_mode_size_title => 'По умолчанию: По размеру';

  @override
  String get settings_default_mode_weight_title => 'По умолчанию: По весу';

  @override
  String get settings_default_mode_weight_subtitle =>
      'Только если у рецепта указан вес';

  @override
  String get settings_auto_update_subtitle =>
      'При запуске приложение спрашивает GitHub о новой версии';

  @override
  String get settings_export_done => 'Экспортировано';

  @override
  String get settings_export_empty => 'Нечего экспортировать — список пустой';

  @override
  String settings_export_error(String err) {
    return 'Ошибка экспорта: $err';
  }

  @override
  String get settings_import_nothing => 'Ничего не импортировано';

  @override
  String settings_import_count(int count) {
    return 'Импортировано: $count';
  }

  @override
  String settings_import_error_with(String err) {
    return 'Ошибка импорта: $err';
  }

  @override
  String get settings_open_link_failed => 'Не удалось открыть ссылку';

  @override
  String get settings_no_custom_types => 'Нет кастомных типов';

  @override
  String settings_custom_type_scale_label(String name) {
    return 'масштаб: $name';
  }

  @override
  String get settings_reset_dialog_title => 'Сбросить настройки?';

  @override
  String get settings_reset_dialog_body =>
      'Тема, сортировка, авто-проверка обновлений, default-режим пересчёта и быстрые диаметры вернутся к дефолтам. Рецепты и кастомные типы секций НЕ затронутся.';

  @override
  String get settings_reset_action => 'Сбросить';

  @override
  String get settings_reset_subtitle =>
      'Тема, сортировка, авто-обновление, default режим, быстрые диаметры. Рецепты не трогаются.';

  @override
  String get settings_delete_all_action => 'Удалить всё';

  @override
  String get settings_delete_all_full_body =>
      'Все рецепты, кастомные типы секций и snapshot импорта будут удалены безвозвратно. Резервная копия предыдущего сохранения тоже исчезнет. Уверен?';

  @override
  String get settings_check_update_done => 'Установлена последняя версия';

  @override
  String settings_check_update_available(String version) {
    return 'Доступна v$version. Открой приложение заново — появится баннер с обновлением.';
  }

  @override
  String get settings_show_welcome_again_subtitle =>
      'Краткий тур по приложению';

  @override
  String get settings_version_label => 'Версия';

  @override
  String get settings_privacy_policy => 'Политика конфиденциальности';

  @override
  String get settings_license_label => 'Лицензия';

  @override
  String get settings_license_value => 'MIT';

  @override
  String get settings_github_source => 'Исходники на GitHub';

  @override
  String get settings_show_stats => 'Показать статистику';

  @override
  String get settings_import_undo_action => 'Откатить последний импорт';

  @override
  String get settings_save_action => 'Сохранить';

  @override
  String get stats_title => 'Статистика';

  @override
  String get stats_recipes => 'Рецептов';

  @override
  String get stats_ingredients => 'Ингредиентов всего';

  @override
  String get stats_total_recipe_weights => 'Сумма весов рецептов';

  @override
  String get stats_top_ingredients_header => 'ТОП ИНГРЕДИЕНТОВ';

  @override
  String get stats_top_tags_header => 'ТОП ТЕГОВ';

  @override
  String get custom_type_dialog_new => 'Новый тип секции';

  @override
  String get custom_type_dialog_edit => 'Изменить тип секции';

  @override
  String get custom_type_field_name => 'Название';

  @override
  String get custom_type_field_name_hint => 'Например, Маршмеллоу';

  @override
  String get custom_type_field_icon => 'Иконка (эмодзи)';

  @override
  String get custom_type_field_scale_label => 'Как масштабировать';

  @override
  String get custom_type_scale_volume => 'По объёму (d² × h)';

  @override
  String get custom_type_scale_area => 'По площади (d²)';

  @override
  String get custom_type_scale_fixed => 'Фикс (не меняется)';

  @override
  String get scale_label_volume => 'объём';

  @override
  String get scale_label_area => 'площадь';

  @override
  String get scale_label_fixed => 'фикс';

  @override
  String get preset_sponge => 'Бисквит';

  @override
  String get preset_cream => 'Крем';

  @override
  String get preset_filling => 'Начинка';

  @override
  String get preset_coating => 'Покрытие';

  @override
  String get preset_ganache => 'Ганаш';

  @override
  String get preset_syrup => 'Пропитка';

  @override
  String get preset_mousse => 'Мусс';

  @override
  String get preset_meringue => 'Безе';

  @override
  String get preset_glaze => 'Глазурь';

  @override
  String get preset_decor => 'Декор';

  @override
  String get custom_type_create => 'Создать';

  @override
  String custom_type_used_dialog_title(String name) {
    return 'Удалить тип «$name»?';
  }

  @override
  String custom_type_used_dialog_body(int count, String names) {
    return 'Этот тип используется в $count рецепте(ах):\n\n$names\n\nУже сохранённые секции продолжат работать как есть. Но добавить новые секции этого типа будет нельзя.';
  }

  @override
  String custom_type_more(int n) {
    return '... и ещё $n';
  }

  @override
  String get custom_type_force_delete => 'Всё равно удалить';

  @override
  String get settings_default_scale_mode => 'Режим пересчёта по умолчанию';

  @override
  String get settings_default_scale_mode_size => 'По размеру';

  @override
  String get settings_default_scale_mode_weight => 'По весу';

  @override
  String get settings_custom_types => 'Кастомные типы секций';

  @override
  String get settings_custom_types_add => 'Добавить тип';

  @override
  String get settings_custom_type_in_use_title => 'Тип используется';

  @override
  String settings_custom_type_in_use_body(int count) {
    return 'Этот тип используется в $count рецепт(ах). Уже сохранённые секции продолжат работать, но добавить новые будет нельзя.';
  }

  @override
  String get settings_auto_update => 'Автоматически проверять обновления';

  @override
  String get settings_check_update_now => 'Проверить обновление сейчас';

  @override
  String get settings_update_no_new => 'У вас актуальная версия';

  @override
  String settings_update_found(String version) {
    return 'Доступна версия $version';
  }

  @override
  String get settings_cloud_connect => 'Подключить Google Drive';

  @override
  String get settings_cloud_connect_subtitle => 'Автоматический бэкап рецептов';

  @override
  String get settings_cloud_connected => 'Подключено';

  @override
  String get settings_cloud_email => 'Аккаунт';

  @override
  String settings_cloud_last_sync(String when) {
    return 'Последняя синхронизация: $when';
  }

  @override
  String get settings_cloud_never_synced => 'Ещё не синхронизировано';

  @override
  String get settings_cloud_sync_now => 'Синхронизировать сейчас';

  @override
  String get settings_cloud_restore => 'Восстановить из облака';

  @override
  String get settings_cloud_sign_out => 'Выйти';

  @override
  String get settings_cloud_busy => 'Подождите…';

  @override
  String get settings_cloud_restore_prompt_title => 'Восстановить из бэкапа?';

  @override
  String settings_cloud_restore_prompt_body(String when) {
    return 'Найден бэкап от $when. Восстановить?';
  }

  @override
  String get settings_cloud_restore_keep_local => 'Нет, оставить локальные';

  @override
  String get settings_cloud_restore_replace => 'Восстановить';

  @override
  String settings_cloud_restore_done(int count) {
    return 'Восстановлено $count рецепт(ов)';
  }

  @override
  String get settings_export => 'Экспортировать в JSON';

  @override
  String get settings_import => 'Импортировать из JSON';

  @override
  String get settings_import_undo => 'Откатить последний импорт';

  @override
  String settings_import_done(int count) {
    return 'Импортировано $count рецепт(ов)';
  }

  @override
  String get settings_import_undone => 'Импорт отменён';

  @override
  String get settings_import_error => 'Не удалось прочитать файл';

  @override
  String get settings_stats => 'Статистика';

  @override
  String get settings_show_welcome_again => 'Показать приветствие снова';

  @override
  String get settings_reset_settings => 'Сбросить настройки до дефолтов';

  @override
  String get settings_reset_settings_done => 'Настройки сброшены';

  @override
  String get settings_regen_samples =>
      'Пересоздать демо-рецепты на текущем языке';

  @override
  String get settings_regen_samples_subtitle =>
      'Заменит нетронутые демо (Лёгкий бисквит / Шоколадный торт / Свадебный торт). Ваши рецепты не пострадают.';

  @override
  String get settings_regen_samples_confirm_title =>
      'Пересоздать демо-рецепты?';

  @override
  String get settings_regen_samples_confirm_body =>
      'Существующие демо-рецепты (определяются по заголовку) будут удалены и пересозданы на текущем языке UI. Ваши собственные рецепты не пострадают.';

  @override
  String get settings_regen_samples_action => 'Пересоздать';

  @override
  String get settings_regen_samples_done => 'Демо-рецепты пересозданы';

  @override
  String get settings_delete_all => 'Удалить все рецепты и кастомные типы';

  @override
  String get settings_delete_all_confirm_title => 'Удалить всё?';

  @override
  String get settings_delete_all_confirm_body =>
      'Будут удалены все рецепты и кастомные типы. Действие необратимо.';

  @override
  String get settings_delete_all_done => 'Всё удалено';

  @override
  String about_version(String v) {
    return 'Версия $v';
  }

  @override
  String get about_repo => 'Исходный код на GitHub';

  @override
  String get about_license => 'Лицензия: MIT';

  @override
  String get stats_recipes_total => 'Всего рецептов';

  @override
  String get stats_ingredients_total => 'Всего ингредиентов';

  @override
  String get stats_total_weight => 'Сумма весов рецептов';

  @override
  String get stats_top_ingredients => 'Топ-5 ингредиентов';

  @override
  String get stats_top_tags => 'Топ-5 тегов';

  @override
  String get welcome_title => 'Привет, кондитер!';

  @override
  String get welcome_subtitle =>
      'Tortio пересчитает ингредиенты под нужный размер торта.';

  @override
  String get welcome_bullet_add =>
      'Кнопка «+ Рецепт» снизу — добавить новый. Можно начать с готового примера.';

  @override
  String get welcome_bullet_scale =>
      'Открыл рецепт → меняй диаметр или вес → ингредиенты пересчитываются автоматически.';

  @override
  String get welcome_bullet_tiers =>
      'Многоярусный торт? Добавь ярус прямо в форме рецепта — у каждого свой размер.';

  @override
  String get welcome_bullet_sort =>
      '↕ — сортировка списка. ⚙ — настройки (тема, бэкапы, статистика).';

  @override
  String get welcome_bullet_inside =>
      'Внутри рецепта: ✓ «Я приготовил», ↗ «Экспорт» (PDF / шаринг), 🛒 «Список покупок».';

  @override
  String get welcome_button_start => 'Начать!';

  @override
  String get snack_recipe_saved => 'Рецепт сохранён';

  @override
  String get snack_export_done => 'Экспортировано';

  @override
  String get snack_no_internet => 'Нет интернета';

  @override
  String get snack_drive_connected => 'Google Drive подключён';

  @override
  String get snack_drive_uploaded => 'Загружено в облако';

  @override
  String get snack_drive_failed => 'Ошибка облака. Попробуйте позже';

  @override
  String update_banner_available(String version) {
    return 'Версия $version доступна';
  }

  @override
  String get update_banner_tap => 'Нажмите чтобы обновить';

  @override
  String update_banner_downloading(int percent) {
    return 'Скачивание... $percent%';
  }

  @override
  String get update_error_generic => 'Ошибка обновления. Проверьте интернет.';

  @override
  String get update_error_no_internet =>
      'Нет интернета. Проверьте подключение.';

  @override
  String get update_error_install_permission =>
      'Нужно разрешить установку из неизвестных источников в настройках Android.';

  @override
  String get sample_title => 'Шоколадный торт (пример)';

  @override
  String get sample_notes =>
      'Печь бисквит при 180°C 35–40 мин. Дать остыть, разрезать на 2 коржа. Прослоить кремом, покрыть глазурью.';

  @override
  String get sample_sponge_notes => 'Просеять муку с какао перед смешиванием';

  @override
  String get sample_tag_chocolate => 'шоколадный';

  @override
  String get sample_tag_sample => 'пример';

  @override
  String get sample_ing_flour => 'Мука';

  @override
  String get sample_ing_cocoa => 'Какао';

  @override
  String get sample_ing_sugar => 'Сахар';

  @override
  String get sample_ing_eggs => 'Яйца';

  @override
  String get sample_ing_butter => 'Сливочное масло';

  @override
  String get sample_ing_cream33 => 'Сливки 33%';

  @override
  String get sample_ing_powdered_sugar => 'Сахарная пудра';

  @override
  String get sample_ing_dark_chocolate => 'Тёмный шоколад';

  @override
  String get sample_simple_title => 'Лёгкий бисквит (пример)';

  @override
  String get sample_simple_notes =>
      'Взбить яйца с сахаром до пышной пены. Аккуратно вмешать просеянную муку с разрыхлителем. Выпекать при 175°C 25 мин. Прослоить взбитыми сливками.';

  @override
  String get sample_simple_tag_easy => 'простой';

  @override
  String get sample_simple_tag_birthday => 'день рождения';

  @override
  String get sample_wedding_title => 'Свадебный торт (пример)';

  @override
  String get sample_wedding_notes =>
      'Печь каждый ярус отдельно. В нижний ярус перед сборкой вставить 4 шпильки для опоры верхнего. Сахарные фигурки ставить в самом конце.';

  @override
  String get sample_wedding_tier_bottom => 'Низ';

  @override
  String get sample_wedding_tier_top => 'Верх';

  @override
  String get sample_wedding_tag_wedding => 'свадебный';

  @override
  String get sample_wedding_tag_tiered => 'ярусный';

  @override
  String get sample_wedding_tag_celebration => 'торжество';

  @override
  String get sample_ing_baking_powder => 'Разрыхлитель';

  @override
  String get sample_ing_vanilla => 'Ваниль';

  @override
  String get sample_ing_sugar_figures => 'Сахарные фигурки';
}
