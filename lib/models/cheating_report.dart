class AnalysisResponse {
  final int totalDocumentsProcessed;
  final int cheatingPairsFound;
  final List<CheatingReport> report;
  final String? error;

  AnalysisResponse({
    required this.totalDocumentsProcessed,
    required this.cheatingPairsFound,
    required this.report,
    this.error,
  });

  factory AnalysisResponse.fromJson(Map<String, dynamic> json) {
    return AnalysisResponse(
      totalDocumentsProcessed: json['total_documents_processed'] ?? 0,
      cheatingPairsFound: json['cheating_pairs_found'] ?? 0,
      report: (json['report'] as List<dynamic>? ?? [])
          .map((e) => CheatingReport.fromJson(e))
          .toList(),
      error: json['error'],
    );
  }
}

class CheatingReport {
  final List<String> students;
  final double? similarityScore;
  final DetailedAnalysis analysis;

  CheatingReport({
    required this.students,
    required this.similarityScore,
    required this.analysis,
  });

  factory CheatingReport.fromJson(Map<String, dynamic> json) {
    return CheatingReport(
      students: List<String>.from(json['students'] ?? []),
      similarityScore: json['similarity_score'] != null
          ? (json['similarity_score'] as num).toDouble()
          : null,
      analysis: DetailedAnalysis.fromJson(json['analysis'] ?? {}),
    );
  }
}

class DetailedAnalysis {
  final bool isCheating;
  final String reason;
  final List<String> suspiciousParts;

  DetailedAnalysis({
    required this.isCheating,
    required this.reason,
    required this.suspiciousParts,
  });

  factory DetailedAnalysis.fromJson(Map<String, dynamic> json) {
    return DetailedAnalysis(
      isCheating: json['is_cheating'] ?? false,
      reason: json['reason'] ?? "Belirtilmedi",
      suspiciousParts: List<String>.from(json['suspicious_parts'] ?? []),
    );
  }
}
