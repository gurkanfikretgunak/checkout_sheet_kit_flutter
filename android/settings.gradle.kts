rootProject.name = 'checkout_sheet_kit_flutter'

pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
    repositories {
        google()
        mavenCentral()
        // Shopify's Maven repository
        maven { url = uri("https://jitpack.io") }
    }
}
