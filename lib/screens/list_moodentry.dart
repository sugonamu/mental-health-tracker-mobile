import 'package:flutter/material.dart';
import 'package:mental_health_tracker/models/moodentry.dart';
import 'package:mental_health_tracker/widgets/left_drawer.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class MoodEntryPage extends StatefulWidget {
  const MoodEntryPage({super.key});

  @override
  State<MoodEntryPage> createState() => _MoodEntryPageState();
}

class _MoodEntryPageState extends State<MoodEntryPage> {
  // Function to fetch mood entries from the API
  Future<List<MoodEntry>> fetchMood(CookieRequest request) async {
    try {
      final response = await request.get('http://localhost:8000/json/');
      if (response != null) {
        // Decode the response into a list of MoodEntry objects
        var data = response as List<dynamic>;
        return data
            .where((item) => item != null)
            .map((d) => MoodEntry.fromJson(d))
            .toList();
      } else {
        throw Exception('Failed to load mood entries');
      }
    } catch (e) {
      rethrow;  // Pass the error to the FutureBuilder's error handler
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();  // CookieRequest from provider

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Entry List'),
      ),
      drawer: const LeftDrawer(),
      body: FutureBuilder<List<MoodEntry>>(
        future: fetchMood(request),  // Fetch mood entries
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Handle any error that occurred during the fetch
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}', style: const TextStyle(fontSize: 18, color: Colors.red)),
            );
          }

          // Handle case where no data is found
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'There is no mood data in the mental health tracker.',
                style: TextStyle(fontSize: 20, color: Color(0xff59A5D8)),
              ),
            );
          }

          // Display the list of mood entries if data is available
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (_, index) {
              final moodEntry = snapshot.data![index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${moodEntry.fields.mood}",
                      style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text("${moodEntry.fields.feelings}"),
                    const SizedBox(height: 10),
                    Text("${moodEntry.fields.moodIntensity}"),
                    const SizedBox(height: 10),
                    Text("${moodEntry.fields.time}")
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
