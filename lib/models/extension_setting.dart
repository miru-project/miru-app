import 'package:isar/isar.dart';

part 'extension_setting.g.dart';

enum ExtensionSettingType {
  // 输入框
  input,
  // 单选
  radio,
  // 开关
  toggle,
}

@collection
class ExtensionSetting {
  Id id = Isar.autoIncrement;

  @Index(name: 'package&key', composite: [CompositeIndex('key')], unique: true)
  late String package;
  // 标题
  late String title;
  // 键
  late String key;
  // 值
  String? value;
  // 默认值
  late String defaultValue;
  // 类型
  @Enumerated(EnumType.name)
  late ExtensionSettingType type;
  // 描述
  String? description;

  String? options;

  static ExtensionSettingType stringToType(String type) {
    switch (type) {
      case 'input':
        return ExtensionSettingType.input;
      case 'radio':
        return ExtensionSettingType.radio;
      case 'toggle':
        return ExtensionSettingType.toggle;
      default:
        return ExtensionSettingType.input;
    }
  }
}
