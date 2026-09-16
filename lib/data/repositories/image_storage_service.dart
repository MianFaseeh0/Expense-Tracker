import 'dart:io';

/// Abstraction over where/how a picked receipt image is persisted so it
/// survives after the temp file the image picker handed us is gone.
abstract interface class ImageStorageService {
  Future<File> persist(File sourceImage);
}
