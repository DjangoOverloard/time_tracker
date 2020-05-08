import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'mainPage.dart';

class ProjectWid extends StatefulWidget {
  final index;
  final doc;
  final update;
  final VoidCallback cancel;

  const ProjectWid({Key key, this.doc, this.cancel, this.index, this.update}) : super(key: key);
  @override
  _ProjectWidState createState() => _ProjectWidState();
}

class _ProjectWidState extends State<ProjectWid> {
  bool show = false;
  String projectName = '';
  bool sendingProject = false;
  showCoolAnimation(){
    if(widget.doc != null){
      show = true;
    }else{
      Future.delayed(Duration(milliseconds: 1), (){
          show = true;
        if(mounted){
        setState(() {});
        }
      });
    }
  }
  createProject()async{
     widget.cancel();
    sendingProject = true;
    setState((){});
    var time =  (DateTime.now().millisecondsSinceEpoch/1000).round();
    var project = {
      'timeCreated':time,
      'allTime': 0,
      'lastActive':time,
      'running': false,
      'name': projectName
    };
  var sendingString = jsonEncode(project);
  await Firestore.instance.collection('users').document(userDoc.documentID).updateData({
    'projects': FieldValue.arrayUnion([sendingString])
  });
  sendingProject = false;
  }
  @override
  void initState() {
    showCoolAnimation();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final obj = widget.doc;
    return AnimatedContainer(
      duration: Duration(milliseconds: !show?100:300),
      height: obj == null?show?100:0:210,
      width: double.maxFinite,
      decoration: BoxDecoration(
        color: Colors.white, 
        boxShadow: [
          BoxShadow(
            color: Colors.black38, 
            blurRadius: 2, 
          ),
        ],
        borderRadius: BorderRadius.circular(5),
      ),
      child: obj!=null?SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
              child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              height:80,
              decoration: BoxDecoration(
                color: Colors.cyan, 
                borderRadius: BorderRadius.only(topLeft: Radius.circular(5),
                 topRight: Radius.circular(5)),
              ),
              child: Stack(
                children: <Widget>[
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                      child: Text(obj['name'], style: TextStyle(
                        color: Colors.white, fontSize: 22,fontWeight: FontWeight.bold, 
                      ),maxLines: 1,overflow: TextOverflow.ellipsis,)),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        GestureDetector(
                          onTap: (){
                            showDialog(context: context, builder: (context)=> AreYourSure(
                              update: (){
                                widget.update();
                              },
                              obj: obj,
                            ));
                          },
                                            child: Container(
                            height: 40,
                            width: 40,
                            color: Colors.transparent,
                            child: Align(
                              alignment: Alignment.center,
                              child: Icon(Icons.delete, color: Colors.white, size: 25,),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 5, left:10, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Total Time:', style: TextStyle(
                    color: Colors.black, fontSize: 18, 
                  )),
                  Text(secondsToElapsedHours(obj['allTime']), style: TextStyle(
                    color: Colors.black, fontSize: 18, 
                  )),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 50),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: TimerWid(
                  index: widget.index,
                  changeRun: (){},
                  running: obj['running'],
                  startTime: obj['lastActive'], 
                ),
              ),
            ),
          ],
        ),
      ):AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
              child:!sendingProject? Padding(
          padding: EdgeInsets.only(left: 5, right: 5),
          child: SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  height: 50,
                              child: Align(
                                alignment: Alignment.centerLeft,
                    child: TextField(
                      onChanged: (val){
                        projectName = val.trim();
                        if(projectName.length == 0 || projectName.length== 1){
                          setState((){});
                        }
                      },
                    autofocus: true,
                    decoration: InputDecoration(
                      border: InputBorder.none, 
                      hintText: 'Name of the project'
                    ),
                  ),
                ),
                ),
                Container(
                  height: 50,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(2, (bt){
                        return Padding(
                          padding: EdgeInsets.only(right: bt == 0?10:0),
                                                child: GestureDetector(
                                                  onTap: (){
                                                    if(bt == 0){
                                                      show = false;
                                                    setState((){});
                                                    Future.delayed(Duration(milliseconds: 120), (){
                                                      widget.cancel();
                                                    });
                                                    }else{
                                                      if(projectName.length!=0){
                                                        createProject();
                                                      }
                                                    }
                                                  },
                            child: Opacity(
                              opacity: bt == 0?1.0: projectName.length!=0?1.0:0.4,
                                                        child: Container(
                              height: 35, 
                              decoration: BoxDecoration(
                                color: bt == 0?Colors.red:Colors.teal, 
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Padding(
                                padding: EdgeInsets.only(left: 15, right: 15),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(bt == 0?'Cancel':'Done', style: TextStyle(
                                      color: Colors.white,fontSize: 16, 
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
                  ),
                ),
              ],
            ),
          ),
        ):Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Colors.teal),
          ),
        ),
      ),
    );
  }
}


class AreYourSure extends StatefulWidget {
  final obj;
  final update;

  const AreYourSure({Key key, this.obj, this.update}) : super(key: key);
  @override
  _AreYourSureState createState() => _AreYourSureState();
}

class _AreYourSureState extends State<AreYourSure> {
  bool sent;

  delete()async{
    sent = false;
    setState((){});
    await Firestore.instance.collection('users').document(userDoc.documentID).updateData({
      'projects': FieldValue.arrayRemove([jsonEncode(widget.obj)])
    });
    projects.removeWhere((d)=>d['timeCreated'] == widget.obj['timeCreated']);
    widget.update();
    sent = true;
    setState((){});
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: sent  == null? Padding(
                padding: EdgeInsets.only(left: 5, right: 5),
                          child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Text('Are you sure you want to delete ${widget.obj['name']}?', style: TextStyle(
                      color: Colors.black, fontSize: 18, 
                    ), textAlign: TextAlign.center,),
                    Row(
                      children: List.generate(2, (bt){
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(left: bt == 0?10:5, right: bt == 1?10:5),
                            child: GestureDetector(
                              onTap: (){
                                if(bt == 0){
                                  Navigator.of(context).pop();
                                }else{
                                  delete();
                                }
                              },
                                                      child: Container(
                                height: 45,
                                width: double.maxFinite,
                                decoration: BoxDecoration(
                                  color: bt == 0?Colors.teal:Colors.red,
                                  borderRadius: BorderRadius.circular(5), 
                                ),
                                child: Center(
                                  child: Text(bt == 0?'No':'Yes', style: TextStyle(
                                    color: Colors.white, fontSize: 18,
                                  )),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ): sent == false? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.teal),
                ),
              ):Padding(
                padding: EdgeInsets.only(left: 5, right: 5),
                          child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Text('${widget.obj['name']} has been deleted', style: TextStyle(
                      color: Colors.black, fontSize: 18
                    ), textAlign: TextAlign.center,),
                    GestureDetector(
                      onTap: (){
                        Navigator.of(context).pop();
                      },
                                    child: Container(
                        height: 45,
                        width: double.maxFinite,
                        decoration: BoxDecoration(
                          color: Colors.teal, 
                          borderRadius: BorderRadius.circular(5), 
                        ),
                        child: Center(
                          child: Text('Ok', style: TextStyle(
                            color: Colors.white, fontSize: 18,
                          )),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ),
      ),
          ),
    );
  }
}

secondsToElapsedHours(inp){
  int start = inp;
  var hours = (start/3600).floor();
  start = start - hours*3600;
  var minutes = (start/60).floor();
  start = start - minutes*60;
  var seconds = start;
  l(inp){
    return inp.toString().padLeft(2, '0');
  }
  return '${l(hours)}:${l(minutes)}:${l(seconds)}'; 
}

class TimerWid extends StatefulWidget {
  final running;
  final startTime;
  final changeRun;
  final index;

  const TimerWid({Key key, this.running, this.startTime, this.changeRun, this.index}) : super(key: key);
  @override
  _TimerWidState createState() => _TimerWidState();
}

class _TimerWidState extends State<TimerWid> {
  Timer loopTimer;
  bool running;
  int startTime = 0;
  loop(){
    loopTimer = new Timer(Duration(seconds: 1), (){
      if(mounted){
        setState((){});
      }
      if(running){
        loop();
      }
    });
  }

  initiate(){
      running = widget.running;
      startTime = widget.startTime;
      if(running){
        loop();
      }
  }
  start()async{
    startTime = (DateTime.now().millisecondsSinceEpoch/1000).round();
    running = true;
    setState((){});
    loop();
    projects[widget.index]['running'] = true;
    projects[widget.index]['lastActive'] = startTime;
    var allProjects = []; allProjects.addAll(userDoc.data['projects']);
    allProjects[widget.index] =  jsonEncode(projects[widget.index]);
    await Firestore.instance.collection('users').document(userDoc.documentID).updateData({
      'projects': allProjects,
    });
  }
  stop()async{
    final difference = (DateTime.now().millisecondsSinceEpoch/1000).round() - startTime;
    running = false;
    startTime = (DateTime.now().millisecondsSinceEpoch/1000).round();
    setState((){});
    projects[widget.index]['allTime'] = projects[widget.index]['allTime'] + difference;
    projects[widget.index]['lastActive'] = startTime;
    projects[widget.index]['running'] = false;
     var allProjects = []; allProjects.addAll(userDoc.data['projects']);
     allProjects[widget.index] =  jsonEncode(projects[widget.index]);
     await Firestore.instance.collection('users').document(userDoc.documentID).updateData({
      'projects': allProjects,
    });
  }

  @override
  void initState() {
    initiate();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 5, left: 5, right: 5),
          child: Row(
        children: <Widget>[
          Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: 10),
                                          child: Container(
                        height: 50,
                        width: double.maxFinite,
                        color: Colors.white,
                                          child: Center(
                                            child: Text(running?'${secondsToElapsedHours((DateTime.now().millisecondsSinceEpoch/1000).round() - startTime)}':'00:00:00', style: TextStyle(
              color: Colors.black, fontSize: 30,
            )),
           ),
                      ),
                    ),
          ),
          GestureDetector(
            onTap: (){
              if(running){
                stop();
              }else{
                start();
              }
            },
                      child: Container(
              height: 50,
              width: 50,
              color: Colors.transparent,
              child: Center(
                child: Icon(running?Icons.stop:Icons.play_arrow,size: 30, color: running?Colors.black54:Colors.teal, ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
