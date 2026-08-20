import java.io.FileInputStream
import java.util.Properties

// Firma de release. Los datos viven en android/key.properties, que NO va a git.
// Si el fichero no está (por ejemplo en una máquina recién clonada), la app
// sigue compilando con la firma de depuración en vez de romper el build.
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
val hayKeystore = keystorePropertiesFile.exists()
if (hayKeystore) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.prototipe1"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.prototipe1"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hayKeystore) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // Con la clave propia, la APK sale con la MISMA firma se compile en
            // el Mac o en Windows. Con la de depuración no: cada máquina genera
            // la suya, y entonces Android no deja actualizar la app instalada y
            // el login con Google falla (su SHA-1 no coincide con el de Firebase).
            signingConfig = if (hayKeystore) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }

            // Blindaje del binario. R8 elimina el codigo Java/Kotlin que no se
            // usa y renombra lo que queda, de modo que abrir la APK ya no
            // muestra nombres de clases y metodos legibles. `shrinkResources`
            // descarta ademas los recursos que ningun codigo referencia.
            //
            // Ojo: R8 NO toca el codigo Dart, que va compilado a codigo nativo;
            // ese se ofusca aparte con --obfuscate al compilar.
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

flutter {
    source = "../.."
}
