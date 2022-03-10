import 'package:equatable/equatable.dart';

class CleanFailure extends Equatable {
  final String tag;
  final String error;

  const CleanFailure({
    required this.tag,
    required this.error,
  });

  CleanFailure copyWith({
    String? tag,
    String? error,
  }) {
    return CleanFailure(
      tag: tag ?? this.tag,
      error: error ?? this.error,
    );
  }

  factory CleanFailure.none() => const CleanFailure(tag: '', error: '');

  @override
  String toString() => 'CleanFailure(type: $tag, error: $error)';

  @override
  List<Object> get props => [tag, error];
}
