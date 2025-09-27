import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reverie/model/user_model.dart';
import 'package:reverie/provider/user_provider.dart';

class ProfileScreen extends StatelessWidget {
  final String userId;
  const ProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return StreamBuilder<UserModel?>(
      stream: userProvider.listenUser(userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data!;

        return Scaffold(
          appBar: AppBar(title: Text(user.name)),
          body: Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(user.photoUrl),
              ),
              const SizedBox(height: 20),
              Text("Email: ${user.email}"),
              Text("Suscripción: ${user.suscription}"),
              Text("Género: ${user.selectedGender}"),
            ],
          ),
        );
      },
    );
  }
}
