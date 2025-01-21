class PasswordValidationResponse {
  final bool isValid;
  final int strength;
  final List<String> validationErrors;

  const PasswordValidationResponse({
    required this.isValid,
    required this.strength,
    required this.validationErrors,
  });
}
