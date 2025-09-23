import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.dndmasteraid.app"
    compileSdk = 35  // Alto per compilazione
    ndkVersion = "27.0.12077973"  // Versione richiesta dai plugin

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_1_8.toString()
    }

    signingConfigs {
        create("release") {
            val keystorePropertiesFile = rootProject.file("key.properties")
            if (keystorePropertiesFile.exists()) {
                val keystoreProperties = Properties()
                keystoreProperties.load(keystorePropertiesFile.inputStream())

                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    defaultConfig {
        applicationId = "com.dndmasteraid.app"
        minSdk = 21
        targetSdk = 31  // Android 12 - bilanciato sicurezza/compatibilità
        versionCode = 4
        versionName = "1.0.4"

        // Enable multidex support for large apps
        multiDexEnabled = true
    }

    lint {
        checkReleaseBuilds = true
        abortOnError = false
        // Ignore obsolete target SDK warnings for now
        disable.add("ExpiredTargetSdkVersion")
    }

    buildTypes {
        release {
            // Disable minification to avoid R8 issues for now
            isMinifyEnabled = false
            isShrinkResources = false
            signingConfig = signingConfigs.getByName("release")
        }
        debug {
            isDebuggable = true
            applicationIdSuffix = ".debug"
        }
    }
}

flutter {
    source = "../.."
}
