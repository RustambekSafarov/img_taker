// ignore_for_file: must_be_immutable

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CarDetailWidget extends StatelessWidget {
  bool isSvg;
  File image;
  String title;
  void Function()? func;
  double imagePadding;
  CarDetailWidget({
    super.key,
    required this.image,
    required this.title,
    required this.func,
    this.imagePadding = 0,
    this.isSvg = true,
  });

  @override
  Widget build(BuildContext context) {
    // final Map<String, dynamic> args =
    //     ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return Container(
      padding: EdgeInsets.fromLTRB(
        MediaQuery.of(context).size.width / 40,
        0,
        MediaQuery.of(context).size.width / 40,
        0,
      ),
      width: MediaQuery.of(context).size.width / 2,
      child: GestureDetector(
        onTap: func,
        child: Card(
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height / 40),
              Text(
                title,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width / 28,
                ),
              ),

              isSvg
                  ? Container(
                      padding: EdgeInsets.fromLTRB(
                        0,
                        imagePadding,
                        0,
                        imagePadding,
                      ),
                      width: MediaQuery.of(context).size.width / 1.5,
                      height: MediaQuery.of(context).size.width / 2.5,
                      child: SvgPicture.asset(
                        image.path,
                        fit: BoxFit.fitHeight,
                      ),
                      // : Image.file(File(image.path), fit: BoxFit.fitWidth),
                    )
                  : Center(
                      child: Container(
                        margin: EdgeInsets.all(
                          MediaQuery.of(context).size.width / 30,
                        ),
                        width: MediaQuery.of(context).size.width / 3,
                        height: MediaQuery.of(context).size.width / 3,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: FileImage(File(image.path)),
                            fit: BoxFit.cover,
                          ),
                          // shape: BoxShape.circle,
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
