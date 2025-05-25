class Group {
  final String id;
  final String name;
  final String avatarUrl;
  final List<String> members;
  final List<String> admins;

  Group({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.members,
    required this.admins,
  });

  bool isAdmin(String userId) => admins.contains(userId);
  bool isMember(String userId) => members.contains(userId);

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'],
      name: json['name'],
      avatarUrl: json['avatarUrl'],
      members: List<String>.from(json['members']),
      admins: List<String>.from(json['admins']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatarUrl': avatarUrl,
      'members': members,
      'admins': admins,
    };
  }
}
