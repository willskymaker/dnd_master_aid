class CharacterCreationException implements Exception {
  final String message;
  final String step;

  const CharacterCreationException(this.message, this.step);

  @override
  String toString() => 'CharacterCreationException in $step: $message';
}

class ValidationException extends CharacterCreationException {
  const ValidationException(super.message, super.step);
}

class DataException extends CharacterCreationException {
  const DataException(super.message, super.step);
}

class NavigationException extends CharacterCreationException {
  const NavigationException(super.message, super.step);
}
