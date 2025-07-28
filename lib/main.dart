import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const FitnessChatBotApp());
}

class FitnessChatBotApp extends StatelessWidget {
  const FitnessChatBotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness ChatBot',
      home: const ChatScreen(),
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final List<ChatMessage> _messages = [];

  Map<String, List<String>> workouts = {};
  Map<String, List<String>> meals = {};

  final Map<String, List<String>> categorizedExercises = {
    'Upper Body': [
      'push up',
      'pull up',
      'bench press',
      'shoulder press',
      'bicep curl',
      "tricep extension",
      "chest workout",
      "arm workout",
      'tricep dips',
      'lat pulldown',
      'chest fly',
      'overhead press',
      "arm curls",
      "arm raises",
      "arm extensions",
      "shoulder workout",
      "back workout",
      "bicep workout",
      "tricep workout"
    ],
    'Lower Body': [
      'squats',
      'lunges',
      'deadlift',
      'leg press',
      'calf raises',
      'glute bridge',
      'step ups',
      "leg workout"
    ],
    'Core': [
      'plank',
      'sit ups',
      'crunches',
      'russian twists',
      'leg raises',
      'mountain climbers',
      'bicycle crunches'
    ],
    'Cardio': [
      'jumping jacks',
      'running',
      'cycling',
      'swimming',
      'jump rope',
      'burpees',
      'high knees'
    ],
    'Flexibility': [
      'yoga',
      'stretching',
      'hamstring stretch',
      'quad stretch',
      'shoulder stretch',
      'cobra stretch',
      'child pose'
    ],
    'Gym Machines': [
      'treadmill',
      'elliptical',
      'rower',
      'leg curl machine',
      'chest press machine',
      'cable row',
      'smith machine'
    ],
  };

  final List<String> healthyFoods = [
    "banana",
    "apple",
    "orange",
    "chicken",
    "rice",
    "vegetables",
    "salad",
    "nuts",
    "broccoli",
    "spinach",
    "kale",
    "quinoa",
    "sweet potato",
    "oats",
    "berries",
    "avocado",
    "fish",
    "tofu",
    "lentils",
    "beans",
    "yogurt",
    "almonds",
    "chia seeds",
    "flaxseeds",
    "cucumber",
    "carrots",
    "tomatoes",
    "bell peppers",
    "cauliflower",
    "mushrooms",
    "green peas",
    "brown rice",
    "walnuts",
    "pumpkin seeds",
    "edamame",
    "cottage cheese",
    "hummus",
    "zucchini",
    "beets",
    "asparagus",
    "brussels sprouts",
    "pineapple",
    "pomegranate",
    "grapefruit",
    "watermelon",
    "celery",
    "chia pudding",
    "black beans",
    "kidney beans",
    "turkey",
    "lean beef",
    "seaweed",
    "spirulina"
  ];

  final List<String> junkFoods = [
    "burger",
    "pizza",
    "fries",
    "soda",
    "chips",
    "cake",
    "candy",
    "ice cream",
    "donut",
    "hot dog",
    "fried chicken",
    "cookie",
    "chocolate",
    "popcorn (buttery)",
    "nachos",
    "milkshake",
    "corn dog",
    "tacos (fast food style)",
    "cheesecake",
    "brownie",
    "pretzels (salted)",
    "mochi (sweet)",
    "energy drinks",
    "frozen pizza",
    "pancakes (with syrup)",
    "pastries",
    "muffins",
    "sugar cereals",
    "whipped cream",
    "fast food sandwiches",
    "processed cheese",
    "instant noodles",
    "fried snacks",
    "sugary drinks",
    "deep fried foods",
    "processed meats",
    "candies",
    "lollipops",
    "gum (sugary)",
    "granola bars (sugary)",
    "chewing gum (sugary)",
    "corn chips",
    "sugar cookies",
    "cinnamon rolls",
    "toffee",
    "marshmallows",
    "cupcakes"
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String todayString() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  int? exactNumber(String text) {
    final regex = RegExp(r'\d+');
    final match = regex.firstMatch(text);
    if (match != null) {
      return int.tryParse(match.group(0)!);
    }
    return null;
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      workouts = Map<String, List<String>>.from(
        json.decode(prefs.getString('workouts') ?? '{}')
            .map((k, v) => MapEntry(k, List<String>.from(v))),
      );
      meals = Map<String, List<String>>.from(
        json.decode(prefs.getString('meals') ?? '{}')
            .map((k, v) => MapEntry(k, List<String>.from(v))),
      );
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('workouts', json.encode(workouts));
    await prefs.setString('meals', json.encode(meals));
  }

  Future<String> generatePdfSummary(String dateStr) async {
    final pdf = pw.Document();
    final workoutList = workouts[dateStr] ?? [];
    final mealList = meals[dateStr] ?? [];

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Fitness Summary - $dateStr',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            pw.Text('🏋️ Workouts:', style: pw.TextStyle(fontSize: 18)),
            if (workoutList.isEmpty)
              pw.Text('No workouts recorded.')
            else
              ...workoutList.map((w) => pw.Text('- $w')),
            pw.SizedBox(height: 20),
            pw.Text('🍽️ Meals:', style: pw.TextStyle(fontSize: 18)),
            if (mealList.isEmpty)
              pw.Text('No meals recorded.')
            else
              ...mealList.map((m) => pw.Text('- $m')),
          ],
        ),
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/summary_$dateStr.pdf');
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }

  Future<void> openPdf(String path) async {
    await OpenFile.open(path);
  }

  String getRandomWorkoutReply(String entry) {
    List<String> replies = [
      "Great job! I noted down your $entry. Ready to log some meals?",
      "$entry added! Keep pushing! Want to add meals now?",
      "Nice work! Logged $entry. Any meals you'd like to add?",
      "You crushed it with $entry! Want to log any meals?",
      "Awesome! $entry is logged. How about some meals?",
      "You logged $entry. Keep up the great work! Any meals to add?",
      "You added $entry. Fantastic effort! Want to log meals too?",
      "You logged $entry. You're on fire! Any meals to log?",
      "You added $entry. Amazing job! Want to log meals?",
      "You logged $entry. You're doing great! Any meals to log?",
      "You added $entry. Keep it up! Want to log meals?", 
    ];
    replies.shuffle();
    return replies.first;
  }

  String getRandomMealReply(String food, bool healthy) {
    List<String> healthyReplies = [
      "Meal Saved: $food. Keep Eating Healthy!\nAny workouts you want to log?",
      "Yum! Noted your $food. Want to add workouts too?",
      "$food logged! Great choice for your health.",
      "Healthy choice! $food added to your meals.\nAny workouts you want to log?",
      "You added $food. Keep up the healthy eating!\nAny workouts to log?",
      "Noted $food. You're doing great with your meals!\nWant to log any workouts?",
      "You logged $food. Excellent choice for your health!\nAny workouts you want to log?",
      "You added $food. Keep it up with the healthy choices!\nAny workouts to log?",
      "You logged $food. Great job on eating healthy!\nAny workouts you want to log?",
      "You added $food. Keep up the good work with your meals!\nAny workouts to log?",
      "You logged $food. You're making healthy choices!\nAny workouts you want to log?",
    ];
    List<String> junkReplies = [
      "🍔 That's a junk food: $food. Try to eat healthier.\nAny workouts you want to log?",
      "Logged $food, but remember to balance with healthy meals!",
      "Noted $food. Let's try to keep healthy options too!",
      "You logged $food. Balance it with some workouts!",
      "You added $food. Don't forget to exercise today!",
      "You logged $food. Remember, moderation is key!",
      "You added $food. Let's make sure to balance it with workouts!",
      "You logged $food. How about some exercise to balance it out?",
      "You added $food. Remember to stay active today!",
    ];

    if (healthy) {
      healthyReplies.shuffle();
      return healthyReplies.first;
    } else {
      junkReplies.shuffle();
      return junkReplies.first;
    }
  }

  String getRandomGreeting() {
    List<String> greetings = [
      "Hello! Can you tell me your workout for today?",
      "Hey there! Ready to log some workouts and meals?",
      "Hi! What fitness activity did you do today?",
      "Greetings! Let's track your fitness journey.",
      "Welcome back! What workout or meal do you want to log today?",
      "Hi there! How can I assist you with your fitness goals today?",
      "Hello! Let's get you motivated and track your progress!",
      "Hey! Ready to crush some fitness goals today?",
      "Hi! Let's make today a healthy day!",
      "Hello! What workout or meal do you want to log today?",
      "Hey! Let's keep you on track with your fitness journey!",
      "Hi! Ready to log your fitness activities?",
      "Hello! Let's make today a great day for your health!",
      "Hey! What fitness activity are you excited about today?",
    ];
    greetings.shuffle();
    return greetings.first;
  }

  String getRandomGoodbye() {
    List<String> goodbyes = [
      "Goodbye! Stay fit and healthy!",
      "See you later! Keep pushing!",
      "Take care! Your health matters!",
      "Bye! Don't forget to stretch today!",
    ];
    goodbyes.shuffle();
    return goodbyes.first;
  }

  String getRandomHelp() {
    return "Here are some commands you can use:\n"
        "- Log a workout: 'push up', 'squats', etc.\n"
        "- Log a meal: 'banana', 'pizza', etc.\n"
        "- Get a summary: 'summary YYYY-MM-DD'\n"
        "- Ask for help: 'help' or 'commands'\n"
        "- Ask for a joke: 'tell me a joke'\n"
        "- Get motivation: 'motivate me'";
  }

  String getRandomMotivation() {
    List<String> quotes = [
      "Keep pushing your limits! Every rep counts 💪",
      "Believe in yourself and all that you are!",
      "Sweat now, shine later!",
      "Strong body, strong mind!",
      "Your only limit is you!",
      "Success is the sum of small efforts, repeated day in and day out.",
      "Don't stop until you're proud!",
      "Fitness is not about being better than someone else. It's about being better than you used to be.",
      "Push yourself because no one else is going to do it for you.",
      "The pain you feel today will be the strength you feel tomorrow.",
      "You are one workout away from a better mood!",
      "Fitness is like a relationship. You can’t cheat and expect it to work.",
    ];
    quotes.shuffle();
    return quotes.first;
  }

  String getRandomJoke() {
    List<String> jokes = [
      "Why don't some fish do well in school? Because they're below sea level!",
      "Why did the scarecrow become a great trainer? Because he was outstanding in his field!",
      "Why don't skeletons fight each other? They don't have the guts!",
      "What do you call a fake noodle? An Impasta!",
    ];
    jokes.shuffle();
    return jokes.first;
  }

  Future<void> handleSend() async {
    final input = _controller.text.trim();
    if (input.isEmpty) return;
    _controller.clear();

    setState(() {
      _messages.add(ChatMessage(sender: "You", text: input));
      _messages.add(ChatMessage(sender: "Bot", text: "Typing..."));
    });

    await Future.delayed(const Duration(milliseconds: 800));

    setState(() {
      _messages.removeWhere((msg) => msg.text == "Typing...");
    });

    String botResponse = await handleMessage(input);

    setState(() {
      _messages.add(ChatMessage(sender: "Bot", text: botResponse));
    });

    await Future.delayed(const Duration(milliseconds: 100));
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }

    FocusScope.of(context).requestFocus(_focusNode);
  }

  Future<String> handleMessage(String msg) async {
    String today = todayString();
    msg = msg.toLowerCase().trim();

    // Normalize common phrases
    msg = msg.replaceAll("work out", "workout");
    msg = msg.replaceAll("work-out", "workout");
    msg = msg.replaceAll("pushup", "push up");
    msg = msg.replaceAll("squat", "squats");
    msg = msg.replaceAll("jumping jack", "jumping jacks");
    msg = msg.replaceAll("chestworkout", "chest workout");
    msg = msg.replaceAll("legworkout", "leg workout");
    msg = msg.replaceAll("armworkout", "arm workout");
    msg = msg.replaceAll("pull up", "pullup");

    // Greetings
    if (msg.contains("hi") || msg.contains("hello")) {
      return getRandomGreeting();
    }

    // Goodbye
    if (msg == "bye" || msg == "no"|| msg == "ok" || msg == "okey" || msg == "okei" || msg == "bei") {
      return getRandomGoodbye();
    }

    // Check for workouts
    for (var category in categorizedExercises.values) {
      for (var exercise in category) {
        if (msg.contains(exercise)) {
          int? reps = exactNumber(msg);
          String entry = reps != null ? "$reps $exercise" : exercise;
          workouts.putIfAbsent(today, () => []);
          if (!workouts[today]!.contains(entry)) {
            workouts[today]!.add(entry);
            await _saveData();
            return getRandomWorkoutReply(entry);
          } else {
            return "You already logged $entry today.\nAny meals you want to log?";
          }
        }
      }
    }

    // Check for healthy foods
    for (var food in healthyFoods) {
      if (msg.contains(food)) {
        meals.putIfAbsent(today, () => []);
        if (!meals[today]!.contains(food)) {
          meals[today]!.add(food);
          await _saveData();
          return getRandomMealReply(food, true);
        } else {
          return "You already logged $food today.\nAny workouts you want to log?";
        }
      }
    }

    // Check for junk foods
    for (var food in junkFoods) {
      if (msg.contains(food)) {
        meals.putIfAbsent(today, () => []);
        if (!meals[today]!.contains(food)) {
          meals[today]!.add(food);
          await _saveData();
          return getRandomMealReply(food, false);
        } else {
          return "You already logged $food today.\nAny workouts you want to log?";
        }
      }
    }

    if (msg.contains("thank you") || msg.contains("thanks")) {
      return "You're welcome! Keep up the good work!";
    }

    if (msg.contains("help") || msg.contains("commands")) {
      return getRandomHelp();
    }

    if (msg.contains("injury") || msg.contains("hurt") || msg.contains("pain")) {
      return "❗ If you're injured, please consult a healthcare professional. Rest and recovery are important.";
    }

    if (msg.contains("how are you")) {
      return "I'm feeling great, thanks for asking! Ready to log some workouts?";
    }

    if (msg.contains("joke")) {
      return getRandomJoke();
    }

    if (msg.contains("motivate")) {
      return getRandomMotivation();
    }

    // Summary command
    if (msg.startsWith("summary")) {
      final parts = msg.split(" ");
      String queryDate = today;

      if (parts.length >= 2) {
        queryDate = parts[1]; // e.g. "summary 2025-06-18"
      }

      // Validate date format YYYY-MM-DD
      if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(queryDate)) {
        return "❗ Please enter the date in YYYY-MM-DD format, e.g., summary 2025-06-18.";
      }

      StringBuffer summary = StringBuffer();
      summary.writeln("📅 Summary for $queryDate:");
      summary.writeln("🏋️ Workouts:");
      if (workouts.containsKey(queryDate) && workouts[queryDate]!.isNotEmpty) {
        for (var w in workouts[queryDate]!) {
          summary.writeln("- $w");
        }
      } else {
        summary.writeln("No workouts recorded.");
      }

      summary.writeln("🍽️ Meals:");
      if (meals.containsKey(queryDate) && meals[queryDate]!.isNotEmpty) {
        for (var m in meals[queryDate]!) {
          summary.writeln("- $m");
        }
      } else {
        summary.writeln("No meals recorded.");
      }

      return summary.toString();
    }

    return "Sorry, I didn't understand that. Try logging a workout or meal, or type 'help' for commands.";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Fitness Chatbot"),
      backgroundColor: Color.fromARGB(255, 0, 0, 0),
      titleTextStyle: const TextStyle(
      color: Colors.white,   // your desired text color here
      fontSize: 24,
      fontWeight: FontWeight.bold,
  ), ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[_messages.length - 1 - index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Align(
                    alignment:
                        msg.sender == "You" ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: msg.sender == "You" ? const Color.fromARGB(255, 83, 83, 83) : Colors.grey[300],
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(12),
                          topRight: const Radius.circular(12),
                          bottomLeft: msg.sender == "You"
                              ? const Radius.circular(12)
                              : const Radius.circular(0),
                          bottomRight: msg.sender == "You"
                              ? const Radius.circular(0)
                              : const Radius.circular(12),
                        ),
                      ),
                      child: Text(
                        msg.text,
                        style: TextStyle(
                          color: msg.sender == "You" ? Colors.white : const Color.fromARGB(225, 0, 0, 0),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    onSubmitted: (_) => handleSend(),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Type your message...",
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: handleSend,
                  child: const Text("Send"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String sender;
  final String text;
  ChatMessage({required this.sender, required this.text});
} 
