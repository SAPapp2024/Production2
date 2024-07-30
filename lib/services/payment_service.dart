import 'package:agro_k/models/company_payment_method.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@injectable
class PaymentService {
  Future<CompanyPaymentMethod?> getPaymentMethodForCompany(String companyId) async {
    try {
      final companyPaymentMethodDoc = await FirebaseFirestore.instance
          .collection('company_payment').doc(companyId).get();
      final data = companyPaymentMethodDoc.data();
      if (data != null) {
        return CompanyPaymentMethod.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      debugPrint("error getting payment method for company: $e");
      return null;
    }
  }
}