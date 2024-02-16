import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;

class CommandBarDropDownButton extends fluent.CommandBarItem {
  const CommandBarDropDownButton(
      {super.key,
      required this.items,
      this.onPressed,
      this.icon,
      this.leading,
      this.title});
  final List<fluent.MenuFlyoutItem> items;
  final VoidCallback? onPressed;
  final Widget? icon;
  final Widget? leading;
  final Widget? title;
  @override
  Widget build(
      BuildContext context, fluent.CommandBarItemDisplayMode displayMode) {
    return fluent.DropDownButton(
      leading: leading,
      title: title,
      items: items,
      closeAfterClick: false,
    );
  }
}

class CommandBarFlyOutTarget extends fluent.CommandBarItem {
  const CommandBarFlyOutTarget(
      {super.key, required this.controller, required this.child, this.label});
  final fluent.FlyoutController controller;
  final Widget child;
  final Widget? label;
  @override
  Widget build(
      BuildContext context, fluent.CommandBarItemDisplayMode displayMode) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      if (label != null) ...[
        label!,
        const SizedBox(
          width: 6.0,
        )
      ],
      fluent.FlyoutTarget(
        controller: controller,
        child: child,
      )
    ]);
  }
}

class CommandBarText extends fluent.CommandBarItem {
  const CommandBarText({super.key, required this.text});
  final String text;
  @override
  Widget build(
      BuildContext context, fluent.CommandBarItemDisplayMode displayMode) {
    return Padding(padding: const EdgeInsets.all(10), child: Text(text));
  }
}

class CommandBarToggleButton extends fluent.CommandBarItem {
  const CommandBarToggleButton(
      {super.key,
      required this.onchange,
      required this.checked,
      required this.child});
  final bool checked;
  final void Function(bool)? onchange;
  final Widget child;
  @override
  Widget build(
      BuildContext context, fluent.CommandBarItemDisplayMode displayMode) {
    return Padding(
        padding: const EdgeInsets.all(10),
        child: fluent.ToggleButton(
          checked: checked,
          onChanged: onchange,
          child: child,
        ));
  }
}

class CommnadBarDivider extends fluent.CommandBarItem {
  const CommnadBarDivider({super.key, this.thickness, this.height, this.color});
  final double? thickness;
  final double? height;
  final Color? color;
  @override
  Widget build(
      BuildContext context, fluent.CommandBarItemDisplayMode displayMode) {
    return Container(
      height: height ?? 20.0,
      width: thickness ?? 3.0,
      decoration: BoxDecoration(
          color: fluent.FluentTheme.of(context).brightness ==
                  fluent.Brightness.dark
              ? const Color(0xFF484848)
              : const Color(0xFFB7B7B7)),
    );
  }
}

class CommandBarSpacer extends fluent.CommandBarItem {
  const CommandBarSpacer({super.key, this.width});
  final double? width;
  @override
  Widget build(
      BuildContext context, fluent.CommandBarItemDisplayMode displayMode) {
    return SizedBox(width: width ?? 8.0);
  }
}

class CommandBarSplitButton extends fluent.CommandBarItem {
  const CommandBarSplitButton(
      {super.key,
      required this.child,
      required this.flyOutWidget,
      this.onInvoked,
      this.label,
      this.flyoutController});
  final Widget child;
  final VoidCallback? onInvoked;
  final Widget flyOutWidget;
  final Widget? label;
  final GlobalKey<fluent.SplitButtonState>? flyoutController;
  @override
  Widget build(
      BuildContext context, fluent.CommandBarItemDisplayMode displayMode) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      fluent.SplitButton(
        flyout: flyOutWidget,
        onInvoked: onInvoked,
        child: child,
      )
    ]);
  }
}

class CommandBarNumberBox extends fluent.CommandBarItem {
  const CommandBarNumberBox(
      {super.key,
      required this.onchange,
      required this.value,
      required this.min,
      required this.max,
      this.title});
  final void Function(double?)? onchange;
  final double value;
  final double min;
  final double max;
  final Widget? title;
  @override
  Widget build(
      BuildContext context, fluent.CommandBarItemDisplayMode displayMode) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      if (title != null) ...[title!, const SizedBox(width: 8.0)],
      SizedBox(
          width: 50,
          child: fluent.NumberBox(
            value: value,
            min: min,
            max: max,
            onChanged: onchange,
            mode: fluent.SpinButtonPlacementMode.none,
            clearButton: false,
          ))
    ]);
  }
}
