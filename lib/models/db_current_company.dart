import 'package:drift/drift.dart';

class DBCurrentCompany extends Table {

  TextColumn get id => text()();

  @override
  Set<Column>? get primaryKey => {id};

}