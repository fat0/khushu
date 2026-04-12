A gentle notification tone (notification_tone.ogg) is needed for pre-adhan alerts.

Requirements:
- Short duration (2-3 seconds)
- Gentle, non-intrusive sound
- OGG or MP3 format
- Royalty-free / public domain

To generate one with ffmpeg (when available):
  ffmpeg -f lavfi -i "sine=frequency=440:duration=1.5" -af "afade=t=in:d=0.3,afade=t=out:st=1.0:d=0.5" -c:a libvorbis assets/audio/notification_tone.ogg
