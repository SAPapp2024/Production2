enum SampleSortFields {
  collectedDate,
  createdDate,
  farm,
  status,
  field,
  crop,
  variety,
  grower,
  notes,
  sampleBarcodes,
  user,
  company,
  none
}

enum CropSortFields { id, name, status, none }

enum BarcodeSortFields {
  barcode,
  company,
  createdDate,
  addedToFarmDate,
  none,
  sample
}

enum UserSortFields { firstName, lastName, email, phone, farmName, none }

enum CompanySortFields {
  address,
  companyAdminEmail,
  phone,
  alternativePhone,
  city,
  state,
  zipcode,
  country,
  name,
  none
}

enum SortType { asc, desc, none }

class UserSortFilterWrapper {
  final UserSortFields field;
  final SortType sortType;

  UserSortFilterWrapper({required this.field, required this.sortType});

  UserSortFilterWrapper copyWith({UserSortFields? field, SortType? sortType}) {
    return UserSortFilterWrapper(
      field: field ?? this.field,
      sortType: sortType ?? this.sortType,
    );
  }

  static UserSortFilterWrapper empty() {
    return UserSortFilterWrapper(
        field: UserSortFields.none, sortType: SortType.none);
  }

  bool isEmpty() {
    return field == UserSortFields.none || sortType == SortType.none;
  }
}

class CompanySortFilterWrapper {
  final CompanySortFields field;
  final SortType sortType;

  CompanySortFilterWrapper({required this.field, required this.sortType});

  CompanySortFilterWrapper copyWith(
      {CompanySortFields? field, SortType? sortType}) {
    return CompanySortFilterWrapper(
      field: field ?? this.field,
      sortType: sortType ?? this.sortType,
    );
  }

  static CompanySortFilterWrapper empty() {
    return CompanySortFilterWrapper(
        field: CompanySortFields.none, sortType: SortType.none);
  }

  bool isEmpty() {
    return field == CompanySortFields.none || sortType == SortType.none;
  }
}

class CropSortFilterWrapper {
  final CropSortFields field;
  final SortType sortType;

  CropSortFilterWrapper({required this.field, required this.sortType});

  CropSortFilterWrapper copyWith({CropSortFields? field, SortType? sortType}) {
    return CropSortFilterWrapper(
      field: field ?? this.field,
      sortType: sortType ?? this.sortType,
    );
  }

  static CropSortFilterWrapper empty() {
    return CropSortFilterWrapper(
        field: CropSortFields.none, sortType: SortType.none);
  }

  bool isEmpty() {
    return field == CropSortFields.none || sortType == SortType.none;
  }
}

class BarcodeSortFilterWrapper {
  final BarcodeSortFields field;
  final SortType sortType;

  BarcodeSortFilterWrapper({required this.field, required this.sortType});

  BarcodeSortFilterWrapper copyWith(
      {BarcodeSortFields? field, SortType? sortType}) {
    return BarcodeSortFilterWrapper(
      field: field ?? this.field,
      sortType: sortType ?? this.sortType,
    );
  }

  static BarcodeSortFilterWrapper empty() {
    return BarcodeSortFilterWrapper(
        field: BarcodeSortFields.none, sortType: SortType.none);
  }

  bool isEmpty() {
    return field == BarcodeSortFields.none || sortType == SortType.none;
  }
}

class SampleSortFilterWrapper {
  final SampleSortFields field;
  final SortType sortType;

  SampleSortFilterWrapper({required this.field, required this.sortType});

  SampleSortFilterWrapper copyWith(
      {SampleSortFields? field, SortType? sortType}) {
    return SampleSortFilterWrapper(
      field: field ?? this.field,
      sortType: sortType ?? this.sortType,
    );
  }

  static SampleSortFilterWrapper empty() {
    return SampleSortFilterWrapper(
        field: SampleSortFields.none, sortType: SortType.none);
  }

  bool isEmpty() {
    return field == SampleSortFields.none || sortType == SortType.none;
  }
}
