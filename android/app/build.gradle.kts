plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.scan_learn"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.example.scan_learn"
        minSdk = 23
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

dependencies {
    // Firebase BoM (manages versions automatically)
    implementation(platform("com.google.firebase:firebase-bom:33.1.2"))

    // Firebase Authentication
    implementation("com.google.firebase:firebase-auth")

    // Google Sign-In
    implementation("com.google.android.gms:play-services-auth:21.2.0")

    // (Optional) Firebase Analytics
    implementation("com.google.firebase:firebase-analytics")

    // (Optional) Firestore
    implementation("com.google.firebase:firebase-firestore")

    // (Optional) Realtime Database
    implementation("com.google.firebase:firebase-database")
}
