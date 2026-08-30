enum MessageRole { user, assistant, system }

class ChatMessageModel {
  final String id;
  final MessageRole role;
  final String content;
  final bool isStreaming;
  final List<MedicineCardModel> medicineCards;
  final ClarificationPromptModel? clarificationPrompt;

  const ChatMessageModel({
    required this.id,
    required this.role,
    required this.content,
    this.isStreaming = false,
    this.medicineCards = const [],
    this.clarificationPrompt,
  });

  ChatMessageModel copyWith({
    String? id,
    MessageRole? role,
    String? content,
    bool? isStreaming,
    List<MedicineCardModel>? medicineCards,
    ClarificationPromptModel? clarificationPrompt,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      isStreaming: isStreaming ?? this.isStreaming,
      medicineCards: medicineCards ?? this.medicineCards,
      clarificationPrompt: clarificationPrompt ?? this.clarificationPrompt,
    );
  }
}

class MedicineCardModel {
  final String? id;
  final String slug;
  final String brand;
  final String? genericName;
  final String? strength;
  final String? dosageForm;
  final double? unitPrice;
  final String? packSize;
  final bool inStock;
  final String? image;
  final String? manufacturer;

  const MedicineCardModel({
    this.id,
    required this.slug,
    required this.brand,
    this.genericName,
    this.strength,
    this.dosageForm,
    this.unitPrice,
    this.packSize,
    this.inStock = true,
    this.image,
    this.manufacturer,
  });

  factory MedicineCardModel.fromJson(Map<String, dynamic> json) {
    return MedicineCardModel(
      id: json['id']?.toString(),
      slug: json['slug']?.toString() ?? '',
      brand: json['brand']?.toString() ?? json['medicine_name']?.toString() ?? '',
      genericName: json['generic_name']?.toString(),
      strength: json['strength']?.toString(),
      dosageForm: json['dosage_form']?.toString(),
      unitPrice: (json['unit_price'] as num?)?.toDouble(),
      packSize: json['pack_size']?.toString(),
      inStock: json['in_stock'] as bool? ?? true,
      image: json['image']?.toString() ?? json['medicine_image']?.toString(),
      manufacturer: json['manufacturer']?.toString() ?? json['manufacturer_name']?.toString(),
    );
  }
}

class ClarificationPromptModel {
  final String clarificationId;
  final String message;
  final List<ClarificationQuestionModel> questions;

  const ClarificationPromptModel({
    required this.clarificationId,
    required this.message,
    required this.questions,
  });

  factory ClarificationPromptModel.fromJson(Map<String, dynamic> json) {
    final qList = json['questions'] as List<dynamic>? ?? [];
    return ClarificationPromptModel(
      clarificationId: json['clarification_id']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      questions: qList
          .map((q) => ClarificationQuestionModel.fromJson(q as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ClarificationQuestionModel {
  final String id;
  final String type;
  final String question;
  final List<ClarificationOptionModel> options;

  const ClarificationQuestionModel({
    required this.id,
    required this.type,
    required this.question,
    this.options = const [],
  });

  factory ClarificationQuestionModel.fromJson(Map<String, dynamic> json) {
    final opts = json['options'] as List<dynamic>? ?? [];
    return ClarificationQuestionModel(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'text',
      question: json['question']?.toString() ?? '',
      options: opts
          .map((o) => ClarificationOptionModel.fromJson(o as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ClarificationOptionModel {
  final String id;
  final String label;

  const ClarificationOptionModel({required this.id, required this.label});

  factory ClarificationOptionModel.fromJson(Map<String, dynamic> json) {
    return ClarificationOptionModel(
      id: json['id']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
    );
  }
}
