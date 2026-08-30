class Failure {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  String toString() => 'Failure(message: $message, code: $code)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure && other.message == message && other.code == code;

  @override
  int get hashCode => message.hashCode ^ code.hashCode;
}
