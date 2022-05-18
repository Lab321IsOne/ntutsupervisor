import 'package:firevisor/custom_widgets/message_screen.dart';
import 'package:firevisor/pages/select_page.dart';
import 'package:firevisor/pages/user_pages/supervisor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firevisor/blocs/authenticate_bloc/authenticate_bloc.dart';

import 'user_pages/administrator_page.dart';
import 'user_pages/guest_page.dart';

class User extends StatelessWidget {
  static const sName = "/user_page";

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticateBloc, AuthenticateState>(
      builder: (context, state) {
        if (state is AuthenticateLoggedInState) {
          final Map userData = state.loginResult; // 從 AuthenticateState 取得登入者資料
          switch (userData['role']) {
            // 取得登入者權限
            case 'administrator': // 最高權限
              return Administrator();
            case 'staff': // 醫護人員
              return Sel();
            case 'guest': // 家屬
              return Guest(userData); // 一併傳入登入資料
            default:
              // 錯誤處理
              return Scaffold(
                appBar: null,
                body: MessageScreen(
                  child: Icon(Icons.error_outline),
                  message: '使用者資訊出現問題',
                ),
              );
          }
        } else {
          // 錯誤處理
          return Scaffold(
            appBar: null,
            body: MessageScreen(
              child: Icon(Icons.error_outline),
              message: '登入時出現問題',
            ),
          );
        }
      },
    );
  }
}
