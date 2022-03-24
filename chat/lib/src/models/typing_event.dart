enum Typing { start, stop }

extension TypingParsing on Typing {
  String value() {
    return toString().split('.').last;
  }

  static Typing fromString(String status) {
    return Typing.values.firstWhere((item) => item.value() == status);
  }
}

class TypingEvent {
  String? get id => _id;
  String? _id;
  String? from;
  String? to;
  Typing? event;

  TypingEvent({
    this.from,
    this.to,
    this.event,
  });

  Map<String, dynamic> toJson() => {
        'from': from,
        'to': to,
        'event': event!.value(),
      };

  factory TypingEvent.fromJson(Map<String, dynamic> json) {
    TypingEvent typingEvent = TypingEvent(
      from: json['from'],
      to: json['to'],
      event: TypingParsing.fromString(json['event']),
    );
    typingEvent._id = json['id'];
    return typingEvent;
  }
}
