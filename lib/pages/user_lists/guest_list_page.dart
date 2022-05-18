//import 'package:firevisor/blocs/staff_bloc/staff_bloc.dart';
import 'package:firevisor/custom_widgets/message_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firevisor/blocs/guest_bloc/guest_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class GuestListPage extends StatefulWidget {
  final isAdmin; // represents if page is called by admin

  @override
  GuestListPage(bool admin) : isAdmin = admin;

  @override
  _GuestListPageState createState() => _GuestListPageState();
}

class _GuestListPageState extends State<GuestListPage> {
  Color _themeColor; // change color by different role
  bool _isLoading = false; // disable some widgets when loading

  @override
  void initState() {
    super.initState();
    // init theme color
    _themeColor = widget.isAdmin ? Colors.deepPurple : Colors.indigo;
    _refreshList();
  }

  // get guest list from GuestBloc
  Future<void> _refreshList() async {
    BlocProvider.of<GuestBloc>(context).add(LoadingGuestEvent());
    BlocProvider.of<GuestBloc>(context).add(GetGuestEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GuestBloc, GuestState>(
      listener: (context, state) {
        // update _isLoading according to state
        setState(() {
          _isLoading = state is LoadingGuestState;
        });
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('帳戶管理'),
          backgroundColor: _themeColor,
        ),
        body: GuestList(widget.isAdmin),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.refresh),
          backgroundColor: _isLoading ? Colors.grey : _themeColor,
          onPressed: _refreshList,
        ),
      ),
    );
  }
}

class GuestList extends StatelessWidget {
  final bool _isAdmin;
  final Color _themeColor;

  @override
  GuestList(bool isAdmin)
      : _isAdmin = isAdmin,
        _themeColor = isAdmin ? Colors.deepPurple : Colors.indigo;

  // regenerate serial number and reset guest account expire time
  Future<void> _showRegenerateSerialNumberDialog(
      BuildContext context, Map guest) async {
    // expire time length for new serial number
    int _days = 1;
    // textfield controller for custom input expire time length
    final daysController = TextEditingController();

    // show dialog if normal
    final regenerateSerialNumberDialog = AlertDialog(
      title: Text('設定流水號期限'),
      content: SingleChildScrollView(
        child: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Radio(
                      value: 1,
                      groupValue: _days,
                      onChanged: (value) {
                        setState(() => _days = value);
                      },
                    ),
                    Text('1 天', style: TextStyle(fontSize: 20.0)),
                    SizedBox(width: 16.0),
                    Radio(
                      value: 2,
                      groupValue: _days,
                      onChanged: (value) {
                        setState(() => _days = value);
                      },
                    ),
                    Text('2 天', style: TextStyle(fontSize: 20.0)),
                  ],
                ),
                SizedBox(height: 12.0),
                Row(
                  children: [
                    Radio(
                      value: 5,
                      groupValue: _days,
                      onChanged: (value) {
                        setState(() => _days = value);
                      },
                    ),
                    Text('5 天', style: TextStyle(fontSize: 20.0)),
                    SizedBox(width: 16.0),
                    Radio(
                      value: 7,
                      groupValue: _days,
                      onChanged: (value) {
                        setState(() => _days = value);
                      },
                    ),
                    Text('7 天', style: TextStyle(fontSize: 20.0)),
                  ],
                ),
                SizedBox(height: 12.0),
                Row(
                  children: [
                    Radio(
                      value: -1,
                      groupValue: _days,
                      onChanged: (value) {
                        setState(() => _days = value);
                      },
                    ),
                    SizedBox(
                      width: 160.0,
                      child: TextField(
                        controller: daysController,
                        keyboardType: TextInputType.numberWithOptions(),
                        decoration: InputDecoration(
                          labelText: '自訂 (天)',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
      actions: [
        TextButton(
          child: Text(
            '取消',
            style: TextStyle(color: Colors.grey),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          child: Text(
            '確定',
            style: TextStyle(color: _themeColor),
          ),
          onPressed: () {
            BlocProvider.of<GuestBloc>(context).add(LoadingGuestEvent());
            if (_days != -1) {
              // get days from options
              BlocProvider.of<GuestBloc>(context)
                  .add(RegenerateSerialNumberEvent(
                machine: guest['machine'],
                expireTime: _days.toString(),
                position: guest['position'],
              ));
            } else {
              // get days from input text
              final String daysText = daysController.text.trim();
              // add event if daysText only contains numbers
              if (daysText.contains(RegExp('^[0-9]*\$'))) {
                BlocProvider.of<GuestBloc>(context)
                    .add(RegenerateSerialNumberEvent(
                  machine: guest['machine'],
                  expireTime: daysText,
                  position: guest['position'],
                ));
              } else {
                print('Input type not valid');
              }
            }
            Navigator.pop(context);
          },
        )
      ],
    );

    // show dialog if account not authorized
    final regenerateBannedDialog = AlertDialog(
      title: Text('產生流水號'),
      content: Text('請稍後再產生新的流水號！'),
      actions: [
        TextButton(
          child: Text(
            '確定',
            style: TextStyle(color: _themeColor),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
    final int milliseconds = guest['reGenerateSerialNumberTime'];
    final DateTime regenerateTime =
        DateTime.fromMillisecondsSinceEpoch(milliseconds);

    return showDialog<void>(
      context: context,
      builder: (context) {
        // ban user from regenerating if user is not admin && time passed regenerateTime
        if ((!_isAdmin) && regenerateTime.compareTo(DateTime.now()) > 0) {
          return regenerateBannedDialog;
        } else {
          return regenerateSerialNumberDialog;
        }
      },
    );
  }

  // show guest and machine information
  Future<void> _showGuestInfoDialog(BuildContext context, Map guest) async {
    return showDialog(
      context: context,
      builder: (context) {
        final DateTime expireTime =
            new DateTime.fromMillisecondsSinceEpoch(guest['expire']);
        final Duration timeLeft = expireTime.difference(new DateTime.now());
        return AlertDialog(
          title: (guest['expire'] == -1
              ? Text('未啟用帳號')
              : Text(guest['serialNumber'])),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    '床室號：${guest['expire'] == -1 ? '尚未開始使用' : guest['position']}'),
                SizedBox(height: 12.0),
                Text('裝置號：${guest['machine']}'),
                SizedBox(height: 12.0),
                Text(
                    '過期時間：${guest['expire'] == -1 ? '--' : formatTimeLeftToMessage(timeLeft)}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                '確定',
                style: TextStyle(
                  color: _themeColor,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  // delete guest account
  Future<void> _showDeleteGuestDialog(BuildContext context, Map guest) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
            title: Text('永久刪除使用者'),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  Text('你確定要刪除 ${guest['serialNumber']} 嗎？'),
                  Text('此動作將無法復原。'),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: Text(
                  '取消',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text(
                  '確定',
                  style: TextStyle(
                    color: _themeColor,
                  ),
                ),
                onPressed: () {
                  BlocProvider.of<GuestBloc>(context).add(LoadingGuestEvent());
                  BlocProvider.of<GuestBloc>(context)
                      .add(DeleteGuestEvent(machine: guest['machine']));
                  Navigator.pop(context);
                },
              ),
            ]);
      },
    );
  }

  String formatTimeLeftToMessage(Duration _time) {
    if (_time.isNegative) return '已過期';
    if (_time.inMinutes <= 1) return '剩餘 1 分鐘';
    if (_time.inHours < 1) return '剩餘 ${_time.inMinutes} 分鐘';
    if (_time.inDays < 1) return '剩餘 ${_time.inHours} 小時';
    return '剩餘 ${_time.inDays} 天';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<GuestBloc, GuestState>(
        builder: (context, state) {
          if (state is ShowGuestState) {
            return ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              itemCount: state.guestList.length,
              itemBuilder: (context, index) {
                final Map guest = state.guestList[index];
                final popupMenu = PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'regenerateSerialNumber',
                      child: Row(
                        children: [
                          Icon(Icons.fiber_new_rounded),
                          SizedBox(width: 8.0),
                          Text('產生流水號'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'deleteGuest',
                      child: Row(
                        children: [
                          Icon(Icons.delete_forever),
                          SizedBox(width: 8.0),
                          Text('停用家屬帳號'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (action) {
                    switch (action) {
                      case 'regenerateSerialNumber':
                        _showRegenerateSerialNumberDialog(context, guest);
                        break;
                      case 'deleteGuest':
                        _showDeleteGuestDialog(context, guest);
                        break;
                      default:
                        print('@guest_list_page -> popup menu error');
                    }
                  },
                );
                if (guest['expire'] == -1) {
                  return ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    leading: Container(
                      width: 20.0,
                      alignment: Alignment.center,
                      child: Icon(Icons.fiber_new),
                    ),
                    title: Text(
                      guest['position'] == 'unused'
                          ? '未啟用帳號'
                          : guest['position'],
                      style: TextStyle(
                          // color: Colors.grey,
                          ),
                    ),
                    subtitle: Text('產生流水號以啟用帳號'),
                    trailing: popupMenu,
                    onTap: () => _showGuestInfoDialog(context, guest),
                  );
                }
                return ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  leading: Container(
                    width: 20.0,
                    alignment: Alignment.center,
                    child: Icon(Icons.airline_seat_flat),
                  ),
                  title: Text(guest['serialNumber']),
                  subtitle: Text(guest['position']),
                  trailing: popupMenu,
                  onTap: () => _showGuestInfoDialog(context, guest),
                );
              },
            );
          } else if (state is LoadingGuestState) {
            return MessageScreen(
              message: '載入資料中...',
              child: SpinKitRing(color: _themeColor),
            );
          } else {
            return MessageScreen(
              message: '無使用者資料',
              child: Icon(
                Icons.error_outline,
                color: _themeColor,
                size: 48.0,
              ),
            );
          }
        },
      ),
    );
  }
}
