import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_time_tracker/authorization.dart';
import 'package:project_time_tracker/mainPage.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: Navigator(),
    );
  }
}


class Navigator extends StatefulWidget {
  @override
  _NavigatorState createState() => _NavigatorState();
}

class _NavigatorState extends State<Navigator> {
  bool signedIn = false;
  bool ready = false;


  getUser()async{
    await FirebaseAuth.instance.currentUser().then((user){
      if(user!=null && !user.isAnonymous){
        signedIn = true;
      }else{
        signedIn = false;
      }
        print('this is the user $user');
    });
    ready = true;
    if(mounted){
    setState((){});
    }
  }
  @override
  void initState() {
    getUser();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return ready?signedIn?HomePage():Authorization():Container(
      color: Colors.teal,
      child: Center(
        child: Icon(Icons.timelapse, color: Colors.white,size: 100),
      ),
    );
  }
}
