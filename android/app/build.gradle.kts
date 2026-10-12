import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing key and passwords live outside the repo. Gradle reads the path
// to a properties file from the ZERO_KEYSTORE_PROPERTIES environment variable
// (D:\Android\keys\zero-keystore.properties on the owner's PC).
val keystorePropertiesPath: String? = System.getenv("ZERO_KEYSTORE_PROPERTIES")
val keystoreProperties = Properties()
var hasKeystoreProperties = false
if (keystorePropertiesPath != null) {
    val propertiesFile = File(keystorePropertiesPath)
    if (propertiesFile.exists()) {
        FileInputStream(propertiesFile).use { keystoreProperties.load(it) }
        hasKeystoreProperties = true
    }
}

android {
    namespace = "com.tonyvinsenty.smoking_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.tonyvinsenty.smoking_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasKeystoreProperties) {
            create("release") {
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            if (hasKeystoreProperties) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
    }
}

// An APK signed with another key won't install over the previous one (data would
// be lost), so release builds stop without the key. Debug builds/tests still work.
gradle.taskGraph.whenReady {
    val buildingRelease = allTasks.any { task ->
        task.name.contains("Release") &&
            (task.name.startsWith("assemble") ||
                task.name.startsWith("bundle") ||
                task.name.startsWith("package"))
    }
    if (buildingRelease && !hasKeystoreProperties) {
        throw GradleException(
            "Signing key not found: set ZERO_KEYSTORE_PROPERTIES " +
                "(see docs/how-to-install.md)"
        )
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}
