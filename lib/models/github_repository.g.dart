// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_repository.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GitHubRepositoryAdapter extends TypeAdapter<GitHubRepository> {
  @override
  final int typeId = 4;

  @override
  GitHubRepository read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GitHubRepository(
      id: fields[0] as int,
      name: fields[1] as String,
      fullName: fields[2] as String,
      description: fields[3] as String,
      htmlUrl: fields[4] as String,
      cloneUrl: fields[5] as String,
      language: fields[6] as String,
      stars: fields[7] as int,
      forks: fields[8] as int,
      isPrivate: fields[9] as bool,
      isFork: fields[10] as bool,
      createdAt: fields[11] as DateTime,
      updatedAt: fields[12] as DateTime,
      pushedAt: fields[13] as DateTime?,
      openIssuesCount: fields[14] as int,
      defaultBranch: fields[15] as String,
      size: fields[16] as int,
      topics: fields[17] as String?,
      hasIssues: fields[18] as bool,
      hasProjects: fields[19] as bool,
      hasWiki: fields[20] as bool,
      hasPages: fields[21] as bool,
      license: fields[22] as String?,
      archived: fields[23] as bool,
      disabled: fields[24] as bool,
      homepage: fields[25] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, GitHubRepository obj) {
    writer
      ..writeByte(26)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.fullName)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.htmlUrl)
      ..writeByte(5)
      ..write(obj.cloneUrl)
      ..writeByte(6)
      ..write(obj.language)
      ..writeByte(7)
      ..write(obj.stars)
      ..writeByte(8)
      ..write(obj.forks)
      ..writeByte(9)
      ..write(obj.isPrivate)
      ..writeByte(10)
      ..write(obj.isFork)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.updatedAt)
      ..writeByte(13)
      ..write(obj.pushedAt)
      ..writeByte(14)
      ..write(obj.openIssuesCount)
      ..writeByte(15)
      ..write(obj.defaultBranch)
      ..writeByte(16)
      ..write(obj.size)
      ..writeByte(17)
      ..write(obj.topics)
      ..writeByte(18)
      ..write(obj.hasIssues)
      ..writeByte(19)
      ..write(obj.hasProjects)
      ..writeByte(20)
      ..write(obj.hasWiki)
      ..writeByte(21)
      ..write(obj.hasPages)
      ..writeByte(22)
      ..write(obj.license)
      ..writeByte(23)
      ..write(obj.archived)
      ..writeByte(24)
      ..write(obj.disabled)
      ..writeByte(25)
      ..write(obj.homepage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GitHubRepositoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
