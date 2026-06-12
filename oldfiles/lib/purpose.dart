// ignore_for_file: use_build_context_synchronously

import 'package:aditya_time_tracker/main.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'backend.dart';

class Purpose extends StatefulWidget {
  const Purpose({super.key});

  @override
  State<Purpose> createState() => _PurposeState();
}

class _PurposeState extends State<Purpose> {
  TextEditingController employeeController = TextEditingController();
  TextEditingController campusController = TextEditingController();
  TextEditingController purposeController = TextEditingController();
  bool tracking = false;

  Future<void> normalInit() async {
    try {
      if (storage?.get("campusCode") != null &&
          storage?.get("employeeCode") != null) {
        campusCode = storage?.get("campusCode");
        employeeCode = storage?.get("employeeCode");
        employeeController.text = employeeCode;
        campusController.text = campusCode;
      }
      if (purpose != null) {
        employeePlaceholder = purpose != null ? purpose!['input1'] : "";
        campusPlaceholder = purpose != null ? purpose!['input1'] : "";
        purposeController.text = purpose!['purpose'];
        tracking = purpose!['tracking'];
      }
      setState(() {});
    } catch (error) {}
  }

  void initPurposes() async {
    if (await checkInternet()) {
      accessCode = storage?.get("accesscode");
      purpose = await login(accessCode);
      setState(() {});
      if (purpose != null) await normalInit();
    }
  }

  @override
  void initState() {
    initPurposes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      maintainAnimation: true,
      maintainSize: true,
      maintainState: true,
      visible: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 43.h,
            child: Stack(
              children: [
                Positioned(
                  left: 2.w,
                  child: Material(
                    color: Colors.transparent,
                    child: Text(
                      "Total : ${registeredStudents.length - failedStudents.length}/${registeredStudents.length}",
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w600,
                        fontSize: 20.sp,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: -0.8.h,
                  left: 64.w,
                  child: Visibility(
                    maintainAnimation: true,
                    maintainSize: true,
                    maintainState: true,
                    visible: true,
                    child: Material(
                      color: Colors.transparent,
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            if (await checkInternet()) {
                              List sentedData = [];
                              failedStudents = await storage?.get("failed");
                              for (var failed in failedStudents) {
                                var status = await postFailed(failed);
                                if (status) {
                                  sentedData.add(failed);
                                }
                              }
                              for (var failed in sentedData) {
                                failedStudents.remove(failed);
                              }
                              await storage?.put("failed", failedStudents);
                              showToast("Total Submitted ${sentedData.length}",
                                  Colors.greenAccent);
                              registeredStudents = [];
                              await storage?.put(
                                  "RegisteredStudents", registeredStudents);
                              await storage?.put("Count", 0);
                              setState(() {
                                count = 0;
                                warning = false;
                              });
                            } else {
                              showToast("Please Connect To Internet",
                                  Colors.redAccent);
                            }
                          } catch (error) {}
                          stopServie();
                        },
                        autofocus: true,
                        style: ButtonStyle(
                          backgroundColor: MaterialStateColor.resolveWith(
                            (states) => Colors.blueAccent.shade700,
                          ),
                          fixedSize: MaterialStateProperty.resolveWith(
                            (states) => Size(32.w, 4.h),
                          ),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.w),
                            ),
                          ),
                        ),
                        child: Text(
                          "Submit",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w200,
                            fontSize: 20.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 6.2.h,
                  left: 21.w,
                  child: Material(
                    color: Colors.transparent,
                    child: Text(
                      "Enter Your Details",
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w600,
                        fontSize: 20.sp,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 11.h,
                  left: 10.w,
                  child: Material(
                    color: Colors.transparent,
                    child: SizedBox(
                      width: 80.w,
                      height: 15.h,
                      child: TextFormField(
                        enabled: false,
                        controller: purposeController,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 20.h,
                  left: 10.w,
                  child: Material(
                    color: Colors.transparent,
                    child: SizedBox(
                      width: 80.w,
                      height: 10.h,
                      child: TextField(
                        controller: employeeController,
                        onChanged: (value) {
                          employeeCode = employeeController.text.toUpperCase();
                        },
                        onSubmitted: (value) {
                          employeeController.text = value.toUpperCase();
                          employeeCode = employeeController.text.toUpperCase();
                        },
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w700,
                          fontSize: 18.sp,
                        ),
                        textAlign: TextAlign.start,
                        keyboardType: TextInputType.text,
                        maxLines: 1,
                        cursorColor: Colors.blueAccent,
                        decoration: InputDecoration(
                          hintText: employeePlaceholder,
                          counterStyle: TextStyle(
                            color: whitegrey,
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w700,
                            fontSize: 18.sp,
                          ),
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(
                              width: 1.w,
                              color: Colors.indigoAccent.shade700,
                              style: BorderStyle.solid,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 29.h,
                  left: 10.w,
                  child: Material(
                    color: Colors.transparent,
                    child: SizedBox(
                      width: 80.w,
                      height: 10.h,
                      child: TextField(
                        controller: campusController,
                        onSubmitted: (value) {
                          campusController.text = value.toUpperCase();
                          campusCode = campusController.text;
                        },
                        onChanged: (value) => {
                          campusCode = value.toUpperCase(),
                        },
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w700,
                          fontSize: 18.sp,
                        ),
                        textAlign: TextAlign.start,
                        keyboardType: TextInputType.text,
                        maxLines: 1,
                        cursorColor: Colors.blueAccent,
                        decoration: InputDecoration(
                          hintText: campusPlaceholder,
                          counterStyle: TextStyle(
                            color: whitegrey,
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w700,
                            fontSize: 18.sp,
                          ),
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(
                              width: 1.w,
                              color: Colors.indigoAccent.shade700,
                              style: BorderStyle.solid,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 37.h,
                  left: 10.w,
                  child: Material(
                    color: Colors.transparent,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (employeeCode != "" || campusCode != "") {
                          var response = await submitPurpose(
                            employeeCode,
                            campusCode,
                            purpose!['purpose'],
                          );
                          if (response == "Scanner") {
                            if (tracking) {
                              await startService(
                                employeeCode: employeeCode,
                                campusCode: campusCode,
                                purpose: purpose!['purpose'],
                              );
                            }
                            await storage?.put("Status", "Scanner");
                            context.go("/scanner");
                          } else {
                            showToast("Invalid Credentials", Colors.redAccent);
                          }
                        } else {
                          showToast("Invalid Credentials", Colors.redAccent);
                        }
                      },
                      autofocus: true,
                      style: ButtonStyle(
                        backgroundColor: MaterialStateColor.resolveWith(
                          (states) => Colors.blueAccent.shade700,
                        ),
                        fixedSize: MaterialStateProperty.resolveWith(
                          (states) => Size(80.w, 2.h),
                        ),
                      ),
                      child: Text(
                        "Scan",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w200,
                          fontSize: 20.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
