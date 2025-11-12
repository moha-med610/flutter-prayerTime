import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:prayer_time_app/widgets/prayer_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Timer _timer;
  String time = "";
  Widget? status;
  bool isLoading = false;
  String date =
      "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}";

  String? hijriDate = "";
  String? day;
  String? location = "";
  Map<String, dynamic>? timings = {};

  @override
  void initState() {
    super.initState();
    getPrayerTime();
    _startClock();
  }

  void _startClock() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        DateTime now = DateTime.now();
        time =
            "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
      });
    });
  }

  Future<void> getPrayerTime() async {
    try {
      setState(() {
        isLoading = true;
      });
      bool serviceEnable = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnable) {
        setState(() {
          status = Center(
            child: Text(
              "الرجاء تشغيل خدمات الموقع!",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          );
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          status = Center(
            child: Text(
              "لا يمكنك الاكمال في التطبيق بدون الاذن بالوصول للموقع",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          );
        });
        return;
      }
      Position? lastPos = await Geolocator.getLastKnownPosition();

      if (lastPos != null) {
        List<Placemark> marks = await placemarkFromCoordinates(
          lastPos.latitude,
          lastPos.longitude,
        );
        location =
            marks.first.locality ??
            marks.first.administrativeArea ??
            marks.first.subAdministrativeArea;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );
      final lat = position.latitude;
      final log = position.longitude;

      List<Placemark> placemark = await placemarkFromCoordinates(lat, log);

      Placemark place = placemark[0];

      location =
          place.locality ??
          place.administrativeArea ??
          place.subAdministrativeArea;

      final url = Uri.parse(
        "https://api.aladhan.com/v1/timings/$date?latitude=$lat&longitude=$log&method=2",
      );
      final data = await http.get(url);

      final res = await jsonDecode(data.body);

      setState(() {
        hijriDate = res["data"]?["date"]?["hijri"]?["date"];
        day = res["data"]?["date"]["hijri"]?["weekday"]?["ar"];
        timings = res["data"]?["timings"];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        status = Center(
          child: Text(
            "حدث خطأ ما",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
        isLoading = false;
      });
      return;
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(221, 27, 27, 29),
        body: SingleChildScrollView(
          child: isLoading
              ? Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(150),
                      child: Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(
                              color: Colors.cyan,
                              strokeWidth: 2,
                              backgroundColor: Colors.blueGrey,
                            ),
                            SizedBox(height: 10),
                            Text(
                              "جاري التحميل",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.normal,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(
                        top: 60,
                        right: 20,
                        left: 20,
                        bottom: 5,
                      ),
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 18, 40, 58),
                        borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(40),
                          bottomLeft: Radius.circular(40),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "$day",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  time,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(height: 20),
                                Row(
                                  // mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 22,
                                      color: Colors.black87,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      "$location",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // ناحية الشمال
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  date,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          PrayerCard(
                            image: "assets/icons/App_icon.png",
                            prayerName: "الفجر",
                            prayerTime: "${timings?["Fajr"]}",
                          ),
                          PrayerCard(
                            image: "assets/icons/App_icon.png",
                            prayerName: "الشروق",
                            prayerTime: "${timings?["Sunrise"]}",
                          ),
                          PrayerCard(
                            image: "assets/icons/App_icon.png",
                            prayerName: "الضهر",
                            prayerTime: "${timings?["Dhuhr"]}",
                          ),
                          PrayerCard(
                            image: "assets/icons/App_icon.png",
                            prayerName: "العصر",
                            prayerTime: "${timings?["Asr"]}",
                          ),
                          PrayerCard(
                            image: "assets/icons/App_icon.png",
                            prayerName: "المغرب",
                            prayerTime: "${timings?["Maghrib"]}",
                          ),
                          PrayerCard(
                            image: "assets/icons/App_icon.png",
                            prayerName: "العشاء",
                            prayerTime: "${timings?["Isha"]}",
                          ),
                          PrayerCard(
                            image: "assets/icons/App_icon.png",
                            prayerName: "منتصف الليل",
                            prayerTime: "${timings?["Midnight"]}",
                          ),
                          PrayerCard(
                            image: "assets/icons/App_icon.png",
                            prayerName: "الثلث الاول",
                            prayerTime: "${timings?["Firstthird"]}",
                          ),
                          PrayerCard(
                            image: "assets/icons/App_icon.png",
                            prayerName: "الثلث الاخير",
                            prayerTime: "${timings?["Lastthird"]}",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
        bottomNavigationBar: Container(
          color: Colors.black45,
          padding: EdgeInsets.all(10),
          child: Text(
            "Developed By Mohamed khaled \u00A9 All Rights Received ${DateTime.now().year}",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
