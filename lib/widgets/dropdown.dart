import 'package:flutter/material.dart';

typedef AnchorChildBuilder = Function(
  BuildContext context,
  VoidCallback onPressed,
  Widget? child,
);

typedef MenuChildrenBuildert = List<Widget> Function(FocusNode focusNode);

class Dropdown extends StatefulWidget {
  final MenuChildrenBuildert menuChildrenBulder;
  final AnchorChildBuilder? anchorBuilder;
  final Offset? alignmentOffset;
  final MenuStyle? style;

  @override
  State<Dropdown> createState() => _DropdownState();

  const Dropdown({
    super.key,
    required this.anchorBuilder,
    required this.menuChildrenBulder,
    this.alignmentOffset,
    this.style,
  });

  Dropdown.button({
    Key? key,
    required String label,
    Icon? icon,
    Offset? alignmentOffset,
    MenuStyle? style,
    required MenuChildrenBuildert menuChildrenBulder,
  }) : this(
          key: key,
          anchorBuilder: (context, onPressed, child) => ElevatedButton.icon(
            onPressed: onPressed,
            icon: icon,
            label: Text(label),
          ),
          alignmentOffset: alignmentOffset,
          style: style,
          menuChildrenBulder: menuChildrenBulder,
        );

  Dropdown.iconButton({
    Key? key,
    required Icon icon,
    Offset? alignmentOffset,
    MenuStyle? style,
    required MenuChildrenBuildert menuChildrenBulder,
  }) : this(
          key: key,
          anchorBuilder: (context, onPressed, child) => IconButton(
            onPressed: onPressed,
            icon: icon,
          ),
          alignmentOffset: alignmentOffset,
          style: style,
          menuChildrenBulder: menuChildrenBulder,
        );
}

class _DropdownState extends State<Dropdown> {
  final _menuControler = MenuController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      controller: _menuControler,
      builder: widget.anchorBuilder == null
          ? null
          : (context, controller, child) {
              final anchorBuilder = widget.anchorBuilder!;
              return anchorBuilder(
                context,
                () {
                  if (controller.isOpen) {
                    _focusNode.previousFocus();
                    controller.close();
                  } else {
                    _focusNode.requestFocus();
                    controller.open();
                  }
                },
                child,
              );
            },
      alignmentOffset: widget.alignmentOffset,
      style: widget.style,
      menuChildren: [
        BackButtonListener(
          onBackButtonPressed: () async {
            _focusNode.previousFocus();
            _menuControler.close();
            return true;
          },
          child: FocusScope(
            child: Column(
              children: widget.menuChildrenBulder(_focusNode),
            ),
          ),
        )
      ],
      consumeOutsideTap: true,
    );
  }
}
