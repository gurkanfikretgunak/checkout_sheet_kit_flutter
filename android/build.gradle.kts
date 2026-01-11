plugins {
    id("com.android.library")
    id("org.jetbrains.kotlin.android")
}

group = "com.shopify.checkout_sheet_kit_flutter"
version = "1.0.0"

android {
    namespace = "com.shopify.checkout_sheet_kit_flutter"
    compileSdk = 34

    defaultConfig {
        minSdk = 23
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
            isMinifyEnabled = false
        }
    }
}

dependencies {
    // Shopify Checkout Sheet Kit for Android
    implementation("com.shopify:checkout-sheet-kit:3.0.5")
    
    // AndroidX dependencies
    implementation("androidx.activity:activity-ktx:1.8.2")
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.7.0")
    
    // Kotlin coroutines
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3")
}
