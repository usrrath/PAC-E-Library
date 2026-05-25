import 'dart:io';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/profile_edit_resultxx.dart';
import 'profile_avatar.dart';

class EditProfileSheet extends StatefulWidget {
  final String name;
  final String email;
  final String userLevel;
  final String photoUrl;
  final Future<File?> Function() pickPhoto;

  const EditProfileSheet({
    super.key,
    required this.name,
    required this.email,
    required this.userLevel,
    required this.photoUrl,
    required this.pickPhoto,
  });

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  late final TextEditingController nameCtrl;
  File? selectedPhoto;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.name);
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _choosePhoto() async {
    final file = await widget.pickPhoto();

    if (!mounted || file == null) return;

    setState(() => selectedPhoto = file);
  }

  void _save() {
    final cleanName = nameCtrl.text.trim();

    if (cleanName.isEmpty) return;

    Navigator.of(context).pop(
      ProfileEditResult(
        name: cleanName,
        photo: selectedPhoto,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              t.profilesEditProfile,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 16),
            Stack(
              children: [
                ProfileAvatar(
                  photoUrl: widget.photoUrl,
                  selectedPhoto: selectedPhoto,
                  size: 96,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: InkWell(
                    onTap: _choosePhoto,
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).cardColor,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: t.profilesName,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.person_outline_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: widget.email,
              enabled: false,
              decoration: InputDecoration(
                labelText: t.profilesEmail,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: widget.userLevel,
              enabled: false,
              decoration: InputDecoration(
                labelText: t.profilesUserLevel,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.verified_user_outlined),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(t.profilesCancel),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _save,
                    child: Text(t.profilesSave),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}