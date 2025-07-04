# Firebase App Check Integration

This document outlines the Firebase App Check integration that has been implemented in your Flutter app.

## What is Firebase App Check?

Firebase App Check helps protect your API resources from abuse by preventing unauthorized clients from accessing your backend resources. It works with Firebase services like Firestore, Realtime Database, Cloud Storage, and Cloud Functions.

## Implementation Details

### 1. Dependencies Added
- `firebase_app_check: ^0.3.1+3` has been added to `pubspec.yaml`

### 2. Files Modified/Created

#### `lib/main.dart`
- Added Firebase App Check imports
- Initialized App Check after Firebase initialization
- Configured different providers for different platforms:
  - **Android**: Debug provider for development, Play Integrity for production
  - **iOS**: Debug provider for development, DeviceCheck for production
  - **Web**: reCAPTCHA v3 provider

#### `lib/services/app_check_service.dart` (New file)
- Created a service class for App Check operations
- Includes methods for initialization, token retrieval, and configuration

### 3. Platform-Specific Configuration

#### Android Configuration
- **Development**: Uses `AndroidProvider.debug`
- **Production**: Uses `AndroidProvider.playIntegrity`
- Play Integrity API requires Google Play Services

#### iOS Configuration
- **Development**: Uses `AppleProvider.debug`
- **Production**: Uses `AppleProvider.deviceCheck`
- DeviceCheck is automatically available on iOS 11+

#### Web Configuration
- Uses reCAPTCHA v3 provider
- Currently configured with a test site key: `6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI`

## Next Steps for Production

### 1. Firebase Console Configuration
1. Go to your Firebase Console
2. Navigate to Project Settings > App Check
3. Register your apps for App Check:
   - **Android**: Enable Play Integrity API
   - **iOS**: Enable DeviceCheck
   - **Web**: Set up reCAPTCHA v3

### 2. reCAPTCHA Setup for Web (if using web platform)
1. Go to [Google reCAPTCHA](https://www.google.com/recaptcha/)
2. Create a new reCAPTCHA v3 site
3. Add your domain(s)
4. Replace the test key in `main.dart` with your actual site key
5. Add the site key to your Firebase Console App Check settings

### 3. Android Production Setup
1. In Firebase Console, go to App Check
2. Enable Play Integrity API for your Android app
3. The app will automatically use Play Integrity in production builds

### 4. iOS Production Setup
1. In Firebase Console, go to App Check
2. Enable DeviceCheck for your iOS app
3. DeviceCheck will automatically work in production

### 5. Testing
- In development, debug providers are used automatically
- Test your app to ensure Firebase services still work correctly
- Monitor App Check metrics in Firebase Console

## Debug Tokens (Development Only)

For development and testing, you can generate debug tokens:

1. Run your app in debug mode
2. Check the console logs for App Check debug token
3. Add the debug token to Firebase Console > App Check > Apps > Debug tokens

## Security Considerations

1. **Never use debug providers in production**
2. **Keep your reCAPTCHA site key secure**
3. **Monitor App Check metrics regularly**
4. **Set up alerts for suspicious activity**

## Troubleshooting

### Common Issues:
1. **App Check token errors**: Ensure proper configuration in Firebase Console
2. **reCAPTCHA not working**: Verify site key and domain configuration
3. **Play Integrity failures**: Ensure Google Play Services are available
4. **DeviceCheck failures**: Verify iOS version compatibility

### Debug Commands:
```dart
// Get current App Check token
final token = await AppCheckService.getToken();
print('App Check Token: $token');

// Enable token auto-refresh
AppCheckService.setTokenAutoRefreshEnabled(true);
```

## Benefits

1. **Enhanced Security**: Protects against API abuse and unauthorized access
2. **Automatic Protection**: Works seamlessly with Firebase services
3. **Platform Optimized**: Uses the best available attestation method for each platform
4. **Minimal Performance Impact**: Lightweight and efficient

## Monitoring

Monitor your App Check usage in the Firebase Console:
- View request metrics
- Track token generation
- Monitor for anomalies
- Set up alerts for unusual activity

---

**Note**: This integration uses debug providers for development. Make sure to properly configure production providers before releasing your app.
