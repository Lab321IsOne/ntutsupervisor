part of 'guest_bloc.dart';

abstract class GuestEvent extends Equatable {
  const GuestEvent();
}

// loading event that yields state for ui change
class LoadingGuestEvent extends GuestEvent {
  @override
  List<Object> get props => [];
}

// regenerate serial number for a particular guest
class RegenerateSerialNumberEvent extends GuestEvent {
  final String machine;
  final String expireTime;
  final String position;

  RegenerateSerialNumberEvent({
    this.machine,
    this.expireTime,
    this.position,
  })  : assert(machine != null),
        assert(expireTime != null);

  @override
  List<Object> get props => [
        this.machine,
        this.expireTime,
        this.position,
      ];
}

// event get all guests
class GetGuestEvent extends GuestEvent {
  @override
  List<Object> get props => [];
}

// event deletes particular guest and machine
class DeleteGuestEvent extends GuestEvent {
  final String machine;

  DeleteGuestEvent({this.machine}) : assert(machine != null);

  @override
  List<Object> get props => [this.machine];
}
