import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import '../config/api_config.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Reusable interactive media viewer supporting both images and video playback.
class AppMediaViewer extends StatefulWidget {
  final List<String> urls;
  final int initialIndex;
  final String? title;

  const AppMediaViewer({
    super.key,
    required this.urls,
    this.initialIndex = 0,
    this.title,
  });

  static Future<void> show(
    BuildContext context, {
    required String url,
    String? title,
  }) {
    return showGallery(
      context,
      urls: [url],
      initialIndex: 0,
      title: title,
    );
  }

  static Future<void> showGallery(
    BuildContext context, {
    required List<String> urls,
    int initialIndex = 0,
    String? title,
  }) {
    if (urls.isEmpty) return Future.value();
    return showDialog(
      context: context,
      useSafeArea: false,
      barrierColor: Colors.black.withValues(alpha: 0.92),
      builder: (_) => AppMediaViewer(
        urls: urls,
        initialIndex: initialIndex,
        title: title,
      ),
    );
  }

  @override
  State<AppMediaViewer> createState() => _AppMediaViewerState();
}

class _AppMediaViewerState extends State<AppMediaViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.urls.length - 1);
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUrl = widget.urls[_currentIndex];
    final isVideo = ApiConfig.isVideoUrl(currentUrl);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Content Gallery
          PageView.builder(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            itemCount: widget.urls.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              final url = ApiConfig.resolveMediaUrl(widget.urls[index]);
              final itemIsVideo = ApiConfig.isVideoUrl(url);

              if (itemIsVideo) {
                return Center(
                  child: AppVideoPlayer(
                    url: url,
                    autoPlay: true,
                  ),
                );
              }

              return Center(
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4.0,
                  child: CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.contain,
                    placeholder: (context, _) => const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white70,
                      ),
                    ),
                    errorWidget: (context, _, error) => Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.broken_image_rounded,
                          color: Colors.white60,
                          size: 64,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Impossible de charger l\'image'.tr,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // Header Overlay (Title, Counter, Close)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isVideo ? Icons.videocam_rounded : Icons.image_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.urls.length > 1
                            ? '${_currentIndex + 1} / ${widget.urls.length}'
                            : (widget.title ?? (isVideo ? 'Vidéo'.tr : 'Image'.tr)),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Standalone video player component with modern playback controls
class AppVideoPlayer extends StatefulWidget {
  final String url;
  final bool autoPlay;

  const AppVideoPlayer({
    super.key,
    required this.url,
    this.autoPlay = true,
  });

  @override
  State<AppVideoPlayer> createState() => _AppVideoPlayerState();
}

class _AppVideoPlayerState extends State<AppVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  String _errorMessage = '';
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    final cleanUrl = ApiConfig.resolveMediaUrl(widget.url);
    try {
      final uri = Uri.parse(cleanUrl);
      _controller = VideoPlayerController.networkUrl(uri);
      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        if (widget.autoPlay) {
          _controller!.play();
        }
        _controller!.addListener(_onVideoChanged);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _onVideoChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.removeListener(_onVideoChanged);
    _controller?.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48),
            const SizedBox(height: 12),
            Text(
              'Erreur de lecture vidéo'.tr,
              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              _errorMessage,
              style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _isInitialized = false;
                });
                _initializePlayer();
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text('Réessayer'.tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (!_isInitialized || _controller == null) {
      return const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 12),
          Text(
            'Chargement de la vidéo...',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      );
    }

    final isPlaying = _controller!.value.isPlaying;
    final position = _controller!.value.position;
    final duration = _controller!.value.duration;
    final isFinished = position >= duration && duration > Duration.zero;

    return GestureDetector(
      onTap: () {
        setState(() => _showControls = !_showControls);
      },
      child: AspectRatio(
        aspectRatio: _controller!.value.aspectRatio > 0
            ? _controller!.value.aspectRatio
            : 16 / 9,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Video Frame
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: VideoPlayer(_controller!),
            ),

            // Center Play/Pause/Replay Button
            if (_showControls || !isPlaying || isFinished)
              GestureDetector(
                onTap: () {
                  if (isFinished) {
                    _controller!.seekTo(Duration.zero);
                    _controller!.play();
                  } else if (isPlaying) {
                    _controller!.pause();
                  } else {
                    _controller!.play();
                  }
                  setState(() {});
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white38, width: 1.5),
                  ),
                  child: Icon(
                    isFinished
                        ? Icons.replay_rounded
                        : (isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
                    color: Colors.white,
                    size: 38,
                  ),
                ),
              ),

            // Bottom Controls Bar
            if (_showControls)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Scrubber
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 3,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                          activeTrackColor: AppColors.primary,
                          inactiveTrackColor: Colors.white24,
                          thumbColor: Colors.white,
                        ),
                        child: Slider(
                          value: position.inMilliseconds
                              .clamp(0, duration.inMilliseconds)
                              .toDouble(),
                          min: 0,
                          max: duration.inMilliseconds > 0
                              ? duration.inMilliseconds.toDouble()
                              : 1,
                          onChanged: (val) {
                            _controller!.seekTo(Duration(milliseconds: val.toInt()));
                          },
                        ),
                      ),
                      // Time indicator & Mute
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_formatDuration(position)} / ${_formatDuration(duration)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  final isMuted = _controller!.value.volume == 0;
                                  _controller!.setVolume(isMuted ? 1.0 : 0.0);
                                  setState(() {});
                                },
                                child: Icon(
                                  _controller!.value.volume == 0
                                      ? Icons.volume_off_rounded
                                      : Icons.volume_up_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A versatile thumbnail widget for previewing images or videos in grids/lists.
/// Supports video badges, play icons, and tap-to-view fullscreen modal.
class AppMediaThumbnail extends StatelessWidget {
  final String url;
  final double width;
  final double height;
  final double borderRadius;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;
  final List<String>? allUrls;
  final int index;

  const AppMediaThumbnail({
    super.key,
    required this.url,
    this.width = 80,
    this.height = 80,
    this.borderRadius = 12,
    this.onDelete,
    this.onTap,
    this.allUrls,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    final cleanUrl = ApiConfig.resolveMediaUrl(url);
    final isVideo = ApiConfig.isVideoUrl(cleanUrl);

    return Stack(
      children: [
        GestureDetector(
          onTap: onTap ??
              () {
                if (allUrls != null && allUrls!.isNotEmpty) {
                  AppMediaViewer.showGallery(
                    context,
                    urls: allUrls!,
                    initialIndex: index,
                  );
                } else {
                  AppMediaViewer.show(context, url: cleanUrl);
                }
              },
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              color: isVideo ? const Color(0xFF1E293B) : AppColors.fieldBackground,
              border: Border.all(
                color: isVideo ? AppColors.primary.withValues(alpha: 0.3) : AppColors.border,
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: isVideo
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        // Video decorative background
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF0F172A),
                                Color(0xFF1E293B),
                                Color(0xFF334155),
                              ],
                            ),
                          ),
                        ),
                        // Play badge icon
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.85),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        // Bottom Video Tag
                        Positioned(
                          bottom: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.videocam_rounded,
                                  color: Colors.white,
                                  size: 10,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  'VIDÉO'.tr,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : CachedNetworkImage(
                      imageUrl: cleanUrl,
                      width: width,
                      height: height,
                      fit: BoxFit.cover,
                      placeholder: (context, _) => Container(
                        color: AppColors.fieldBackground,
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (context, _, error) => Container(
                        color: AppColors.fieldBackground,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image_outlined,
                              size: 22,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        ),

        // Delete badge if edit mode
        if (onDelete != null)
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
