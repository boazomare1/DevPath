import 'package:hive/hive.dart';

part 'github_repository.g.dart';

@HiveType(typeId: 4)
class GitHubRepository {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String fullName;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final String htmlUrl;

  @HiveField(5)
  final String cloneUrl;

  @HiveField(6)
  final String language;

  @HiveField(7)
  final int stars;

  @HiveField(8)
  final int forks;

  @HiveField(9)
  final bool isPrivate;

  @HiveField(10)
  final bool isFork;

  @HiveField(11)
  final DateTime createdAt;

  @HiveField(12)
  final DateTime updatedAt;

  @HiveField(13)
  final DateTime? pushedAt;

  @HiveField(14)
  final int openIssuesCount;

  @HiveField(15)
  final String defaultBranch;

  @HiveField(16)
  final int size;

  @HiveField(17)
  final String? topics;

  @HiveField(18)
  final bool hasIssues;

  @HiveField(19)
  final bool hasProjects;

  @HiveField(20)
  final bool hasWiki;

  @HiveField(21)
  final bool hasPages;

  @HiveField(22)
  final String? license;

  @HiveField(23)
  final bool archived;

  @HiveField(24)
  final bool disabled;

  @HiveField(25)
  final String? homepage;

  GitHubRepository({
    required this.id,
    required this.name,
    required this.fullName,
    required this.description,
    required this.htmlUrl,
    required this.cloneUrl,
    required this.language,
    required this.stars,
    required this.forks,
    required this.isPrivate,
    required this.isFork,
    required this.createdAt,
    required this.updatedAt,
    this.pushedAt,
    required this.openIssuesCount,
    required this.defaultBranch,
    required this.size,
    this.topics,
    required this.hasIssues,
    required this.hasProjects,
    required this.hasWiki,
    required this.hasPages,
    this.license,
    required this.archived,
    required this.disabled,
    this.homepage,
  });

  factory GitHubRepository.fromJson(Map<String, dynamic> json) {
    return GitHubRepository(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      fullName: json['full_name'] ?? '',
      description: json['description'] ?? '',
      htmlUrl: json['html_url'] ?? '',
      cloneUrl: json['clone_url'] ?? '',
      language: json['language'] ?? '',
      stars: json['stargazers_count'] ?? 0,
      forks: json['forks_count'] ?? 0,
      isPrivate: json['private'] ?? false,
      isFork: json['fork'] ?? false,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      pushedAt: json['pushed_at'] != null ? DateTime.parse(json['pushed_at']) : null,
      openIssuesCount: json['open_issues_count'] ?? 0,
      defaultBranch: json['default_branch'] ?? 'main',
      size: json['size'] ?? 0,
      topics: json['topics'] != null ? (json['topics'] as List).join(',') : null,
      hasIssues: json['has_issues'] ?? false,
      hasProjects: json['has_projects'] ?? false,
      hasWiki: json['has_wiki'] ?? false,
      hasPages: json['has_pages'] ?? false,
      license: json['license']?['name'],
      archived: json['archived'] ?? false,
      disabled: json['disabled'] ?? false,
      homepage: json['homepage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'full_name': fullName,
      'description': description,
      'html_url': htmlUrl,
      'clone_url': cloneUrl,
      'language': language,
      'stargazers_count': stars,
      'forks_count': forks,
      'private': isPrivate,
      'fork': isFork,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'pushed_at': pushedAt?.toIso8601String(),
      'open_issues_count': openIssuesCount,
      'default_branch': defaultBranch,
      'size': size,
      'topics': topics?.split(','),
      'has_issues': hasIssues,
      'has_projects': hasProjects,
      'has_wiki': hasWiki,
      'has_pages': hasPages,
      'license': license != null ? {'name': license} : null,
      'archived': archived,
      'disabled': disabled,
      'homepage': homepage,
    };
  }

  GitHubRepository copyWith({
    int? id,
    String? name,
    String? fullName,
    String? description,
    String? htmlUrl,
    String? cloneUrl,
    String? language,
    int? stars,
    int? forks,
    bool? isPrivate,
    bool? isFork,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? pushedAt,
    int? openIssuesCount,
    String? defaultBranch,
    int? size,
    String? topics,
    bool? hasIssues,
    bool? hasProjects,
    bool? hasWiki,
    bool? hasPages,
    String? license,
    bool? archived,
    bool? disabled,
    String? homepage,
  }) {
    return GitHubRepository(
      id: id ?? this.id,
      name: name ?? this.name,
      fullName: fullName ?? this.fullName,
      description: description ?? this.description,
      htmlUrl: htmlUrl ?? this.htmlUrl,
      cloneUrl: cloneUrl ?? this.cloneUrl,
      language: language ?? this.language,
      stars: stars ?? this.stars,
      forks: forks ?? this.forks,
      isPrivate: isPrivate ?? this.isPrivate,
      isFork: isFork ?? this.isFork,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      pushedAt: pushedAt ?? this.pushedAt,
      openIssuesCount: openIssuesCount ?? this.openIssuesCount,
      defaultBranch: defaultBranch ?? this.defaultBranch,
      size: size ?? this.size,
      topics: topics ?? this.topics,
      hasIssues: hasIssues ?? this.hasIssues,
      hasProjects: hasProjects ?? this.hasProjects,
      hasWiki: hasWiki ?? this.hasWiki,
      hasPages: hasPages ?? this.hasPages,
      license: license ?? this.license,
      archived: archived ?? this.archived,
      disabled: disabled ?? this.disabled,
      homepage: homepage ?? this.homepage,
    );
  }

  @override
  String toString() {
    return 'GitHubRepository(id: $id, name: $name, fullName: $fullName, language: $language, stars: $stars)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GitHubRepository && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}