import 'package:flutter/material.dart';

class PrayerCard extends StatelessWidget {
  const PrayerCard({
    super.key,
    required this.image,
    required this.prayerName,
    required this.prayerTime,
  });

  final String image;
  final String prayerName;
  final String prayerTime;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color.fromARGB(255, 0, 0, 0),
      elevation: 10,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: AssetImage(image),
                fit: BoxFit.cover,
              ),
            ),
          ),

          SizedBox(width: 20),
          Column(
            children: [
              Text(
                prayerName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              Text(
                prayerTime,
                style: TextStyle(
                  fontWeight: FontWeight.w100,
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
