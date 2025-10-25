import '../models/video.dart';

class SampleVideos {
  static List<Video> getVideos() {
    return [
      Video(
        id: '1',
        title: 'Flutter Development Tutorial',
        description: 'Learn Flutter development from basics to advanced concepts',
        thumbnailUrl: 'https://picsum.photos/320/180?random=1',
        videoUrl: 'https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/360/Big_Buck_Bunny_360_10s_1MB.mp4',
        channelName: 'Flutter Tutorials',
        uploadDate: DateTime.now().subtract(const Duration(days: 1)),
        duration: '10:32',
        viewCount: 15420,
      ),
      Video(
        id: '2',
        title: 'Building Beautiful UIs with Flutter',
        description: 'Creating stunning user interfaces using Flutter widgets',
        thumbnailUrl: 'https://picsum.photos/320/180?random=2',
        videoUrl: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_2mb.mp4',
        channelName: 'UI Design Pro',
        uploadDate: DateTime.now().subtract(const Duration(days: 3)),
        duration: '15:47',
        viewCount: 28340,
      ),
      Video(
        id: '3',
        title: 'State Management in Flutter',
        description: 'Understanding different state management solutions',
        thumbnailUrl: 'https://picsum.photos/320/180?random=3',
        videoUrl: 'https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/360/Big_Buck_Bunny_360_10s_1MB.mp4',
        channelName: 'Flutter Advanced',
        uploadDate: DateTime.now().subtract(const Duration(days: 5)),
        duration: '22:15',
        viewCount: 45680,
      ),
      Video(
        id: '4',
        title: 'Flutter Animation Masterclass',
        description: 'Creating smooth and engaging animations in Flutter',
        thumbnailUrl: 'https://picsum.photos/320/180?random=4',
        videoUrl: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_2mb.mp4',
        channelName: 'Animation Studio',
        uploadDate: DateTime.now().subtract(const Duration(days: 7)),
        duration: '18:23',
        viewCount: 32150,
      ),
    ];
  }
}