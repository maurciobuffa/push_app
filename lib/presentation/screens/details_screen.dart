import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:push_app/domain/entities/push_message.dart';
import 'package:push_app/presentation/blocs/notifications/notifications_bloc.dart';

class DetailsScreen extends StatelessWidget {
  final String pushMessageId;

  const DetailsScreen({super.key, required this.pushMessageId});

  @override
  Widget build(BuildContext context) {
    final PushMessage? message =
        context.watch<NotificationsBloc>().getMessageById(pushMessageId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Details Screen'),
      ),
      body: (message != null)
          ? _DetailsView(message: message)
          : const Center(
              child: Text('Message not found'),
            ),
    );
  }
}

class _DetailsView extends StatelessWidget {
  final PushMessage message;

  const _DetailsView({required this.message});

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textTheme;

    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.title,
              style: textStyles.titleMedium,
            ),
            const SizedBox(height: 10),
            Text(
              message.body,
              style: textStyles.bodyMedium,
            ),
            const SizedBox(height: 10),
            Text(
              message.sentDate.toString(),
              style: textStyles.bodySmall,
            ),
            const SizedBox(height: 10),
            if (message.data != null)
              Text(
                message.data.toString(),
              ),
            const SizedBox(height: 10),
            if (message.imageUrl != null)
              Image.network(
                message.imageUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
          ],
        ));
  }
}
