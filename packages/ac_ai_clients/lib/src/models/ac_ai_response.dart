import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';

/* AcDoc({
  "summary": "Structured AI response model with status, output data, and raw metadata.",
  "description": "Represents the result of an AI operation including success/failure status, structured response content, and full raw API payload.",
  "author": "Sanket Patel",
  "type": "model",
  "category": "AI",
  "group": "Response"
}) */
@AcReflectable()
class AcAIResponse extends AcResult {
  static const String keyText = 'text';
  static const String keyImageUrls = 'imageUrls';
  static const String keyAudioUrls = 'audioUrls';
  static const String keyVideoUrls = 'videoUrls';
  static const String keyFileUrls = 'fileUrls';
  static const String keyTokensUsed = 'tokensUsed';
  static const String keyRaw = 'raw';

  /* AcDoc({ "description": "Primary text response returned by the AI." }) */
  @AcBindJsonProperty(key: keyText)
  String? text;

  /* AcDoc({ "description": "List of image URLs generated or returned." }) */
  @AcBindJsonProperty(key: keyImageUrls)
  List<String> imageUrls = [];

  /* AcDoc({ "description": "List of audio URLs returned by the AI." }) */
  @AcBindJsonProperty(key: keyAudioUrls)
  List<String> audioUrls = [];

  /* AcDoc({ "description": "List of video URLs in the response." }) */
  @AcBindJsonProperty(key: keyVideoUrls)
  List<String> videoUrls = [];

  /* AcDoc({ "description": "List of downloadable file URLs (e.g., PDFs, ZIPs)." }) */
  @AcBindJsonProperty(key: keyFileUrls)
  List<String> fileUrls = [];

  /* AcDoc({ "description": "Number of tokens used in the generation." }) */
  @AcBindJsonProperty(key: keyTokensUsed)
  int? tokensUsed;

  /* AcDoc({ "description": "Raw response data from the AI provider." }) */
  @AcBindJsonProperty(key: keyRaw)
  Map<String, dynamic>? raw;

  /* AcDoc({ "description": "Creates a new AI response instance." }) */
  AcAIResponse();

  /* AcDoc({
    "summary": "Creates an instance from a JSON map.",
    "params": [{"name": "jsonData", "description": "The input map representing a raw or parsed AI response."}],
    "returns": "A new AcAIResponse object."
  }) */
  factory AcAIResponse.instanceFromJson({
    required Map<String, dynamic> jsonData,
  }) {
    final instance = AcAIResponse();
    return instance.fromJson(jsonData: jsonData);
  }

  /* AcDoc({
    "summary": "Populates this instance from JSON.",
    "params": [{"name": "jsonData", "description": "The map containing JSON keys."}],
    "returns": "The same instance after mapping properties."
  }) */
  @override
  AcAIResponse fromJson({Map<String, dynamic> jsonData = const {}}) {
    super.fromJson(jsonData: jsonData);
    text = AcJsonUtils.deserializeValue<String>(
      jsonData[keyText],
      defaultValue: text,
    );
    imageUrls = AcJsonUtils.deserializeList<String>(
      jsonData[keyImageUrls] ?? jsonData['image_urls'],
    );
    audioUrls = AcJsonUtils.deserializeList<String>(
      jsonData[keyAudioUrls] ?? jsonData['audio_urls'],
    );
    videoUrls = AcJsonUtils.deserializeList<String>(
      jsonData[keyVideoUrls] ?? jsonData['video_urls'],
    );
    fileUrls = AcJsonUtils.deserializeList<String>(
      jsonData[keyFileUrls] ?? jsonData['file_urls'],
    );
    tokensUsed = AcJsonUtils.deserializeValue<int>(
      jsonData[keyTokensUsed] ?? jsonData['tokens_used'],
      defaultValue: tokensUsed,
    );
    if (jsonData.containsKey(keyRaw)) {
      final val = jsonData[keyRaw];
      if (val is Map<String, dynamic>) {
        raw = val;
      } else if (val is Map) {
        raw = val.cast<String, dynamic>();
      }
    }
    return this;
  }

  /* AcDoc({
    "summary": "Serializes the object into a JSON map.",
    "returns": "A `Map<String, dynamic>` representation."
  }) */
  @override
  Map<String, dynamic> toJson() {
    final result = super.toJson();
    if (text != null) {
      result[keyText] = text;
    }
    if (imageUrls.isNotEmpty) {
      result[keyImageUrls] = AcJsonUtils.serializeValue(imageUrls);
    }
    if (audioUrls.isNotEmpty) {
      result[keyAudioUrls] = AcJsonUtils.serializeValue(audioUrls);
    }
    if (videoUrls.isNotEmpty) {
      result[keyVideoUrls] = AcJsonUtils.serializeValue(videoUrls);
    }
    if (fileUrls.isNotEmpty) {
      result[keyFileUrls] = AcJsonUtils.serializeValue(fileUrls);
    }
    if (tokensUsed != null) {
      result[keyTokensUsed] = tokensUsed;
    }
    if (raw != null) {
      result[keyRaw] = AcJsonUtils.serializeValue(raw);
    }
    return result;
  }

  /* AcDoc({ "summary": "Pretty-prints the response as a JSON string." }) */
  @override
  String toString() => AcJsonUtils.prettyEncode(toJson());

  /* AcDoc({
    "summary": "Returns true if any output field has content.",
    "returns": "true if any media or text is populated."
  }) */
  bool hasContent() {
    return (text?.isNotEmpty ?? false) ||
        imageUrls.isNotEmpty ||
        audioUrls.isNotEmpty ||
        videoUrls.isNotEmpty ||
        fileUrls.isNotEmpty;
  }
}
