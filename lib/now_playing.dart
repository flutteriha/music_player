import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class NowPlaying extends StatefulWidget {
  NowPlaying({
    Key? key,
    required this.listMusic,
    required this.index,
  }) : super(key: key);

  final List listMusic;
  int index;

  @override
  State<NowPlaying> createState() => _NowPlayingState();
}

class _NowPlayingState extends State<NowPlaying> {
  final _audioPlayer = AudioPlayer();
  String? musicName;
  String? artistName;
  Duration _duration = const Duration();
  Duration _position = const Duration();
  bool _loop = false;
  double volume = 1.0;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    playMusic(widget.index);
  }

  void playMusic(int index) {
    try {
      _audioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.parse(widget.listMusic[index].uri),
        ),
      );
      musicName = widget.listMusic[index].displayNameWOExt;
      artistName = widget.listMusic[index].artist;
      _audioPlayer.play();
      _isPlaying = true;
    } catch (e) {
      print('Exception');
    }
    _audioPlayer.durationStream.listen((d) {
      setState(() {
        _duration = d!;
      });
    });
    _audioPlayer.positionStream.listen((p) {
      setState(() {
        _position = p;
      });
    });
  }

  void changeToSeconds(int seconds) {
    Duration duration = Duration(seconds: seconds);
    _audioPlayer.seek(duration);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Now Playing',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.purple,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const SizedBox(height: 25.0),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 50.0),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 2.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.purple.withOpacity(0.7),
                  Colors.purple,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: const Center(
              child: Icon(
                Icons.music_note,
                color: Colors.white,
                size: 100.0,
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 50.0, vertical: 10.0),
            child: AutoSizeText(
              musicName!,
              style: const TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 80.0),
            child: AutoSizeText(
              artistName!,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
            child: Row(
              children: [
                Text(
                  _position.toString().split('.')[0],
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.purple,
                      inactiveTrackColor: Colors.grey,
                      thumbColor: Colors.purple,
                      overlayColor: Colors.purple[100],
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 10.0),
                    ),
                    child: Slider(
                      value: _position.inSeconds.toDouble(),
                      min: const Duration(microseconds: 0).inSeconds.toDouble(),
                      max: _duration.inSeconds.toDouble(),
                      onChanged: (value) {
                        setState(() {
                          changeToSeconds(value.toInt());
                          value = value;
                        });
                      },
                    ),
                  ),
                ),
                Text(
                  _duration.toString().split('.')[0],
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _loop
                        ? _audioPlayer.setLoopMode(LoopMode.off)
                        : _audioPlayer.setLoopMode(LoopMode.one);
                    _loop = !_loop;
                  });
                },
                icon: Icon(_loop ? Icons.repeat_one : Icons.repeat),
                iconSize: 30.0,
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    if (widget.index != -1) {
                      playMusic(widget.index--);
                    } else {
                      playMusic(widget.index = widget.listMusic.length - 1);
                    }
                  });
                },
                icon: Icon(Icons.skip_previous),
                iconSize: 30.0,
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _isPlaying ? _audioPlayer.pause() : _audioPlayer.play();
                    _isPlaying = !_isPlaying;
                  });
                },
                icon: Icon(_isPlaying ? Icons.pause_circle : Icons.play_circle),
                iconSize: 70.0,
                color: Colors.purple,
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    if (widget.index != widget.listMusic.length) {
                      playMusic(widget.index++);
                    } else {
                      playMusic(widget.index = 0);
                    }
                  });
                },
                icon: const Icon(Icons.skip_next),
                iconSize: 30.0,
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    if (volume == 1.0) {
                      _audioPlayer.setVolume(0.0);
                      volume = 0.0;
                    } else {
                      _audioPlayer.setVolume(1.0);
                      volume = 1.0;
                    }
                  });
                },
                icon: Icon(volume == 1.0 ? Icons.volume_up : Icons.volume_off),
                iconSize: 30.0,
              ),
            ],
          ),
          const SizedBox(height: 25.0),
        ],
      ),
    );
  }
}
