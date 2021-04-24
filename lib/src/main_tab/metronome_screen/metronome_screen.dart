import 'package:audioplayers/audio_cache.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

enum MetronomeState { Playing, Stopped, Stopping }

class MetronomeControl extends StatefulWidget {
  MetronomeControl();
  MetronomeControlState createState() => new MetronomeControlState();
}

class MetronomeControlState extends State<MetronomeControl> {
  ScrollController _scrollController;
  final _maxRotationAngle = 0.26;
  final _minTempo = 30;
  final _maxTempo = 220;

  static AudioCache player = new AudioCache();
  String _clickAudioPath = "sounds/click.mp3";
  String _bellAudioPath = "sounds/bell.mp3";

  List<int> _tapTimes = List();

  int _tempo = 60;

  bool _bobPanning = false;

  MetronomeState _metronomeState = MetronomeState.Stopped;
  int _lastFrameTime = 0;
  Timer _tickTimer;
  Timer _frameTimer;
  int _lastEvenTick;
  bool _lastTickWasEven;
  int _tickInterval;

  int _compassTempo = 1;
  int _compassSize = 4;

  double _rotationAngle = 0;

  MetronomeControlState();

  @override
  void dispose() {
    _frameTimer?.cancel();
    _tickTimer?.cancel();
    super.dispose();
  }

  void _start() {
    _metronomeState = MetronomeState.Playing;

    double bps = _tempo / 60;
    _tickInterval = 1000 ~/ bps;
    _lastEvenTick = DateTime.now().millisecondsSinceEpoch;
    _tickTimer =
        new Timer.periodic(new Duration(milliseconds: _tickInterval), _onTick);
    _animationLoop();

    //SystemSound.play(SystemSoundType.click);
    player.play(_bellAudioPath);

    if (mounted) setState(() {});
  }

  void _animationLoop() {
    _frameTimer?.cancel();
    int thisFrameTime = DateTime.now().millisecondsSinceEpoch;

    if (_metronomeState == MetronomeState.Playing ||
        _metronomeState == MetronomeState.Stopping) {
      int delay =
          max(0, _lastFrameTime + 17 - DateTime.now().millisecondsSinceEpoch);
      _frameTimer = new Timer(new Duration(milliseconds: delay), () {
        _animationLoop();
      });
    } else {
      _rotationAngle = 0;
    }
    if (mounted) setState(() {});
    _lastFrameTime = thisFrameTime;
  }

  void _onTick(Timer t) {
    _lastTickWasEven = t.tick % 2 == 0;
    if (_lastTickWasEven) _lastEvenTick = DateTime.now().millisecondsSinceEpoch;

    setState(() {
      _compassTempo = _compassTempo < _compassSize ? _compassTempo + 1 : 1;
    });

    if (_metronomeState == MetronomeState.Playing) {
      //SystemSound.play(SystemSoundType.click);
      player.play(_compassTempo == 1 ? _bellAudioPath : _clickAudioPath);
      //print(SystemSoundType.values.length);
      // SystemSound.play(SystemSoundType.values[0]);
    } else if (_metronomeState == MetronomeState.Stopping) {
      _tickTimer?.cancel();
      _metronomeState = MetronomeState.Stopped;
      setState(() {
        _compassTempo = 1;
      });
    }
  }

  void _stop() {
    _metronomeState = MetronomeState.Stopping;
    if (mounted) setState(() {});
  }

  void _tap() {
    if (_metronomeState != MetronomeState.Stopped) return;
    int now = DateTime.now().millisecondsSinceEpoch;
    _tapTimes.add(now);
    if (_tapTimes.length > 3) {
      _tapTimes.removeAt(0);
    }
    int tapCount = 0;
    int tapIntervalSum = 0;

    for (int i = _tapTimes.length - 1; i >= 1; i--) {
      int currentTapTime = _tapTimes[i];
      int previousTapTime = _tapTimes[i - 1];
      int currentInterval = currentTapTime - previousTapTime;
      if (currentInterval > 3000) break;

      tapIntervalSum += currentInterval;
      tapCount++;
    }
    if (tapCount > 0) {
      int msBetweenTicks = tapIntervalSum ~/ tapCount;
      double bps = 1000 / msBetweenTicks;
      _tempo = min(max((bps * 60).toInt(), _minTempo), _maxTempo);
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: metronomeBody(context),
    );
    // return NestedScrollView(
    //   controller: _scrollController,
    //   headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
    //     return <Widget>[
    //       SliverAppBar(
    //         centerTitle: false,
    //         backgroundColor: Colors.white,
    //         elevation: 1,
    //         title: Text("Metrônomo",
    //             style: TextStyle(
    //               color: Colors.black,
    //               fontSize: 36,
    //             )),
    //         pinned: true,
    //         floating: true,
    //         forceElevated: innerBoxIsScrolled,
    //       )
    //     ];
    //   },
    //   body: metronomeBody(context),
    // );
  }

  Widget metronomeBody(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Theme.of(context).backgroundColor, Color(0xFF151619)]),
      ),
      // color: Theme.of(context).backgroundColor,
      // decoration: BoxDecoration(
      //   image: DecorationImage(
      //     image: AssetImage("assets/images/fundo-pedra.jpg"),
      //     fit: BoxFit.cover,
      //   ),
      // ),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 50,
          ),
          Container(
            width: double.infinity,
            child: Text(
              "BPM",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white60,
              ),
            ),
          ),
          bpmPanel(),
          Container(
            padding: const EdgeInsets.only(top: 0.0),
            width: double.infinity,
            color: Colors.transparent,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(),
                ),
                Container(
                  width: 80,
                  padding: EdgeInsets.only(left: 10, right: 10),
                  height: 1,
                  color: Colors.white60,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(MdiIcons.metronome, color: Colors.white60),
                ),
                Container(
                  width: 80,
                  padding: EdgeInsets.only(left: 10, right: 10),
                  height: 1,
                  color: Colors.white60,
                ),
                Expanded(
                  child: Container(),
                ),
              ],
            ),
            // child: Text(
            //   "Tempo",
            //   textAlign: TextAlign.center,
            //   style: TextStyle(
            //     fontSize: 30,
            //     fontWeight: FontWeight.bold,
            //     color: Colors.white60,
            //   ),
            // ),
          ),
          tempoPanel(),
          Container(
            padding: const EdgeInsets.only(top: 0.0),
            width: double.infinity,
            color: Colors.transparent,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(),
                ),
                Container(
                  width: 80,
                  padding: EdgeInsets.only(left: 10, right: 10),
                  height: 1,
                  color: Colors.white60,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(MdiIcons.music, color: Colors.white60),
                ),
                Container(
                  width: 80,
                  padding: EdgeInsets.only(left: 10, right: 10),
                  height: 1,
                  color: Colors.white60,
                ),
                Expanded(
                  child: Container(),
                ),
              ],
            ),
            // child: Text(
            //   "Compasso",
            //   textAlign: TextAlign.center,
            //   style: TextStyle(
            //     fontSize: 30,
            //     fontWeight: FontWeight.bold,
            //     color: Colors.white60,
            //   ),
            // ),
          ),
          Expanded(
            child: compassPanel(),
          ),
          controlPanel(),
        ],
      ),
    );
  }

  Widget bpmPanel() {
    return Container(
      width: double.infinity,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width * 0.3,
            child: FloatingActionButton(
              backgroundColor: Theme.of(context).primaryColor,
              child: Icon(MdiIcons.minus),
              onPressed: () {
                setState(() {
                  _tempo--;
                });
              },
            ),
          ),
          Expanded(
            child: Center(
              child: Container(
                child: Text(
                  _tempo.toString(),
                  style: TextStyle(
                    fontSize: 80,
                    color: Colors.grey[100],
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.3,
            child: FloatingActionButton(
              backgroundColor: Theme.of(context).primaryColor,
              child: Icon(Icons.add),
              onPressed: () {
                setState(() {
                  _tempo++;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget tempoPanel() {
    return Center(
      child: Container(
          width: double.infinity,
          height: 80,
          color: Colors.transparent,
          child: Center(
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: _compassSize,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  width: 50,
                  height: 50,
                  child: Center(
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: _compassTempo == index + 1
                              ? [
                                  Theme.of(context).primaryColor,
                                  Theme.of(context).primaryColor
                                ]
                              : [
                                  Theme.of(context).accentColor,
                                  //Theme.of(context).accentColor,
                                  Colors.grey[800]
                                  //Color(0xFF151619),
                                ],
                        ),
                        // color: _compassTempo == index + 1
                        //     ? Theme.of(context).primaryColor
                        //     : Theme.of(context).accentColor,
                        border: Border.all(
                          color: Colors.transparent,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(30),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _compassTempo == index + 1
                                ? Theme.of(context).primaryColor
                                : Colors.black,
                            blurRadius: 10,
                            spreadRadius: 1,
                            //offset: Offset(0.0, 5.0),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          (index + 1).toString(),
                          softWrap: true,
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white60,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          )),
    );
  }

  Widget compassPanel() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 0),
        child: Wrap(
          spacing: 5.0,
          runSpacing: 5,
          alignment: WrapAlignment.spaceBetween,
          children: <Widget>[
            compassButton(2),
            compassButton(3),
            compassButton(4),
            compassButton(5),
            compassButton(6),
            compassButton(7),
          ],
        ),
      ),
    );
  }

  Widget compassButton(int tempo) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: _compassSize == tempo
                  ? Theme.of(context).primaryColor
                  : Colors.grey[900],
              blurRadius: 40,
              spreadRadius: 0.1,
              //offset: Offset(0.0, 5.0),
            ),
          ],
        ),
        child: RaisedButton(
          elevation: 0,
          child: Text(
            "$tempo",
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          onPressed: () {
            setState(() {
              _compassSize = tempo;
            });
          },
          color: _compassSize == tempo
              ? Theme.of(context).primaryColor
              : Theme.of(context).accentColor,
          shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(18.0),
            // side: BorderSide(
            //   color: Theme.of(context).primaryColor,
            // ),
          ),
        ),
      ),
    );
  }

  Widget controlPanel() {
    return Container(
      height: 100,
      width: double.infinity,
      color: Colors.transparent,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(20),
            height: double.infinity,
            color: Colors.transparent,
            width: MediaQuery.of(context).size.width * 0.5,
            child: RaisedButton(
              child: Icon(
                _metronomeState == MetronomeState.Stopped
                    ? Icons.play_arrow
                    : _metronomeState == MetronomeState.Stopping
                        ? Icons.hourglass_empty
                        : Icons.stop,
                color: Colors.white,
                size: 50,
              ),
              onPressed: _metronomeState == MetronomeState.Stopping
                  ? null
                  : () {
                      _metronomeState == MetronomeState.Stopped
                          ? _start()
                          : _stop();
                    },
              color: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(
                    (MediaQuery.of(context).size.width * 0.5) / 2),
                side: BorderSide(
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            width: MediaQuery.of(context).size.width * 0.5,
            height: double.infinity,
            child: RaisedButton(
              child: Text(
                "Tap",
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                _tap();
              },
              color: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(
                    (MediaQuery.of(context).size.width * 0.5) / 2),
                side: BorderSide(
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
