class Video {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String videoUrl;
  final String channelName;
  final DateTime uploadDate;
  final String duration;
  final int viewCount;

  Video({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.channelName,
    required this.uploadDate,
    required this.duration,
    required this.viewCount,
  });
}