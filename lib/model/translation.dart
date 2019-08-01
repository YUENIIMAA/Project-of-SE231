class Result {
  String originalText;
  String translatedText;
  Result(this.originalText, this.translatedText){}

  Result.fromJson(Map<String, dynamic> json)
      : originalText = json['originalText'],
        translatedText = json['translatedText'];

  Map<String, dynamic> toJson() =>
      {
        'originalText':originalText,
        'translatedText': translatedText,
      };
}

class Trans {
  String source;
  Future<String> dest;
  bool isColletion;
  Trans(this.source, this.dest,this.isColletion){}
}