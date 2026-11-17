# elapse
The elapse app.  
![elapse logo](./Promo%20Material/App%20Store%20ScreenShots/Frame%20130.png)
If you have any questions, please join our discord server! https://discord.gg/2BDqbeqrJx  
We hope you enjoy using elapse.  
  
Google Play Store: [https://play.google.com/store/apps/details?id=com.elapseapp.elapse_app](https://play.google.com/store/apps/details?id=com.elapseapp.elapse_app)  
Apple App Store: [https://apps.apple.com/ca/app/elapse/id6596757269](https://apps.apple.com/ca/app/elapse/id6596757269)  

---  
All app release files are stored within the elapse_app folder.  
The `dev` branch is used for active development, `main` for our production release.  

Elapse utilizes flutter to program and build, ensure [flutter is installed](https://docs.flutter.dev/get-started/install) on your system.  
We utilize Android Studio as our primary form of testing Elapse. After setting up a virtual device in Android Studio, `cd` into the `elapse_app` folder, and run the `flutter run` command to open a debug instance. After running this command for the first time, it should install all packages automatically.
  
We are using Firebase Auth and Firebase Firestore to manage user data and accounts.  
Add the below `firebase_token.dart` file to `/elapse_app/lib/extras`, containing your tokens taken from your firebase setup.  
You do not need to fill out every key, use with android studio should only require the android tokens, xcode requires ios. 
```dart
class firebaseTokens {
  static const messagingSenderID = '';

  // web
  static const web_api_key = '';
  static const web_app_id = '';
  
  // android
  static const android_api_key = '';
  static const android_app_id = '';

  // ios
  static const ios_api_key = '';
  static const ios_app_id = '';

  // macos
  static const mac_api_key = '';
  static const mac_app_id = '';

  // windows
  static const windows_api_key =  '';
  static const windows_app_id = '';
}
```  
  
You will also need to add a `token.dart` file to `/elapse_app/lib/extras` which contains your tokens from the [VEX Events API](https://events.vex.com/api/v2). Elapse utilizes several tokens to prevent getting ratelimited by VEX Events, but only 1 token should be required.
```dart
import 'dart:math';

String getToken() {
  List<String> tokens = [
    "Bearer ",
    "Bearer ",
    "Bearer ",
    "Bearer ",
    "Bearer ",
    "Bearer ",
    "Bearer ",
    "Bearer ",
  ];

  int randomIndex = Random().nextInt(tokens.length);
  return tokens[randomIndex];
}

String getVexDexToken() {
  return "Bearer ";
}
```  
In addition, Elapse pulls TrueSkill, OPR/DPR/CCWM, and skills-ranking data from [VexDex](https://github.com/elapse-app/VexDex), our own service hosted at `https://vexdex.fly.dev`. Add the `getVexDexToken()` function above to your `token.dart`, returning a bearer token minted via VexDex's `manage_tokens.py create` CLI against its database.