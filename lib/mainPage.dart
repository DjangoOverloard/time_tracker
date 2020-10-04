import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stattrek/authorization.dart';
import 'package:stattrek/projectWid.dart';

DocumentSnapshot userDoc;
GlobalKey<ScaffoldState> scaff = new GlobalKey<ScaffoldState>();

var projects = [];

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var curPage = 0;
  bool loading = true;
  bool adding = false;
  StreamSubscription sub;
  bool ready = false;

  getProjects() async {
    var email = '';
    await FirebaseAuth.instance.currentUser().then((user) {
      email = user.email;
    });
    sub = Firestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .snapshots()
        .listen((data) {
      userDoc = data.documents.first;
      data.documents.first.data['projects'].forEach((d) {
        var encode = jsonDecode(d);
        if (projects
                .indexWhere((b) => b['timeCreated'] == encode['timeCreated']) ==
            -1) {
          projects.insert(0, encode);
        }
      });
      if (mounted) {
        setState(() {});
      }
      if (!ready) {
        ready = true;
        setState(() {});
      }
    });
    projects.sort((a, b) => b['timeCreated'].compareTo(a['timeCreated']));
  }

  @override
  void initState() {
    getProjects();
    super.initState();
  }

  @override
  void dispose() {
    if (sub != null) {
      sub.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {},
      child: Scaffold(
        key: scaff,
        appBar: AppBar(
          leading: GestureDetector(
            onTap: () {
              scaff.currentState.openDrawer();
            },
            child: Container(
              height: 40,
              width: 40,
              color: Colors.transparent,
              child: Center(
                child: Icon(
                  Icons.menu,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          title: Text('Stattrek'),
        ),
        drawer: Drawer(
          child: SafeArea(
            top: true,
            child: Column(
              children: <Widget>[
                Container(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 20, top: 20),
                    child: Column(
                      children: <Widget>[
                        Container(
                          height: 70,
                          width: 70,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(Icons.person,
                                color: Colors.white, size: 30),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Text(
                            'Signed in as\n${userDoc != null ? userDoc.data['email'] : ''}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: 2,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          curPage = index;
                          scaff.currentState.openEndDrawer();
                          setState(() {});
                        },
                        child: Container(
                          height: 50,
                          color: curPage == index ? Colors.teal : Colors.white,
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 10),
                                    child: Text(
                                        index == 0 ? 'Main Page' : 'Credits',
                                        style: TextStyle(
                                          color: curPage == index
                                              ? Colors.white
                                              : Colors.black,
                                          fontSize: 18,
                                        )),
                                  ),
                                ),
                              ),
                              Container(
                                height: 40,
                                width: 40,
                                child: Center(
                                  child: Icon(
                                    index == 0 ? Icons.home : Icons.person,
                                    color: curPage == index
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    scaff.currentState.openEndDrawer();
                    showDialog(
                        context: context,
                        builder: (context) => Scaffold(
                              backgroundColor: Colors.black26,
                              body: Center(
                                child: Padding(
                                  padding: EdgeInsets.only(left: 5, right: 5),
                                  child: Container(
                                    height: 200,
                                    width: double.maxFinite,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: <Widget>[
                                        Text(
                                            'Are you sure you want to log-out?',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 18,
                                            )),
                                        Row(
                                          children: List.generate(2, (bt) {
                                            return Expanded(
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                    left: bt == 0 ? 10 : 5,
                                                    right: bt == 1 ? 10 : 5),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    if (bt == 0) {
                                                      Navigator.of(context)
                                                          .pop();
                                                    } else {
                                                      sub.cancel();
                                                      FirebaseAuth.instance
                                                          .signOut();
                                                      projects.clear();
                                                      Navigator.of(context)
                                                          .push(
                                                              MaterialPageRoute(
                                                        builder: (context) =>
                                                            Authorization(),
                                                      ));
                                                    }
                                                  },
                                                  child: Container(
                                                    height: 40,
                                                    decoration: BoxDecoration(
                                                      color: bt == 0
                                                          ? Colors.teal
                                                          : Colors.red,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                    ),
                                                    child: Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 10, right: 10),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                          Text(
                                                              bt == 0
                                                                  ? 'No'
                                                                  : 'Yes',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 18,
                                                              )),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ));
                  },
                  child: Container(
                    color: Colors.transparent,
                    height: 50,
                    width: double.maxFinite,
                    child: Center(
                      child: Text('Log-out',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 20,
                          )),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: curPage == 0
            ? Column(
                children: <Widget>[
                  adding
                      ? Padding(
                          padding: EdgeInsets.only(
                              left: 10, right: 10, top: 10, bottom: 10),
                          child: ProjectWid(
                            update: () {
                              if (mounted) {
                                setState(() {});
                              }
                            },
                            cancel: () {
                              adding = false;
                              setState(() {});
                            },
                          ),
                        )
                      : SizedBox.shrink(),
                  Expanded(
                    child: ready
                        ? projects.length != 0 || adding
                            ? ListView.builder(
                                padding: EdgeInsets.only(bottom: 100),
                                shrinkWrap: true,
                                physics: BouncingScrollPhysics(),
                                itemCount: projects.length,
                                itemBuilder: (contexto, index) {
                                  return Padding(
                                    padding: EdgeInsets.only(
                                        left: 10,
                                        right: 10,
                                        top: index == 0 ? !adding ? 10 : 0 : 0,
                                        bottom: 10),
                                    child: ProjectWid(
                                      update: () {
                                        if (mounted) {
                                          setState(() {});
                                        }
                                      },
                                      index: index,
                                      cancel: () {
                                        adding = false;
                                        setState(() {});
                                      },
                                      doc: index < projects.length
                                          ? projects[index]
                                          : null,
                                    ),
                                  );
                                },
                              )
                            : Center(
                                child: Text("You don't have any projects yet",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                    )),
                              )
                        : Center(
                            child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.teal)),
                          ),
                  ),
                ],
              )
            : Center(
                child: Center(
                  child: Text(
                    'Created by Zhangir Siranov,\naka starlord.',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
        floatingActionButton: AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
          child: loading && !adding && curPage == 0
              ? FloatingActionButton(
                  onPressed: () {
                    adding = true;
                    if (mounted) {
                      setState(() {});
                    }
                  },
                  child: Center(
                    child: Icon(Icons.add),
                  ),
                )
              : SizedBox.shrink(),
        ),
      ),
    );
  }
}
