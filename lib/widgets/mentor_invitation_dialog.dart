import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class MentorInvitationDialog extends StatefulWidget {
  final Function(String mentorEmail, String mentorName, String message)
  onInvite;

  const MentorInvitationDialog({super.key, required this.onInvite});

  @override
  State<MentorInvitationDialog> createState() => _MentorInvitationDialogState();
}

class _MentorInvitationDialogState extends State<MentorInvitationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _mentorEmailController = TextEditingController();
  final _mentorNameController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _mentorEmailController.dispose();
    _mentorNameController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.person_add, color: AppColors.warning),
          const SizedBox(width: 12),
          const Text('Invite Mentor'),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Mentor email
              TextFormField(
                controller: _mentorEmailController,
                decoration: const InputDecoration(
                  labelText: 'Mentor Email',
                  hintText: 'mentor@example.com',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value?.isEmpty == true) {
                    return 'Please enter mentor email';
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value!)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Mentor name
              TextFormField(
                controller: _mentorNameController,
                decoration: const InputDecoration(
                  labelText: 'Mentor Name',
                  hintText: 'John Doe',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value?.isEmpty == true) {
                    return 'Please enter mentor name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Message
              TextFormField(
                controller: _messageController,
                decoration: const InputDecoration(
                  labelText: 'Message (Optional)',
                  hintText:
                      'I would like to share my learning progress with you...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.message),
                ),
                maxLines: 3,
                maxLength: 200,
              ),
              const SizedBox(height: 16),

              // Info card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your mentor will receive a secure link to view your progress in read-only mode.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _sendInvitation,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.warning,
            foregroundColor: Colors.white,
          ),
          child: const Text('Send Invitation'),
        ),
      ],
    );
  }

  void _sendInvitation() {
    if (_formKey.currentState?.validate() == true) {
      widget.onInvite(
        _mentorEmailController.text.trim(),
        _mentorNameController.text.trim(),
        _messageController.text.trim(),
      );
      Navigator.of(context).pop();
    }
  }
}
