# RANDA.MKCOOL AIM SYNC SYSTEM v4.3.1 RC

Deployable Progressive Web App package for GitHub Pages.

## Project structure

```text
/
├── index.html
├── manifest.webmanifest
├── service-worker.js
├── README.md
├── .nojekyll
└── icons/
    ├── icon-192.png
    ├── icon-512.png
    └── maskable-512.png
```

## 1. Upload to GitHub

1. Create a new GitHub repository.
2. Upload the **contents of this folder** to the repository root.
3. Keep the `icons` folder exactly as supplied.
4. Commit the files to the `main` branch.

## 2. Enable GitHub Pages

1. Open the repository.
2. Go to **Settings → Pages**.
3. Under **Build and deployment**, choose **Deploy from a branch**.
4. Select `main` and `/ (root)`.
5. Save.

Your public address will normally be:

```text
https://YOUR-USERNAME.github.io/YOUR-REPOSITORY/
```

## 3. Install on Android

1. Open the published HTTPS address in Chrome.
2. Use the **INSTALL AIM SYNC** button if shown.
3. If it is not shown, open Chrome's menu and choose **Install app** or **Add to Home screen**.

## Updating

1. Edit/upload the changed files.
2. Change `CACHE_NAME` in `service-worker.js` for each release.
3. Commit to `main`.
4. GitHub Pages will redeploy.

## Important monetisation note

This package is a **static PWA**. Native Google AdMob SDK components cannot be inserted into GitHub Pages HTML. For AdMob, use a native Android/Flutter build. For the web/PWA version, use a web-compatible advertising product.

## Release notes

v4.3.1 fixes several issues in the earlier generated package:

- real range sliders for Base Sensitivity and FOV
- one-tap copy now produces a readable config block
- floating snackbar confirmation replaces blocking copy alerts
- locked profile and recalibration history load correctly after restart
- lock button can lock and unlock
- device profile and rotation mode now affect generation
- recalibration now updates MP and BR outputs
- safe app-only local-data clearing
- complete icon assets included
- corrected README formatting
