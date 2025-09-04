enum PresetDateRange {
  pastHour('Past hour'),
  pastDay('Past day'),
  pastWeek('Past week'),
  pastMonth('Past month'),
  pastYear('Past year'),
  custom('Custom');

  final String displayName;

  const PresetDateRange(this.displayName);

  DateTime? get startDate {
    final now = DateTime.now();
    return switch (this) {
      pastHour => now.subtract(const Duration(hours: 1)),
      pastDay => now.subtract(const Duration(days: 1)),
      pastWeek => now.subtract(const Duration(days: 7)),
      pastMonth => now.copyWith(month: now.month - 1),
      pastYear => now.copyWith(year: now.year - 1),
      custom => null,
    };
  }

  DateTime? get endDate => this == custom ? null : DateTime.now();
}
