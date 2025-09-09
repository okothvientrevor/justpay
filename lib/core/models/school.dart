import 'organization.dart';
import 'student.dart';
import 'parent.dart';

class School extends Organization {
  final List<Student> students;
  final List<Parent> parents;
  final Map<String, ClassInfo> classes;

  School({
    required super.id,
    required super.name,
    required super.type,
    required super.slug,
    super.logoUrl,
    required super.primaryColor,
    required super.secondaryColor,
    required super.settings,
    required this.students,
    required this.parents,
    required this.classes,
  });
}

class ClassInfo {
  // Define class info fields here
  // ...add fields as needed...
}
