// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'skill_project.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SkillProjectAdapter extends TypeAdapter<SkillProject> {
  @override
  final int typeId = 3;

  @override
  SkillProject read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SkillProject(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      difficulty: fields[3] as String,
      isCompleted: fields[4] as bool,
      completedAt: fields[5] as DateTime?,
      requirements: (fields[6] as List).cast<String>(),
      notes: fields[7] as String?,
      estimatedHours: fields[8] as int,
    );
  }

  @override
  void write(BinaryWriter writer, SkillProject obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.difficulty)
      ..writeByte(4)
      ..write(obj.isCompleted)
      ..writeByte(5)
      ..write(obj.completedAt)
      ..writeByte(6)
      ..write(obj.requirements)
      ..writeByte(7)
      ..write(obj.notes)
      ..writeByte(8)
      ..write(obj.estimatedHours);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SkillProjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
