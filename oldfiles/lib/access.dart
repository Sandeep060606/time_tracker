import 'package:aditya_time_tracker/backend.dart';
import 'package:aditya_time_tracker/main.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class AccessCode extends StatefulWidget {
  const AccessCode({super.key});

  @override
  State<AccessCode> createState() => _AccessCodeState();
}

class _AccessCodeState extends State<AccessCode> {
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
                  left: 21.w,
                  child: Material(
                    color: Colors.transparent,
                    child: Text(
                      "Enter Access Code",
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
                  top: 6.h,
                  left: 10.w,
                  child: Material(
                    color: Colors.transparent,
                    child: SizedBox(
                      width: 80.w,
                      height: 10.h,
                      child: TextField(
                        onChanged: (value) => {accessCode = value},
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w700,
                          fontSize: 18.sp,
                        ),
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLines: 1,
                        cursorColor: Colors.blueAccent,
                        decoration: InputDecoration(
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
                  top: 16.h,
                  left: 10.w,
                  child: Material(
                    color: Colors.transparent,
                    child: ElevatedButton(
                      onPressed: () async => {
                        purpose = await login(accessCode),
                        if (purpose != null)
                          {
                            await storage?.put("Status", "Purpose"),
                            context.go("/purpose"),
                          }
                        else
                          {
                            showToast("Invalid Credentials", Colors.redAccent),
                          }
                      },
                      autofocus: true,
                      style: ButtonStyle(
                        backgroundColor: MaterialStateColor.resolveWith(
                          (states) => Colors.blueAccent.shade700,
                        ),
                        fixedSize: MaterialStateProperty.resolveWith(
                          (states) => Size(80.w, 6.h),
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
              ],
            ),
          )
        ],
      ),
    );
  }
}
