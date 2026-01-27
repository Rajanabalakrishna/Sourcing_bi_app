plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("com.google.firebase.crashlytics") version "3.0.2" apply false // if using crashlytics

    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.BharatIntelligence.supply_bi"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        isCoreLibraryDesugaringEnabled = true

        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.BharatIntelligence.supply_bi"
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../../"
}

dependencies {

    implementation(platform("com.google.firebase:firebase-bom:33.1.2"))



    // Add the dependency for the Google Analytics library
    implementation("com.google.firebase:firebase-analytics")
    // UPDATED: Version changed from 2.0.3 to 2.1.4 to satisfy flutter_local_notifications requirements
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")




}
