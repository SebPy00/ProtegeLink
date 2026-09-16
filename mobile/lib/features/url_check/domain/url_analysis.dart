enum AnalysisStatus { safe, suspicious, dangerous }

class UrlAnalysis {
  const UrlAnalysis({
    required this.url,
    required this.domain,
    required this.status,
    required this.riskScore,
    required this.reasons,
    required this.analyzedAt,
  });

  final String url;
  final String domain;
  final AnalysisStatus status;
  final int riskScore;
  final List<String> reasons;
  final DateTime analyzedAt;

  factory UrlAnalysis.fromJson(Map<String, dynamic> json) {
    return UrlAnalysis(
      url: json['url'] as String,
      domain: json['domain'] as String,
      status: AnalysisStatus.values.byName(
        (json['status'] as String).toLowerCase(),
      ),
      riskScore: json['risk_score'] as int,
      reasons: List<String>.from(json['reasons'] as List<dynamic>),
      analyzedAt: json['analyzed_at'] == null
          ? DateTime.now()
          : DateTime.parse(json['analyzed_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'url': url,
    'domain': domain,
    'status': status.name.toUpperCase(),
    'risk_score': riskScore,
    'reasons': reasons,
    'analyzed_at': analyzedAt.toIso8601String(),
  };
}
