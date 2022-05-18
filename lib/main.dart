import 'package:firevisor/pages/test_page.dart';
import 'package:firevisor/pages/user_pages/supervisor.dart';
import 'package:flutter/material.dart';
import 'package:firevisor/blocs/authenticate_bloc/authenticate_bloc.dart';
//import 'package:firevisor/pages/user_pages/administrator_page.dart';
import 'package:firevisor/pages/login_page.dart';
import 'package:firevisor/pages/user_page.dart';
import 'package:firevisor/user_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firevisor/blocs/guest_bloc/guest_bloc.dart';
import 'package:firevisor/blocs/staff_bloc/staff_bloc.dart';

import 'pages/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  ErrorWidget.builder = (FlutterErrorDetails details) => Center(
          child: Row(children: [
        Text(
          '資料已被護理人員刪除',
          style: TextStyle(fontSize: 50.0),
        ),
        Text(
          '請聯繫護理人員',
          style: TextStyle(fontSize: 50.0),
        ),
        //Text('',style: TextStyle(fontSize: 20.0,color: Colors.grey),),
      ]));
  runApp(MultiBlocProvider(
    providers: [
      BlocProvider<AuthenticateBloc>(
        create: (context) => AuthenticateBloc(userRepository: userRepository),
      ),
      BlocProvider<StaffBloc>(
        create: (context) => StaffBloc(userRepository: userRepository),
      ),
      BlocProvider<GuestBloc>(
        create: (context) => GuestBloc(userRepository: userRepository),
      ),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: Login.sName,
      //initialRoute: Supervisor.sName,
      routes: {
        Login.sName: (context) => Login(),
        User.sName: (context) => User(),
        TimeCurvePage.sName: (context) => TimeCurvePage(),
        Supervisor.sName: (context) => Supervisor(),
      },
      builder: (context, child) {
        final MediaQueryData data = MediaQuery.of(context);
        return MediaQuery(
          data: data.copyWith(textScaleFactor: 1.0),
          child: child,
        );
      },
    );
  }
}
