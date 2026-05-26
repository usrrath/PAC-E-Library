import 'dart:io';

class ProfileEditResult {
  final String name;
  final File? photo;

  const ProfileEditResult({
    required this.name,
    this.photo,
  });
}