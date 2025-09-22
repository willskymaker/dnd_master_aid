class CharacterCreationException implements Exception {
  final String message;
  final String step;

  const CharacterCreationException(this.message, this.step);

  @override
  String toString() => 'CharacterCreationException in $step: $message';
}

class ValidationException extends CharacterCreationException {
  const ValidationException(String message, String step) : super(message, step);
}

class DataException extends CharacterCreationException {
  const DataException(String message, String step) : super(message, step);
}

class NavigationException extends CharacterCreationException {
  const NavigationException(String message, String step) : super(message, step);
}