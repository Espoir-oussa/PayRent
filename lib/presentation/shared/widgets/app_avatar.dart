// Widget avatar réutilisable avec support d'image et upload
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../config/colors.dart';
import '../../../core/services/appwrite_service.dart';
import '../../../core/services/image_upload_service.dart';
import 'image_picker_bottom_sheet.dart';

class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? initials;
  final double radius;
  final VoidCallback? onTap;
  final bool showEditButton;
  final bool isLoading;

  const AppAvatar({
    super.key,
    this.imageUrl,
    this.initials,
    this.radius = 50,
    this.onTap,
    this.showEditButton = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: onTap,
          child: CircleAvatar(
            radius: radius,
            backgroundColor: AppColors.accentRed.withOpacity(0.1),
            backgroundImage: _hasValidImage ? NetworkImage(imageUrl!) : null,
            onBackgroundImageError: _hasValidImage
                ? (_, __) {
                    debugPrint('Erreur chargement image avatar');
                  }
                : null,
            child: _buildAvatarContent(),
          ),
        ),
        if (showEditButton)
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                padding: EdgeInsets.all(radius * 0.15),
                decoration: BoxDecoration(
                  color: AppColors.accentRed,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: radius * 0.35,
                ),
              ),
            ),
          ),
      ],
    );
  }

  bool get _hasValidImage => imageUrl != null && imageUrl!.isNotEmpty;

  Widget? _buildAvatarContent() {
    if (isLoading) {
      return SizedBox(
        width: radius,
        height: radius,
        child: const CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (_hasValidImage) {
      return null; // L'image de fond sera affichée
    }

    if (initials != null && initials!.isNotEmpty) {
      return Text(
        initials!.toUpperCase(),
        style: TextStyle(
          fontSize: radius * 0.6,
          fontWeight: FontWeight.bold,
          color: AppColors.accentRed,
        ),
      );
    }

    return Icon(
      Icons.person,
      size: radius * 0.8,
      color: AppColors.accentRed,
    );
  }
}

/// Widget avatar avec fonctionnalité d'upload intégrée
class AppAvatarUploader extends StatefulWidget {
  final String? initialImageUrl;
  final String? initials;
  final double radius;
  final String uploadFolder;
  final String? userId;
  final void Function(String imageUrl)? onImageUploaded;
  final void Function(String error)? onError;

  const AppAvatarUploader({
    super.key,
    this.initialImageUrl,
    this.initials,
    this.radius = 55,
    required this.uploadFolder,
    this.userId,
    this.onImageUploaded,
    this.onError,
  });

  @override
  State<AppAvatarUploader> createState() => _AppAvatarUploaderState();
}

class _AppAvatarUploaderState extends State<AppAvatarUploader> {
  final ImagePicker _imagePicker = ImagePicker();
  late ImageUploadService _uploadService;
  String? _imageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _imageUrl = widget.initialImageUrl;
    _uploadService = ImageUploadService(AppwriteService());
  }

  @override
  void didUpdateWidget(AppAvatarUploader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialImageUrl != widget.initialImageUrl) {
      _imageUrl = widget.initialImageUrl;
    }
  }

  Future<void> _pickAndUploadImage() async {
    final source = await showImagePickerBottomSheet(context);
    if (source == null) return;

    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedFile == null) return;

      setState(() => _isLoading = true);

      final imageUrl = await _uploadService.uploadImage(
        filePath: pickedFile.path,
        folder: widget.uploadFolder,
        userId: widget.userId,
      );

      setState(() {
        _imageUrl = imageUrl;
      });

      widget.onImageUploaded?.call(imageUrl);
    } catch (e) {
      debugPrint('Erreur upload: $e');
      widget.onError?.call(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppAvatar(
      imageUrl: _imageUrl,
      initials: widget.initials,
      radius: widget.radius,
      showEditButton: true,
      isLoading: _isLoading,
      onTap: _isLoading ? null : _pickAndUploadImage,
    );
  }
}
