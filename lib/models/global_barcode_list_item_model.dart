import 'package:agro_k/app/setup/injectable_setup.dart';
import 'package:agro_k/models/document_serializer_nullable.dart';
import 'package:agro_k/models/company/company_model.dart';
import 'package:agro_k/models/company/sample_model.dart';
import 'package:agro_k/utilities/remote_error_logging_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'global_barcode_list_item_model.g.dart';

@JsonSerializable()
@DocumentSerializerNullable()
class GlobalBarcodeListItemModel {
  final String barcode;
  final DocumentReference? companyReference;
  final String? companyName;
  final DocumentReference? sampleReference;
  final bool? wasPurchased;
  @JsonKey(
      fromJson: dateTimeFromTimestampNullable, toJson: firestoreTimestampToJson)
  final DateTime? createdDate;
  @JsonKey(
      fromJson: dateTimeFromTimestampNullable, toJson: firestoreTimestampToJson)
  final DateTime? dateAddedToCompany;
  final List<dynamic> reclaimedTimestamps;

  GlobalBarcodeListItemModel(
      this.barcode,
      this.companyReference,
      this.companyName,
      this.sampleReference,
      this.createdDate,
      this.dateAddedToCompany, this.wasPurchased, this.reclaimedTimestamps);

  factory GlobalBarcodeListItemModel.fromJson(Map<String, dynamic> json) =>
      _$GlobalBarcodeListItemModelFromJson(json);
  Map<String, dynamic> toJson() => _$GlobalBarcodeListItemModelToJson(this);

  static DateTime? dateTimeFromTimestampNullable(Timestamp? timestamp) {
    return timestamp?.toDate();
  }

  static List<DateTime> dateTimeFromTimestamps(List<Timestamp> timestamps) {
    return timestamps.map((e) => e.toDate()).toList();
  }

  static dynamic dateTimesToTimestampList(List<DateTime> dateTimes) {
    return dateTimes.map((e) => Timestamp.fromDate(e)).toList();
  }

  static dynamic firestoreTimestampToJson(dynamic value) => value;

  Future<GlobalBarcodeListItemModelWithCompanyAndSample>
      toGlobalBarcodeListItemModelWithCompanyAndSample() async {
    CompanyModel? company;
    try {
      company = await companyReference?.get().then(
          (value) => CompanyModel.fromJson(value.data()! as Map<String, dynamic>));
    } catch (exception, stacktrace) {
      getIt.get<RemoteErrorLoggingService>().recordError(exception, stacktrace);
    }
    SampleModel? sample;
    try {
      sample = await sampleReference?.get().then((value) =>
          SampleModel.fromJson(value.data()! as Map<String, dynamic>));
    } catch (exception, stacktrace) {
      getIt.get<RemoteErrorLoggingService>().recordError(exception, stacktrace);
    }
    return GlobalBarcodeListItemModelWithCompanyAndSample(
        barcode, company, sample);
  }
}

class GlobalBarcodeListItemModelWithCompanyAndSample {
  final String barcode;
  final CompanyModel? company;
  final SampleModel? sample;

  GlobalBarcodeListItemModelWithCompanyAndSample(
      this.barcode, this.company, this.sample);
}
