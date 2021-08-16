import 'package:ProExpress/reg_landing_page.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'dashboard_location.dart';


class LoginScreen extends StatefulWidget{
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

Widget _alertmessage(){
  return Center(
    child: Column(

    ),
  );
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          flexibleSpace: Container(
            margin: EdgeInsets.only(top: 10),
            child: Image.asset(
                "assets/PROExpress-logo.png",
              height: 120,
              width: 120,
            ),
          ),
          //title: Text("PROExpress"),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Container(
                  margin: EdgeInsets.only(top: 100),
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 50),
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: "Email",
                          prefixIcon: Icon(Icons.email_rounded),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 50,),
                      child: TextFormField(
                        obscureText: true,
                        decoration: InputDecoration(
                            labelText: "Password",
                            prefixIcon: Icon(Icons.lock),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 15),
                      //margin: EdgeInsets.only(top: 190),
                      height: MediaQuery.of(context).size.height / 15,
                      width: MediaQuery.of(context).size.width / 1.3,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageTransition(child: DashboardLocation(), type: PageTransitionType.rightToLeftWithFade),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Color(0xfffb0d0d),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),

                        child: Text(
                          "Login",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 8),
                      child: InkWell(
                        onTap: () {
                          showDialog(
                              context: context, builder: (BuildContext context) => AlertDialog(
                            content: (_alertmessage()),
                          )
                          );
                        },
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: Color(0xffFD3F40),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 10, top: 90),
                      child: Divider(
                        thickness: 5,
                        color: Colors.black,
                        indent: 52,
                        endIndent: 52,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 15),
                      height: MediaQuery.of(context).size.height / 15,
                      width: MediaQuery.of(context).size.width / 1.8,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageTransition(child: RegLandingPage(), type: PageTransitionType.rightToLeftWithFade),
                          );
                        },

                        style: ElevatedButton.styleFrom(
                          primary: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),

                        child: Text(
                          "Create a New Account",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ),
            ],
          ),
        ),
      )
    );
  }
}