import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 37.h,
          child: Stack(
            children: [
              Positioned(
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.indigoAccent.shade400,
                    ),
                    width: 100.w,
                    height: 30.h,
                  ),
                ),
              ),
              Positioned(
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: 100.w,
                    height: 10.h,
                    foregroundDecoration: BoxDecoration(
                      image: const DecorationImage(
                        image: AssetImage("assets/images/aditya-logo.png"),
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
                ),
              ),
              Positioned(
                top: 12.h,
                left: 2.5.w,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6.w),
                      color: const Color.fromARGB(255, 90, 88, 224)
                          .withOpacity(0.3),
                    ),
                    width: 95.w,
                    height: 25.h,
                    foregroundDecoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.transparent,
                        width: 0.5.w,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(4.w),
                      image: const DecorationImage(
                        image: AssetImage("assets/images/Scanner.jpeg"),
                        fit: BoxFit.fill,
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
                ),
              ),
              Positioned(
                top: 30.h,
                left: 18.w,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                    ),
                    width: 100.w,
                    height: 10.h,
                    child: Text(
                      "Time Tracker",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w600,
                        fontSize: 25.sp,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
