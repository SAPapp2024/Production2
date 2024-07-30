import 'package:agro_k/models/db_current_company.dart';
import 'package:agro_k/models/company/db_sample_model.dart';
import 'package:agro_k/services/Database/shared_connection.dart';
import 'package:drift/drift.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [DBSampleModel, DBCurrentCompany])
class AppDatabase extends _$AppDatabase {
  static AppDatabase? _instance;

  factory AppDatabase() {
    _instance ??= AppDatabase._internal();
    return _instance!;
  }

  AppDatabase._internal() : super(constructDb());

  @override
  int get schemaVersion => 13;

  @override
  MigrationStrategy get migration => destructiveFallback;

  Future saveSample(DBSampleModelData sample) =>
      into(dBSampleModel).insert(sample, mode: InsertMode.replace);

  Future<DBSampleModelData?> getSamples() => select(dBSampleModel).getSingleOrNull();

  Future deleteAllSamples() => delete(dBSampleModel).go();

  Future<void> deleteSampleById(String id) => (delete(dBSampleModel)..where((dbSample) => dbSample.id.equals(id))).go();

  Future setCurrentCompany(String id) async {
    return transaction(() async {
      await deleteCurrentCompany();
      await into(dBCurrentCompany).insert(
          DBCurrentCompanyData(id: id), mode: InsertMode.replace);
    });
  }

  Future<DBCurrentCompanyData?> getCurrentCompany() => select(dBCurrentCompany).getSingleOrNull();

  Future deleteCurrentCompany() => delete(dBCurrentCompany).go();

}
