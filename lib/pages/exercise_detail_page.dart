import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExerciseDetailPage extends StatefulWidget {
  final Map<String, dynamic> workout;

  const ExerciseDetailPage({Key? key, required this.workout}) : super(key: key);

  @override
  _ExerciseDetailPageState createState() => _ExerciseDetailPageState();
}

class _ExerciseDetailPageState extends State<ExerciseDetailPage> {
  bool isGifVisible = false;
  bool isStarted = false;
  int secondsElapsed = 0;
  DateTime? startTime;
  Timer? _timer;
  late FlutterTts tts;
  late int durationMinutes;

  @override
  void initState() {
    super.initState();
    tts = FlutterTts();
    durationMinutes = widget.workout['duration'];

    isGifVisible = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      playSteps();
    });
  }

  void playSteps() async {
    final allSteps = widget.workout['steps'].join('. ');
    await tts.speak(allSteps);
  }

  void startTimer() {
    setState(() {
      isStarted = true;
      startTime = DateTime.now();
      secondsElapsed = 0;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || !isStarted) {
        timer.cancel();
        return;
      }

      setState(() => secondsElapsed++);

      final totalSeconds = durationMinutes * 60;
      if (totalSeconds - secondsElapsed == 10) {
        tts.speak("10 seconds left!");
      }

      if (secondsElapsed >= totalSeconds) {
        stopTimer();
      }
    });
  }

  Future<void> stopTimer() async {
    if (!isStarted) return;

    _timer?.cancel();
    _timer = null;

    final endTime = DateTime.now();
    final duration = endTime.difference(startTime ?? endTime);
    final formattedDuration = formatDuration(duration);

    setState(() => isStarted = false);

    try {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;

      if (userId == null) {
        throw Exception("User not authenticated");
      }

      final response = await client.from('workout_logs').insert({
        'user_id': userId,
        'detail': widget.workout['name'],
        'duration': formattedDuration,
      });

      if (response != null) {
        debugPrint("Workout log inserted successfully.");
      }

      if (!mounted) return;

      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Workout Stopped"),
          content: Text("Duration: $formattedDuration"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        ),
      );

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint("Error saving workout log: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save log: $e")),
        );
      }
    }
  }

  String formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return "$hours:$minutes:$seconds";
  }

  @override
  void dispose() {
    tts.stop();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    return WillPopScope(
      onWillPop: () async {
        tts.stop();
        if (isStarted) await stopTimer();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title:
              Text(widget.workout['name'], style: TextStyle(color: textColor)),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() => isGifVisible = !isGifVisible);
                  if (isGifVisible) playSteps();
                },
                child: Image.asset(
                  isGifVisible
                      ? widget.workout['gif']
                      : widget.workout['image'],
                  height: 200,
                ),
              ),
              const SizedBox(height: 16),
              Text("Steps:",
                  style:
                      TextStyle(fontWeight: FontWeight.bold, color: textColor)),
              ...widget.workout['steps']
                  .map<Widget>(
                    (s) => Align(
                      alignment: Alignment.centerLeft,
                      child: Text("• $s", style: TextStyle(color: textColor)),
                    ),
                  )
                  .toList(),
              const SizedBox(height: 24),
              if (!isStarted)
                ElevatedButton(
                  onPressed: startTimer,
                  child: Text("Start (${durationMinutes} min)"),
                )
              else
                Column(
                  children: [
                    Text(
                      "Time: ${(secondsElapsed ~/ 60).toString().padLeft(2, '0')}:${(secondsElapsed % 60).toString().padLeft(2, '0')}",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: stopTimer,
                      icon: const Icon(Icons.stop),
                      label: const Text("Stop"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
