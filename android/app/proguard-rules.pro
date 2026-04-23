# Flutter wrapper — оставляем основные классы.
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# permission_handler / open_filex / path_provider / package_info_plus
# работают через method channels — не обфусцируем.
-keep class com.baseflow.permissionhandler.** { *; }
-keep class com.crazecoder.openfile.** { *; }
-keep class com.dexterous.** { *; }

# Dio + http используют рефлексию в некоторых местах.
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes Exceptions

# share_plus (Android intent helpers)
-keep class dev.fluttercommunity.plus.share.** { *; }

# Flutter ссылается на Play Core SDK для deferred components, но мы его
# не используем. Подавляем R8 missing class warnings, иначе release-билд
# падает с "Missing class com.google.android.play.core...".
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }
