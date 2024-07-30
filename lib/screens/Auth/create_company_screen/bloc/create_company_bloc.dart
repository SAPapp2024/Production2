import 'package:agro_k/app/setup/injectable_setup.dart';
import 'package:agro_k/app/setup/user_state.dart';
import 'package:agro_k/models/user/phone_model.dart';
import 'package:agro_k/screens/common/models/models.dart';
import 'package:agro_k/screens/common/models/phone_number.dart';
import 'package:agro_k/screens/common/models/zipcode.dart';
import 'package:agro_k/services/auth_service.dart';
import 'package:agro_k/utilities/constants.dart';
import 'package:agro_k/utilities/remote_error_logging_service.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:intl_phone_field/countries.dart';

part 'create_company_event.dart';

part 'create_company_state.dart';

class CreateCompanyBloc extends Bloc<CreateCompanyEvent, CreateCompanyState> {
  final String? uid;
  AuthService authService;
  UserState userState;

  CreateCompanyBloc(
      {required this.authService, required this.userState, this.uid})
      : super(CreateCompanyState(
            country: countries
                .where((element) => element.name == "United States")
                .first)) {
    on<CreateCompanyNameChanged>(_onNameChanged);
    on<CreateCompanyAddressChanged>(_onAddressChanged);
    on<CreateCompanyCityChanged>(_onCityChanged);
    on<CreateCompanyCountryChanged>(_onCountryChanged);
    on<CreateCompanyStateChanged>(_onStateChanged);
    on<CreateCompanyZipcodeChanged>(_onZipcodeChanged);
    on<CreateCompanyPhoneChanged>(_onPhoneChanged);
    on<CreateCompanyAltPhoneChanged>(_onAltPhoneChanged);
    on<CreateCompanySubmitted>(_onSubmitted);
    on<CreateCompanySkipped>(_onSkipped);
  }

  void _onNameChanged(
    CreateCompanyNameChanged event,
    Emitter<CreateCompanyState> emit,
  ) {
    final name = RequiredField.dirty(event.name);
    emit(
      state.copyWith(
        name: name,
        isValid: Formz.validate([
          name,
          state.address,
          state.city,
          state.companyState,
          state.zipcode,
          state.phone,
          state.altPhone
        ]),
      ),
    );
  }

  void _onAddressChanged(
    CreateCompanyAddressChanged event,
    Emitter<CreateCompanyState> emit,
  ) {
    final address = RequiredField.dirty(event.address);
    emit(
      state.copyWith(
        address: address,
        isValid: Formz.validate([
          address,
          state.name,
          state.city,
          state.companyState,
          state.zipcode,
          state.phone,
          state.altPhone
        ]),
      ),
    );
  }

  void _onCityChanged(
    CreateCompanyCityChanged event,
    Emitter<CreateCompanyState> emit,
  ) {
    final city = RequiredField.dirty(event.city);
    emit(
      state.copyWith(
        city: city,
        isValid: Formz.validate([
          city,
          state.name,
          state.address,
          state.companyState,
          state.zipcode,
          state.phone,
          state.altPhone
        ]),
      ),
    );
  }

  void _onCountryChanged(
    CreateCompanyCountryChanged event,
    Emitter<CreateCompanyState> emit,
  ) {
    event.countryTextEditingController.text = event.country.name;
    var listOfStates = Provinces.getProvinces(event.country.name);
    var companyState = state.companyState;
    if (!listOfStates.contains(state.companyState.value)) {
      companyState = const RequiredField.pure();
      event.stateTextEditingController.text = "";
    }
    var zipcode = Zipcode.dirty(event.country.name, state.zipcode.value);
    emit(
      state.copyWith(
        country: event.country,
        companyState: companyState,
        listOfStates: Provinces.getProvinces(event.country.name),
        zipcode: zipcode,
        isValid: Formz.validate([
          state.name,
          state.address,
          state.city,
          state.companyState,
          zipcode,
          state.phone,
          state.altPhone
        ]),
      ),
    );
  }

  void _onStateChanged(
    CreateCompanyStateChanged event,
    Emitter<CreateCompanyState> emit,
  ) {
    event.stateTextEditingController.text = event.state;
    final state = RequiredField.dirty(event.state);
    emit(
      this.state.copyWith(
            companyState: state,
            isValid: Formz.validate([
              state,
              this.state.name,
              this.state.address,
              this.state.city,
              this.state.zipcode,
              this.state.phone,
              this.state.altPhone
            ]),
          ),
    );
  }

  void _onZipcodeChanged(
    CreateCompanyZipcodeChanged event,
    Emitter<CreateCompanyState> emit,
  ) {
    final zipcode = Zipcode.dirty(state.country.name, event.zipcode);
    emit(
      state.copyWith(
        zipcode: zipcode,
        isValid: Formz.validate([
          zipcode,
          state.name,
          state.address,
          state.city,
          state.companyState,
          state.phone,
          state.altPhone
        ]),
      ),
    );
  }

  void _onPhoneChanged(
    CreateCompanyPhoneChanged event,
    Emitter<CreateCompanyState> emit,
  ) {
    var phone = PhoneNumber.dirty(event.phone);
    emit(
      state.copyWith(
        phone: phone,
      ),
    );
  }

  void _onAltPhoneChanged(
    CreateCompanyAltPhoneChanged event,
    Emitter<CreateCompanyState> emit,
  ) {
    var altPhone = PhoneNumber.dirty(event.altPhone);
    emit(
      state.copyWith(
        altPhone: altPhone,
      ),
    );
  }

  Future<void> _onSubmitted(
    CreateCompanySubmitted event,
    Emitter<CreateCompanyState> emit,
  ) async {
    if (state.isValid) {
      emit(state.copyWith(
          status: CreateCompanyStatus.loading, errorMessage: null));
      try {
        String? newCompanyId = await authService.createCompanyInDB(
            uid: uid ?? FirebaseAuth.instance.currentUser?.uid,
            companyName: state.name.value,
            companyAddress: state.address.value,
            companyCity: state.city.value,
            companyState: state.companyState.value,
            companyCountry: state.country.name,
            companyZip: state.zipcode.value,
            companyPhone:
                state.phone.value.phone.isEmpty ? null : state.phone.value,
            companyAltPhone: state.altPhone.value.phone.isEmpty
                ? null
                : state.altPhone.value);
        if (newCompanyId != null) {
          await userState.getUserDataFirstTime();
          try {
            await userState.updateCurrentCompany(newCompanyId);
          } catch (exception, stacktrace) {
            getIt
                .get<RemoteErrorLoggingService>()
                .recordError(exception, stacktrace);
          }
        }
        await _goNextScreen(emit);
      } on FirebaseAuthException catch (err) {
        emit(state.copyWith(
            status: CreateCompanyStatus.failure,
            errorMessage:
                err.message ?? "Error logging in. Please try again."));
      } catch (_) {
        emit(state.copyWith(
            status: CreateCompanyStatus.failure,
            errorMessage: "There was an error."));
      }
    } else {
      emit(state.copyWith(
          status: CreateCompanyStatus.failure, errorMessage: null));
    }
  }

  Future<void> _onSkipped(
    CreateCompanySkipped event,
    Emitter<CreateCompanyState> emit,
  ) async {
    if (state.isValid) {
      emit(state.copyWith(
          status: CreateCompanyStatus.loading, errorMessage: null));
      try {
        await _goNextScreen(emit);
      } catch (_) {
        emit(state.copyWith(
            status: CreateCompanyStatus.failure,
            errorMessage: "There was an error."));
      }
    } else {
      emit(state.copyWith(
          status: CreateCompanyStatus.failure, errorMessage: null));
    }
  }

  Future<void> _goNextScreen(Emitter<CreateCompanyState> emit) async {
    if (uid != null) {
      emit(state.copyWith(status: CreateCompanyStatus.goManageUsers));
    } else {
      try {
        await userState.getUserDataFirstTime();
      } catch (e) {
        debugPrint("e -> $e");
      }
      emit(state.copyWith(status: CreateCompanyStatus.goDashboard));
    }
  }
}
