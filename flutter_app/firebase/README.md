# Firebase Android configuration

Place the Firebase Console download here with the exact filename:

`google-services.json`

Expected local path:

`flutter_app/firebase/google-services.json`

This path is intentionally Git-ignored. Do not commit the file to this public repository.

The file contains Firebase project identifiers rather than a server-side admin secret, but keep it owner-controlled. It must contain the registered Android package `systems.randamkcool.randa_mkcool_aim_sync`; the bootstrap script fails closed on a mismatch.

After the Android wrapper is generated, run:

```bash
bash configure_firebase_android.sh
```

The script copies the config into `android/app/google-services.json` and adds the current Google Services Gradle plugin to the generated Kotlin DSL Gradle files.

Do not place service-account keys, private keys, bank data, or other credentials in this folder.

For GitHub Actions, use the encrypted repository secret `FIREBASE_ANDROID_GOOGLE_SERVICES_JSON_B64` containing the base64-encoded file. The workflow materializes it only during the Android check and removes the temporary copies afterward.
