import 'package:flutter/material.dart';

class NotesSlideout extends StatelessWidget {
  const NotesSlideout({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // Make the content scrollable if it's too large
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom, // Adjust for keyboard height
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Close Button
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(context); // Close the modal
                    },
                  ),
                ),
                const SizedBox(height: 10),

                // Add a New Note text
                const Center(
                  child: Text(
                    "What is RIR (Reps in Reserve)?",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                const Center(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      // "RIR is a method for measuring the intensity of a lift by counting how many more repetitions you could perform before technical failure.",
                      "Reps in reserve is a subjective measurement which has you estimating how many additional reps you’d be able to perform at the end of your set. We use RIR to quantify effort (proximity to failure).",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20), // Padding inside the container
                  decoration: BoxDecoration(
                    color: Color(0xFF2196F3), // Background color
                    border: Border.all(
                      color: Color(0xFF2196F3), // Border color
                      width: 1, // Border width
                    ),
                    borderRadius: BorderRadius.circular(8), // Rounded corners
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '0 REPS',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              "I can't do any more reps.",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '0',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20), // Padding inside the container
                  decoration: BoxDecoration(
                    color: Color(0xFF5D79C3), // Background color
                    border: Border.all(
                      color: Color(0xFF5D79C3), // Border color
                      width: 1, // Border width
                    ),
                    borderRadius: BorderRadius.circular(8), // Rounded corners
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '1 REP',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              "I can do 1 more rep.",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '1',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Color(0xFFCD5A77), // Background color
                    border: Border.all(
                      color: Color(0xFFCD5A77), // Border color
                      width: 1, // Border width
                    ),
                    borderRadius: BorderRadius.circular(8), // Rounded corners
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '2 REPS',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              "I can do 2 more reps.",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '2',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20), // Padding inside the container
                  decoration: BoxDecoration(
                    color: Color(0xFFB7436B), // Background color
                    border: Border.all(
                      color: Color(0xFFB7436B), // Border color
                      width: 1, // Border width
                    ),
                    borderRadius: BorderRadius.circular(8), // Rounded corners
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '3 REPS',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              "I can do 3 more reps.",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '3',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20), // Padding inside the container
                  decoration: BoxDecoration(
                    color: Color(0xFF9A354E), // Background color
                    border: Border.all(
                      color: Color(0xFF9A354E), // Border color
                      width: 1, // Border width
                    ),
                    borderRadius: BorderRadius.circular(8), // Rounded corners
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '4 REPS',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              "I can do 4+ more reps.",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '4+',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
