import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taxi/screen_routs.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.0),
            boldText: false,
          ),
          child: MaterialApp(
            title: 'Taxi App',
            debugShowCheckedModeBanner: false,
            routes: ScreenRouteList.screenRoutes,
            home: null,
            theme: ThemeData(
              primarySwatch: Colors.grey,
              textSelectionTheme: const TextSelectionThemeData(
                cursorColor: Colors.black,
                selectionHandleColor: Colors.grey,
                selectionColor: Color.fromARGB(255, 0, 0, 0),
              ),
              useMaterial3: false,
            ),
            initialRoute: '/splash',
          ),
        );
      },
    );
  }
}
