plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.task_manager_project_tekmob"
    compileSdk = flutter.compileSdkVersion

    // ✅ Tambahan penting agar bisa jalan dengan plugin yang butuh NDK 27
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // ✅ Pastikan ini sesuai dengan ID unik aplikasi kamu
        applicationId = "com.example.task_manager_project_tekmob"

        // ✅ Tetap menggunakan variabel dari flutter block
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Signing sementara menggunakan debug agar flutter run --release tetap bisa
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
