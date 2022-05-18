import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:firevisor/api.dart';
import 'package:firevisor/user_repository.dart';

part 'guest_event.dart';

part 'guest_state.dart';

class GuestBloc extends Bloc<GuestEvent, GuestState> {
  final UserRepository _guestRepository;

  GuestBloc({@required UserRepository userRepository})
      : assert(userRepository != null),
        _guestRepository = userRepository,
        super(NoGuestState());

  @override
  Stream<GuestState> mapEventToState(
    GuestEvent event,
  ) async* {
    if (event is RegenerateSerialNumberEvent) {
      yield* _mapRegenerateSerialNumberEventToState(
        event.machine,
        event.expireTime,
        event.position,
      );
    } else if (event is GetGuestEvent) {
      yield* _mapGetGuestEventToState();
    } else if (event is DeleteGuestEvent) {
      yield* _mapDeleteGuestEventToState(event.machine);
    } else if (event is LoadingGuestEvent) {
      yield* _mapLoadingGuestEventToState();
    }
  }
  
  Stream<GuestState> _mapRegenerateSerialNumberEventToState(
    String machine,
    String expireTime,
    String position,
  ) async* {
    final String jwtToken = _guestRepository.getJwtToken();
    if (jwtToken != null) {
      final Duration addTime = Duration(days: int.parse(expireTime));
      final DateTime expire = DateTime.now().add(addTime);
      final Map requestData = {
        'jwtToken': jwtToken,
        'machine': machine,
        'expire': expire.millisecondsSinceEpoch.toString(),
        'position': position,
      };
      final List _guestList = await regenerateGuestSerialNumber(requestData);
      yield ShowGuestState(guestList: _guestList);
    } else {
      print('JwtToken is not provided.');
      yield NoGuestState();
    }
  }

  Stream<GuestState> _mapGetGuestEventToState() async* {
    final String jwtToken = _guestRepository.getJwtToken();
    if (jwtToken != null) {
      final List _guestList = await getGuestList(jwtToken);
      print(
          '@guest_bloc.dart -> _mapGetStaffEventToState -> guestList = $_guestList');
      if (_guestList != null) {
        yield ShowGuestState(guestList: _guestList);
      } else {
        yield NoGuestState();
      }
    } else {
      print('JwtToken is not provided.');
      yield NoGuestState();
    }
  }

  Stream<GuestState> _mapDeleteGuestEventToState(String machine) async* {
    final String jwtToken = _guestRepository.getJwtToken();
    if (jwtToken != null) {
      final List _guestList = await deleteGuest(jwtToken: jwtToken, machine: machine);
      if (_guestList != null) {
        yield ShowGuestState(guestList: _guestList);
      } else {
        yield NoGuestState();
      }
    } else {
      print('JwtToken is not provided.');
      yield NoGuestState();
    }
  }

  Stream<GuestState> _mapLoadingGuestEventToState() async* {
    yield LoadingGuestState();
  }
}
