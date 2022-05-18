part of 'guest_bloc.dart';

abstract class GuestState extends Equatable {
  const GuestState();
}

// loading state for ui change
class LoadingGuestState extends GuestState {
  @override
  List<Object> get props => [];
}

// state that shows guest list
class ShowGuestState extends GuestState {
  final List<Map> guestList;

  ShowGuestState({this.guestList}): assert(guestList != null);

  @override
  List<Object> get props => [this.guestList];
}

// state that firebase has no guest or error occurred
class NoGuestState extends GuestState {
  @override
  List<Object> get props => [];
}
