import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CustomVideoPlayerController extends StatefulWidget {
  final ChewieController chewieController;
  const CustomVideoPlayerController({super.key, required this.chewieController});

  @override
  State<CustomVideoPlayerController> createState() => _CustomControlsState();
}

class _CustomControlsState extends State<CustomVideoPlayerController> {
  VideoPlayerController get controller =>
      widget.chewieController.videoPlayerController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Seekbar + thời gian
        ValueListenableBuilder(
          valueListenable: controller,
          builder: (context, VideoPlayerValue value, child) {
            final duration = value.duration;
            final position = value.position;

            return Column(
              children: [
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 7,
                    ),
                    overlayShape: SliderComponentShape.noOverlay,
                    activeTrackColor: theme.colorScheme.onPrimary,
                    inactiveTrackColor:
                    theme.colorScheme.onSurface.withOpacity(0.3),
                    thumbColor: theme.colorScheme.onPrimary,
                  ),
                  child: Slider(
                    min: 0,
                    max: duration.inMilliseconds.toDouble(),
                    value: position.inMilliseconds.clamp(
                      0,
                      duration.inMilliseconds,
                    ).toDouble(),
                    onChanged: (value) {
                      controller
                          .seekTo(Duration(milliseconds: value.toInt()));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatDuration(position),
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontSize: 12,
                          )),
                      Text(_formatDuration(duration),
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontSize: 12,
                          )),
                    ],
                  ),
                ),
              ],
            );
          },
        ),

        // Play / Pause
        IconButton(
          icon: Icon(
            controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
            color: Colors.white,
            size: 32,
          ),
          onPressed: () {
            controller.value.isPlaying
                ? controller.pause()
                : controller.play();
          },
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return "${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}";
    } else {
      return "${twoDigits(minutes)}:${twoDigits(seconds)}";
    }
  }
}
