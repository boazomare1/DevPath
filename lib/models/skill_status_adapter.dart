import 'package:hive/hive.dart';
import 'skill_status.dart';

class SkillStatusAdapter extends TypeAdapter<SkillStatus> {
  @override
  final int typeId = 1;

  @override
  SkillStatus read(BinaryReader reader) {
    final index = reader.readByte();
    return SkillStatus.values[index];
  }

  @override
  void write(BinaryWriter writer, SkillStatus obj) {
    writer.writeByte(obj.index);
  }
}