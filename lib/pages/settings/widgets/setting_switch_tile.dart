import 'package:fluent_ui/fluent_ui.dart';
import 'package:miru_app/pages/settings/widgets/setting_tile.dart';

class SettingSwitchTile extends StatelessWidget {
  const SettingSwitchTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.checked,
    required this.onChanged,
    this.buildSubtitle,
  }) : super(key: key);
  final Widget icon;
  final String title;
  final String Function()? buildSubtitle;
  final bool checked;
  final Function(bool) onChanged;
  @override
  Widget build(BuildContext context) {
    return SettingTile(
      icon: icon,
      title: title,
      buildSubtitle: buildSubtitle,
      trailing: ToggleSwitch(checked: checked, onChanged: onChanged),
    );
  }
}
