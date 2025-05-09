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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserModel?>.value(
      value: AuthService().user,
      initialData: null,
      child: MaterialApp(
        title: 'Einkaufslisten',
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
                ModalRoute.of(context)!.settings.arguments
                    as Map<String, dynamic>;
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
