import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcards/data/remote/cloud_function_service.dart';
import 'package:flashcards/data/utils/image_compression.dart';
import 'package:flashcards/utils/firebase_error_mapper.dart';
import 'package:flutter/material.dart';

/// The signed-in user's profile photo, kept on their account so it shows
/// on every device.
final profilePhotoUrl = ValueNotifier<String?>(
  FirebaseAuth.instance.currentUser?.photoURL,
);

/// The user's photo (or an icon when there is none). With [editable], a tap
/// lets them choose a new photo or remove it.
class ProfileAvatar extends StatefulWidget {
  final double size;
  final bool editable;
  final Color? iconColor;

  const ProfileAvatar({
    super.key,
    this.size = 80,
    this.editable = false,
    this.iconColor,
  });

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // Another user may have signed in since the app started.
    profilePhotoUrl.value = FirebaseAuth.instance.currentUser?.photoURL;
  }

  Future<void> _choose() async {
    final hasPhoto = profilePhotoUrl.value != null;
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(hasPhoto ? 'Change photo' : 'Add a profile photo'),
              onTap: () => Navigator.of(context).pop('pick'),
            ),
            if (hasPhoto)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Remove photo'),
                onTap: () => Navigator.of(context).pop('remove'),
              ),
          ],
        ),
      ),
    );
    if (action == null || !mounted) return;

    String? base64;
    if (action == 'pick') {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );
      final bytes = picked?.files.single.bytes;
      if (bytes == null || !mounted) return;
      setState(() => _saving = true);
      final jpeg = await prepareJpeg(bytes, maxSide: 512);
      if (jpeg == null) {
        _show("This image couldn't be read. Try another one.");
        setState(() => _saving = false);
        return;
      }
      base64 = base64Encode(jpeg);
    }

    setState(() => _saving = true);
    try {
      final url = await CloudFunctionService().setProfilePhoto(base64);
      await FirebaseAuth.instance.currentUser?.reload();
      profilePhotoUrl.value = url;
      _show(url == null ? 'Photo removed.' : 'Profile photo updated.');
    } on Exception catch (error) {
      _show("Couldn't save the photo: ${extractErrorMessage(error)}");
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _show(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final iconColor = widget.iconColor ?? Theme.of(context).colorScheme.primary;
    final avatar = ValueListenableBuilder<String?>(
      valueListenable: profilePhotoUrl,
      builder: (context, url, _) {
        final fallback = Icon(
          Icons.account_circle,
          size: size,
          color: iconColor,
        );
        if (url == null) return fallback;
        return ClipOval(
          child: Image.network(
            url,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => fallback,
          ),
        );
      },
    );

    if (!widget.editable) return avatar;
    return Semantics(
      button: true,
      label: 'Change profile photo',
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: _saving ? null : _choose,
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            children: [
              avatar,
              if (_saving)
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.black38,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(color: Colors.white),
                  ),
                ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(
                    Icons.photo_camera,
                    size: size * 0.18,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
