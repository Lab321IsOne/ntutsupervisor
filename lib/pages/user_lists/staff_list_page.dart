import 'package:firevisor/custom_widgets/message_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firevisor/blocs/staff_bloc/staff_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class StaffList extends StatelessWidget {
  // add a staff account
  Future<void> _showAddStaffDialog(BuildContext context) async {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final displayNameController = TextEditingController();

    final _staffAlertDialog = AlertDialog(
      title: Text('新增醫護人員'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 12.0),
            TextField(
              keyboardType: TextInputType.text,
              controller: usernameController,
              obscureText: false,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.account_circle),
                hintText: '帳號',
              ),
            ),
            SizedBox(height: 20.0),
            TextField(
              keyboardType: TextInputType.text,
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.https),
                hintText: '密碼',
              ),
            ),
            SizedBox(height: 20.0),
            TextField(
              keyboardType: TextInputType.text,
              controller: displayNameController,
              obscureText: false,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.person),
                hintText: '用戶名稱',
              ),
            ),
            SizedBox(height: 12.0),
          ],
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
            '新增用戶',
            style: TextStyle(color: Colors.deepPurple),
          ),
          onPressed: () {
            BlocProvider.of<StaffBloc>(context).add(LoadingStaffEvent());
            // add staff via StaffBloc
            BlocProvider.of<StaffBloc>(context).add(AddStaffEvent(
              email: usernameController.text,
              password: passwordController.text,
              displayName: displayNameController.text,
            ));
            Navigator.pop(context);
          },
        ),
      ],
    );

    return showDialog(
      context: context,
      builder: (context) => _staffAlertDialog,
    );
  }

  Future<void> _showDeleteStaffDialog(BuildContext context, Map staff) async {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('刪除醫護人員'),
          content: SingleChildScrollView(
            child: Text('你確定要刪除 ${staff['displayName']} 嗎？'),
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
                '刪除',
                style: TextStyle(color: Colors.deepPurple),
              ),
              onPressed: () {
                BlocProvider.of<StaffBloc>(context).add(LoadingStaffEvent());
                // delete staff via StaffBloc
                BlocProvider.of<StaffBloc>(context)
                    .add(DeleteStaffEvent(deleteUid: staff['uid']));
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<StaffBloc, StaffState>(
        builder: (context, state) {
          if (state is ShowStaffState) {
            return ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              itemCount: state.staffList.length + 1,
              itemBuilder: (context, index) {
                if (index == state.staffList.length) {
                  // add staff ListTile
                  return ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    leading: Icon(Icons.add, color: Colors.deepPurple),
                    title: Text(
                      '新增醫護人員',
                      style: TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () => _showAddStaffDialog(context),
                  );
                } else {
                  // staff ListTile
                  final Map staff = state.staffList[index];
                  return ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    leading: Container(
                      width: 20.0,
                      alignment: Alignment.center,
                      child: Icon(Icons.assignment_ind),
                    ),
                    title: Text(staff['displayName']),
                    subtitle: Text('醫護人員'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _showDeleteStaffDialog(context, staff),
                    ),
                  );
                }
              },
            );
          } else if (state is LoadingStaffState) {
            return MessageScreen(
              message: '載入資料中...',
              child: SpinKitRing(color: Colors.deepPurple),
            );
          } else {
            return MessageScreen(
              message: '無使用者資料',
              child: Icon(
                Icons.error_outline,
                color: Colors.deepPurple,
                size: 48.0,
              ),
            );
          }
        },
      ),
    );
  }
}
