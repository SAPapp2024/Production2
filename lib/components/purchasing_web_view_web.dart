import 'dart:ui_web' as ui_web;

import 'package:agro_k/components/purchasing_web_view.dart';
import 'package:agro_k/screens/CompanyTab/purchase_barcodes_screen.dart';
import 'package:agro_k/utilities/encrypt_utils.dart';
import 'package:agro_k/utilities/function_utils/view_utils.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' hide Navigator;

class PurchasingWebView extends StatefulWidget {
  static const id = "/purchase_screen";
  final String address;
  final String zipcode;
  final int amount;
  final String email;
  final String companyId;
  final bool isAdmin;
  final String? cardToken;
  final bool saveCard;

  const PurchasingWebView(
      {super.key,
      required this.address,
      required this.zipcode,
      required this.amount,
      required this.email,
      required this.companyId,
      required this.isAdmin,
      required this.cardToken,
      required this.saveCard});

  @override
  State<PurchasingWebView> createState() => _PurchasingWebViewState();
}

class _PurchasingWebViewState extends State<PurchasingWebView> {
  @override
  void initState() {
    super.initState();
    iframeId = 'my-iframe';
    final iframeUrl = buildPaymentUrl(context,
        companyId: widget.companyId,
        address: widget.address,
        zipcode: widget.zipcode,
        email: widget.email,
        amount: widget.amount,
        isAdmin: widget.isAdmin,
        cardToken: widget.cardToken,
        saveCard: widget.saveCard,
        fromMobileApp: false);
    debugPrint("iframeUrl: $iframeUrl");
    ui_web.platformViewRegistry.registerViewFactory(
      iframeId,
      (int viewId) => IFrameElement()
        ..style.width = '100%'
        ..style.height = '100%'
        ..src = iframeUrl
        ..style.border = 'none'
        ..attributes['Content-Security-Policy'] = 'frame-ancestors https://agro-k.com',
    );
    window.onMessage.listen((event) {
      try {
        // Maneja el mensaje recibido
        if (event.data == null) {
          Navigator.of(context).pop();
          return;
        }
        final data = event.data;
        debugPrint("data: $data");
        final result = data['result'];
        if (result == null) {
          paymentStatus = PaymentStatus.unknown;
        } else {
          paymentStatus = typeToPaymentStatus(result);
        }
        Navigator.of(context).pop(paymentStatus);
      } catch (e) {
        debugPrint(
            'Error al recibir mensaje desde el iframe: $e ${event.data}');
        showOneButtonAlertDialog(context, "Ok", () {
          Navigator.of(context).pop();
        }, "Error",
            "There was an error getting the response from the payment processor");
      }
    });
  }

  late String iframeId;
  PaymentStatus? paymentStatus;

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: iframeId);
  }
}
