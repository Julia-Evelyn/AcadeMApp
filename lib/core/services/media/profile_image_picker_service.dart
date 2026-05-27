import 'dart:io';

import 'package:image_picker/image_picker.dart';

abstract class ProfileImagePickerService {
  Future<File?> pickImage(ImageSource source);
}

class DeviceProfileImagePickerService implements ProfileImagePickerService {
  final ImagePicker _picker = ImagePicker();

  @override
  Future<File?> pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    return pickedFile != null ? File(pickedFile.path) : null;
  }
}
