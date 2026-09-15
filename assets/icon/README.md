# App icon

Place the launcher icon here and it will be used to generate the
Android + iOS launcher icons.

## Steps

1. Put a **1024×1024 PNG** named `app_icon.png` in this folder:

   ```
   assets/icon/app_icon.png
   ```

   (Transparency is removed automatically on iOS.)

2. From the project root run:

   ```bash
   dart run flutter_launcher_icons
   ```

3. Rebuild the app:

   ```bash
   flutter run            # or
   flutter build ios      # then run from Xcode
   flutter build apk      # Android
   ```

## Optional: separate Android / iOS icons

If you want different icons per platform, place them here and point
`flutter_launcher_icons` in `pubspec.yaml` at them:

```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path_android: "assets/icon/android_icon.png"
  image_path_ios: "assets/icon/ios_icon.png"
```
