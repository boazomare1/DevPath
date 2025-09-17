// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'skill.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SkillAdapter extends TypeAdapter<Skill> {
  @override
  final int typeId = 0;

  @override
  Skill read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Skill(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      category: fields[3] as SkillCategory,
      status: fields[4] as SkillStatus,
      notes: fields[5] as String?,
      resources: (fields[6] as List).cast<String>(),
      createdAt: fields[7] as DateTime,
      completedAt: fields[8] as DateTime?,
      priority: fields[9] as int,
      tags: (fields[10] as List).cast<String>(),
      projects: (fields[11] as List?)?.cast<SkillProject>(),
    );
  }

  @override
  void write(BinaryWriter writer, Skill obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.notes)
      ..writeByte(6)
      ..write(obj.resources)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.completedAt)
      ..writeByte(9)
      ..write(obj.priority)
      ..writeByte(10)
      ..write(obj.tags)
      ..writeByte(11)
      ..write(obj.projects);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SkillAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
