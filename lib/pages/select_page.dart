import 'package:firevisor/pages/user_pages/supervisor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Sel extends StatefulWidget {
  final String keyword;
  final String type;
  const Sel({Key key, this.keyword, this.type}) : super(key: key);

  @override
  _SelState createState() => _SelState();
}

class _SelState extends State<Sel> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('請選擇分院'),
        ),
        body: Center(
          child: Column(
            children: [
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.lightBlue[50],
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Supervisor(
                          selMode: true,
                          keyWord: '1',
                          type: '一病房',
                        ),
                      ),
                    );
                  },
                  child: Text('一病房',
                      style: TextStyle(color: Colors.black, fontSize: 40))),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.lightBlue[50],
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Supervisor(
                            selMode: true, keyWord: '3', type: '三病房'),
                      ),
                    );
                  },
                  child: Text('三病房',
                      style: TextStyle(color: Colors.black, fontSize: 40))),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.lightBlue[50],
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Supervisor(
                            selMode: true, keyWord: '5', type: '五病房'),
                      ),
                    );
                  },
                  child: Text('五病房',
                      style: TextStyle(color: Colors.black, fontSize: 40))),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.redAccent,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            Supervisor(selMode: false, type: '總覽'),
                      ),
                    );
                  },
                  child: Text('全部',
                      style: TextStyle(color: Colors.black, fontSize: 40))),
            ],
          ),
        ));
  }
}
