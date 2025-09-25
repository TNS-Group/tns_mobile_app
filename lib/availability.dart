enum Availability {
  available,
  doNotDisturb,
  inClass,
  absent
}

extension AvailabilityExtension on Availability {
  String get label {
    switch (this) {
      case Availability.available:
        return 'Available';
      case Availability.doNotDisturb:
        return 'Do Not Disturb';
      case Availability.inClass:
        return 'In Class';
      case Availability.absent:
        return 'Absent';
    }
  }

  String get reason {
    switch (this) {
      case Availability.available:
        return 'is Available';
      case Availability.doNotDisturb:
        return 'Cannot be Disturbed';
      case Availability.inClass:
        return 'is in Class';
      case Availability.absent:
        return 'is Absent';
    }
  }
}
