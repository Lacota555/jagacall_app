buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Tidak perlu declare plugin Flutter di sini (sudah otomatis)
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

/*
 * Memindahkan build directory agar struktur Flutter tetap konsisten.
 * Ini standar dari template Flutter (Kotlin DSL).
 */
val flutterBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()

rootProject.layout.buildDirectory.value(flutterBuildDir)

subprojects {
    val subBuildDir: Directory = flutterBuildDir.dir(project.name)
    layout.buildDirectory.value(subBuildDir)
}

// Sama seperti Groovy: membersihkan folder build
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
