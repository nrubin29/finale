# Runs screenshot_test on all devices.

RUN_IOS=true
RUN_MACOS=true
RUN_ANDROID=true

flutter_test() { # $1 = device name, $2 = device id, $3 = censor images (true by default)
  echo "Running on $1"
  flutter test \
    --device-id="$2" \
    --dart-define=device="$1" \
    --dart-define=censorImages="$3" \
    --update-goldens \
    integration_test/screenshot_test.dart
}

# iOS
if [ $RUN_IOS = true ]; then
  for device in "iPhone 12 Pro Max" "iPhone 8 Plus" "iPad Pro (12.9-inch) (5th generation)" "iPad Pro (12.9-inch) (2nd generation)"; do
    xcrun simctl boot "$device"
    flutter_test "$device" "$device"
  done

  # Get uncensored images for the landing page
  xcrun simctl boot "iPhone 12 Pro"
  flutter_test "iPhone 12 Pro" "iPhone 12 Pro" "false"
fi

# macOS
# macOS can't write to the Documents folder, so we have to put the screenshots
# in the Downloads folder and then move them.
SOURCE="$HOME/Downloads/macOS"
TARGET="$HOME/Documents/DartProjects/finale/screenshots/macOS"

if [ $RUN_MACOS = true ]; then
  flutter_test "macOS" "macOS"
  mkdir "$TARGET"
  mv $SOURCE/* $TARGET
  rm -r "$SOURCE"
  (
    cd "$TARGET" || exit
    sips -c 1600 2560 ./*.png
  )
fi

# Android
# Android can't write to the Documents folder, so we have to put the screenshots
# on the SD card and then pull them.
if [ $RUN_ANDROID = true ]; then
  for device in "Pixel_5_API_31" "7_WSVGA_Tablet_API_31" "10.1_WXGA_Tablet_API_31"; do
    ~/Library/Android/sdk/emulator/emulator -avd "$device" &
    sleep 5
    ~/Library/Android/sdk/platform-tools/adb shell rm -rR "sdcard/Documents/$device"
    sleep 5
    flutter_test "$device" "emulator-5554"
    sleep 5
    (
      cd screenshots || exit
      ~/Library/Android/sdk/platform-tools/adb pull "sdcard/Documents/$device"
    )
    sleep 5
    ~/Library/Android/sdk/platform-tools/adb shell rm -rR "sdcard/Documents/$device"
    sleep 5
    killall qemu-system-aarch64
    sleep 5
  done
fi
