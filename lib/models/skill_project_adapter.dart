import 'package:hive/hive.dart';
import 'skill_project.dart';

class SkillProjectAdapter extends TypeAdapter<SkillProject> {
  @override
  final int typeId = 3;

  @override
  SkillProject read(BinaryReader reader) {
    return SkillProject(
      id: reader.readString(),
      title: reader.readString(),
      description: reader.readString(),
      difficulty: reader.readString(),
      isCompleted: reader.readBool(),
      completedAt: reader.readBool() ? DateTime.fromMillisecondsSinceEpoch(reader.readInt()) : null,
      requirements: (reader.readList() as List).cast<String>(),
      notes: reader.readBool() ? reader.readString() : null,
      estimatedHours: reader.readInt(),
    );
  }

  @override
  void write(BinaryWriter writer, SkillProject obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeString(obj.description);
    writer.writeString(obj.difficulty);
    writer.writeBool(obj.isCompleted);
    writer.writeBool(obj.completedAt != null);
    if (obj.completedAt != null) {
      writer.writeInt(obj.completedAt!.millisecondsSinceEpoch);
    }
    writer.writeList(obj.requirements);
    writer.writeBool(obj.notes != null);
    if (obj.notes != null) {
      writer.writeString(obj.notes!);
    }
    writer.writeInt(obj.estimatedHours);
  }
}