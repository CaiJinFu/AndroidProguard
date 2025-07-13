plugins {
    alias(libs.plugins.androidApplication)
    alias(libs.plugins.jetbrainsKotlinAndroid)
    id("kotlin-parcelize")
}

android {
    signingConfigs {
        create("keyStore") {
            storeFile = file("..\\keystore.jks")
            storePassword = "123456"
            keyAlias = "aaa"
            keyPassword = "123456"
        }
    }
    namespace = "com.yuanxiaocai.androidproguard"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.yuanxiaocai.androidproguard"
        minSdk = 24
        targetSdk = 33
        versionCode = 1
        versionName = "1.0"

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    buildTypes {
        val signConfig = signingConfigs.getByName("keyStore")
        debug {
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
                file("proguard-rules-generated.pro")
            )
            signingConfig = signConfig
        }
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
                file("proguard-rules-generated.pro")
            )
            signingConfig = signConfig
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }
    kotlinOptions {
        jvmTarget = "1.8"
    }
    buildFeatures {
        viewBinding = true
    }
}
val proguardSource = file("proguard-rules-base.pro")
val proguardTarget = file("proguard-rules-generated.pro")
val generateProguardRules by tasks.registering {
    doLast {
        println("➡️ 正在生成混淆规则...")
        // 正则规则，删除以 `-keep class com.example.debug.` 开头的规则
        val deleteRegex = Regex("""^-keep class com\.example\.debug\..*\{.*\}$""")
        // 过滤行
        val filteredLines = proguardSource.readLines()
            .filterNot { it.trim().matches(deleteRegex) }
        // 写入目标文件
        proguardTarget.writeText(filteredLines.joinToString("\n"))

        println("✅ 生成完成，已写入到 ${proguardTarget.absolutePath}")
    }
}

tasks.named("preBuild") {
    dependsOn(generateProguardRules)
}

dependencies {

    implementation(libs.androidx.core.ktx)
    implementation(libs.androidx.appcompat)
    implementation(libs.material)
    implementation(libs.androidx.constraintlayout)
    implementation(libs.androidx.navigation.fragment.ktx)
    implementation(libs.androidx.navigation.ui.ktx)
    implementation(libs.androidx.activity)
    testImplementation(libs.junit)
    androidTestImplementation(libs.androidx.junit)
    androidTestImplementation(libs.androidx.espresso.core)
}