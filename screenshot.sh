# Runs screenshot_test on all devices.

# android device: emulator-5554

for device in "iPhone 12 Pro Max" "iPhone 8 Plus" "iPad Pro (12.9-inch) (4th generation)" "iPad Pro (12.9-inch) (2nd generation)"; do
  echo "Running on $device"
  xcrun simctl boot "$device"
  flutter test \
    --device-id="$device" \
    --dart-define=device="$device" \
    integration_test/screenshot_test.dart
done
