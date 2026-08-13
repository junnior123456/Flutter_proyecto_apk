# Reglas de R8 para PawFinder.
#
# El plugin de Gradle de Flutter ya aporta las reglas del motor; lo de aqui es
# una red de seguridad para las librerias que usan reflexion, que es donde la
# minificacion suele romper cosas en tiempo de ejecucion (no al compilar).

# --- Flutter -----------------------------------------------------------------
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# --- Firebase y servicios de Google ------------------------------------------
# firebase_core/auth/storage/messaging y google_sign_in resuelven clases por
# nombre en tiempo de ejecucion: si R8 las renombra, fallan al arrancar.
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# --- Metadatos que varias librerias leen por reflexion ------------------------
-keepattributes *Annotation*, Signature, InnerClasses, EnclosingMethod

# --- Trazas de fallo legibles sin revelar el nombre real del fichero ----------
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
