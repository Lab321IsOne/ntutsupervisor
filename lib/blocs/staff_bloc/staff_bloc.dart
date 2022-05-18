import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:firevisor/user_repository.dart';
import 'package:firevisor/api.dart';

part 'staff_event.dart';

part 'staff_state.dart';

class StaffBloc extends Bloc<StaffEvent, StaffState> {
  final UserRepository _staffRepository;

  StaffBloc({@required UserRepository userRepository})
      : assert(userRepository != null),
        _staffRepository = userRepository,
        super(NoStaffState());

  @override
  Stream<StaffState> mapEventToState(
    StaffEvent event,
  ) async* {
    if (event is AddStaffEvent) {
      yield* _mapAddStaffEventToState(
        event.email,
        event.password,
        event.displayName,
      );
    } else if (event is GetStaffEvent) {
      yield* _mapGetStaffEventToState();
    } else if (event is DeleteStaffEvent) {
      yield* _mapDeleteStaffEventToState(event.deleteUid);
    } else if (event is LoadingStaffEvent) {
      yield* _mapLoadingStaffEventToState();
    }
  }

  Stream<StaffState> _mapAddStaffEventToState(
    String email,
    String password,
    String displayName,
  ) async* {
    final String jwtToken = _staffRepository.getJwtToken();
    if (jwtToken != null) {
      final Map<String, String> requestData = {
        'jwtToken': jwtToken,
        'email': email,
        'password': password,
        'displayName': displayName,
      };
      final List _staffList = await createStaff(requestData);
      yield ShowStaffState(staffList: _staffList);
    } else {
      print('JwtToken is not provided.');
      yield NoStaffState();
    }
  }

  Stream<StaffState> _mapGetStaffEventToState() async* {
    final String jwtToken = _staffRepository.getJwtToken();
    if (jwtToken != null) {
      final List _staffList = await getStaffList(jwtToken);
      print(
          '@staff_bloc.dart -> _mapGetStaffEventToState -> staffList = $_staffList');
      if (_staffList != null) {
        yield ShowStaffState(staffList: _staffList);
      } else {
        yield NoStaffState();
      }
    } else {
      print('JwtToken is not provided.');
      yield NoStaffState();
    }
  }

  Stream<StaffState> _mapDeleteStaffEventToState(String deleteUid) async* {
    final String jwtToken = _staffRepository.getJwtToken();
    if (jwtToken != null) {
      final List _staffList =
          await deleteStaff(jwtToken: jwtToken, uid: deleteUid);
      yield ShowStaffState(staffList: _staffList);
    } else {
      print('JwtToken is not provided.');
      yield NoStaffState();
    }
  }

  Stream<StaffState> _mapLoadingStaffEventToState() async* {
    yield LoadingStaffState();
  }
}
