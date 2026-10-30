import 'package:flutter/material.dart';

/// Bottom Control Bar for Live Broadcast screen
/// Features:
/// - Clean, modern message input field that dynamically expands to full width when focused/typing
/// - Unwanted black container completely removed (filled: false, transparent decoration)
/// - Perfectly aligned, prominent Send icon button (magenta/purple gradient)
/// - Emoji button with asset emojis support
/// - Sleek, decreased-size action buttons (30x30) with 14px icons matching live aesthetics
/// - Single dynamic microphone button (Green when unmuted/speaking, Red when muted)
/// - Gifts button with asset gifts support
/// - Sound toggle button
/// - Room tools & options button
/// - Safe responsive layout for all screen sizes without overflow
class BroadcastBottomToolbar extends StatefulWidget {
  final TextEditingController textController;
  final bool isAudioMode;
  final bool isMuted;
  final bool isSoundOn;
  final VoidCallback onSendMessage;
  final VoidCallback onEmojiTap;
  final VoidCallback onMicToggle;
  final VoidCallback onGiftsTap;
  final VoidCallback onSoundToggle;
  final VoidCallback onMoreTap;

  // Optional backward compatibility parameters
  final bool? isMicActive;
  final VoidCallback? onMuteToggle;

  const BroadcastBottomToolbar({
    super.key,
    required this.textController,
    required this.isAudioMode,
    this.isMuted = false,
    this.isSoundOn = true,
    required this.onSendMessage,
    required this.onEmojiTap,
    required this.onMicToggle,
    required this.onGiftsTap,
    required this.onSoundToggle,
    required this.onMoreTap,
    this.isMicActive,
    this.onMuteToggle,
  });

  @override
  State<BroadcastBottomToolbar> createState() => _BroadcastBottomToolbarState();
}

class _BroadcastBottomToolbarState extends State<BroadcastBottomToolbar> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (mounted) setState(() {});
    });
    widget.textController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.textController.removeListener(_onTextChanged);
    _focusNode.dispose();
    super.dispose();
  }

  bool get _effectivelyMuted {
    if (widget.isMicActive != null) {
      return !widget.isMicActive!;
    }
    return widget.isMuted;
  }

  @override
  Widget build(BuildContext context) {
    final muted = _effectivelyMuted;
    final isExpanded = _focusNode.hasFocus || widget.textController.text.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0B1C).withValues(alpha: 0.96),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
            width: 0.8,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── 1. Message Input Box: Expands dynamically when tapped/typing ──
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                height: 42,
                padding: const EdgeInsets.only(left: 10, right: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1633),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isExpanded
                        ? const Color(0xFFFF1493).withValues(alpha: 0.6)
                        : Colors.white.withValues(alpha: 0.18),
                    width: isExpanded ? 1.4 : 1.0,
                  ),
                  boxShadow: isExpanded
                      ? [
                          BoxShadow(
                            color: const Color(0xFFFF1493).withValues(alpha: 0.2),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: Colors.white54,
                      size: 15,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: TextField(
                        controller: widget.textController,
                        focusNode: _focusNode,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                        cursorColor: const Color(0xFFFF1493),
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) {
                          widget.onSendMessage();
                          _focusNode.unfocus();
                        },
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(
                            color: Colors.white38,
                            fontSize: 12,
                          ),
                          filled: false,
                          fillColor: Colors.transparent,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                        ),
                      ),
                    ),
                    // Emoji Picker Button
                    InkWell(
                      onTap: widget.onEmojiTap,
                      borderRadius: BorderRadius.circular(16),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.sentiment_satisfied_alt_rounded,
                          color: Colors.white70,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Send Button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          widget.onSendMessage();
                          _focusNode.unfocus();
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF1493), Color(0xFF8A2BE2)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF1493).withValues(alpha: 0.4),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                    // If expanded, show an optional collapse unfocus check/close icon
                    if (isExpanded) ...[
                      const SizedBox(width: 2),
                      InkWell(
                        onTap: () => _focusNode.unfocus(),
                        borderRadius: BorderRadius.circular(12),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.keyboard_hide_rounded,
                            color: Colors.white38,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // ── 2. Compact Decreased Size Action Icons (hidden smoothly while typing to expand input) ──
            if (!isExpanded) ...[
              const SizedBox(width: 5),

              // Mic Button
              Tooltip(
                message: muted ? 'Unmute Microphone' : 'Mute Microphone',
                child: _buildCircleButton(
                  icon: muted ? Icons.mic_off_rounded : Icons.mic_rounded,
                  bgColor: muted ? const Color(0xFF2A0E18) : const Color(0xFF0E2A1C),
                  borderColor: muted ? const Color(0xFFFF1744) : const Color(0xFF00E676),
                  glowColor: muted ? const Color(0xFFFF1744) : const Color(0xFF00E676),
                  iconColor: muted ? const Color(0xFFFF5252) : const Color(0xFF00E676),
                  gradient: muted
                      ? const LinearGradient(
                          colors: [Color(0xFFD50000), Color(0xFFFF1744)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : const LinearGradient(
                          colors: [Color(0xFF00C853), Color(0xFF00E676)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  onTap: widget.onMuteToggle ?? widget.onMicToggle,
                ),
              ),
              const SizedBox(width: 4),

              // Gifts Button
              Tooltip(
                message: 'Send Gifts',
                child: _buildCircleButton(
                  icon: Icons.card_giftcard_rounded,
                  glowColor: const Color(0xFFFF1493),
                  borderColor: const Color(0xFFFF1493),
                  iconColor: Colors.white,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF1493), Color(0xFFC2185B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap: widget.onGiftsTap,
                ),
              ),
              const SizedBox(width: 4),

              // Sound Toggle Button
              Tooltip(
                message: widget.isSoundOn ? 'Sound On' : 'Sound Off',
                child: _buildCircleButton(
                  icon: widget.isSoundOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                  glowColor: const Color(0xFF00BFFF),
                  borderColor: const Color(0xFF00BFFF),
                  iconColor: Colors.white,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E88E5), Color(0xFF00BFFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap: widget.onSoundToggle,
                ),
              ),
              const SizedBox(width: 4),

              // More Options Button
              Tooltip(
                message: 'Room Tools & Options',
                child: _buildCircleButton(
                  icon: Icons.more_horiz_rounded,
                  glowColor: Colors.transparent,
                  borderColor: Colors.white24,
                  iconColor: Colors.white70,
                  bgColor: const Color(0xFF1F1A3A),
                  onTap: widget.onMoreTap,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required Color glowColor,
    required Color borderColor,
    required Color iconColor,
    Color? bgColor,
    LinearGradient? gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 31,
        height: 31,
        decoration: BoxDecoration(
          color: bgColor,
          gradient: gradient,
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: 1.0),
          boxShadow: glowColor != Colors.transparent
              ? [
                  BoxShadow(
                    color: glowColor.withValues(alpha: 0.35),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 15,
        ),
      ),
    );
  }
}
