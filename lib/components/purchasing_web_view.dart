import 'package:agro_k/utilities/enums/environment_enum.dart';

enum PaymentStatus { approved, error, canceled, declined, unknown }

String getPaymentUrl(Environment environment) {
  return "${environment == Environment.qa ? 'https://SAPapp2024.github.io/agrok' : 'https://www.agro-k.com/elavon'}/payment_process_container.html";
}

PaymentStatus typeToPaymentStatus(String type) {
  switch (type) {
    case "approved":
      return PaymentStatus.approved;
    case "error":
      return PaymentStatus.error;
    case "canceled":
      return PaymentStatus.canceled;
    case "declined":
      return PaymentStatus.declined;
    default:
      return PaymentStatus.unknown;
  }
}
