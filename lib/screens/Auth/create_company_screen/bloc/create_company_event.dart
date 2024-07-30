part of 'create_company_bloc.dart';

sealed class CreateCompanyEvent extends Equatable {
  const CreateCompanyEvent();

  @override
  List<Object> get props => [];
}

final class CreateCompanyNameChanged extends CreateCompanyEvent {
  const CreateCompanyNameChanged(this.name);

  final String name;

  @override
  List<Object> get props => [name];
}

final class CreateCompanyAddressChanged extends CreateCompanyEvent {
  const CreateCompanyAddressChanged(this.address);

  final String address;

  @override
  List<Object> get props => [address];
}

final class CreateCompanyCityChanged extends CreateCompanyEvent {
  const CreateCompanyCityChanged(this.city);

  final String city;

  @override
  List<Object> get props => [city];
}

final class CreateCompanyCountryChanged extends CreateCompanyEvent {
  const CreateCompanyCountryChanged(this.country, this.countryTextEditingController, this.stateTextEditingController);

  final Country country;
  final TextEditingController countryTextEditingController;
  final TextEditingController stateTextEditingController;

  @override
  List<Object> get props => [country];
}

final class CreateCompanyStateChanged extends CreateCompanyEvent {
  const CreateCompanyStateChanged(this.state, this.stateTextEditingController);

  final TextEditingController stateTextEditingController;
  final String state;

  @override
  List<Object> get props => [state];
}

final class CreateCompanyZipcodeChanged extends CreateCompanyEvent {
  const CreateCompanyZipcodeChanged(this.zipcode);

  final String zipcode;

  @override
  List<Object> get props => [zipcode];
}

final class CreateCompanyPhoneChanged extends CreateCompanyEvent {
  const CreateCompanyPhoneChanged(this.phone);

  final PhoneModel phone;

  @override
  List<Object> get props => [phone];
}

final class CreateCompanyAltPhoneChanged extends CreateCompanyEvent {
  const CreateCompanyAltPhoneChanged(this.altPhone);

  final PhoneModel altPhone;

  @override
  List<Object> get props => [altPhone];
}

final class CreateCompanySubmitted extends CreateCompanyEvent {
  const CreateCompanySubmitted();
}

final class CreateCompanySkipped extends CreateCompanyEvent {
  const CreateCompanySkipped();
}
