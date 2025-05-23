class Staffs {
  final String id;
  final String title;
  final String location;
  final int type;
  final String bio;
  final String photo;
  final String link;
  final String facebook;
  final String linkedin;
  final String tiktok;
  final String twitter;
  final String instagram;

  Staffs({
    required this.id,
    required this.title,
    required this.location,
    required this.type,
    required this.bio,
    required this.photo,
    required this.link,
    required this.facebook,
    required this.linkedin,
    required this.tiktok,
    required this.twitter,
    required this.instagram,
  });

  factory Staffs.fromJson(Map<String, dynamic> json) {
    return Staffs(
      id: json['_id'] ?? '', // MongoDB object ID
      title: json['title'] ?? '',
      location: json['location'] ?? '',
      type: json['type'],
      bio: json['bio'] ?? '',
      photo: json['photo'] ?? '',
      link: json['link'] ?? '',
      facebook: json['facebook'] ?? '',
      linkedin: json['linkedin'] ?? '',
      tiktok: json['tiktok'] ?? '',
      twitter: json['twitter'] ?? '',
      instagram: json['instagram'] ?? '',
    );
  }
}
