class AwsRekognitionResult {
  final double bestSimilarity;
  final int unmatchedFaces;
  final List<Map<String, dynamic>> faceMatches;
  final String result; // 'Matched', 'No_Matched', 'Error'

  AwsRekognitionResult({
    required this.bestSimilarity,
    required this.faceMatches,
    required this.unmatchedFaces,
    required this.result,
  });

  factory AwsRekognitionResult.fromJson(Map<String, dynamic> json,
      {double similarityThreshold = 80.0}) {
    final matches = (json['FaceMatches'] as List<dynamic>?)
            ?.map((e) => e as Map<String, dynamic>)
            .toList() ??
        [];

    // Encuentra la similitud más alta
    double best = 0;
    if (matches.isNotEmpty) {
      best = matches
          .map((e) => (e['Similarity'] as num).toDouble())
          .reduce((a, b) => a > b ? a : b);
    }

    // Calcula el resultado dinámicamente
    String computedResult = 'No_Matched';
    if (best >= similarityThreshold) {
      computedResult = 'Matched';
    } else if (matches.isEmpty) {
      computedResult = 'Error';
    }

    return AwsRekognitionResult(
      bestSimilarity: best,
      unmatchedFaces: json['UnmatchedFaces'] as int? ?? 0,
      faceMatches: matches,
      result: computedResult,
    );
  }
}
