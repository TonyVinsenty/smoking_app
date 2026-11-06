import java.io.FileInputStream
import java.util.Properties
import groovy.json.JsonSlurper

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

// Native Firebase must initialize before Dart when FCM wakes a terminated app.
val firebaseConfigFile = rootProject.file("../firebase/google-services.json")
val firebaseConfig = if (firebaseConfigFile.exists()) JsonSlurper().parse(firebaseConfigFile) as Map<*, *> else null
val firebaseProject = firebaseConfig?.get("project_info") as? Map<*, *>
val firebaseClient = (firebaseConfig?.get("client") as? List<*>)?.map { it as Map<*, *> }?.firstOrNull {
    val info = it["client_info"] as? Map<*, *>
    val androidInfo = info?.get("android_client_info") as? Map<*, *>
    androidInfo?.get("package_name") == "com.tonyvinsenty.smoking_app"
}

android {
    buildFeatures { resValues = true }
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
        if (firebaseClient != null && firebaseProject != null) {
            val info = firebaseClient["client_info"] as Map<*, *>
            val key = (firebaseClient["api_key"] as List<*>).first() as Map<*, *>
            resValue("string", "google_app_id", info["mobilesdk_app_id"].toString())
            resValue("string", "google_api_key", key["current_key"].toString())
            resValue("string", "gcm_defaultSenderId", firebaseProject["project_number"].toString())
            resValue("string", "project_id", firebaseProject["project_id"].toString())
            // FlutterFire compares these optional values with FirebaseOptions during startup.
            // Omitting an existing bucket makes the native default app look like a different app.
            firebaseProject["storage_bucket"]?.let {
                resValue("string", "google_storage_bucket", it.toString())
            }
            firebaseProject["firebase_url"]?.let {
                resValue("string", "firebase_database_url", it.toString())
            }
        } else {
            throw GradleException("Firebase Android config missing: firebase/google-services.json")
        }
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
