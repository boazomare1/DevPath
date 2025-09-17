import 'package:hive/hive.dart';

part 'github_user.g.dart';

@HiveType(typeId: 5)
class GitHubUser {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String login;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final String email;

  @HiveField(4)
  final String avatarUrl;

  @HiveField(5)
  final String htmlUrl;

  @HiveField(6)
  final String bio;

  @HiveField(7)
  final String company;

  @HiveField(8)
  final String blog;

  @HiveField(9)
  final String location;

  @HiveField(10)
  final int publicRepos;

  @HiveField(11)
  final int publicGists;

  @HiveField(12)
  final int followers;

  @HiveField(13)
  final int following;

  @HiveField(14)
  final DateTime createdAt;

  @HiveField(15)
  final DateTime updatedAt;

  @HiveField(16)
  final bool hireable;

  @HiveField(17)
  final String type;

  @HiveField(18)
  final String? twitterUsername;

  GitHubUser({
    required this.id,
    required this.login,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.htmlUrl,
    required this.bio,
    required this.company,
    required this.blog,
    required this.location,
    required this.publicRepos,
    required this.publicGists,
    required this.followers,
    required this.following,
    required this.createdAt,
    required this.updatedAt,
    required this.hireable,
    required this.type,
    this.twitterUsername,
  });

  factory GitHubUser.fromJson(Map<String, dynamic> json) {
    return GitHubUser(
      id: json['id'] ?? 0,
      login: json['login'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      avatarUrl: json['avatar_url'] ?? '',
      htmlUrl: json['html_url'] ?? '',
      bio: json['bio'] ?? '',
      company: json['company'] ?? '',
      blog: json['blog'] ?? '',
      location: json['location'] ?? '',
      publicRepos: json['public_repos'] ?? 0,
      publicGists: json['public_gists'] ?? 0,
      followers: json['followers'] ?? 0,
      following: json['following'] ?? 0,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      hireable: json['hireable'] ?? false,
      type: json['type'] ?? 'User',
      twitterUsername: json['twitter_username'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'login': login,
      'name': name,
      'email': email,
      'avatar_url': avatarUrl,
      'html_url': htmlUrl,
      'bio': bio,
      'company': company,
      'blog': blog,
      'location': location,
      'public_repos': publicRepos,
      'public_gists': publicGists,
      'followers': followers,
      'following': following,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'hireable': hireable,
      'type': type,
      'twitter_username': twitterUsername,
    };
  }

  GitHubUser copyWith({
    int? id,
    String? login,
    String? name,
    String? email,
    String? avatarUrl,
    String? htmlUrl,
    String? bio,
    String? company,
    String? blog,
    String? location,
    int? publicRepos,
    int? publicGists,
    int? followers,
    int? following,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? hireable,
    String? type,
    String? twitterUsername,
  }) {
    return GitHubUser(
      id: id ?? this.id,
      login: login ?? this.login,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      htmlUrl: htmlUrl ?? this.htmlUrl,
      bio: bio ?? this.bio,
      company: company ?? this.company,
      blog: blog ?? this.blog,
      location: location ?? this.location,
      publicRepos: publicRepos ?? this.publicRepos,
      publicGists: publicGists ?? this.publicGists,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      hireable: hireable ?? this.hireable,
      type: type ?? this.type,
      twitterUsername: twitterUsername ?? this.twitterUsername,
    );
  }

  @override
  String toString() {
    return 'GitHubUser(id: $id, login: $login, name: $name, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GitHubUser && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}