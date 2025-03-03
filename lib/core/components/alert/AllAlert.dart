import 'dart:ui';

import 'package:_12sale_app/core/styles/style.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class AllAlert {
  static void customAlert(
      BuildContext context, String title, String desc, Function fuc) {
    Alert(
      context: context,
      title: title,
      style: AlertStyle(
        animationType: AnimationType.grow,
        isCloseButton: true,
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
      desc: desc,
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
          onPressed: () async {
            await fuc();
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

  static void editAlert(BuildContext context, Function fuc) {
    Alert(
      context: context,
      title: "store.processtimeline_screen.alert.title".tr(),
      style: AlertStyle(
        animationType: AnimationType.grow,
        isCloseButton: true,
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
      desc: "คุณต้องการแก้ไขข้อมูลร้านค้าใช่หรือไม่ ?",
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
          onPressed: () async {
            // await checkIn();
            await fuc();
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

  static void checkinAlert(BuildContext context, Function fuc) {
    Alert(
      context: context,
      title: "store.processtimeline_screen.alert.title".tr(),
      style: AlertStyle(
        animationType: AnimationType.grow,
        isCloseButton: true,
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
      desc: "คุณต้องการยืนยันการเช็คอินร้านค้าใช่หรือไม่ ?",
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
          onPressed: () async {
            await fuc();
            Navigator.of(context).pop(); // Close the bottom sheet
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

  static void changeAddRouteAlert(BuildContext context, Function fuc) {
    Alert(
      context: context,
      title: "store.processtimeline_screen.alert.title".tr(),
      style: AlertStyle(
        animationType: AnimationType.grow,
        isCloseButton: true,
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
      desc:
          "ยังมีร้านที่คุณยังไม่ได้กดขออนุมัติกรุณาตรวจสอบก่อนกดเปลี่ยนเป็นย้ายรูทร้านค้า คุณต้องการเปลี่ยนเป็นเพิ่มรูทร้านค้าใช่หรือไม่ ?",
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
          onPressed: () async {
            await fuc();
            Navigator.of(context).pop(); // Close the bottom sheet
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

  static void changeAjustRouteAlert(BuildContext context, Function fuc) {
    Alert(
      context: context,
      title: "store.processtimeline_screen.alert.title".tr(),
      style: AlertStyle(
        animationType: AnimationType.grow,
        isCloseButton: true,
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
      desc:
          "ยังมีร้านที่คุณยังไม่ได้กดขออนุมัติกรุณาตรวจสอบก่อนกดเปลี่ยนเป็นเพิ่มรูทร้านค้า คุณต้องการเปลี่ยนเป็นเพิ่มรูทร้านค้าใช่หรือไม่ ?",
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
          onPressed: () async {
            await fuc();
            Navigator.of(context).pop(); // Close the bottom sheet
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

  static void acceptAlert(BuildContext context, Function fuc) {
    Alert(
      context: context,
      title: "store.processtimeline_screen.alert.title".tr(),
      style: AlertStyle(
        animationType: AnimationType.grow,
        isCloseButton: true,
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
      desc: "คุณต้องการขออนุมัติการปรับรูทใช่ไหม ?",
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
          onPressed: () async {
            await fuc();
            Navigator.of(context).pop(); // Close the bottom sheet
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
}
