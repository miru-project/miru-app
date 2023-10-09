import 'package:fluent_ui/fluent_ui.dart';

class CardTile extends StatelessWidget {
  const CardTile({
    Key? key,
    required this.title,
    required this.child,
    this.trailing,
    this.leading,
  }) : super(key: key);
  final String title;
  final Widget? leading;
  final Widget? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(
        color: FluentTheme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 3),
                if (leading != null) leading!,
                const Spacer(),
                if (trailing != null) trailing!
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: FluentTheme.of(context).brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            child: child,
          )
        ],
      ),
    );
  }
}
