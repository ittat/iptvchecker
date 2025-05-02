class ChannelTestResult {
  final bool available;
  final int? httpStatus;
  final int? ffprobeExit;
  final double? duration;
  final String? error;
  final dynamic streams;
  final dynamic ffprobeRaw;
  final int elapsedMs;

  ChannelTestResult({
    required this.available,
    this.httpStatus,
    this.ffprobeExit,
    this.duration,
    this.error,
    this.streams,
    this.ffprobeRaw,
    required this.elapsedMs,
  });

  Map<String, dynamic> toJson() => {
    'available': available,
    'http_status': httpStatus,
    'ffprobe_exit': ffprobeExit,
    'duration': duration,
    'error': error,
    'streams': streams,
    'ffprobe_raw': ffprobeRaw,
    'elapsed_ms': elapsedMs,
  };
}