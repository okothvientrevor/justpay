enum StudentStatus { active, graduated, suspended, left }

class Student {
  final String id;
  final String name;
  final String email;
  final String schoolId;
  final String parentId;
  final String className;
  final String? stream;
  final String admissionNumber;
  final StudentStatus status;

  Student({
    required this.id,
    required this.name,
    required this.email,
    required this.schoolId,
    required this.parentId,
    required this.className,
    this.stream,
    required this.admissionNumber,
    required this.status,
  });
}
