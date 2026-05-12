import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const ItalianChemistryCookbookApp());
}

class ItalianChemistryCookbookApp extends StatelessWidget {
  const ItalianChemistryCookbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Italian Chemistry Cookbook',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red.shade900,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class LessonStep {
  final String title;
  final String instruction;
  final String scienceNote;

  const LessonStep({
    required this.title,
    required this.instruction,
    required this.scienceNote,
  });
}

const List<LessonStep> lessonSteps = [
  LessonStep(
    title: 'Step 1: Gather Ingredients',
    instruction:
        'Collect flour, warm water, yeast, sugar, salt, and olive oil. Make sure an adult is nearby for safety.',
    scienceNote:
        'Cooking uses chemistry because ingredients change when they are mixed, heated, or combined.',
  ),
  LessonStep(
    title: 'Step 2: Activate the Yeast',
    instruction:
        'Mix warm water, sugar, and yeast in a bowl. Let it sit for 5–10 minutes until it becomes foamy.',
    scienceNote:
        'Yeast is a living organism. It eats sugar and begins producing carbon dioxide gas.',
  ),
  LessonStep(
    title: 'Step 3: Mix the Dough',
    instruction:
        'Add flour, salt, and olive oil to the yeast mixture. Stir until it forms dough.',
    scienceNote:
        'When flour and water mix, gluten begins forming. Gluten helps bread become stretchy and chewy.',
  ),
  LessonStep(
    title: 'Step 4: Knead the Dough',
    instruction:
        'Knead the dough for about 8–10 minutes until it becomes smooth and elastic.',
    scienceNote:
        'Kneading strengthens gluten, which helps trap gas bubbles inside the dough.',
  ),
  LessonStep(
    title: 'Step 5: Let the Dough Rise',
    instruction:
        'Cover the dough and let it rise in a warm place. Use the timer below to track the rise.',
    scienceNote:
        'As yeast ferments sugar, it releases carbon dioxide. This gas makes the dough expand.',
  ),
  LessonStep(
    title: 'Step 6: Bake the Bread',
    instruction:
        'With adult help, place the dough in the oven and bake until golden brown.',
    scienceNote:
        'Heat causes chemical and physical changes. The dough becomes solid bread, and the crust browns.',
  ),
  LessonStep(
    title: 'Reflection',
    instruction:
        'Write down what changed during the lesson. What happened to the yeast mixture? What happened to the dough?',
    scienceNote:
        'Scientists observe changes and explain them using evidence. In this lesson, the rising dough is evidence of fermentation.',
  ),
];

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        title: const Text('Italian Chemistry Cookbook'),
        backgroundColor: Colors.red.shade900,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_pizza,
                  size: 90,
                  color: Colors.red.shade900,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Learn Science Through Italian Cooking',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'This lesson teaches homeschool students about yeast, fermentation, carbon dioxide, and bread making.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 30),
                FilledButton.icon(
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start Yeast Lesson'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red.shade900,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 18,
                    ),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LessonPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LessonPage extends StatefulWidget {
  const LessonPage({super.key});

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  int currentStep = 0;

  bool get isLastStep => currentStep == lessonSteps.length - 1;

  void nextStep() {
    if (!isLastStep) {
      setState(() {
        currentStep++;
      });
    }
  }

  void previousStep() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = lessonSteps[currentStep];
    final progress = (currentStep + 1) / lessonSteps.length;

    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        title: const Text('Yeast Bread Lesson'),
        backgroundColor: Colors.red.shade900,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 12,
                  borderRadius: BorderRadius.circular(20),
                ),
                const SizedBox(height: 10),
                Text(
                  'Step ${currentStep + 1} of ${lessonSteps.length}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),

                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.title,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade900,
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Cooking Task',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          step.instruction,
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 22),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.science, size: 32),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Science Note: ${step.scienceNote}',
                                  style: const TextStyle(fontSize: 17),
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (currentStep == 4) ...[
                          const SizedBox(height: 24),
                          const DoughTimer(),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back'),
                      onPressed: currentStep == 0 ? null : previousStep,
                    ),
                    FilledButton.icon(
                      icon: Icon(isLastStep ? Icons.check : Icons.arrow_forward),
                      label: Text(isLastStep ? 'Finish' : 'Next'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red.shade900,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: isLastStep
                          ? () {
                              Navigator.pop(context);
                            }
                          : nextStep,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DoughTimer extends StatefulWidget {
  const DoughTimer({super.key});

  @override
  State<DoughTimer> createState() => _DoughTimerState();
}

class _DoughTimerState extends State<DoughTimer> {
  static const int totalSeconds = 60 * 30; // 30 minutes
  int secondsLeft = totalSeconds;
  Timer? timer;
  bool isRunning = false;

  void startTimer() {
    if (isRunning) return;

    setState(() {
      isRunning = true;
    });

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsLeft <= 0) {
        timer.cancel();
        setState(() {
          isRunning = false;
        });
      } else {
        setState(() {
          secondsLeft--;
        });
      }
    });
  }

  void pauseTimer() {
    timer?.cancel();
    setState(() {
      isRunning = false;
    });
  }

  void resetTimer() {
    timer?.cancel();
    setState(() {
      secondsLeft = totalSeconds;
      isRunning = false;
    });
  }

  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = secondsLeft / totalSeconds;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'Dough Rise Timer',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            formatTime(secondsLeft),
            style: const TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            borderRadius: BorderRadius.circular(20),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            children: [
              FilledButton(
                onPressed: startTimer,
                child: const Text('Start'),
              ),
              OutlinedButton(
                onPressed: pauseTimer,
                child: const Text('Pause'),
              ),
              OutlinedButton(
                onPressed: resetTimer,
                child: const Text('Reset'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
