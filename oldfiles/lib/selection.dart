import 'package:aditya_time_tracker/purpose.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:aditya_time_tracker/header.dart';

class PurposeSelections extends StatefulWidget {
  const PurposeSelections({super.key});

  @override
  State<PurposeSelections> createState() => _PurposeSelectionsState();
}

class _PurposeSelectionsState extends State<PurposeSelections> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: [
              const Header(),
              SizedBox(
                height: 3.h,
                child: Container(
                  color: Colors.transparent,
                ),
              ),
              const Purpose(),
              SizedBox(
                height: 13.h,
                child: Stack(
                  children: [
                    Positioned(
                      top: 7.h,
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.indigoAccent.shade400,
                          ),
                          width: 100.w,
                          height: 6.h,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Developed By",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: "Poppins",
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16.sp,
                                ),
                              ),
                              SizedBox(
                                width: 1.w,
                              ),
                              Text(
                                "IT DIVISION",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: "Poppins",
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
