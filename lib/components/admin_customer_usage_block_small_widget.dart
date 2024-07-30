import 'package:agro_k/theme/colors.dart';
import 'package:flutter/material.dart';

class AdminCustomerUsageBlockSmallWidget extends StatefulWidget {
  final String titleText;
  final int number;

  const AdminCustomerUsageBlockSmallWidget({
    Key? key,
    required this.titleText,
    required this.number,
  }) : super(key: key);

  @override
  AdminCustomerUsageBlockSmallWidgetState createState() => AdminCustomerUsageBlockSmallWidgetState();
}

class AdminCustomerUsageBlockSmallWidgetState extends State<AdminCustomerUsageBlockSmallWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          widget.titleText,
          style: const TextStyle(color: AppColors.grayTextColor,  fontSize: 13, fontWeight: FontWeight.w600),
        ),
        Text(
          widget.number.toString(),
          style: const TextStyle(color: AppColors.darkGrayTextColor,  fontSize: 65, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
