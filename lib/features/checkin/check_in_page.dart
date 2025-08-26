import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/check_in_bloc.dart';
import '../../services/notification_service.dart';
import '../../services/check_in_repository.dart';
import 'bloc/check_in_event.dart';
import 'bloc/check_in_state.dart';

class CheckInPage extends StatelessWidget {
  const CheckInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CheckInBloc(
        repo: CheckInRepository(),
        notifications: NotificationService(),
      ),
      child: _CheckInView(),
    );
  }
}

class _CheckInView extends StatefulWidget {
  const _CheckInView();

  @override
  State<_CheckInView> createState() => _CheckInViewState();
}

class _CheckInViewState extends State<_CheckInView> {
  Duration _duration = const Duration(minutes: 30);
  Duration _grace = const Duration(minutes: 5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Check-In Timer', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: BlocBuilder<CheckInBloc, CheckInState>(
          builder: (context, state) {
            final active = state is CheckInActive ? state : null;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _section('Remind me in'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final mins in [10, 20, 30, 45, 60])
                      ChoiceChip(
                        label: Text('$mins min'),
                        selected: _duration.inMinutes == mins,
                        onSelected: (_) => setState(() => _duration = Duration(minutes: mins)),
                      ),
                    ActionChip(
                      label: const Text('Custom...'),
                      onPressed: () async {
                        final d = await _pickCustomDuration(context, defaultMinutes: _duration.inMinutes);
                        if (d != null) setState(() => _duration = d);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _section('Grace period before auto-alert'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final mins in [3, 5, 10, 15])
                      ChoiceChip(
                        label: Text('$mins min'),
                        selected: _grace.inMinutes == mins,
                        onSelected: (_) => setState(() => _grace = Duration(minutes: mins)),
                      ),
                  ],
                ),
                const Spacer(),
                if (active == null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        context.read<CheckInBloc>().add(CheckInStart(duration: _duration, gracePeriod: _grace));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Check-in timer started')),
                        );
                      },
                      child: const Text('Start Check-In'),
                    ),
                  )
                else ...[
                  _statusTile(active),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white54),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        context.read<CheckInBloc>().add(const CheckInCancel());
                      },
                      child: const Text('Cancel Check-In'),
                    ),
                  )
                ]
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _statusTile(CheckInActive s) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Active Check-In', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text('Reminder: ${s.remindAt}', style: const TextStyle(color: Colors.white70)),
          Text('Auto-alert (if no response): ${s.autoAlertAt}', style: const TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }

  Widget _section(String title) => Text(title, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600));

  Future<Duration?> _pickCustomDuration(BuildContext context, {required int defaultMinutes}) async {
    final controller = TextEditingController(text: defaultMinutes.toString());
    final result = await showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Custom minutes'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Minutes'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, int.tryParse(controller.text)), child: const Text('OK')),
        ],
      ),
    );
    if (result == null || result <= 0) return null;
    return Duration(minutes: result);
  }
}
