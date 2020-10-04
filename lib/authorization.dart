import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stattrek/mainPage.dart';


class Authorization extends StatefulWidget {
  @override
  _AuthorizationState createState() => _AuthorizationState();
}

class _AuthorizationState extends State<Authorization> {

  bool showBar = false;
  bool userLoaded = false;
  bool reged = false;
  String email = '';
  String password = '';
  bool showError =false;
  bool atIsPresent = false;
  Timer debounceTimer;
  bool emailError = false;
  anonymous()async{
    final user = await FirebaseAuth.instance.currentUser();
    if(user == null){
    await FirebaseAuth.instance.signInAnonymously();
    }
    print('anonymous log-in');
  }

  check()async{
    showBar = true;
    setState((){});
    await Firestore.instance.collection('users')
    .where('email', isEqualTo: email.toLowerCase()).limit(1).
    getDocuments().then((ds){
      reged = ds.documents.length!=0;
    });
    userLoaded = true;
    setState((){});
  }

  logIn()async{
    userLoaded = false;
    setState((){});
    await FirebaseAuth.instance.currentUser().then((user){
      if(user.isAnonymous){
      user.delete();
      }
    });
    if(!reged){
    await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, 
    password: password).then((done)async{
      await Firestore.instance.collection('users').document().setData({
        'projects': [],
        'email': email.toLowerCase(), 
        'registeredAt': DateTime.now(),
      });
      print('created new user');
      Navigator.of(context).push(CupertinoPageRoute(
        builder: (context) => HomePage()));
      });
    }else{
    await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password:password)
    .then((done){
      print('everything good, authenticating old user.');
      Navigator.of(context).push(CupertinoPageRoute(
        builder: (context) => HomePage()));
    }).catchError((err){
      print('something is wrong, not authenticating old user. $err');
      showError = true;
      userLoaded = true;
      setState((){});
      anonymous();
    });
    }

  }

@override
  void initState() {
    print('initialization');
    anonymous();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: (){},
          child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.only(left: 5, right: 5),
                            child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text('Project Manager Tool', style: TextStyle(
                          color: Colors.teal, fontSize: 18, 
                        )),
                        Icon(Icons.timelapse, color: Colors.teal,size: 100),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10),
                                        child: Container(
                        height: 45,
                        width: double.maxFinite,
                        decoration: BoxDecoration(
                          color: Colors.white, 
                          border: Border.all(
                            color: Colors.black26, 
                            width: 1.5
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(left: 5, right: 5),
                          child: TextField(
                            autofocus: false,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (val){
                              FocusScope.of(context).unfocus();
                            },
                            onChanged: (val){
                              email = val.trim().toLowerCase();
                              if(RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email)){
                                if(!atIsPresent){
                                atIsPresent = true;
                                setState((){});
                                }
                              }else{
                                if(atIsPresent){
                                  atIsPresent = false;
                                  setState((){});
                                }
                              }
                              if(debounceTimer!=null){
                                debounceTimer.cancel();
                              }
                              debounceTimer = new Timer(Duration(milliseconds: 300), (){
                                setState((){});
                              });
                            },
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Email Address'
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: GestureDetector(
                        onTap: (){
                          if(atIsPresent && email.length>1){
                         check();
                          }
                        },
                                            child: Container(
                          height: 45,
                          width: double.maxFinite,
                          decoration: BoxDecoration(
                            color: Colors.teal.withOpacity(RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email)?1.0:0.3),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Center(
                            child: Text('Enter', style: TextStyle(
                              color: Colors.white,
                            )),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            showBar?GestureDetector(
              onTap: (){
                showBar = false;
                setState((){});
              },
                        child: Container(
                color: Colors.black26,
              ),
            ):SizedBox.shrink(),
            AnimatedPositioned(
              left: 0,right: 0, 
              bottom: showBar?0:-200,
              duration: Duration(milliseconds: 200),
              child: Container(
                height: 200, 
                width: double.maxFinite,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(5),
                  topRight: Radius.circular(5)),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26, 
                      offset: Offset(0.0, -1.0),
                      blurRadius: 3,
                    ),
                  ],
                ),
                child: AnimatedSwitcher(duration:Duration(milliseconds: 300), 
                child:userLoaded?Padding(
                  padding: EdgeInsets.only(left: 5, right: 10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Text(!reged?'Welcome, $email':"We're glad to see you again, $email", style: TextStyle(
                        color: Colors.black, fontSize: 18,
                      ), textAlign: TextAlign.center,), 
                      showError?Text('Password is incorrect', style: TextStyle(
                        color: Colors.red,fontSize: 18, 
                      )):SizedBox.shrink(),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
Container(
                        height: 45,
                        width: double.maxFinite,
                        decoration: BoxDecoration(
                          color: Colors.white, 
                          border: Border.all(
                            color: Colors.black26, 
                            width: 1.5
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(left: 5, right: 5),
                          child: TextField(
                            autofocus: true,
                            onSubmitted: (val){},
                            onChanged: (val){
                              password = val.trim();
                              if(password.length == 5 || password.length == 6){
                                setState((){});
                              }
                            },
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            obscureText: true,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Password'
                            ),
                          ),
                        ),
                      ),
                    Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: GestureDetector(
                        onTap: (){
                          if(password.length>=6){
                          logIn();
                          }
                          if(debounceTimer!=null){
                            debounceTimer.cancel();
                          }
                          debounceTimer = new Timer(Duration(milliseconds: 300), (){
                            if(mounted){
                            setState((){});
                            }
                          });
                        },
                                            child: Opacity(
                                              opacity: password.length>=6?1.0:0.3,
                                                                                        child: Container(
                          height: 45,
                          width: double.maxFinite,
                          decoration: BoxDecoration(
                            color: Colors.teal,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Center(
                            child: Text('Authenticate', style: TextStyle(
                              color: Colors.white,
                            )),
                          ),
                        ),
                                            ),
                      ),
                    ),
                        ],
                      ),
                    ],
                  ),
                ):Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.teal)
                  ),
                ) ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}