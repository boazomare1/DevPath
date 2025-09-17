// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GitHubUserAdapter extends TypeAdapter<GitHubUser> {
  @override
  final int typeId = 5;

  @override
  GitHubUser read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GitHubUser(
      id: fields[0] as int,
      login: fields[1] as String,
      name: fields[2] as String,
      email: fields[3] as String,
      avatarUrl: fields[4] as String,
      htmlUrl: fields[5] as String,
      bio: fields[6] as String,
      company: fields[7] as String,
      blog: fields[8] as String,
      location: fields[9] as String,
      publicRepos: fields[10] as int,
      publicGists: fields[11] as int,
      followers: fields[12] as int,
      following: fields[13] as int,
      createdAt: fields[14] as DateTime,
      updatedAt: fields[15] as DateTime,
      hireable: fields[16] as bool,
      type: fields[17] as String,
      twitterUsername: fields[18] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, GitHubUser obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.login)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.avatarUrl)
      ..writeByte(5)
      ..write(obj.htmlUrl)
      ..writeByte(6)
      ..write(obj.bio)
      ..writeByte(7)
      ..write(obj.company)
      ..writeByte(8)
      ..write(obj.blog)
      ..writeByte(9)
      ..write(obj.location)
      ..writeByte(10)
      ..write(obj.publicRepos)
      ..writeByte(11)
      ..write(obj.publicGists)
      ..writeByte(12)
      ..write(obj.followers)
      ..writeByte(13)
      ..write(obj.following)
      ..writeByte(14)
      ..write(obj.createdAt)
      ..writeByte(15)
      ..write(obj.updatedAt)
      ..writeByte(16)
      ..write(obj.hireable)
      ..writeByte(17)
      ..write(obj.type)
      ..writeByte(18)
      ..write(obj.twitterUsername);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GitHubUserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
