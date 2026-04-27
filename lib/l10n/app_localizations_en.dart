// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Tortio';

  @override
  String get common_save => 'Save';

  @override
  String get common_cancel => 'Cancel';

  @override
  String get common_delete => 'Delete';

  @override
  String get common_edit => 'Edit';

  @override
  String get common_close => 'Close';

  @override
  String get common_confirm => 'Confirm';

  @override
  String get common_yes => 'Yes';

  @override
  String get common_no => 'No';

  @override
  String get common_ok => 'OK';

  @override
  String get common_back => 'Back';

  @override
  String get common_done => 'Done';

  @override
  String get common_optional => 'optional';

  @override
  String get common_undo => 'Undo';

  @override
  String get common_retry => 'Retry';

  @override
  String get common_loading => 'Loading…';

  @override
  String get common_error => 'Error';

  @override
  String get common_continue => 'Continue';

  @override
  String get common_skip => 'Skip';

  @override
  String get common_open => 'Open';

  @override
  String get common_share => 'Share';

  @override
  String get unit_grams_short => 'g';

  @override
  String get unit_kilograms_short => 'kg';

  @override
  String get unit_centimeters_short => 'cm';

  @override
  String get unit_pieces_short => 'pcs';

  @override
  String get unit_diameter_symbol => '⌀';

  @override
  String get list_title => 'Recipes';

  @override
  String get list_search_hint => 'Search by name or ingredient';

  @override
  String get list_empty_title => 'No cakes yet';

  @override
  String get list_empty_subtitle => 'Add your first cake!';

  @override
  String get list_empty_demo_button => 'Create sample recipe';

  @override
  String get list_no_results_title => 'Nothing found';

  @override
  String get list_no_results_reset => 'Reset filters';

  @override
  String get list_filter_all_tags => 'All';

  @override
  String get list_fab_new_recipe => 'Recipe';

  @override
  String list_section_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sect.',
      one: '$count sect.',
    );
    return '$_temp0';
  }

  @override
  String list_ingredient_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ingr.',
      one: '$count ingr.',
    );
    return '$_temp0';
  }

  @override
  String list_tier_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tiers',
      one: '$count tier',
    );
    return '$_temp0';
  }

  @override
  String list_cooked_times(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count times',
      one: '$count time',
    );
    return 'Cooked $_temp0';
  }

  @override
  String list_cooked_days_ago(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '$count day ago',
      zero: 'today',
    );
    return '$_temp0';
  }

  @override
  String get list_badge_new => 'NEW';

  @override
  String get list_menu_edit => 'Edit';

  @override
  String get list_menu_duplicate => 'Duplicate';

  @override
  String get list_menu_pin => 'Pin';

  @override
  String get list_menu_unpin => 'Unpin';

  @override
  String get list_menu_delete => 'Delete';

  @override
  String get list_menu_select_bulk => 'Select (bulk delete)';

  @override
  String list_selection_count(int count) {
    return 'Selected: $count';
  }

  @override
  String get list_recipe_deleted => 'Recipe deleted';

  @override
  String list_recipe_named_deleted(String title) {
    return '«$title» deleted';
  }

  @override
  String list_bulk_delete_title(int count) {
    return 'Delete $count recipe(s)?';
  }

  @override
  String get list_bulk_delete_body =>
      'All selected recipes will be permanently deleted.';

  @override
  String list_bulk_deleted(int count) {
    return 'Deleted: $count';
  }

  @override
  String list_tooltip_sort(String label) {
    return 'Sort: $label';
  }

  @override
  String get list_tooltip_settings => 'Settings';

  @override
  String get list_tooltip_cancel_selection => 'Cancel selection';

  @override
  String get list_tooltip_delete_selected => 'Delete selected';

  @override
  String list_no_results_filtered(String filters) {
    return 'no recipes $filters';
  }

  @override
  String get list_no_results_empty => 'nothing found';

  @override
  String list_filter_by_query(String q) {
    return 'matching «$q»';
  }

  @override
  String list_filter_by_tag(String t) {
    return 'with tag «$t»';
  }

  @override
  String get time_today => 'today';

  @override
  String get time_yesterday => 'yesterday';

  @override
  String time_days_ago(int n) {
    return '$n day(s) ago';
  }

  @override
  String time_weeks_ago(int n) {
    return '$n week(s) ago';
  }

  @override
  String time_months_ago(int n) {
    return '$n month(s) ago';
  }

  @override
  String time_years_ago(int n) {
    return '$n year(s) ago';
  }

  @override
  String list_card_summary(
    String diameter_sym,
    int diameter,
    String cm,
    int sections,
    int ingredients,
  ) {
    return '$diameter_sym $diameter $cm • $sections sect. • $ingredients ingr.';
  }

  @override
  String list_card_cooked(int count, String suffix) {
    return 'Cooked $count time(s)$suffix';
  }

  @override
  String get list_recipe_duplicate_suffix => '(copy)';

  @override
  String get list_sort_label => 'Sort';

  @override
  String get list_sort_manual => 'Manual';

  @override
  String get list_sort_newest => 'Newest first';

  @override
  String get list_sort_oldest => 'Oldest first';

  @override
  String get list_sort_alpha => 'Alphabetical';

  @override
  String get list_sort_rating => 'By rating';

  @override
  String get list_sort_cook_count => 'Most cooked';

  @override
  String get list_sort_recently_cooked => 'Recently cooked';

  @override
  String get list_menu_stats => 'Stats';

  @override
  String get form_title_new => 'New recipe';

  @override
  String get form_title_edit => 'Edit recipe';

  @override
  String get form_field_title => 'Name';

  @override
  String get form_field_diameter => 'Diameter';

  @override
  String get form_field_height => 'Height';

  @override
  String get form_field_weight => 'Weight';

  @override
  String get form_field_notes => 'Notes';

  @override
  String get form_field_tags => 'Tags';

  @override
  String get form_field_tags_hint => 'comma-separated';

  @override
  String get form_field_ingredient => 'Ingredient';

  @override
  String get form_field_amount => 'Amount';

  @override
  String get form_section_size_header => 'Cake form size';

  @override
  String get form_section_size_subtitle => '(height — optional)';

  @override
  String get form_section_extras_header => 'More';

  @override
  String get form_section_composition_header => 'Composition';

  @override
  String get form_add_section => 'Add section';

  @override
  String get form_add_ingredient => 'Add ingredient';

  @override
  String get form_add_tier => 'Add tier';

  @override
  String get form_remove_tier => 'Remove tier';

  @override
  String form_tier_label(int n) {
    return 'Tier $n';
  }

  @override
  String get form_tier_name_optional => 'Name (opt)';

  @override
  String get form_section_note_label => 'Section note';

  @override
  String get form_rating_label => 'Personal rating';

  @override
  String get form_rating_clear => 'Clear';

  @override
  String get form_unsaved_dialog_title => 'Unsaved changes';

  @override
  String get form_unsaved_dialog_body =>
      'You made changes. Leave without saving?';

  @override
  String get form_unsaved_stay => 'Stay';

  @override
  String get form_unsaved_leave => 'Leave';

  @override
  String get form_error_title_required => 'Enter recipe name';

  @override
  String get form_error_diameter_required => 'Enter diameter';

  @override
  String get form_error_no_sections =>
      'Add at least one section with ingredients';

  @override
  String form_error_tiers_skipped(String numbers) {
    return 'Tier(s) $numbers skipped: no ingredients with weight > 0';
  }

  @override
  String get form_photo_pick => 'From gallery';

  @override
  String get form_photo_camera => 'Take photo';

  @override
  String get form_photo_remove => 'Remove photo';

  @override
  String form_photo_error_camera(String err) {
    return 'Couldn\'t open camera: $err';
  }

  @override
  String form_photo_error_gallery(String err) {
    return 'Couldn\'t pick photo: $err';
  }

  @override
  String get form_photo_label => 'Photo';

  @override
  String get form_field_title_hint => 'e.g. Chocolate cake';

  @override
  String get form_field_diameter_short => 'Diameter';

  @override
  String get form_field_height_optional => 'opt.';

  @override
  String get form_field_weight_optional_label => 'Weight (optional)';

  @override
  String get form_field_notes_label => 'Notes / steps (optional)';

  @override
  String get form_field_notes_hint =>
      'e.g. bake at 170°C for 35 min. Sponge — day before assembly.';

  @override
  String get form_field_rating_label => 'Rating';

  @override
  String get form_field_tags_label_optional => 'Tags (optional)';

  @override
  String get form_field_tags_input_hint => 'chocolate, gluten-free';

  @override
  String get form_field_tags_helper => 'Enter a tag and press Enter (or comma)';

  @override
  String get form_section_extras_subtitle => 'weight, notes, rating, tags';

  @override
  String get form_tier_composition => 'Tier composition';

  @override
  String get form_section_button => 'Section';

  @override
  String get form_section_empty_title => 'Add a section';

  @override
  String get form_section_empty_hint => 'Sponge, cream, filling...';

  @override
  String get form_section_note_hint => 'Section note (optional)';

  @override
  String form_section_scale_label(String label) {
    return 'scale: $label';
  }

  @override
  String get form_ingredient_hint => 'Ingredient';

  @override
  String get form_add_tier_first => 'Add another tier';

  @override
  String get form_add_tier_more => 'One more tier';

  @override
  String get form_error_no_ingredients =>
      'Fill at least one ingredient with weight > 0';

  @override
  String form_error_tiers_skipped_full(String numbers) {
    return 'Tier(s) $numbers skipped: no ingredients with weight > 0 or sizes not filled';
  }

  @override
  String get form_section_picker_title => 'Choose section';

  @override
  String get form_section_picker_create_custom => 'Create custom type';

  @override
  String get form_section_picker_custom_group => 'Custom types';

  @override
  String get form_section_picker_cat_base => 'Base';

  @override
  String get form_section_picker_cat_creams => 'Creams & fillings';

  @override
  String get form_section_picker_cat_coatings => 'Coatings & syrups';

  @override
  String get form_section_picker_cat_decor => 'Decor';

  @override
  String get form_custom_type_actions_title => 'Custom section type';

  @override
  String get scaler_title_size => 'By size';

  @override
  String get scaler_title_weight => 'By weight';

  @override
  String get scaler_target_diameter => 'Target diameter';

  @override
  String get scaler_target_height => 'Target height';

  @override
  String get scaler_target_weight => 'Target weight';

  @override
  String scaler_total_weight(String grams) {
    return 'total ≈ $grams';
  }

  @override
  String get scaler_height_label_short => 'H';

  @override
  String get scaler_height_label_full => 'Height';

  @override
  String scaler_cooked_today(int n) {
    return 'Logged! Cooking time #$n';
  }

  @override
  String get scaler_cooked_button => 'I cooked it';

  @override
  String get scaler_share_text => 'Share as text';

  @override
  String get scaler_share_pdf => 'Save as PDF';

  @override
  String get scaler_shopping_list => 'Shopping list';

  @override
  String get scaler_shopping_list_title => 'Shopping list';

  @override
  String scaler_shopping_list_total(String grams) {
    return 'total $grams';
  }

  @override
  String get scaler_shopping_list_empty => 'No ingredients';

  @override
  String get scaler_total_label => 'rescaled';

  @override
  String get scaler_export_tooltip => 'Export';

  @override
  String get scaler_export_share_text => 'Share as text';

  @override
  String get scaler_export_save_pdf => 'Save as PDF';

  @override
  String scaler_pdf_error(String err) {
    return 'PDF error: $err';
  }

  @override
  String get scaler_cooked_first => 'Logged! First time 🎂';

  @override
  String scaler_original_size(String sym, int d, String cm) {
    return 'Original: $sym $d $cm';
  }

  @override
  String scaler_original_size_with_height(String sym, int d, int h, String cm) {
    return 'Original: $sym $d×$h $cm';
  }

  @override
  String scaler_original_size_with_height_weight(
    String sym,
    int d,
    int h,
    String cm,
    String weight,
  ) {
    return 'Original: $sym $d×$h $cm • $weight';
  }

  @override
  String scaler_original_size_weight(
    String sym,
    int d,
    String cm,
    String weight,
  ) {
    return 'Original: $sym $d $cm • $weight';
  }

  @override
  String scaler_original_weight(String weight) {
    return 'Original: $weight';
  }

  @override
  String scaler_tier_label_named(int n, String label) {
    return 'Tier $n: $label';
  }

  @override
  String scaler_tier_label(int n) {
    return 'Tier $n';
  }

  @override
  String scaler_tiers_total(int tiers, String weight) {
    return '$tiers tier(s) • total $weight';
  }

  @override
  String share_diameter(String sym, int d, String cm) {
    return '$sym $d $cm';
  }

  @override
  String share_height(int h, String cm) {
    return 'height $h $cm';
  }

  @override
  String get share_notes_header => '📝 Notes';

  @override
  String get settings_title => 'Settings';

  @override
  String get settings_group_appearance => 'Appearance';

  @override
  String get settings_group_behavior => 'Behaviour';

  @override
  String get settings_group_cloud => 'Cloud backup';

  @override
  String get settings_group_backup => 'Backup files';

  @override
  String get settings_group_data => 'Data';

  @override
  String get settings_group_danger => 'Danger zone';

  @override
  String get settings_group_about => 'About';

  @override
  String get settings_theme => 'Theme';

  @override
  String get settings_theme_auto => 'Auto (light by day, dark by evening)';

  @override
  String get settings_theme_light => 'Light';

  @override
  String get settings_theme_dark => 'Dark';

  @override
  String get settings_language => 'Language';

  @override
  String get settings_language_system => 'System';

  @override
  String get settings_language_ru => 'Русский';

  @override
  String get settings_language_en => 'English';

  @override
  String get settings_quick_diameters => 'Quick diameters';

  @override
  String get settings_quick_diameters_hint => 'Comma-separated, cm';

  @override
  String get settings_quick_diameters_helper =>
      'These numbers appear as chip buttons under the diameter slider on the scaler screen.';

  @override
  String get settings_quick_diameters_saved => 'Quick diameters saved';

  @override
  String get settings_default_mode_size_title => 'Default: by size';

  @override
  String get settings_default_mode_weight_title => 'Default: by weight';

  @override
  String get settings_default_mode_weight_subtitle =>
      'Only if the recipe has weight set';

  @override
  String get settings_auto_update_subtitle =>
      'On launch, the app asks GitHub for a new version';

  @override
  String get settings_export_done => 'Exported';

  @override
  String get settings_export_empty => 'Nothing to export — list is empty';

  @override
  String settings_export_error(String err) {
    return 'Export error: $err';
  }

  @override
  String get settings_import_nothing => 'Nothing imported';

  @override
  String settings_import_count(int count) {
    return 'Imported: $count';
  }

  @override
  String settings_import_error_with(String err) {
    return 'Import error: $err';
  }

  @override
  String get settings_open_link_failed => 'Couldn\'t open link';

  @override
  String get settings_no_custom_types => 'No custom types';

  @override
  String settings_custom_type_scale_label(String name) {
    return 'scale: $name';
  }

  @override
  String get settings_reset_dialog_title => 'Reset settings?';

  @override
  String get settings_reset_dialog_body =>
      'Theme, sort order, auto-update check, default scale mode and quick diameters will return to defaults. Recipes and custom section types will NOT be touched.';

  @override
  String get settings_reset_action => 'Reset';

  @override
  String get settings_reset_subtitle =>
      'Theme, sort, auto-update, default mode, quick diameters. Recipes are kept.';

  @override
  String get settings_delete_all_action => 'Delete everything';

  @override
  String get settings_delete_all_full_body =>
      'All recipes, custom section types and import snapshot will be deleted permanently. The previous backup will also disappear. Sure?';

  @override
  String get settings_check_update_done => 'You\'re on the latest version';

  @override
  String settings_check_update_available(String version) {
    return 'v$version is available. Reopen the app — the update banner will show up.';
  }

  @override
  String get settings_show_welcome_again_subtitle => 'Quick app tour';

  @override
  String get settings_version_label => 'Version';

  @override
  String get settings_license_label => 'License';

  @override
  String get settings_license_value => 'MIT';

  @override
  String get settings_github_source => 'Source on GitHub';

  @override
  String get settings_show_stats => 'Show stats';

  @override
  String get settings_import_undo_action => 'Undo last import';

  @override
  String get settings_save_action => 'Save';

  @override
  String get stats_title => 'Statistics';

  @override
  String get stats_recipes => 'Recipes';

  @override
  String get stats_ingredients => 'Total ingredients';

  @override
  String get stats_total_recipe_weights => 'Sum of recipe weights';

  @override
  String get stats_top_ingredients_header => 'TOP INGREDIENTS';

  @override
  String get stats_top_tags_header => 'TOP TAGS';

  @override
  String get custom_type_dialog_new => 'New section type';

  @override
  String get custom_type_dialog_edit => 'Edit section type';

  @override
  String get custom_type_field_name => 'Name';

  @override
  String get custom_type_field_name_hint => 'e.g. Marshmallow';

  @override
  String get custom_type_field_icon => 'Icon (emoji)';

  @override
  String get custom_type_field_scale_label => 'How to scale';

  @override
  String get custom_type_scale_volume => 'By volume (d² × h)';

  @override
  String get custom_type_scale_area => 'By area (d²)';

  @override
  String get custom_type_scale_fixed => 'Fixed (no change)';

  @override
  String get scale_label_volume => 'volume';

  @override
  String get scale_label_area => 'area';

  @override
  String get scale_label_fixed => 'fixed';

  @override
  String get preset_sponge => 'Sponge';

  @override
  String get preset_cream => 'Cream';

  @override
  String get preset_filling => 'Filling';

  @override
  String get preset_coating => 'Coating';

  @override
  String get preset_ganache => 'Ganache';

  @override
  String get preset_syrup => 'Syrup';

  @override
  String get preset_mousse => 'Mousse';

  @override
  String get preset_meringue => 'Meringue';

  @override
  String get preset_glaze => 'Glaze';

  @override
  String get preset_decor => 'Decor';

  @override
  String get custom_type_create => 'Create';

  @override
  String custom_type_used_dialog_title(String name) {
    return 'Delete type «$name»?';
  }

  @override
  String custom_type_used_dialog_body(int count, String names) {
    return 'This type is used in $count recipe(s):\n\n$names\n\nExisting sections will keep working as is. But you won\'t be able to add new sections of this type.';
  }

  @override
  String custom_type_more(int n) {
    return '... and $n more';
  }

  @override
  String get custom_type_force_delete => 'Delete anyway';

  @override
  String get settings_default_scale_mode => 'Default scale mode';

  @override
  String get settings_default_scale_mode_size => 'By size';

  @override
  String get settings_default_scale_mode_weight => 'By weight';

  @override
  String get settings_custom_types => 'Custom section types';

  @override
  String get settings_custom_types_add => 'Add type';

  @override
  String get settings_custom_type_in_use_title => 'Type in use';

  @override
  String settings_custom_type_in_use_body(int count) {
    return 'This type is used in $count recipe(s). Existing sections will keep working but new ones can\'t be added.';
  }

  @override
  String get settings_auto_update => 'Check for updates automatically';

  @override
  String get settings_check_update_now => 'Check for update now';

  @override
  String get settings_update_no_new => 'You\'re on the latest version';

  @override
  String settings_update_found(String version) {
    return 'Version $version available';
  }

  @override
  String get settings_cloud_connect => 'Connect Google Drive';

  @override
  String get settings_cloud_connect_subtitle => 'Automatic recipe backup';

  @override
  String get settings_cloud_connected => 'Connected';

  @override
  String get settings_cloud_email => 'Account';

  @override
  String settings_cloud_last_sync(String when) {
    return 'Last sync: $when';
  }

  @override
  String get settings_cloud_never_synced => 'Never synced';

  @override
  String get settings_cloud_sync_now => 'Sync now';

  @override
  String get settings_cloud_restore => 'Restore from cloud';

  @override
  String get settings_cloud_sign_out => 'Sign out';

  @override
  String get settings_cloud_busy => 'Please wait…';

  @override
  String get settings_cloud_restore_prompt_title => 'Restore from backup?';

  @override
  String settings_cloud_restore_prompt_body(String when) {
    return 'Backup found from $when. Restore?';
  }

  @override
  String get settings_cloud_restore_keep_local => 'No, keep local';

  @override
  String get settings_cloud_restore_replace => 'Restore';

  @override
  String settings_cloud_restore_done(int count) {
    return 'Restored $count recipe(s)';
  }

  @override
  String get settings_export => 'Export to JSON';

  @override
  String get settings_import => 'Import from JSON';

  @override
  String get settings_import_undo => 'Undo last import';

  @override
  String settings_import_done(int count) {
    return 'Imported $count recipe(s)';
  }

  @override
  String get settings_import_undone => 'Import undone';

  @override
  String get settings_import_error => 'Couldn\'t read file';

  @override
  String get settings_stats => 'Stats';

  @override
  String get settings_show_welcome_again => 'Show welcome again';

  @override
  String get settings_reset_settings => 'Reset settings to defaults';

  @override
  String get settings_reset_settings_done => 'Settings reset';

  @override
  String get settings_delete_all => 'Delete all recipes and custom types';

  @override
  String get settings_delete_all_confirm_title => 'Delete everything?';

  @override
  String get settings_delete_all_confirm_body =>
      'All recipes and custom types will be deleted. This cannot be undone.';

  @override
  String get settings_delete_all_done => 'Everything deleted';

  @override
  String about_version(String v) {
    return 'Version $v';
  }

  @override
  String get about_repo => 'Source on GitHub';

  @override
  String get about_license => 'License: MIT';

  @override
  String get stats_recipes_total => 'Total recipes';

  @override
  String get stats_ingredients_total => 'Total ingredients';

  @override
  String get stats_total_weight => 'Sum of recipe weights';

  @override
  String get stats_top_ingredients => 'Top 5 ingredients';

  @override
  String get stats_top_tags => 'Top 5 tags';

  @override
  String get welcome_title => 'Hi, baker!';

  @override
  String get welcome_subtitle =>
      'Tortio rescales ingredients to the cake size you need.';

  @override
  String get welcome_bullet_add =>
      '«+ Recipe» button below — add a new one. You can start from a sample.';

  @override
  String get welcome_bullet_scale =>
      'Open a recipe → change diameter or weight → ingredients rescale automatically.';

  @override
  String get welcome_bullet_tiers =>
      'Tiered cake? Add a tier right in the recipe form — each tier has its own size.';

  @override
  String get welcome_bullet_sort =>
      '↕ — list sort. ⚙ — settings (theme, backups, stats).';

  @override
  String get welcome_bullet_inside =>
      'Inside a recipe: ✓ «I cooked it», ↗ «Export» (PDF / share), 🛒 «Shopping list».';

  @override
  String get welcome_button_start => 'Get started!';

  @override
  String get snack_recipe_saved => 'Recipe saved';

  @override
  String get snack_export_done => 'Exported';

  @override
  String get snack_no_internet => 'No internet';

  @override
  String get snack_drive_connected => 'Google Drive connected';

  @override
  String get snack_drive_uploaded => 'Uploaded to cloud';

  @override
  String get snack_drive_failed => 'Cloud error. Try again later';

  @override
  String update_banner_available(String version) {
    return 'Version $version available';
  }

  @override
  String get update_banner_tap => 'Tap to update';

  @override
  String update_banner_downloading(int percent) {
    return 'Downloading... $percent%';
  }

  @override
  String get update_error_generic => 'Update error. Check your internet.';

  @override
  String get update_error_no_internet => 'No internet. Check your connection.';

  @override
  String get update_error_install_permission =>
      'Allow install from unknown sources in Android settings.';
}
