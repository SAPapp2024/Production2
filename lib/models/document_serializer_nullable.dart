import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

class DocumentSerializerNullable implements JsonConverter<DocumentReference?, DocumentReference?> {
  const DocumentSerializerNullable();

  @override
  DocumentReference? fromJson(DocumentReference? docRef) => docRef;

  @override
  DocumentReference? toJson(DocumentReference? docRef) => docRef;
}
