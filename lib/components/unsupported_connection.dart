import 'package:flutter/material.dart';

class PurchasingWebView extends StatelessWidget {
  static const id = "/purchase_screen";
  final String? address;
  final String? zipcode;
  final int? amount;
  final String? email;
  final String? token;
  final String companyId;
  final bool isAdmin;
  final String? cardToken;
  final bool saveCard;
  final bool shipping;

  const PurchasingWebView(
      {super.key,
      this.address,
      this.zipcode,
      this.amount,
      this.email,
      this.token,
        required this.shipping,
      required this.companyId,
      required this.isAdmin,
      required this.cardToken, required this.saveCard});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
