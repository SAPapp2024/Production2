import 'package:agro_k/theme/colors.dart';
import 'package:flutter/material.dart';

class AdminCustomerUsageBlockLargeWidget extends StatefulWidget {
  final String titleText;
  final int number;

  const AdminCustomerUsageBlockLargeWidget({Key? key,
    required this.titleText,
    required this.number,
  }) : super(key: key);

  @override
  AdminCustomerUsageBlockLargeWidgetState createState() => AdminCustomerUsageBlockLargeWidgetState();
}

class AdminCustomerUsageBlockLargeWidgetState extends State<AdminCustomerUsageBlockLargeWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 620,
      height: 316,
      decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12.0),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey,
                                    spreadRadius: 4,
                                    blurRadius: 6,
                                    offset: Offset(4, 6),
                                  ),
                                ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 17,),
          Row(
            children: [
              const SizedBox(width: 17,),
              Text(widget.titleText, style: const TextStyle(color: AppColors.darkGrayTitleTextColor,  fontSize: 27, fontWeight: FontWeight.w700),),
            ],
          ),
        ],
      ),
    );
  }
}
