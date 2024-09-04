import 'package:agro_k/components/purchasing_web_view.dart';
import 'package:agro_k/utilities/encrypt_utils.dart';
import 'package:agro_k/utilities/enums/environment_enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class PurchasingWebView extends StatefulWidget {
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
      required this.companyId,
      required this.shipping,
      required this.isAdmin,
      required this.cardToken,
      required this.saveCard});

  @override
  State<PurchasingWebView> createState() => _PurchasingWebViewState();
}

class _PurchasingWebViewState extends State<PurchasingWebView> {
  PaymentStatus? paymentStatus;

  @override
  void initState() {
    final token = encryptMap({
      'address': widget.address,
      'zipcode': widget.zipcode,
      'amount': widget.amount,
      'email': widget.email,
      'shipping': widget.shipping,
    });
    final paymentUrl = getPaymentUrl(RepositoryProvider.of<Environment>(context, listen: false));
    launchUrl(
        Uri.parse(
            "$paymentUrl?company_id=${widget.companyId}&from_mobile_app=1&amount=${widget.amount}&shipping=${widget.shipping}&address=${widget.address}&zip=${widget.zipcode}&email=${widget.email}"),
        mode: LaunchMode.externalNonBrowserApplication);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
