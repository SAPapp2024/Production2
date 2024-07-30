class CompanyPaymentMethod {
  String companyId;
  String cardCompanyName;
  String cardNumber;
  String cardExpDate;
  String token;

  CompanyPaymentMethod({required this.companyId, required this.cardCompanyName, required this.cardNumber, required this.cardExpDate, required this.token});

  factory CompanyPaymentMethod.fromJson(Map<String, dynamic> json) {
    return CompanyPaymentMethod(
      companyId: json['companyId'],
      cardCompanyName: json['cardCompanyName'],
      cardNumber: json['cardNumber'],
      cardExpDate: json['cardExpDate'],
      token: json['cardToken'],
    );
  }

  //formatExpirationDate function tries to format to XX/XX format
  String formattedExpirationDate() {
    if (cardExpDate.length == 4) {
      return "${cardExpDate.substring(0, 2)}/${cardExpDate.substring(2, 4)}";
    } else {
      return cardExpDate;
    }
  }
}