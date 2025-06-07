import 'package:einkaufslite/models/user.dart';
import 'package:einkaufslite/screens/authenticate/authenticate_screen.dart';
import 'package:einkaufslite/screens/authenticate/register_screen.dart';
import 'package:einkaufslite/screens/einkauf/article_screen.dart';
import 'package:einkaufslite/screens/einkauf/einkauf_screen.dart';
import 'package:einkaufslite/screens/home/home_screen.dart';
import 'package:einkaufslite/screens/wrapper.dart';
import 'package:einkaufslite/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAnalytics.instance.logEvent(name: 'app_started');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserModel?>.value(
      value: AuthService().user,
      initialData: null,
      child: MaterialApp(
        title: 'Einkaufslisten',
        debugShowCheckedModeBanner: false,
        navigatorObservers: [observer], // <--- Wichtig für automatisches Screen-Tracking

        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 35, 110, 248),
            brightness: Brightness.light,
          ),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
          ),
        ),

        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
        ),

        themeMode: ThemeMode.light,

        initialRoute: '/',
        routes: {
          '/': (context) => Wrapper(),
          '/login': (context) => const Authenticate(),
          '/register': (context) => const Register(),
          '/home': (context) => const Home(),

          '/sale': (context) {
            final uid = ModalRoute.of(context)?.settings.arguments as String;
            return EinkaufScreen(uid: uid);
          },

          '/article': (context) {
            final args =
                ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
            return EditArticleScreen(
              listId: args['listId'],
              articleId: args['articleId'],
              article: args['article'],
            );
          },
        },
      ),
    );
  }
}

