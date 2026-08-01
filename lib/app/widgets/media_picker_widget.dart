import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/upload_service.dart';
import '../theme/app_colors.dart';


class MediaPickerWidget extends StatefulWidget {
  final List<String> initialMediaUrls;
  final ValueChanged<List<String>> onMediasChanged;

  const MediaPickerWidget({
    super.key,
    this.initialMediaUrls = const [],
    required this.onMediasChanged,
  });

  @override
  State<MediaPickerWidget> createState() => _MediaPickerWidgetState();
}

class _MediaPickerWidgetState extends State<MediaPickerWidget> {
  final ImagePicker _picker = ImagePicker();
  final UploadService _uploadService = UploadService();
  late List<String> _mediaUrls;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _mediaUrls = List.from(widget.initialMediaUrls);
  }

  Future<void> _pickAndUpload(ImageSource source) async {
    final XFile? file = await _picker.pickImage(source: source);
    if (file == null) return;

    setState(() => _isUploading = true);

    try {
      final url = await _uploadService.uploadFile(File(file.path));
      setState(() {
        _mediaUrls.add(url);
      });
      widget.onMediasChanged(_mediaUrls);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'upload : $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
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
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isUploading ? null : () => _pickAndUpload(ImageSource.camera),
                icon: const Icon(Icons.camera_alt_rounded),
                label: const Text('Prendre une photo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 44),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isUploading ? null : () => _pickAndUpload(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_rounded),
                label: const Text('Galerie'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryLight,
                  foregroundColor: AppColors.primary,
                  minimumSize: const Size(0, 44),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_isUploading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: LinearProgressIndicator(),
          ),
        if (_mediaUrls.isNotEmpty)
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _mediaUrls.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: NetworkImage(_mediaUrls[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 12,
                      child: GestureDetector(
                        onTap: () => _removeMedia(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.delete_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
      ],
    );
  }
}
