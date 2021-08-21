import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:proxpress/UI/dashboard_customer.dart';
import 'package:flutter/material.dart';
import 'package:proxpress/UI/load_screen.dart';
import 'package:proxpress/UI/login_screen.dart';
import 'package:proxpress/UI/reg_landing_page.dart';
import 'package:proxpress/UI/signup_courier.dart';
import 'package:proxpress/UI/signup_customer.dart';
import 'package:proxpress/UI/dashboard_location.dart';
import 'package:page_transition/page_transition.dart';
import 'UI/courier_bookmarks.dart';
import 'UI/customer_remarks.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(DevicePreview(builder: (context) => PROXpressApp()));
}

class PROXpressApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      //home: LoginScreen(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return PageTransition(child: LoadScreen(), type: PageTransitionType.fade);
            break;
          case '/loginScreen':
            return PageTransition(child: LoginScreen(), type: PageTransitionType.rightToLeftWithFade);
            break;
          case '/regLandingPage':
            return PageTransition(child: RegLandingPage(), type: PageTransitionType.rightToLeftWithFade);
            break;
          case '/signupCustomer':
            return PageTransition(child: SignupCustomer(), type: PageTransitionType.rightToLeftWithFade);
            break;
          case '/signupCourier':
            return PageTransition(child: SignupCourier(), type: PageTransitionType.rightToLeftWithFade);
            break;
          case '/dashboardLocation':
            return PageTransition(child: DashboardLocation(), type: PageTransitionType.rightToLeftWithFade);
            break;
          case '/dashboardCustomer':
            return PageTransition(child: DashboardCustomer(), type: PageTransitionType.rightToLeftWithFade);
            break;
          case '/courierBookmarks':
            return PageTransition(child: CourierBookmarks(), type: PageTransitionType.rightToLeftWithFade);
            break;
          case '/customerRemarks':
            return PageTransition(child: CustomerRemarks(), type: PageTransitionType.rightToLeftWithFade);
            break;
          default:
            return null;
        }
      },
    );
  }
}