export 'unsupported_connection.dart'
if (dart.library.ffi) 'purchasing_web_view_mobile.dart'
if (dart.library.html) 'purchasing_web_view_web.dart';

class PurchasingWebViewArguments {
  final String address;
  final String zipcode;
  final int amount;
  final String email;
  final String companyId;
  final bool isAdmin;
  final String? cardToken;
  final bool saveCard;
  final bool shipping;

  PurchasingWebViewArguments(
      {required this.address,
      required this.zipcode,
      required this.amount,
        required this.shipping,
      required this.email, required this.companyId, required this.isAdmin, required this.cardToken, required this.saveCard});
}