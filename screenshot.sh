# Runs screenshot_test on all devices.

flutter_test() {  # $1 = device name, $2 = device id, $3 = censor images (true by default)
  echo "Running on $1"
  flutter test \
    --device-id="$2" \
    --dart-define=device="$1" \
    --dart-define=censorImages="$3" \
    --update-goldens \
    integration_test/screenshot_test.dart
}

# iOS
for device in "iPhone 12 Pro Max" "iPhone 8 Plus" "iPad Pro (12.9-inch) (4th generation)" "iPad Pro (12.9-inch) (2nd generation)"; do
  xcrun simctl boot "$device"
  flutter_test "$device" "$device"
done

# Get uncensored images for the landing page
xcrun simctl boot "iPhone 12 Pro"
flutter_test "iPhone 12 Pro" "iPhone 12 Pro" "false"

# macOS
flutter_test "macOS" "macOS"

# Android
for device in "Pixel_3_API_29" "7_inch_tablet_API_29" "10_inch_tablet_API_29"; do
  ~/Library/Android/sdk/emulator/emulator -avd "$device" &
  sleep 5
  flutter_test "$device" "emulator-5554"
  killall qemu-system-x86_64
  sleep 5
done
