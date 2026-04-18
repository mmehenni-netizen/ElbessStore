class ApiError {
  final String message;
  final bool? success;

  ApiError({required this.message,  this.success});

  @override
  String toString() {
    return "error is: $message";
  }
}
