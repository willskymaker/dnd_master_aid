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
            // Disable minification for now to avoid R8 issues
            isMinifyEnabled = false
            isShrinkResources = false
            signingConfig = signingConfigs.getByName("debug")
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
