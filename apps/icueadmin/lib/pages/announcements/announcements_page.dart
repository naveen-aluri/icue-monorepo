import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import '../../providers/announcements_provider.dart';

class AnnouncementsPage extends StatefulWidget {
  const AnnouncementsPage({super.key});

  @override
  State<AnnouncementsPage> createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends State<AnnouncementsPage> {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnnouncementsProvider>(
        context,
        listen: false,
      ).getAnnouncements();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AnnouncementsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcements'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.only(bottom: 20),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 1.5, color: Colors.grey),
                ),
              ),
              child: const Text(
                'Timely and informative messages enhancing communication and ensuring important updates reach the intended effectively.',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final item = provider.announcements[index];
                return ListTile(
                  title: Text(
                    item.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(item.description),
                );
              },
              separatorBuilder: (context, index) => const Divider(),
              itemCount: provider.announcements.length,
            ),
    );
  }
}
