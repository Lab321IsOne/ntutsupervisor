//import 'dart:html';
import 'package:firevisor/custom_widgets/message_screen.dart';
import 'package:firevisor/custom_widgets/status_card.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:audioplayers/audioplayers.dart';
//import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

class Guest extends StatefulWidget {
  @override
  _GuestState createState() => _GuestState();

  // get machine initial data when constructor is called
  final Map data;

  Guest(Map<String, String> machineData) : data = machineData;
}

class _GuestState extends State<Guest> {
  FirebaseFirestore _firestore;
  Map _data; // machine data
  Stream _dataStream; // listen machine data change from api
  bool music = true;
  bool ring = false;
  var subscription;
  AudioPlayer audioPlayer = AudioPlayer();
  AudioCache audioCache;
  String filePath = 'alarm.mp3';
  // show color according to power
  Color getPowerColor(String s) {
    int power = int.parse(s);
    if (power > 50 && power < 101) {
      return Colors.green;
    } else if (power > 25 && power < 51) {
      return Colors.yellow;
    } else if (power > 0 && power < 26) {
      return Colors.red;
    } else {
      return Colors.black12;
    }
  }

  Icon getPowerIcon(String s) {
    int power = int.parse(s);
    if (power > 50 && power < 101) {
      return Icon(
        Icons.battery_full,
        color: Colors.green[700],
        size: 48.0,
      );
    } else if (power > 25 && power < 51) {
      return Icon(
        Icons.battery_std,
        color: Colors.yellow[700],
        size: 48.0,
      );
    } else if (power > 0 && power < 26) {
      return Icon(
        Icons.battery_alert,
        color: Colors.redAccent,
        size: 48.0,
      );
    } else {
      return Icon(
        Icons.battery_full,
        color: Colors.grey,
        size: 48.0,
      );
    }
  }

  Icon getJudgeIcon(String judge) {
    switch (judge) {
      case 'unused':
        return Icon(
          Icons.airline_seat_flat,
          color: Colors.grey,
          size: 48.0,
        );

      default:
        return Icon(
          Icons.airline_seat_flat_outlined,
          color: Colors.blueAccent,
          size: 48.0,
        );
    }
  }

  Icon getModeIcon(String modedescription) {
    switch (modedescription) {
      case '尿袋':
        return Icon(
          Icons.whatshot_outlined,
          color: Colors.yellow[700],
          size: 48.0,
        );
      case '點滴':
        return Icon(
          Icons.waves,
          color: Colors.blue[400],
          size: 48.0,
        );
      case '未使用':
        return Icon(
          Icons.clear,
          color: Colors.redAccent,
          size: 48.0,
        );
      default:
        return Icon(
          Icons.update_outlined,
          color: Colors.white38,
          size: 48.0,
        );
    }
  }

  Icon getSensorIcon(int diff) {
    if (diff > 15) {
      return Icon(
        Icons.warning,
        color: Colors.red,
        size: 48.0,
      );
    } else {
      return Icon(
        Icons.check,
        color: Colors.greenAccent,
        size: 48.0,
      );
    }
  }

  Future<void> _showPauseAlarmDialog() async {
    return showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('關閉鈴聲'),
            content: Text('確定要關閉警告鈴聲？'),
            actions: <Widget>[
              TextButton(
                child: Text('取消', style: TextStyle(color: Colors.grey)),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text('貪睡', style: TextStyle(color: Colors.blueAccent)),
                onPressed: () {
                  triggerAlarmMusic(ring);

                  Navigator.pop(context);
                },
              ),
              // TextButton(
              //   child: Text('確定', style: TextStyle(color: themeColor)),
              //   onPressed: () {
              //     stopMusic();

              //     Navigator.pop(context);
              //   },
              // ),
            ],
          );
        });
  }

  @override
  void initState() {
    super.initState();
    // get data from constructor
    _data = widget.data;

    // get datastream from firebase
    _firestore = FirebaseFirestore.instance;
    _dataStream =
        _firestore.collection('NTUTLab321').doc(_data['machine']).snapshots();

    audioPlayer = AudioPlayer();
    audioCache = AudioCache(fixedPlayer: audioPlayer);
  }

  playMusic() async {
    await audioCache.loop(filePath);
  }

  stopMusic() async {
    await audioPlayer.stop();
  }

  void triggerAlarmMusic(bool music) {
    if (music) {
      playMusic();
    } else {
      stopMusic();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('點滴尿袋智慧監控系統'),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: _dataStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print(
                '@guest_page.dart -> snapshot.error -> ${snapshot.error.toString()}');
            return MessageScreen(
              message: '資料載入出現問題，請稍後再試',
              child: Icon(
                Icons.error_outline,
                color: Colors.lightBlue,
                size: 48.0,
              ),
            );
          } else {
            // update data if snapshot has data
            if (snapshot.hasData) {
              print('@guest_page.dart -> snapshot.data = ${snapshot.data}');

              _data['judge'] = snapshot.data['judge'];
              _data['alarm'] = snapshot.data['alarm'];
              _data['change'] = snapshot.data['change'];
              _data['modedescription'] = snapshot.data['modedescription'];
              _data['power'] = snapshot.data['power'];
              // _data['time'] = snapshot.data['time'].toString();
              _data['time'] = snapshot.data['time'];
              print('@guest_page.dart -> _data = $_data');
            }

            switch (snapshot.connectionState) {
              case ConnectionState.active:
                var timenow = new DateTime.now();
                DateTime machinetime = _data['time'].toDate();
                var diff = timenow.difference(machinetime).inMinutes;

                // Card dashboard(s
                //   String cont,
                // ) {
                //   return Card(
                //       elevation: 1.0,
                //       margin: new EdgeInsets.all(8.0),
                //       child: Container(
                //           child: Column(
                //         crossAxisAlignment: CrossAxisAlignment.stretch,
                //         mainAxisSize: MainAxisSize.min,
                //         verticalDirection: VerticalDirection.down,
                //         children: [
                //           SizedBox(height: 50.0),
                //           // Center(
                //           //   child: icon,
                //           // ),
                //           SizedBox(height: 20.0),
                //           Center(child: Text(cont))
                //         ],
                //       )));
                // }

                return Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        child: Builder(
                          builder: (context) {
                            // machine that doesn't have a serial number after init
                            if (_data['judge'] == 'unused') {
                              return StatusCard(
                                statusText: '裝置已停用',
                                infoColor: Colors.grey[800],
                                backgroundColor: Colors.yellow[700],
                                iconData: Icons.app_blocking,
                              );
                            }
                            // device normal
                            if (_data['change'] == '0') {
                              triggerAlarmMusic(ring);

                              return StatusCard(
                                statusText: '裝置正常',
                                infoColor: Colors.grey[800],
                                backgroundColor: Colors.green[400],
                                iconData: Icons.check_circle_outline,
                              );
                            }
                            // device should be changed
                            if (_data['change'] == '1') {
                              triggerAlarmMusic(music);
                              return StatusCard(
                                statusText: '裝置待更換',
                                infoColor: Colors.grey[800],
                                backgroundColor: Colors.red[400],
                                iconData: Icons.error_outline,
                              );
                            }
                            // data has error
                            return StatusCard(
                              statusText: '資料錯誤',
                              infoColor: Colors.white,
                              backgroundColor: Colors.deepPurple,
                              iconData: Icons.clear,
                            );
                          },
                        ),
                      ),
                      // GridView.count(
                      //   crossAxisCount: 2,
                      //   padding: EdgeInsets.all(3.0),
                      //   children: [
                      //     dashboard(
                      //       'id',
                      //       //Icon(Icons.airline_seat_flat)
                      //     ),
                      //     dashboard(
                      //       'mode',
                      //       // getModeIcon(_data['modedescription']),
                      //     ),
                      //     dashboard(
                      //       '%',
                      //       // getModeIcon(_data['power']),
                      //     ),
                      //     dashboard(
                      //       '分鐘前',
                      //       // getSensorIcon(diff),
                      //     ),
                      //   ],
                      // ),

                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Divider(color: Colors.black),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          getJudgeIcon(_data['judge']),
                          SizedBox(width: 40.0),
                          Text(
                            '院與床號',
                            style: TextStyle(
                              fontSize: 25.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 25.0),
                          Text(
                            _data['judge'],
                            style: TextStyle(fontSize: 30.0),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Divider(color: Colors.black),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          getModeIcon(_data['modedescription']),
                          SizedBox(width: 40.0),
                          Text(
                            '使用模式',
                            style: TextStyle(
                              fontSize: 25.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 25.0),
                          Text(
                            _data['modedescription'],
                            style: TextStyle(fontSize: 30.0),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Divider(color: Colors.black),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          getPowerIcon(_data['power']),
                          SizedBox(width: 40.0),
                          Text(
                            '剩餘電量',
                            style: TextStyle(
                              fontSize: 25.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 25.0),
                          CircleAvatar(
                            backgroundColor: getPowerColor(_data['power']),
                            child: Text(
                              _data['power'],
                              style: TextStyle(
                                  fontSize: 30.0, color: Colors.black),
                            ),
                          ),
                          SizedBox(width: 25.0),
                          Text(
                            '%',
                            style:
                                TextStyle(fontSize: 30.0, color: Colors.black),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Divider(color: Colors.black),
                      ),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.start,
                      //   crossAxisAlignment: CrossAxisAlignment.center,
                      //   children: [
                      //     Icon(
                      //       Icons.work_outline,
                      //       color: Colors.blueAccent,
                      //       size: 48.0,
                      //     ),
                      //     SizedBox(width: 40.0),
                      //     Text(
                      //       '裝置序號',
                      //       style: TextStyle(
                      //         fontSize: 25.0,
                      //         fontWeight: FontWeight.bold,
                      //       ),
                      //     ),
                      //     SizedBox(width: 25.0),
                      //     Text(
                      //       _data['machine'].substring(0, 5),
                      //       style: TextStyle(fontSize: 30.0),
                      //     ),
                      //   ],
                      // ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          getSensorIcon(diff),
                          SizedBox(width: 40.0),
                          Text(
                            '上次上傳',
                            style: TextStyle(
                              fontSize: 25.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 25.0),
                          Text(
                            diff.toString() + ' 分鐘前',
                            style: TextStyle(fontSize: 30.0),
                          ),
                        ],
                      ),
                    ],
                  ),
                );

              case ConnectionState.waiting:
                return MessageScreen(
                  message: '載入資料中...',
                  child: SpinKitRing(color: Colors.lightBlue),
                );
              case ConnectionState.none:
                return MessageScreen(
                  message: '請檢查手機連線',
                  child: Icon(
                    Icons.perm_scan_wifi_rounded,
                    color: Colors.lightBlue,
                    size: 48.0,
                  ),
                );
              default:
                return MessageScreen(
                  message: 'Unexpected error',
                  child: Icon(
                    Icons.warning_outlined,
                    color: Colors.lightBlue,
                    size: 48.0,
                  ),
                );
            }
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        // 暫時關閉警示鈴
        child: Icon(Icons.alarm_off),
        backgroundColor: Colors.blueAccent,

        onPressed: () => _showPauseAlarmDialog(),
      ),
    );
  }
}
