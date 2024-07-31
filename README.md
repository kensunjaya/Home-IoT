# Home IoT

Home IoT is a mobile application designed for the smart home ecosystem. This app allows users to fully customize access to home sensors, gates, doors, lights, and more. Users can also manage access for their family members.

## Getting Started

#### Pre-requisites
1. <a href="https://docs.flutter.dev/get-started/install">Flutter SDK</a>
2. Android / iOS emulator or physical device (API level 27+)
3. Visual Studio Code + [Flutter](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter) extension

Clone this repository then enter the directory
```
git clone https://github.com/kensunjaya/Home-IoT.git
cd Home-IoT
```


Install all required libraries
```
flutter pub get
```

Replace `firebase_options.dart` file in `lib/` folder with your own firebase credentials. </br>
Watch this [Add firebase to flutter](https://www.youtube.com/watch?v=FkFvQ0SaT1I) video for quick setup.


Power on emulator or connect to a physical device.
```
flutter devices
```



Make sure your device is already listed, then execute the following command:
```
flutter run
```


