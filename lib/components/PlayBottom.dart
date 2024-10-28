import 'package:flutter/material.dart';

class PlaybackControlBar extends StatelessWidget {
  final Function onPlayPausePressed;
  final bool isPlaying;

  PlaybackControlBar({
    required this.onPlayPausePressed,
    required this.isPlaying,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
            onPressed: () => onPlayPausePressed(),
          ),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// class PlaybackControlBar extends StatelessWidget {
//   final Function onPlayPausePressed;
//   final bool isPlaying;
//   final double sliderValue;
//   final Function(double) onSliderChanged;
//   final double maxSliderValue;

//   PlaybackControlBar({
//     required this.onPlayPausePressed,
//     required this.isPlaying,
//     required this.sliderValue,
//     required this.onSliderChanged,
//     required this.maxSliderValue,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(0),
//       decoration: BoxDecoration(
//         color: Colors.white,
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           IconButton(
//             icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
//             onPressed: () => onPlayPausePressed(),
//           ),
//           Expanded(
//             child: Slider(
//               value: sliderValue,
//               min: 0,
//               max: maxSliderValue,
//               onChanged: onSliderChanged,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
