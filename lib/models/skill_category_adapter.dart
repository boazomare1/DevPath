import 'package:hive/hive.dart';
import 'skill_category.dart';

class SkillCategoryAdapter extends TypeAdapter<SkillCategory> {
  @override
  final int typeId = 2;

  @override
  SkillCategory read(BinaryReader reader) {
    final index = reader.readByte();
    return SkillCategory.values[index];
  }

  @override
  void write(BinaryWriter writer, SkillCategory obj) {
    writer.writeByte(obj.index);
  }
}