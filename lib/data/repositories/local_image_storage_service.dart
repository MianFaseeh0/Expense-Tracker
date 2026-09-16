import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../core/errors/app_exception.dart';
import 'image_storage_service.dart';

/// Persists picked images to the platform's app-owned storage directory.
///
/// This was previously two private methods living inside the "add expense"
/// screen; pulling it out means any screen can reuse it and it can be
/// tested/mocked independently of UI.
class LocalImageStorageService implements ImageStorageService {
  @override
  Future<File> persist(File sourceImage) async {
    try {
      final directory = await _resolveSaveDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final destinationPath = '${directory.path}/$fileName';
      return await sourceImage.copy(destinationPath);
    } catch (error) {
      throw FileStorageException(
        'Could not save the selected image.',
        cause: error,
      );
    }
  }

  Future<Directory> _resolveSaveDirectory() async {
    if (Platform.isAndroid) {
      return await getExternalStorageDirectory() ??
          await getApplicationDocumentsDirectory();
    }
    return getApplicationDocumentsDirectory();
  }
}
