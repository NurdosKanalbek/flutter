sealed class Countdown {
  const Countdown();

  factory Countdown.at(DateTime start, DateTime now) {
    final remaining = start.difference(now);
    if (remaining.isNegative == false) return Upcoming(remaining);
    final elapsed = now.difference(start);
    return elapsed < const Duration(hours: 1) ? Started(elapsed) : const Ended();
  }

  String get label => switch (this) {
    Upcoming(:final remaining) => remaining.inDays > 0
        ? 'In ${remaining.inDays} days'
        : remaining.inHours > 0
        ? 'In ${remaining.inHours} h ${remaining.inMinutes.remainder(60)} min'
        : 'In ${remaining.inMinutes} min',
    Started(:final elapsed) => 'Started ${elapsed.inMinutes} min ago',
    Ended() => 'Ended',
  };
}

final class Upcoming extends Countdown {
  const Upcoming(this.remaining);
  final Duration remaining;
}

final class Started extends Countdown {
  const Started(this.elapsed);
  final Duration elapsed;
}

final class Ended extends Countdown {
  const Ended();
}
