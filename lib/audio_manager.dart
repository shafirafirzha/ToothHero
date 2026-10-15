import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  AudioManager._();

  static final AudioManager instance = AudioManager._();

  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _clickPlayer = AudioPlayer();

  double _bgmVolume = 0.35;
  double _sfxVolume = 0.7;

  bool _bgmStarted = false;
  bool _muted = false;

  double get bgmVolume => _bgmVolume;
  double get sfxVolume => _sfxVolume;
  bool get isMuted => _muted;

  // ================= MUSIK LATAR =================

  Future<void> playBgm() async {
    if (_muted || _bgmStarted) return;

    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgmPlayer.setVolume(_bgmVolume);

    _bgmStarted = true;

    await _bgmPlayer.play(AssetSource('audio/bgm.mp3'));
  }

  Future<void> setBgmVolume(double volume) async {
    _bgmVolume = volume.clamp(0.0, 1.0);

    await _bgmPlayer.setVolume(_bgmVolume);

    if (_muted) return;

    if (_bgmVolume == 0) {
      await _bgmPlayer.pause();
    } else if (_bgmStarted) {
      await _bgmPlayer.resume();
    }
  }

  // ================= EFEK SUARA =================

  Future<void> playClick() async {
    if (_muted || _sfxVolume <= 0) return;

    await _clickPlayer.stop();
    await _clickPlayer.setVolume(_sfxVolume);

    await _clickPlayer.play(AssetSource('audio/button_click.mp3'));
  }

  Future<void> setSfxVolume(double volume) async {
    _sfxVolume = volume.clamp(0.0, 1.0);
  }

  // ================= MUTE =================

  Future<void> toggleMute() async {
    _muted = !_muted;

    if (_muted) {
      await _bgmPlayer.pause();
      await _clickPlayer.stop();
    } else if (_bgmStarted) {
      if (_bgmVolume > 0) {
        await _bgmPlayer.resume();
      }
    } else {
      await playBgm();
    }
  }
}

// ==================================================
// TOMBOL DENGAN EFEK SUARA OTOMATIS
// ==================================================

class AudioButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;

  const AudioButton({super.key, required this.child, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        AudioManager.instance.playClick();
        onPressed();
      },
      child: child,
    );
  }
}
