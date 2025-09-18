// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repo_status.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RepoStatusAdapter extends TypeAdapter<RepoStatus> {
  @override
  final int typeId = 4;

  @override
  RepoStatus read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RepoStatus(
      repoId: fields[0] as int,
      status: fields[1] as ProjectStatus,
      lastUpdated: fields[2] as DateTime,
      notes: fields[3] as String?,
      openIssuesCount: fields[4] as int,
      lastActivity: fields[5] as DateTime?,
      isStale: fields[6] as bool,
      hasRecentActivity: fields[7] as bool,
      lastCommitDate: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, RepoStatus obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.repoId)
      ..writeByte(1)
      ..write(obj.status)
      ..writeByte(2)
      ..write(obj.lastUpdated)
      ..writeByte(3)
      ..write(obj.notes)
      ..writeByte(4)
      ..write(obj.openIssuesCount)
      ..writeByte(5)
      ..write(obj.lastActivity)
      ..writeByte(6)
      ..write(obj.isStale)
      ..writeByte(7)
      ..write(obj.hasRecentActivity)
      ..writeByte(8)
      ..write(obj.lastCommitDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RepoStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
