import com.android.build.gradle.AppExtension

val android = project.extensions.getByType(AppExtension::class.java)

fun googleMapsApiKey(flavorName: String): String {
    val envFile = rootProject.file("../.env.$flavorName")
    val fromEnvFile = if (envFile.exists()) {
        envFile.readLines()
            .firstOrNull { it.startsWith("GOOGLE_MAPS_API_KEY=") }
            ?.substringAfter('=')
            ?.trim()
            ?.trim('"')
    } else {
        null
    }

    return fromEnvFile?.takeIf { it.isNotEmpty() }
        ?: providers.gradleProperty("GOOGLE_MAPS_API_KEY").orNull
        ?: System.getenv("GOOGLE_MAPS_API_KEY").orEmpty()
}

android.apply {
    flavorDimensions("flavor-type")

    productFlavors {
        create("dev") {
            dimension = "flavor-type"
            applicationId = "com.example.ilms.dev"
            resValue(type = "string", name = "app_name", value = "ILMS Dev")
            resValue(type = "string", name = "google_maps_api_key", value = googleMapsApiKey("dev"))
        }
        create("stg") {
            dimension = "flavor-type"
            applicationId = "com.example.ilms.stg"
            resValue(type = "string", name = "app_name", value = "ILMS Stg")
            resValue(type = "string", name = "google_maps_api_key", value = googleMapsApiKey("stg"))
        }
        create("prod") {
            dimension = "flavor-type"
            applicationId = "com.example.ilms"
            resValue(type = "string", name = "app_name", value = "ILMS")
            resValue(type = "string", name = "google_maps_api_key", value = googleMapsApiKey("prod"))
        }
    }

    buildFeatures.resValues = true
}