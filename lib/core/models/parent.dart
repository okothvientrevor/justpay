import 'student.dart';

class Parent {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? address;
  final String? occupation;
  final List<Student> children;

  Parent({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.address,
    this.occupation,
    required this.children,
  });
}
