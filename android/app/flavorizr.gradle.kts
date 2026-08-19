import com.android.build.gradle.AppExtension

val android = project.extensions.getByType(AppExtension::class.java)

android.apply {
    flavorDimensions("flavor-type")

    productFlavors {
        create("dev") {
            dimension = "flavor-type"
            applicationId = "com.example.ilms.dev"
            resValue(type = "string", name = "app_name", value = "ILMS Dev")
        }
        create("stg") {
            dimension = "flavor-type"
            applicationId = "com.example.ilms.stg"
            resValue(type = "string", name = "app_name", value = "ILMS Stg")
        }
        create("prod") {
            dimension = "flavor-type"
            applicationId = "com.example.ilms"
            resValue(type = "string", name = "app_name", value = "ILMS")
        }
    }

    buildFeatures.resValues = true
}