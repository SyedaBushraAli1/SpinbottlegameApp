import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bottle Spinner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Image.asset(
              'images/floor.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Bottle Spinner Game',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => GameSetupPage()),
                    );
                  },
                  child: Text('Start Game'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GameSetupPage extends StatefulWidget {
  @override
  _GameSetupPageState createState() => _GameSetupPageState();
}

class _GameSetupPageState extends State<GameSetupPage> {
  int _selectedPlayers = 2;
  List<String> _playerNames = List.generate(7, (index) => "");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Image.asset(
              'images/floor.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: Text('Player List'),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Number of Players:',
                      style: TextStyle(fontSize: 15),
                    ),
                    SizedBox(height: 1),
                    // Replacing the Dropdown with a Slider
                    Slider(
                      value: _selectedPlayers.toDouble(),
                      min: 2,
                      max: 7,
                      divisions: 5,
                      label: _selectedPlayers.toString(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPlayers = value.toInt();
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Enter Player Names:',
                      style: TextStyle(fontSize: 15),
                    ),
                    SizedBox(height: 5),
                    Column(
                      children: List.generate(
                        _selectedPlayers,
                            (index) {
                          return TextField(
                            onChanged: (value) {
                              _playerNames[index] = value;
                            },
                            decoration: InputDecoration(
                              hintText: 'Player ${index + 1}',
                              border: OutlineInputBorder(),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 5),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  GamePage(_playerNames.take(_selectedPlayers).toList()),
                            ),
                          );
                        },
                        child: Text('Rotate Bottle Forward'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GamePage extends StatefulWidget {
  final List<String> players;

  GamePage(this.players);

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late Tween<double> _tween;
  var rng = Random();

  List<String> get taskNames => List.generate(widget.players.length, (index) => widget.players[index]);

  String? winner;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5),
    );
    _tween = Tween<double>(
      begin: rng.nextInt(5).toDouble(),
      end: rng.nextDouble() * pi * 10,
    );
    _animation = _tween.animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );
    _animationController.forward();
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _stopAtRandomTaskPoint();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Image.asset(
              'images/floor.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      _spinBottle();
                    },
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return RotationTransition(
                          turns: _animation,
                          child: Image.asset(
                            'images/bottle.png',
                            height: 250,
                            width: 250,
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width: 300,
                    height: 300,
                    child: CustomPaint(
                      painter: CirclePainter(taskNames),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: ElevatedButton(
                      onPressed: _resetBottle,
                      child: Text('Rotate Again'),
                    ),
                  ),
                  if (winner != null)
                    Positioned(
                      top: 20,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        color: Colors.black54,
                        child: Text(
                          'Winner: $winner',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _spinBottle() {
    _animationController.reset();
    _tween = Tween<double>(
      begin: _animation.value,
      end: rng.nextDouble() * pi * 10,
    );
    _animation = _tween.animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );
    _animationController.forward();
  }

  void _resetBottle() {
    _spinBottle();
    setState(() {
      winner = null;
    });
  }

  void _stopAtRandomTaskPoint() {
    double angle = _animation.value % (2 * pi);
    double closestAngle = angle;
    double minDifference = double.infinity;
    for (int i = 0; i < taskNames.length; i++) {
      double taskAngle = 2 * pi * (i / taskNames.length);
      double difference = (taskAngle - angle).abs();
      if (difference < minDifference) {
        minDifference = difference;
        closestAngle = taskAngle;
      }
    }

    double rotations = closestAngle / (2 * pi);
    setState(() {
      _animationController.duration = Duration(milliseconds: 500);
      _tween = Tween<double>(
        begin: angle,
        end: 2 * pi * (rotations + 1),
      );
      _animation = _tween.animate(
        CurvedAnimation(parent: _animationController, curve: Curves.linear),
      );
      _animationController.forward();
      winner = widget.players[
      (closestAngle * taskNames.length ~/ (2 * pi)) % widget.players.length];
    });
  }
}

class CirclePainter extends CustomPainter {
  final List<String> taskNames;

  CirclePainter(this.taskNames);

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;

    final Paint paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final TextStyle textStyle = TextStyle(
      color: Colors.white,
      fontSize: 20,
    );

    final double angle = 2 * pi / taskNames.length;

    for (int i = 0; i < taskNames.length; i++) {
      final double x = centerX + radius * cos(i * angle);
      final double y = centerY + radius * sin(i * angle);
      final Offset offset = Offset(x, y);

      canvas.drawCircle(offset, 8, paint);

      TextSpan span = TextSpan(
        style: textStyle,
        text: taskNames[i],
      );

      TextPainter tp = TextPainter(
        text: span,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, offset - Offset(tp.width / 2, 15));
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
