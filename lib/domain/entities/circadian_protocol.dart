import 'dart:convert';

class CircadianShiftDay {
  final int dayOffset;
  final String dayLabel;
  final String targetBedtime;
  final String targetWakeup;
  final String lightExposureWindow;
  final String lightAvoidanceWindow;
  final String caffeineCutoff;
  final String mealAnchor;
  final String melatoninWindow;
  final bool isCompleted;

  const CircadianShiftDay({
    required this.dayOffset,
    required this.dayLabel,
    required this.targetBedtime,
    required this.targetWakeup,
    required this.lightExposureWindow,
    required this.lightAvoidanceWindow,
    required this.caffeineCutoff,
    required this.mealAnchor,
    required this.melatoninWindow,
    this.isCompleted = false,
  });

  CircadianShiftDay copyWith({
    int? dayOffset,
    String? dayLabel,
    String? targetBedtime,
    String? targetWakeup,
    String? lightExposureWindow,
    String? lightAvoidanceWindow,
    String? caffeineCutoff,
    String? mealAnchor,
    String? melatoninWindow,
    bool? isCompleted,
  }) {
    return CircadianShiftDay(
      dayOffset: dayOffset ?? this.dayOffset,
      dayLabel: dayLabel ?? this.dayLabel,
      targetBedtime: targetBedtime ?? this.targetBedtime,
      targetWakeup: targetWakeup ?? this.targetWakeup,
      lightExposureWindow: lightExposureWindow ?? this.lightExposureWindow,
      lightAvoidanceWindow: lightAvoidanceWindow ?? this.lightAvoidanceWindow,
      caffeineCutoff: caffeineCutoff ?? this.caffeineCutoff,
      mealAnchor: mealAnchor ?? this.mealAnchor,
      melatoninWindow: melatoninWindow ?? this.melatoninWindow,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'day_offset': dayOffset,
      'day_label': dayLabel,
      'target_bedtime': targetBedtime,
      'target_wakeup': targetWakeup,
      'light_exposure_window': lightExposureWindow,
      'light_avoidance_window': lightAvoidanceWindow,
      'caffeine_cutoff': caffeineCutoff,
      'meal_anchor': mealAnchor,
      'melatonin_window': melatoninWindow,
      'is_completed': isCompleted ? 1 : 0,
    };
  }

  factory CircadianShiftDay.fromMap(Map<String, dynamic> map) {
    return CircadianShiftDay(
      dayOffset: (map['day_offset'] as num?)?.toInt() ?? 0,
      dayLabel: map['day_label'] as String? ?? 'Shift Day',
      targetBedtime: map['target_bedtime'] as String? ?? '22:00',
      targetWakeup: map['target_wakeup'] as String? ?? '06:30',
      lightExposureWindow:
          map['light_exposure_window'] as String? ?? '07:00 - 10:00',
      lightAvoidanceWindow:
          map['light_avoidance_window'] as String? ?? '19:00 - Bedtime',
      caffeineCutoff: map['caffeine_cutoff'] as String? ?? '14:00',
      mealAnchor: map['meal_anchor'] as String? ?? 'Breakfast 07:30',
      melatoninWindow: map['melatonin_window'] as String? ?? '21:30',
      isCompleted: map['is_completed'] == 1 || map['is_completed'] == true,
    );
  }
}

class JetlagPlan {
  final String id;
  final String tripId;
  final String originCity;
  final int originTzOffset;
  final String destinationCity;
  final int destinationTzOffset;
  final int departureTimestamp;
  final int arrivalTimestamp;
  final String direction; // 'Eastward' or 'Westward'
  final int totalHourShift;
  final int daysToAdapt;
  final List<CircadianShiftDay> shiftDays;

  const JetlagPlan({
    required this.id,
    required this.tripId,
    required this.originCity,
    required this.originTzOffset,
    required this.destinationCity,
    required this.destinationTzOffset,
    required this.departureTimestamp,
    required this.arrivalTimestamp,
    required this.direction,
    required this.totalHourShift,
    required this.daysToAdapt,
    required this.shiftDays,
  });

  double get completionRate {
    if (shiftDays.isEmpty) return 0.0;
    final completed = shiftDays.where((d) => d.isCompleted).length;
    return completed / shiftDays.length;
  }

  int get completedCheckpoints => shiftDays.where((d) => d.isCompleted).length;

  JetlagPlan copyWith({
    String? id,
    String? tripId,
    String? originCity,
    int? originTzOffset,
    String? destinationCity,
    int? destinationTzOffset,
    int? departureTimestamp,
    int? arrivalTimestamp,
    String? direction,
    int? totalHourShift,
    int? daysToAdapt,
    List<CircadianShiftDay>? shiftDays,
  }) {
    return JetlagPlan(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      originCity: originCity ?? this.originCity,
      originTzOffset: originTzOffset ?? this.originTzOffset,
      destinationCity: destinationCity ?? this.destinationCity,
      destinationTzOffset: destinationTzOffset ?? this.destinationTzOffset,
      departureTimestamp: departureTimestamp ?? this.departureTimestamp,
      arrivalTimestamp: arrivalTimestamp ?? this.arrivalTimestamp,
      direction: direction ?? this.direction,
      totalHourShift: totalHourShift ?? this.totalHourShift,
      daysToAdapt: daysToAdapt ?? this.daysToAdapt,
      shiftDays: shiftDays ?? this.shiftDays,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'trip_id': tripId,
      'origin_city': originCity,
      'origin_tz_offset': originTzOffset,
      'destination_city': destinationCity,
      'destination_tz_offset': destinationTzOffset,
      'departure_timestamp': departureTimestamp,
      'arrival_timestamp': arrivalTimestamp,
      'direction': direction,
      'total_hour_shift': totalHourShift,
      'days_to_adapt': daysToAdapt,
      'shift_days_json': jsonEncode(shiftDays.map((d) => d.toMap()).toList()),
    };
  }

  factory JetlagPlan.fromMap(Map<String, dynamic> map) {
    List<CircadianShiftDay> days = [];
    final jsonStr = map['shift_days_json'] as String?;
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final decoded = jsonDecode(jsonStr) as List;
        days = decoded
            .map(
              (item) => CircadianShiftDay.fromMap(item as Map<String, dynamic>),
            )
            .toList();
      } catch (_) {
        days = [];
      }
    }

    return JetlagPlan(
      id: map['id'] as String? ?? '',
      tripId: map['trip_id'] as String? ?? '',
      originCity: map['origin_city'] as String? ?? 'Origin',
      originTzOffset: (map['origin_tz_offset'] as num?)?.toInt() ?? 0,
      destinationCity: map['destination_city'] as String? ?? 'Destination',
      destinationTzOffset: (map['destination_tz_offset'] as num?)?.toInt() ?? 0,
      departureTimestamp: (map['departure_timestamp'] as num?)?.toInt() ?? 0,
      arrivalTimestamp: (map['arrival_timestamp'] as num?)?.toInt() ?? 0,
      direction: map['direction'] as String? ?? 'Eastward',
      totalHourShift: (map['total_hour_shift'] as num?)?.toInt() ?? 0,
      daysToAdapt: (map['days_to_adapt'] as num?)?.toInt() ?? 1,
      shiftDays: days,
    );
  }
}
