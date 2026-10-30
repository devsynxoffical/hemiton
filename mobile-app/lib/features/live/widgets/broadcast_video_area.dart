import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../../../../models/live_room_model.dart';

/// Main Video Area for Video Live Broadcast Screen
/// Features:
/// - Prominent rectangular live camera feed with rounded corners
/// - Real CameraPreview when initialized, with graceful fallback for emulator/permission
/// - Floating Picture-in-Picture "Video Preview" tile in bottom-right corner
/// - Interactive expand/collapse and camera flip controls
class BroadcastVideoArea extends StatefulWidget {
  final LiveRoomModel room;
  final CameraController? cameraController;
  final bool isCameraInitialized;
  final VoidCallback? onSwitchCamera;
  final VoidCallback? onTogglePreview;

  const BroadcastVideoArea({
    super.key,
    required this.room,
    this.cameraController,
    this.isCameraInitialized = false,
    this.onSwitchCamera,
    this.onTogglePreview,
  });

  @override
  State<BroadcastVideoArea> createState() => _BroadcastVideoAreaState();
}

class _BroadcastVideoAreaState extends State<BroadcastVideoArea> {
  bool _isPipExpanded = false;

  @override
  Widget build(BuildContext context) {
    final hostAvatar = widget.room.host.avatarUrl.isNotEmpty
        ? widget.room.host.avatarUrl
        : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=600&q=80';

    return Container(
      width: double.infinity,
      height: 205,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF140F26),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF8A2BE2).withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8A2BE2).withValues(alpha: 0.25),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            // ── 1. Main Video Stream Feed ──
            Positioned.fill(
              child: _buildCameraFeed(hostAvatar),
            ),

            // Subtle dark gradient vignette for text readability
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.2),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.4),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // ── 2. Floating Picture-in-Picture "Video Preview" Tile (Bottom Right) ──
            Positioned(
              right: 10,
              bottom: 10,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isPipExpanded = !_isPipExpanded;
                  });
                  widget.onTogglePreview?.call();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  width: _isPipExpanded ? 136 : 108,
                  height: _isPipExpanded ? 80 : 58,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F0B1E),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.6),
                      width: 1.1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.7),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(9),
                    child: Stack(
                      children: [
                        // PiP content (miniature host image or camera feed)
                        Positioned.fill(
                          child: widget.isCameraInitialized &&
                                  widget.cameraController != null &&
                                  widget.cameraController!.value.isInitialized
                              ? FittedBox(
                                  fit: BoxFit.cover,
                                  child: SizedBox(
                                    width: 100,
                                    height: 100 / widget.cameraController!.value.aspectRatio,
                                    child: CameraPreview(widget.cameraController!),
                                  ),
                                )
                              : Image.network(
                                  hostAvatar,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: const Color(0xFF1E143B),
                                    child: const Icon(
                                      Icons.person,
                                      color: Colors.white60,
                                      size: 20,
                                    ),
                                  ),
                                ),
                        ),

                        // PiP Label Bar ("📹 Video Preview" + Expand icon)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            color: Colors.black.withValues(alpha: 0.75),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.videocam_rounded,
                                  color: Colors.white,
                                  size: 9,
                                ),
                                SizedBox(width: 2),
                                Flexible(
                                  child: Text(
                                    'Video Preview',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Expand / Collapse icon in top right
                        Positioned(
                          top: 3,
                          right: 3,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isPipExpanded
                                  ? Icons.close_fullscreen_rounded
                                  : Icons.open_in_full_rounded,
                              color: Colors.white,
                              size: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Camera Flip button if available
            if (widget.onSwitchCamera != null)
              Positioned(
                top: 8,
                right: 8,
                child: InkWell(
                  onTap: widget.onSwitchCamera,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: const Icon(
                      Icons.cameraswitch_rounded,
                      color: Colors.white,
                      size: 15,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraFeed(String hostAvatar) {
    if (widget.isCameraInitialized &&
        widget.cameraController != null &&
        widget.cameraController!.value.isInitialized) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final cameraRatio = widget.cameraController!.value.aspectRatio;
          final previewRatio = 1 / cameraRatio;

          return SizedOverflowBox(
            size: Size(constraints.maxWidth, constraints.maxHeight),
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxWidth / previewRatio,
                child: CameraPreview(widget.cameraController!),
              ),
            ),
          );
        },
      );
    }

    // High quality live stream simulation feed (when camera permission is pending or in simulator)
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          hostAvatar,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: const Color(0xFF140F26),
            child: const Center(
              child: Icon(Icons.videocam_rounded, size: 48, color: Color(0xFF8A2BE2)),
            ),
          ),
        ),
      ],
    );
  }
}
