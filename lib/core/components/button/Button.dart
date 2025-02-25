import 'package:_12sale_app/core/page/route/RouteScreen.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class CustomButton extends StatefulWidget {
  final String title;
  // final VoidCallback onPressed;

  const CustomButton({
    Key? key,
    required this.title,
    // required this.onPressed,
  }) : super(key: key);

  @override
  _CustomButtonState createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _isPressed = false; // State to keep track of button pressed status

  void _handleTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true; // Set the button to pressed state
    });
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false; // Set the button back to unpressed state
    });
    // widget.onPressed(); // Perform the button action
  }

  void _handleTapCancel() {
    setState(() {
      _isPressed = false; // Set the button back to unpressed state
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 100),
        decoration: BoxDecoration(
          color: _isPressed
              ? Styles.secondaryColor
              : Styles.primaryColor, // Darker color when pressed
          borderRadius: BorderRadius.circular(30),
          boxShadow: _isPressed
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    offset: Offset(0, 1), // Slightly sunken shadow
                    blurRadius: 3,
                    spreadRadius: 1,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    offset: Offset(0, 3), // Elevated shadow
                    blurRadius: 5,
                    spreadRadius: 2,
                  ),
                ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: Text(
          widget.title,
          style: Styles.headerWhite18(context),
        ),
      ),
    );
  }
}

class ButtonFullWidth extends StatefulWidget {
  final String text;
  final TextStyle textStyle;
  final Color blackGroundColor;
  final Function? onPressed;
  final Widget? screen;
  const ButtonFullWidth(
      {super.key,
      required this.text,
      required this.textStyle,
      required this.blackGroundColor,
      this.screen,
      this.onPressed});

  @override
  State<ButtonFullWidth> createState() => _ButtonFullWidthState();
}

class _ButtonFullWidthState extends State<ButtonFullWidth> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (widget.screen != null) {
            Alert(
              context: context,
              type: AlertType.info,
              title: "store.processtimeline_screen.alert.title".tr(),
              style: AlertStyle(
                animationType: AnimationType.grow,
                isCloseButton: false,
                isOverlayTapDismiss: false,
                descStyle: Styles.black18(context),
                descTextAlign: TextAlign.start,
                animationDuration: const Duration(milliseconds: 400),
                alertBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22.0),
                  side: const BorderSide(
                    color: Colors.grey,
                  ),
                ),
                titleStyle: Styles.headerBlack32(context),
                alertAlignment: Alignment.center,
              ),
              desc: "store.processtimeline_screen.alert.desc".tr(),
              buttons: [
                DialogButton(
                  onPressed: () => Navigator.pop(context),
                  color: Styles.failTextColor,
                  child: Text(
                    "store.processtimeline_screen.alert.cancel".tr(),
                    style: Styles.white18(context),
                  ),
                ),
                DialogButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => widget.screen!),
                    );
                    // postData();
                  },
                  color: Styles.successButtonColor,
                  child: Text(
                    "store.processtimeline_screen.alert.submit".tr(),
                    style: Styles.white18(context),
                  ),
                )
              ],
            ).show();
          }
          if (widget.onPressed != null) {
            widget.onPressed!();
          }
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8),
          backgroundColor: widget.blackGroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(widget.text, style: widget.textStyle),
      ),
    );
  }
}
