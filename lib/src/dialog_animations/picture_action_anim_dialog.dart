import 'package:flutter/material.dart';

class PictureActionAnimDialog extends StatefulWidget {
  final Widget iconWidget;
  const PictureActionAnimDialog({required this.iconWidget, Key? key})
      : super(key: key);

  @override
  _PictureActionAnimDialogState createState() =>
      _PictureActionAnimDialogState();
}

class _PictureActionAnimDialogState
    extends State<PictureActionAnimDialog>
    with TickerProviderStateMixin {
  late AnimationController iconAnimController;

  late Animation iconScaleAnim;

  @override
  void initState() {
    iconAnimController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    iconScaleAnim = Tween<double>(begin: 0.1, end: 1.0).animate(
        CurvedAnimation(parent: iconAnimController, curve: Curves.ease));
    iconAnimController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    iconAnimController.forward();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: iconScaleAnim.value,
      child: Center(
        child: widget.iconWidget,
      ),
    );
  }
}
