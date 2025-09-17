// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repo_status.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RepoStatusAdapter extends TypeAdapter<RepoStatus> {
  @override
  final int typeId = 7;

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
      isStale: fields[4] as bool,
      openIssuesCount: fields[5] as int,
      lastCommitDate: fields[6] as DateTime?,
      hasRecentActivity: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, RepoStatus obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.repoId)
      ..writeByte(1)
      ..write(obj.status)
      ..writeByte(2)
      ..write(obj.lastUpdated)
      ..writeByte(3)
      ..write(obj.notes)
      ..writeByte(4)
      ..write(obj.isStale)
      ..writeByte(5)
      ..write(obj.openIssuesCount)
      ..writeByte(6)
      ..write(obj.lastCommitDate)
      ..writeByte(7)
      ..write(obj.hasRecentActivity);
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

class ProjectStatusAdapter extends TypeAdapter<ProjectStatus> {
  @override
  final int typeId = 6;

  @override
  ProjectStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ProjectStatus.inProgress;
      case 1:
        return ProjectStatus.onHold;
      case 2:
        return ProjectStatus.completed;
      case 3:
        return ProjectStatus.notStarted;
      default:
        return ProjectStatus.inProgress;
    }
  }

  @override
  void write(BinaryWriter writer, ProjectStatus obj) {
    switch (obj) {
      case ProjectStatus.inProgress:
        writer.writeByte(0);
        break;
      case ProjectStatus.onHold:
        writer.writeByte(1);
        break;
      case ProjectStatus.completed:
        writer.writeByte(2);
        break;
      case ProjectStatus.notStarted:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
