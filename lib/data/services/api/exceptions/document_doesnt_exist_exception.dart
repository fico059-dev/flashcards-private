class DocumentDoesntExistException implements Exception {
  final String? documentPath;
  final String message;

  DocumentDoesntExistException({
    this.documentPath,
    this.message = 'المستند المطلوب غير موجود.',
  });

  @override
  String toString() {
    if (documentPath != null) {
      return 'DocumentDoesntExistException: $message (path: $documentPath)';
    }
    return 'DocumentDoesntExistException: $message';
  }
}
