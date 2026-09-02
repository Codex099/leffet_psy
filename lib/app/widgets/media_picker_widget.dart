import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../services/upload_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_media_viewer.dart';

enum MediaPickerSourceType {
  cameraPhoto,
  cameraVideo,
  galleryPhoto,
  galleryVideo,
}

class MediaPickerWidget extends StatefulWidget {
  final List<String> initialMediaUrls;
  final ValueChanged<List<String>> onMediasChanged;
  final bool allowVideos;

  const MediaPickerWidget({
    super.key,
    this.initialMediaUrls = const [],
    required this.onMediasChanged,
    this.allowVideos = true,
  });

  @override
  State<MediaPickerWidget> createState() => _MediaPickerWidgetState();
}

class _MediaPickerWidgetState extends State<MediaPickerWidget> {
  final ImagePicker _picker = ImagePicker();
  final UploadService _uploadService = UploadService();
  late List<String> _mediaUrls;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String _uploadStatusText = '';

  @override
  void initState() {
    super.initState();
    _mediaUrls = List.from(widget.initialMediaUrls);
  }

  @override
  void didUpdateWidget(covariant MediaPickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialMediaUrls != widget.initialMediaUrls) {
      _mediaUrls = List.from(widget.initialMediaUrls);
    }
  }

  Future<void> _pickAndUpload(MediaPickerSourceType type) async {
    try {
      XFile? file;
      switch (type) {
        case MediaPickerSourceType.cameraPhoto:
          file = await _picker.pickImage(
            source: ImageSource.camera,
            imageQuality: 85,
          );
          break;
        case MediaPickerSourceType.cameraVideo:
          file = await _picker.pickVideo(
            source: ImageSource.camera,
            maxDuration: const Duration(minutes: 10),
          );
          break;
        case MediaPickerSourceType.galleryPhoto:
          file = await _picker.pickImage(
            source: ImageSource.gallery,
            imageQuality: 85,
          );
          break;
        case MediaPickerSourceType.galleryVideo:
          file = await _picker.pickVideo(
            source: ImageSource.gallery,
          );
          break;
      }

      if (file == null) return;

      setState(() {
        _isUploading = true;
        _uploadProgress = 0.0;
        _uploadStatusText = type == MediaPickerSourceType.cameraVideo ||
                type == MediaPickerSourceType.galleryVideo
            ? 'Envoi de la vidéo en cours...'.tr
            : 'Envoi de l\'image en cours...'.tr;
      });

      final url = await _uploadService.uploadFile(
        File(file.path),
        onSendProgress: (count, total) {
          if (total > 0 && mounted) {
            setState(() {
              _uploadProgress = count / total;
            });
          }
        },
      );

      setState(() {
        _mediaUrls.add(url);
      });
      widget.onMediasChanged(_mediaUrls);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text('Média ajouté avec succès'.tr),
              ],
            ),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${'Erreur lors de l\'upload'.tr} : $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadProgress = 0.0;
          _uploadStatusText = '';
        });
      }
    }
  }

  void _showGallerySelectionModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choisir depuis la galerie'.tr,
                  style: AppTextStyles.sectionTitle,
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.photo_rounded, color: AppColors.primary),
                  ),
                  title: Text('Photo'.tr, style: AppTextStyles.bodyMedium),
                  subtitle: Text('Sélectionner une image'.tr, style: AppTextStyles.bodySmall),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickAndUpload(MediaPickerSourceType.galleryPhoto);
                  },
                ),
                if (widget.allowVideos) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.video_library_rounded, color: AppColors.secondary),
                    ),
                    title: Text('Vidéo'.tr, style: AppTextStyles.bodyMedium),
                    subtitle: Text('Sélectionner un enregistrement vidéo'.tr, style: AppTextStyles.bodySmall),
                    onTap: () {
                      Navigator.pop(ctx);
                      _pickAndUpload(MediaPickerSourceType.galleryVideo);
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _removeMedia(int index) {
    setState(() {
      _mediaUrls.removeAt(index);
    });
    widget.onMediasChanged(_mediaUrls);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Action Buttons Row
        Row(
          children: [
            // 1. Photo Camera
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isUploading
                    ? null
                    : () => _pickAndUpload(MediaPickerSourceType.cameraPhoto),
                icon: const Icon(Icons.camera_alt_rounded, size: 18),
                label: Text(
                  'Photo'.tr,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 42),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            if (widget.allowVideos) ...[
              const SizedBox(width: 8),
              // 2. Video Record
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isUploading
                      ? null
                      : () => _pickAndUpload(MediaPickerSourceType.cameraVideo),
                  icon: const Icon(Icons.videocam_rounded, size: 18),
                  label: Text(
                    'Vidéo'.tr,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F766E),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 42),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
            const SizedBox(width: 8),
            // 3. Gallery Modal (Photo or Video)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isUploading ? null : _showGallerySelectionModal,
                icon: const Icon(Icons.photo_library_rounded, size: 18),
                label: Text(
                  'Galerie'.tr,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryLight,
                  foregroundColor: AppColors.primary,
                  minimumSize: const Size(0, 42),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),

        // Uploading Progress Indicator
        if (_isUploading) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _uploadStatusText.isNotEmpty
                          ? _uploadStatusText
                          : 'Téléversement en cours...'.tr,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (_uploadProgress > 0)
                      Text(
                        '${(_uploadProgress * 100).toInt()}%',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: _uploadProgress > 0
                      ? LinearProgressIndicator(
                          value: _uploadProgress,
                          backgroundColor: AppColors.border,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                          minHeight: 4,
                        )
                      : const LinearProgressIndicator(
                          backgroundColor: AppColors.border,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                          minHeight: 4,
                        ),
                ),
              ],
            ),
          ),
        ],

        // Media Thumbnails List
        if (_mediaUrls.isNotEmpty) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 84,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _mediaUrls.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return AppMediaThumbnail(
                  url: _mediaUrls[index],
                  width: 84,
                  height: 84,
                  allUrls: _mediaUrls,
                  index: index,
                  onDelete: () => _removeMedia(index),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
