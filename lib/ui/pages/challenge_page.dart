import 'package:flutter/material.dart';
import '../services/challenge_service.dart';

class ChallengePage extends StatefulWidget {
  const ChallengePage({super.key});

  @override
  State<ChallengePage> createState() => _ChallengePageState();
}

class _ChallengePageState extends State<ChallengePage> {

  final ChallengeService challengeService = ChallengeService();

  String challengeText = "Press Generate to get a challenge.";
  bool loading = false;

  Future<void> generateChallenge() async {

    setState(() {
      loading = true;
    });

    try {

      final text = await challengeService.generateChallenge();

      setState(() {
        challengeText = text;
      });

    } catch (e) {

      setState(() {
        challengeText = "Error generating challenge";
      });

    }

    setState(() {
      loading = false;
    });
  }

  Future<void> validateChallenge() async {

    setState(() {
      loading = true;
    });

    try {

      final result = await challengeService.validateChallenge();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result)),
      );

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Validation failed")),
      );

    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text("Waste Challenge"),
        backgroundColor: Colors.green,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            const Text(
              "Waste Reduction Challenge",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black
              ),
            ),

            const SizedBox(height: 20),

            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),

                child: Text(
                  challengeText,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: loading ? null : generateChallenge,
              child: const Text("Generate Challenge"),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: loading ? null : validateChallenge,
              child: const Text("Validate Challenge"),
            )

          ],
        ),
      ),
    );
  }
}