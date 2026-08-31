class AddressModel {
  final String? id;
  final String label;
  final String recipientName;
  final String recipientPhone;
  final String division;
  final String district;
  final String upazilaOrThana;
  final String streetAddress;
  final bool isDefault;

  const AddressModel({
    this.id,
    this.label = 'Home',
    required this.recipientName,
    required this.recipientPhone,
    this.division = 'Dhaka',
    required this.district,
    required this.upazilaOrThana,
    required this.streetAddress,
    this.isDefault = false,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as String?,
      label: json['label'] as String? ?? 'Home',
      recipientName: json['recipient_name'] as String? ?? '',
      recipientPhone: json['recipient_phone'] as String? ?? '',
      division: json['division'] as String? ?? 'Dhaka',
      district: json['district'] as String? ?? '',
      upazilaOrThana: json['upazila_or_thana'] as String? ?? '',
      streetAddress: json['street_address'] as String? ?? '',
      isDefault: json['is_default'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'label': label,
      'recipient_name': recipientName,
      'recipient_phone': recipientPhone,
      'division': division,
      'district': district,
      'upazila_or_thana': upazilaOrThana,
      'street_address': streetAddress,
      'is_default': isDefault,
    };
  }

  AddressModel copyWith({
    String? id,
    String? label,
    String? recipientName,
    String? recipientPhone,
    String? division,
    String? district,
    String? upazilaOrThana,
    String? streetAddress,
    bool? isDefault,
  }) {
    return AddressModel(
      id: id ?? this.id,
      label: label ?? this.label,
      recipientName: recipientName ?? this.recipientName,
      recipientPhone: recipientPhone ?? this.recipientPhone,
      division: division ?? this.division,
      district: district ?? this.district,
      upazilaOrThana: upazilaOrThana ?? this.upazilaOrThana,
      streetAddress: streetAddress ?? this.streetAddress,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
