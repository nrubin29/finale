# Runs screenshot_test on all devices.

RUN_IOS=true
RUN_MACOS=true
RUN_ANDROID=true

flutter_test() { # $1 = device name, $2 = device id, $3 = censor images (true by default)
  echo "Running on $1"
  flutter test \
    --device-id="$2" \
    --dart-define=device="$1" \
    --dart-define=censorImages="${3:-true}" \
    --dart-define=isScreenshotTest=true \
    --update-goldens \
    integration_test/screenshot_test.dart
}

# iOS
if [ $RUN_IOS = true ]; then
  for device in "iPhone 16 Pro Max" "iPad Pro 13-inch (M4)"; do
    xcrun simctl boot "$device"
    flutter_test "$device" "$device"
  done

  # Get uncensored images for the landing page
  xcrun simctl boot "iPhone 16 Pro"
  flutter_test "iPhone 16 Pro" "iPhone 16 Pro" "false"
fi

# macOS
# macOS can't write to the Documents folder, so we have to put the screenshots
# in the Downloads folder and then move them.
SOURCE="$HOME/Downloads/macOS"
TARGET="$HOME/Documents/DartProjects/finale/screenshots/macOS"

if [ $RUN_MACOS = true ]; then
  flutter_test "macOS" "macOS"
  mkdir "$TARGET"
  mv "$SOURCE"/* "$TARGET"
  rm -r "$SOURCE"
  (
    cd "$TARGET" || exit
    sips -c 1600 2560 ./*.png
  )
fi

# Android
if [ $RUN_ANDROID = true ]; then
  for device in "Pixel_8_API_35" "7_WSVGA_Tablet_API_34" "Medium_Tablet"; do
    ~/Library/Android/sdk/emulator/emulator -avd "$device" &
    sleep 5
    flutter_test "$device" "emulator-5554"
    sleep 5
    killall qemu-system-aarch64
    sleep 5
  done
fi
