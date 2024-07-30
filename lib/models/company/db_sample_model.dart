import 'package:drift/drift.dart';

class DBSampleModel extends Table {
  IntColumn get privateId => integer()();
  TextColumn get id => text()();
  DateTimeColumn? get sampleDate => dateTime().nullable()();
  TextColumn get locationPlot => text()();
  TextColumn get cultivation => text()();
  TextColumn get treatment => text()();
  TextColumn get crop => text()();
  TextColumn? get variety => text().nullable()();
  TextColumn get grower => text()();
  TextColumn get notes => text()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  BoolColumn get youngSamplesProvided => boolean()();
  BoolColumn get oldSamplesProvided => boolean()();

  @override
  Set<Column>? get primaryKey => {privateId};

}