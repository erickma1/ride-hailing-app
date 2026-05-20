plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// android {
//     namespace = "com.example.ride_hailing_app"
//     compileSdk = flutter.compileSdkVersion
//     ndkVersion = flutter.ndkVersion

//     compileOptions {
//         sourceCompatibility = JavaVersion.VERSION_17
//         targetCompatibility = JavaVersion.VERSION_17
//     }

//     kotlinOptions {
//         jvmTarget = JavaVersion.VERSION_17.toString()
//     }

//     // defaultConfig {
//     //     // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
//     //     applicationId = "com.example.ride_hailing_app"
//     //     // You can update the following values to match your application needs.
//     //     // For more information, see: https://flutter.dev/to/review-gradle-config.
//     //     minSdk = flutter.minSdkVersion
//     //     targetSdk = flutter.targetSdkVersion
//     //     versionCode = flutter.versionCode
//     //     versionName = flutter.versionName
//     // }
//         compileSdkVersion 34
    
//     defaultConfig {
//         applicationId "com.example.ride_hailing_app"
//         minSdkVersion 21
//         targetSdkVersion 34
//         versionCode 1
//         versionName "1.0.0"
//     }

//     buildTypes {
//         release {
//             // TODO: Add your own signing config for the release build.
//             // Signing with the debug keys for now, so `flutter run --release` works.
//             signingConfig = signingConfigs.getByName("debug")
//         }
//     }


// }

android {
    namespace = "com.example.ride_hailing_app"
    compileSdk = 36

    ndkVersion = flutter.ndkVersion

    defaultConfig {
        applicationId = "com.example.ride_hailing_app"
        minSdk = flutter.minSdkVersion
        targetSdk = 34
        versionCode = 1
        versionName = "1.0.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
