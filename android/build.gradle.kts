buildscript {
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        // Android Gradle Plugin
        classpath("com.android.tools.build:gradle:8.9.1")
        // Kotlin Gradle Plugin
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:2.1.0")
        // Google Services Plugin
        classpath("com.google.gms:google-services:4.4.4")
    }
}

plugins {
    id("com.google.gms.google-services") version "4.4.4" apply false
    id("dev.flutter.flutter-gradle-plugin") version "1.0.0" apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}