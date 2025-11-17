class ContactModel {
  final String name;
  final String phoneNumber;

  ContactModel({required this.name, required this.phoneNumber});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone_number': phoneNumber,
    };
  }
}
