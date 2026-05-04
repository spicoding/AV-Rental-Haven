class User {
  final String? id; // Firebase UIDs are Strings
  final String fullName;
  final String emailAddress;
  // Password is not stored in the model after registration for security

  User({this.id, required this.fullName, required this.emailAddress});

  // Factory constructor to create a User from a JSON map (e.g., from API response)
  factory User.fromJson(Map<String, dynamic> json) {
    final idValue = json['user_id'] ?? json['id'];
    return User(
      id: idValue?.toString(),
      fullName: json['full_name'] as String,
      emailAddress: json['email_address'] as String,
    );
  }

  // Method to convert a User object to a JSON map (e.g., for API request body)
  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'email_address': emailAddress,
      // Password will be added separately for registration, not part of the model after hashing
    };
  }
}
