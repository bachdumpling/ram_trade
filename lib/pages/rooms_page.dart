import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ram_trade/cubits/profiles/profiles_cubit.dart';
import 'package:ram_trade/cubits/rooms/rooms_cubit.dart';
import 'package:ram_trade/models/profile.dart';
import 'package:ram_trade/pages/chat_page.dart';
import 'package:ram_trade/utils/constants.dart';
import 'package:timeago/timeago.dart';

/// Displays the list of chat threads
class RoomsPage extends StatelessWidget {
  const RoomsPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute(
      builder: (context) => BlocProvider<RoomCubit>(
        create: (context) => RoomCubit()..initializeRooms(context),
        child: const RoomsPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rooms'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await BlocProvider.of<RoomCubit>(context).refreshRooms(context);
        },
        child: BlocBuilder<RoomCubit, RoomState>(
          builder: (context, state) {
            if (state is RoomsLoading) {
              return preloader;
            } else if (state is RoomsLoaded) {
              final newUsers = state.newUsers;
              final rooms = state.rooms;
              return BlocBuilder<ProfilesCubit, ProfilesState>(
                builder: (context, state) {
                  if (state is ProfilesLoaded) {
                    final profiles = state.profiles;
                    return Column(
                      children: [
                        _NewUsers(newUsers: newUsers),
                        Expanded(
                          child: ListView.builder(
                            itemCount: rooms.length,
                            itemBuilder: (context, index) {
                              final room = rooms[index];
                              final otherUser = profiles[room.otherUserId];

                              return ListTile(
                                onTap: () => Navigator.of(context)
                                    .push(ChatPage.route(room.id)),
                                leading: CircleAvatar(
                                  child: otherUser == null
                                      ? preloader
                                      : Text(
                                          otherUser.fullName.substring(0, 2)),
                                ),
                                title: Text(otherUser == null
                                    ? 'Loading...'
                                    : otherUser.fullName),
                                subtitle: room.lastMessage != null
                                    ? Text(
                                        room.lastMessage!.content,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    : const Text('Room created'),
                                trailing: Text(format(
                                    room.lastMessage?.createdAt ??
                                        room.createdAt,
                                    locale: 'en_short')),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  } else {
                    return preloader;
                  }
                },
              );
            } else if (state is RoomsEmpty) {
              final newUsers = state.newUsers;
              return Column(
                children: [
                  _NewUsers(newUsers: newUsers),
                  const Expanded(
                    child: Center(
                      child: Text('Start a chat by tapping on available users'),
                    ),
                  ),
                ],
              );
            } else if (state is RoomsError) {
              return Center(child: Text(state.message));
            }
            throw UnimplementedError();
          },
        ),
      ),
    );
  }
}

class _NewUsers extends StatelessWidget {
  const _NewUsers({
    Key? key,
    required this.newUsers,
  }) : super(key: key);

  final List<Profile> newUsers;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: newUsers
            .map<Widget>((user) => InkWell(
                  onTap: () async {
                    try {
                      final roomId = await BlocProvider.of<RoomCubit>(context)
                          .createRoom(user.id);
                      Navigator.of(context).push(ChatPage.route(roomId));
                    } catch (_) {
                      context.showErrorSnackBar(
                          message: 'Failed creating a new room');
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 60,
                      child: Column(
                        children: [
                          CircleAvatar(
                            child: Text(user.fullName.substring(0, 2)),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            user.fullName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
