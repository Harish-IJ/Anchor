// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_summary.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailySummaryAdapter extends TypeAdapter<DailySummary> {
  @override
  final int typeId = 3;

  @override
  DailySummary read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailySummary(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      totalFocusSeconds: fields[2] as int,
      totalBreakSeconds: fields[3] as int,
      sessionsCompleted: fields[4] as int,
      sessionsInterrupted: fields[5] as int,
      sessionsSkipped: fields[6] as int,
      longestSessionSeconds: fields[7] as int,
      projectSeconds: (fields[8] as Map?)?.cast<String, int>(),
    );
  }

  @override
  void write(BinaryWriter writer, DailySummary obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.totalFocusSeconds)
      ..writeByte(3)
      ..write(obj.totalBreakSeconds)
      ..writeByte(4)
      ..write(obj.sessionsCompleted)
      ..writeByte(5)
      ..write(obj.sessionsInterrupted)
      ..writeByte(6)
      ..write(obj.sessionsSkipped)
      ..writeByte(7)
      ..write(obj.longestSessionSeconds)
      ..writeByte(8)
      ..write(obj.projectSeconds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailySummaryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
