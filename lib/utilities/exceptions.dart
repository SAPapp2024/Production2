class DisabledUserException implements Exception {
  @override
  String toString() => "This user is not enabled.";
}

class DeletedUserException implements Exception {
  @override
  String toString() => "This user was deleted.";
}

class NotEnoughBarcodesToBuyException implements Exception {
  @override
  String toString() => "The system doesn't have this amount of barcodes.";
}