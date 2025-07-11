// firebase
// import 'package:device_preview/device_preview.dart';
import 'dart:developer';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:revivals/providers/class_store.dart';
import 'package:revivals/providers/create_item_provider.dart';
import 'package:revivals/providers/payment_option_provider.dart';
import 'package:revivals/providers/set_price_provider.dart';
import 'package:revivals/screens/authenticate/authenticate.dart';
import 'package:revivals/screens/authenticate/sign_in_up.dart';
import 'package:revivals/screens/help_centre/faqs.dart';
import 'package:revivals/screens/help_centre/how_it_works.dart';
import 'package:revivals/screens/help_centre/sizing_guide.dart';
import 'package:revivals/screens/help_centre/who_are_we.dart';
import 'package:revivals/screens/home_page.dart';
import 'package:revivals/screens/splash/custom_splash_screen.dart';
import 'package:revivals/services/notification_service.dart';
import 'package:revivals/shared/animated_logo_spinner.dart';
import 'package:revivals/theme.dart';

import 'firebase_options.dart';

Future main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
  log('Stripe publishable key: ${Stripe.publishableKey}');
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Allow only portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Firebase App Check
  await FirebaseAppCheck.instance.activate(
    // For Android, use Play Integrity in production, debug for development
    androidProvider:
        kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
    // For iOS, use DeviceCheck in production, debug for development
    appleProvider: kDebugMode ? AppleProvider.debug : AppleProvider.deviceCheck,
    // For Web, use reCAPTCHA (replace with your actual site key for production)
    webProvider: ReCaptchaV3Provider(
        '6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI'), // Test key
  );

  await NotificationService.requestPermission();
  NotificationService.initializeNotifications();
  NotificationService.init();

  runApp(
    // DevicePreview(
    // enabled: true,
    // tools: const [
    //   ...DevicePreview.defaultTools,
    // DevicePreviewTool.showPerformanceOverlay,
    // DevicePreviewTool.showGridOverlay,
    // DevicePreviewTool.showPaintBaselines,
    // DevicePreviewTool.showRepaintRainbow,
    // ],
    // builder: (context) =>
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ItemStoreProvider()),
        ChangeNotifierProvider(create: (_) => CreateItemProvider()),
        ChangeNotifierProvider(create: (_) => SetPriceProvider()),
        ChangeNotifierProvider(create: (_) => PaymentOptionProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Preload logo for better spinner performance
    WidgetsBinding.instance.addPostFrameCallback((_) {
      LogoImageCache.preloadLogo(context);
    });

    return MaterialApp(
      useInheritedMediaQuery: true,
      // locale: DevicePreview.locale(context),
      // builder: DevicePreview.appBuilder,
      debugShowCheckedModeBanner: false,
      theme: primaryTheme,
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        '/': (context) => const CustomSplashScreen(),
        '/home': (context) => const HomePage(),
        // When navigating to the "/second" route, build the SecondScreen widget.
        '/faqs': (context) => const FAQs(),
        '/howItWorks': (context) => const HowItWorks(),
        '/whatIs': (context) => const WhoAreWe(),
        '/sizingGuide': (context) => const SizingGuide(),
        // '/dateAddedItems': (context) => const DateAddedItems(),
        '/login': (context) => const Authenticate(), // <-- Add this line
        '/authenticate': (context) => const Authenticate(), // <-- Add this line
        '/sign_in': (context) =>
            const GoogleSignInScreen(), // <-- Add this line
      },
    );
  }
}

Widget buildImage(String? imageUrl) {
  if (imageUrl != null && imageUrl.isNotEmpty) {
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Image.asset(
        'assets/img/items/No_Image_Available.jpg',
        fit: BoxFit.cover,
      ),
    );
  } else {
    return Image.asset(
      'assets/img/items/No_Image_Available.jpg',
      fit: BoxFit.cover,
    );
  }
}
