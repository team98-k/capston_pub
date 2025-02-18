class ImageModel {
  final String title;
  final String description;
  final String fileUrl;
  final String creatorUid;
  final String creator;
  final int likes;
  final int comments;
  final bool isLiked;
  final int createdAt;

  ImageModel({
    required this.title,
    required this.description,
    required this.fileUrl,
    required this.creatorUid,
    required this.likes,
    required this.comments,
    required this.createdAt,
    required this.creator,
    required this.isLiked,
  });

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "description": description,
      "fileUrl": fileUrl,
      "creatorUid": creatorUid,
      "likes": likes,
      "comments": comments,
      "isLiked": isLiked,
      "createdAt": createdAt,
      "creator": creator,
    };
  }
}
