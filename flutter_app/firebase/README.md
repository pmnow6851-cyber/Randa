# Firebase Android configuration

Place the Firebase Console download here with the exact filename:

`google-services.json`

Expected path:

`flutter_app/firebase/google-services.json`

The file contains Firebase project identifiers rather than a server-side secret, but it must match the Android package registered in Firebase.

After the Android wrapper is generated, run:

```bash
bash configure_firebase_android.sh
```

The script copies the config into `android/app/google-services.json` and adds the current Google Services Gradle plugin to the generated Kotlin DSL Gradle files.

Do not place service-account keys, private keys, bank data, or other credentials in this folder.
