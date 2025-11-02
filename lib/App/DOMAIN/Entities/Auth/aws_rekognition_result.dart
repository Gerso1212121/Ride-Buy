class AwsRekognitionResult {
  final double bestSimilarity;
  final int unmatchedFaces;
  final List<Map<String, dynamic>> faceMatches;
  final String result; //'Matched', 'No_Matched', 'Error'

  AwsRekognitionResult({
    required this.bestSimilarity,
    required this.faceMatches,
    required this.unmatchedFaces,
    required this.result,
  });

  factory AwsRekognitionResult.fromJson(Map<String, dynamic> json) {
    final matches = (json['FaceMatches'] as List<dynamic>?)
            ?.map((e) => e as Map<String, dynamic>)
            .toList() ??
        [];
    double best = 0;
    if (matches.isNotEmpty) {
      best = matches
          .map((e) => (e['Similarity'] as num).toDouble())
          .reduce((a, b) => a > b ? a : b);
    }
    return AwsRekognitionResult(
      bestSimilarity: best,
      unmatchedFaces: json['UnmatchedFaces'] as int? ?? 0,
      faceMatches: matches,
      result: json['Result'] as String? ?? 'Error',
    );
  }
}
