// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:aditya_time_tracker/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'backend.dart';

class Scanner extends StatefulWidget {
  const Scanner({super.key});

  @override
  State<Scanner> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  QRViewController? cameraController;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  @override
  Widget build(BuildContext context) {
    IconData flash = Icons.flash_off_outlined;
    if (purpose == null) {
      storage?.put("Status", "Purpose");
      context.go("/purpose");
    }
    if (storage?.get("RegisteredStudents") != null) {
      registeredStudents = storage?.get("RegisteredStudents");
    } else {
      registeredStudents = [];
    }

    return WillPopScope(
      onWillPop: (() async {
        await storage?.put("Status", "Purpose");
        context.go("/purpose");
        return true;
      }),
      child: Scaffold(
        backgroundColor: Colors.indigoAccent.shade400,
        body: Column(
          children: <Widget>[
            SizedBox(
                height: 8.h,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 50.w,
                          height: 8.h,
                          foregroundDecoration: BoxDecoration(
                            image: const DecorationImage(
                              image:
                                  AssetImage("assets/images/aditya-logo.png"),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(0, 85, 83, 83),
                                spreadRadius: 2.w,
                                blurStyle: BlurStyle.solid,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 28.w,
                        ),
                        Visibility(
                          maintainAnimation: true,
                          maintainSize: true,
                          maintainState: true,
                          visible: warning,
                          child: Icon(
                            Icons.warning_amber_outlined,
                            color: Colors.yellowAccent,
                            size: 25.sp,
                          ),
                        ),
                        SizedBox(
                          width: 2.w,
                        ),
                        Text(
                          "$count",
                          style: TextStyle(
                            color: countColor,
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w600,
                            fontSize: 25.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                )),
            Expanded(flex: 4, child: _createQRView(context)),
            Container(
              padding: EdgeInsets.only(bottom: 2.h, left: 2.w, right: 4.w),
              height: 10.h,
              width: 100.w,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                verticalDirection: VerticalDirection.up,
                children: [
                  IconButton(
                    onPressed: () async {
                      try {
                        await cameraController!.flipCamera();
                      } catch (e) {
                        e;
                      }
                    },
                    icon: Icon(
                      Icons.flip_camera_android_rounded,
                      size: 30.sp,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      try {
                        await cameraController!.toggleFlash();
                        var flashSatus =
                            await cameraController!.getFlashStatus();
                        if (flashSatus == true) {
                          setState(() {
                            flash = Icons.flash_off_outlined;
                          });
                        } else if (flashSatus != null && flashSatus == false) {
                          setState(() {
                            flash = Icons.flash_on_outlined;
                          });
                        }
                      } catch (e) {
                        e;
                      }
                    },
                    icon: Icon(
                      flash,
                      size: 30.sp,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No Permission')),
      );
    }
  }

  void _onQRViewCreated(QRViewController controller) async {
    setState(() {
      cameraController = controller;
    });

    controller.scannedDataStream.listen((scanData) async {
      if (mounted) {
        if (purpose != null) {
          var studentID = "";
          List registeredStudents = [];
          if (await storage?.get("RegisteredStudents") != null) {
            registeredStudents = await storage?.get("RegisteredStudents");
          }
          if (registeredStudents.isEmpty) {
            registeredStudents = [];
          }

          var scanneddata = scanData.code.toString();
          if (scanneddata.length == 10) {
            studentID = scanneddata;
          } else {
            var jsonData = await json.decode(scanData.code.toString());
            if (jsonData["SUC"] != null && jsonData["SUC"] != "") {
              studentID = jsonData["SUC"];
            }
          }
          try {
            scannedData = await storage?.get("ScannedData");
            if (studentID == scannedData) {
              setState(() {
                warning = false;
              });
            } else {
              if (registeredStudents.contains(studentID)) {
                FlutterBeep.playSysSound(AndroidSoundIDs.TONE_CDMA_ABBR_ALERT);
                setState(() {
                  warning = true;
                  countColor = Colors.yellowAccent;
                });
              }
            }
            if (!registeredStudents.contains(studentID) && studentID != "") {
              FlutterBeep.beep();
              registeredStudents.add(studentID);
              await storage?.put("ScannedData", studentID);
              await storage?.put("RegisteredStudents", registeredStudents);
              setState(() {
                count += 1;
                countColor = Colors.white;
              });
              await storage?.put("Count", count);
              FlutterBeep.beep();
              await postMan(studentID);
            }
            await storage?.put("ScannedData", studentID);
          } catch (ex) {
            await storage?.put("ScannedData", studentID);
            ex;
          }
        } else {
          context.go("/purpose");
        }
      }
    });
  }

  Widget _createQRView(BuildContext context) {
    double scanArea = 250;
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: const Color.fromARGB(255, 54, 50, 128),
          borderRadius: 20,
          borderLength: 25,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }
}
