import 'package:flutter/material.dart';

/// 自定义RadioTile组件，避免使用废弃的RadioListTile
class CustomRadioTile<T> extends StatelessWidget {
  final T value;
  final T groupValue;
  final ValueChanged<T?>? onChanged;
  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final bool isThreeLine;
  final bool? dense;
  final ShapeBorder? shape;
  final ListTileStyle? style;
  final Color? selectedColor;
  final Color? tileColor;
  final Color? selectedTileColor;
  final EdgeInsetsGeometry? contentPadding;
  final VoidCallback? onTap;

  const CustomRadioTile({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.isThreeLine = false,
    this.dense,
    this.shape,
    this.style,
    this.selectedColor,
    this.tileColor,
    this.selectedTileColor,
    this.contentPadding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    
    return ListTile(
      leading: leading ?? _buildRadio(context),
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      isThreeLine: isThreeLine,
      dense: dense,
      shape: shape,
      style: style,
      tileColor: tileColor,
      selectedTileColor: selectedTileColor,
      contentPadding: contentPadding,
      selected: isSelected,
      onTap: onTap ?? () => onChanged?.call(value),
    );
  }

  Widget _buildRadio(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged?.call(value),
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: value == groupValue 
                ? (selectedColor ?? Theme.of(context).colorScheme.primary)
                : Theme.of(context).colorScheme.outline,
            width: 2,
          ),
        ),
        child: value == groupValue
            ? Center(
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selectedColor ?? Theme.of(context).colorScheme.primary,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}