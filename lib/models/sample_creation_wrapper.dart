class SampleCreationWrapper {
  String id;
  String? changeId;
  DateTime? sampleDate;
  String locationPlot;
  double? locationPlotLatitude;
  double? locationPlotLongitude;
  String cultivation;
  String treatment;
  String crop;
  String? variety;
  String notes;
  String grower;
  double? latitude;
  double? longitude;
  bool hasYoungSample;
  bool hasOldSample;
  String? youngSampleBarcode;
  String? oldSampleBarcode;

  SampleCreationWrapper({
    required this.id,
    required this.changeId,
    required this.sampleDate,
    required this.locationPlot,
    required this.cultivation,
    required this.treatment,
    required this.crop,
    required this.variety,
    required this.notes,
    required this.grower,
    required this.latitude,
    required this.longitude,
    required this.hasYoungSample,
    required this.hasOldSample,
    required this.youngSampleBarcode,
    required this.oldSampleBarcode,
  });
}
