part of 'create_company_bloc.dart';

enum CreateCompanyStatus {
  initial, loading, failure, goDashboard, goManageUsers
}

final class CreateCompanyState extends Equatable {
  const CreateCompanyState({
    this.status = CreateCompanyStatus.initial,
    this.name = const RequiredField.pure(),
    this.address = const RequiredField.pure(),
    this.city = const RequiredField.pure(),
    required this.country,
    this.companyState = const RequiredField.pure(),
    this.zipcode = const Zipcode.pure(""),
    this.phone = const PhoneNumber.pure(),
    this.altPhone = const PhoneNumber.pure(),
    this.listOfStates = Provinces.usaStates,
    this.isValid = false,
    this.errorMessage,
  });

  final CreateCompanyStatus status;
  final RequiredField name;
  final RequiredField address;
  final RequiredField city;
  final Country country;
  final RequiredField companyState;
  final Zipcode zipcode;
  final PhoneNumber phone;
  final PhoneNumber altPhone;
  final List<String> listOfStates;
  final bool isValid;
  final String? errorMessage;

  CreateCompanyState copyWith({
    CreateCompanyStatus? status,
    RequiredField? name,
    RequiredField? address,
    RequiredField? city,
    Country? country,
    RequiredField? companyState,
    Zipcode? zipcode,
    PhoneNumber? phone,
    PhoneNumber? altPhone,
    List<String>? listOfStates,
    bool? isValid,
    String? errorMessage,
  }) {
    return CreateCompanyState(
      status: status ?? this.status,
      name: name ?? this.name,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      companyState: companyState ?? this.companyState,
      zipcode: zipcode ?? this.zipcode,
      phone: phone ?? this.phone,
      altPhone: altPhone ?? this.altPhone,
      listOfStates: listOfStates ?? this.listOfStates,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, name, address, city, country, companyState, zipcode, phone, altPhone, listOfStates, isValid, errorMessage];
}
