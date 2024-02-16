import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ram_trade/cubits/profiles/profiles_cubit.dart';
import 'package:ram_trade/models/profile.dart';
import 'package:ram_trade/models/message.dart';
import 'package:ram_trade/models/room.dart';
import 'package:ram_trade/utils/constants.dart';

part 'rooms_state.dart';

class RoomCubit extends Cubit<RoomState> {
  RoomCubit() : super(RoomsLoading());

  final Map<String, StreamSubscription<Message?>> _messageSubscriptions = {};

  late final String _myUserId;

  /// List of new users of the app for the user to start talking to
  late final List<Profile> _newUsers;

  /// List of rooms
  List<Room> _rooms = [];
  StreamSubscription<List<Map<String, dynamic>>>? _rawRoomsSubscription;
  bool _haveCalledGetRooms = false;

  Future<void> initializeRooms(BuildContext context) async {
    if (_haveCalledGetRooms) {
      return;
    }
    _haveCalledGetRooms = true;

    _myUserId = supabase.auth.currentUser!.id;

    late final List data;

    try {
      data = await supabase
          .from('profiles')
          .select('*')
          .not('id', 'eq', _myUserId)
          .order('created_at')
          .limit(12);
    } catch (_) {
      emit(RoomsError('Error loading new users'));
    }
    debugPrint('data: $data');
    debugPrint('my userid: $_myUserId');

    final rows = List<Map<String, dynamic>>.from(data);
    _newUsers = rows.map(Profile.fromMap).toList();

    /// Get realtime updates on rooms that the user is in
    _rawRoomsSubscription = supabase.from('room_participants').stream(
      primaryKey: ['room_id', 'profile_id'],
    ).listen((participantMaps) async {
      if (participantMaps.isEmpty) {
        emit(RoomsEmpty(newUsers: _newUsers));
        return;
      }

      _rooms = participantMaps
          .map(Room.fromRoomParticipants)
          .where((room) => room.otherUserId != _myUserId)
          .toList();
      for (final room in _rooms) {
        _getNewestMessage(context: context, roomId: room.id);
        BlocProvider.of<ProfilesCubit>(context).getProfile(room.otherUserId);
      }
      emit(RoomsLoaded(
        newUsers: _newUsers,
        rooms: _rooms,
      ));
    }, onError: (error) {
      emit(RoomsError('Error loading rooms'));
    });
  }

  Future<void> refreshRooms(BuildContext context) async {
    // Optionally show loading state
    // emit(RoomsLoading());
    try {
      // Re-fetch the rooms and new users or perform necessary updates
      // This is a simplified example. Adjust based on your actual data fetching logic.
      _haveCalledGetRooms = false;
      await initializeRooms(context);
      // You might want to emit a new state here even if the data hasn't changed,
      // to ensure the UI refreshes. Consider creating a new instance of the state.
      // For example, if the data hasn't changed:
      if (state is RoomsLoaded) {
        final currentState = state as RoomsLoaded;
        emit(RoomsLoaded(
            rooms: currentState.rooms, newUsers: currentState.newUsers));
      }
    } catch (error) {
      emit(RoomsError('Failed to refresh rooms.'));
    }
  }

  // Setup listeners to listen to the most recent message in each room
  void _getNewestMessage({
    required BuildContext context,
    required String roomId,
  }) {
    _messageSubscriptions[roomId] = supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('room_id', roomId)
        .order('created_at')
        .limit(1)
        .map<Message?>(
          (data) => data.isEmpty
              ? null
              : Message.fromMap(
                  map: data.first,
                  myUserId: _myUserId,
                ),
        )
        .listen((message) {
          final index = _rooms.indexWhere((room) => room.id == roomId);
          _rooms[index] = _rooms[index].copyWith(lastMessage: message);
          _rooms.sort((a, b) {
            /// Sort according to the last message
            /// Use the room createdAt when last message is not available
            final aTimeStamp =
                a.lastMessage != null ? a.lastMessage!.createdAt : a.createdAt;
            final bTimeStamp =
                b.lastMessage != null ? b.lastMessage!.createdAt : b.createdAt;
            return bTimeStamp.compareTo(aTimeStamp);
          });
          if (!isClosed) {
            emit(RoomsLoaded(
              newUsers: _newUsers,
              rooms: _rooms,
            ));
          }
        });
  }

  /// Creates or returns an existing roomID of both participants
  Future<String> createRoom(String otherUserId) async {
    final data = await supabase
        .rpc('create_new_room', params: {'other_user_id': otherUserId});
    emit(RoomsLoaded(rooms: _rooms, newUsers: _newUsers));
    return data as String;
  }

  @override
  Future<void> close() {
    _rawRoomsSubscription?.cancel();
    return super.close();
  }
}
