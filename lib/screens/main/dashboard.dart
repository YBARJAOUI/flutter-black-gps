// import 'package:blackgps/components/CustomBottomNavBar.dart';
// import 'package:blackgps/constants/colors.dart';
// import 'package:blackgps/providers/homeProviders.dart';
// import 'package:blackgps/providers/myCarsProviders.dart';
// import 'package:blackgps/screens/main/Chart.dart';
// import 'package:blackgps/screens/main/traget.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:omni_datetime_picker/omni_datetime_picker.dart';

// class FleetManagement extends ConsumerStatefulWidget {
//   @override
//   _FleetManagementState createState() => _FleetManagementState();
// }

// class _FleetManagementState extends ConsumerState<FleetManagement> {
//   String? selectedDate;

//   int _selectedIndex = 2;

//   void _onItemTapped(int index) {
//     switch (index) {
//       case 0:
//         GoRouter.of(context).push('/home');
//         break;
//       case 1:
//         GoRouter.of(context).push('/mycars');
//         break;
//       case 2:
//         GoRouter.of(context).push('/charts');
//         break;
//       case 3:
//         GoRouter.of(context).push('/settings');
//         break;
//       default:
//     }

//     ref.read(selectedIndexProvider.notifier).state = index;
//   }

//   @override
//   void initState() {
//     super.initState();
//     ref.read(fetchMyCarsProvider);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final imeiList = ref.watch(imeiMyCarsListProvider);
//     final cardata = ref.watch(carListdataProvider);

//     // ignore: deprecated_member_use
//     return WillPopScope(
//       onWillPop: () async => false,
//       child: Scaffold(
//         appBar: AppBar(
//           backgroundColor: CustomColors.blueColor,
//           automaticallyImplyLeading: false,
//           title: Text(
//             'stats.stats'.tr(),
//             style: TextStyle(
//               color: CustomColors.whiteColor,
//               fontSize: 24,
//             ),
//           ),
//         ),
//         body: ref.watch(fetchMyCarsProvider).when(
//               data: (_) {
//                 return ListView.builder(
//                   itemCount: cardata.length,
//                   itemBuilder: (context, index) {
//                     print("contecxt  sad : ${cardata}");
//                     String imei = cardata.keys.elementAt(index);
//                     List<dynamic>? carInfo = cardata[imei];

//                     if (carInfo == null || carInfo.length < 5) {
//                       return ListTile(
//                         title: Text('Data not available'),
//                       );
//                     }

//                     String name = carInfo[0] ?? 'Unknown';
//                     int carNumber = carInfo[2] ?? 'Unknown';
//                     String plateNumber = carInfo[1] ?? 'Unknown';
//                     String gpsdevicePhoneNumber = carInfo[3] ?? 'Unknown';
//                     String imageUrl = carInfo[4] != null
//                         ? "https://mobile.blackgps.xyz${carInfo[4]}"
//                         : 'assets/placeholder.png';

//                     return GestureDetector(
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => Chart(imei: imei),
//                           ),
//                         );
//                       },
//                       child: Card(
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(15.0),
//                         ),
//                         elevation: 5.0,
//                         margin: EdgeInsets.symmetric(
//                             vertical: 10.0, horizontal: 15.0),
//                         child: ListTile(
//                           leading: ClipRRect(
//                             borderRadius: BorderRadius.circular(8.0),
//                             child: Image.network(
//                               imageUrl, // Ensure you have an image asset with this path
//                               width: 76,
//                               height: 76,
//                               fit: BoxFit.cover,
//                               errorBuilder: (context, error, stackTrace) {
//                                 return Image.asset(
//                                   'assets/placeholder.png',
//                                   width: 76,
//                                   height: 76,
//                                   fit: BoxFit.cover,
//                                 );
//                               },
//                             ),
//                           ),
//                           title: Text(
//                             "${carNumber} - ${name}",
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 12,
//                             ),
//                           ),
//                           subtitle: Text(
//                             plateNumber,
//                             style: TextStyle(
//                               fontSize: 10,
//                               color: Colors.grey[600],
//                             ),
//                           ),
//                           contentPadding: EdgeInsets.symmetric(
//                             vertical: 10.0,
//                             horizontal: 16.0,
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//               loading: () => const Center(child: CircularProgressIndicator()),
//               error: (error, stack) =>
//                   const Center(child: Text('Error loading data')),
//             ),
//         bottomNavigationBar: CustomBottomNavigationBar(
//           currentIndex: _selectedIndex,
//           onTap: _onItemTapped,
//         ),
//       ),
//     );
//   }

//   void _showDatePicker(BuildContext context, String imei) async {
//     List<DateTime>? dateTimeList = await showOmniDateTimeRangePicker(
//       context: context,
//       startInitialDate: DateTime.now(),
//       startFirstDate: DateTime(1600).subtract(const Duration(days: 3652)),
//       startLastDate: DateTime.now().add(
//         const Duration(days: 3652),
//       ),
//       endInitialDate: DateTime.now(),
//       endFirstDate: DateTime(1600).subtract(const Duration(days: 3652)),
//       endLastDate: DateTime.now().add(
//         const Duration(days: 3652),
//       ),
//       is24HourMode: true,
//       isShowSeconds: false,
//       minutesInterval: 1,
//       secondsInterval: 1,
//       borderRadius: const BorderRadius.all(Radius.circular(16)),
//       constraints: const BoxConstraints(
//         maxWidth: 350,
//         maxHeight: 650,
//       ),
//       transitionBuilder: (context, anim1, anim2, child) {
//         return FadeTransition(
//           opacity: anim1.drive(
//             Tween(
//               begin: 0,
//               end: 1,
//             ),
//           ),
//           child: child,
//         );
//       },
//       transitionDuration: const Duration(milliseconds: 200),
//       barrierDismissible: true,
//       selectableDayPredicate: (dateTime) {
//         // Disable 25th Feb 2023
//         if (dateTime == DateTime(2023, 2, 25)) {
//           return false;
//         } else {
//           return true;
//         }
//       },
//     );

//     if (dateTimeList != null) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => Traget(
//             imei: imei,
//             startDate: dateTimeList[0],
//             endDate: dateTimeList[1],
//           ),
//         ),
//       );
//     }
//   }
// }

import 'package:blackgps/components/CustomBottomNavBar.dart';
import 'package:blackgps/constants/colors.dart';
import 'package:blackgps/providers/homeProviders.dart';
import 'package:blackgps/screens/main/Chart.dart';
import 'package:blackgps/screens/main/traget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:flip_card/flip_card.dart';

class FleetManagement extends ConsumerStatefulWidget {
  @override
  _FleetManagementState createState() => _FleetManagementState();
}

class _FleetManagementState extends ConsumerState<FleetManagement> {
  String? selectedDate;
  int _selectedIndex = 2;
  void _ShowMore(String imei, int id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Chart(imei: imei, id: id),
      ),
    );
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        GoRouter.of(context).push('/home');
        break;
      case 1:
        GoRouter.of(context).push('/mycars');
        break;
      case 2:
        GoRouter.of(context).push('/charts');
        break;
      case 3:
        GoRouter.of(context).push('/settings');
        break;
      default:
    }
    ref.read(selectedIndexProvider.notifier).state = index;
  }

  @override
  void initState() {
    super.initState();
    ref.read(fetchCarsFutureProvider);
  }

  @override
  Widget build(BuildContext context) {
    final cardata = ref.watch(cardataProvider);

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        extendBody: true,
        appBar: AppBar(
          backgroundColor: CustomColors.blueColor,
          automaticallyImplyLeading: false,
          title: Text(
            'stats.stats'.tr(),
            style: TextStyle(
              color: CustomColors.whiteColor,
              fontSize: 24,
            ),
          ),
        ),
        // body: ref.watch(fetchMyCarsProvider).when(
        body: ref.watch(fetchCarsFutureProvider).when(
              data: (_) {
                return ListView.builder(
                  itemCount: cardata.length,
                  itemBuilder: (context, index) {
                    String imei = cardata.keys.elementAt(index);
                    List<dynamic>? carInfo = cardata[imei];
                    if (carInfo == null) {
                      return ListTile(
                        title: Text('Data not available'),
                      );
                    }
                    int id = carInfo[10] ?? 0;
                    String name = carInfo[0] ?? 'Unknown';
                    int carNumber = carInfo[1] ?? 'Unknown';
                    String plateNumber = carInfo[2] ?? 'Unknown';
                    String gpsdevicePhoneNumber = carInfo[9] ?? 'Unknown';
                    String imageUrl = carInfo[3] != null
                        ? "https://mobile.blackgps.xyz${carInfo[3]}"
                        : 'assets/placeholder.png';
                    int power = carInfo[5] ?? 0;
                    double totalkm = carInfo[6] ?? 0.0;
                    String formattedTotalkm = totalkm.toStringAsFixed(2);

                    return GestureDetector(
                      // onTap: () {
                      //   Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //       builder: (context) => Chart(),
                      //     ),
                      //   );
                      // },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        elevation: 5.0,
                        margin: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 15.0),
                        child: FlipCard(
                          front: component2(
                              name: name,
                              plateNumber: plateNumber,
                              imageUrl: imageUrl,
                              carNumber: carNumber,
                              power: power),
                          // back: component1(
                          //   name: name,
                          //   plateNumber: plateNumber,
                          //   imageUrl: imageUrl,
                          //   carNumber: carNumber,
                          // ),
                          back: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(8.0)),
                                child: SizedBox(
                                  height: 190,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 88,
                                        color: power == 0
                                            ? Colors.red
                                            : Colors.green,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Text(
                                              "$carNumber",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 24,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text.rich(
                                              TextSpan(
                                                style: TextStyle(),
                                                children: [
                                                  TextSpan(
                                                    text: 'ADRESSE\n',
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: carInfo[4],
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          height: double.infinity,
                                          color: Colors.white,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const SizedBox(width: 10),
                                                  Image.asset(
                                                    'assets/dots.png',
                                                    width: 16,
                                                    height: 42,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                          name,
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        Container(
                                                          margin:
                                                              const EdgeInsets
                                                                  .fromLTRB(
                                                                  0, 8, 10, 8),
                                                          width:
                                                              double.infinity,
                                                          height: 0.5,
                                                          color:
                                                              Colors.grey[200],
                                                        ),
                                                        Text(
                                                          plateNumber,
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  explainText('TOTAL KM',
                                                      formattedTotalkm),
                                                  explainText(
                                                      'SPEED', '${carInfo[7]}'),
                                                  explainText(
                                                      'FUEL', '${carInfo[8]}'),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: ElevatedButton(
                                  onPressed: () {
                                    _ShowMore(imei, id);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                  child: Text(
                                    'Show More',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) =>
                  const Center(child: Text('Error loading data')),
            ),
        bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  void _showDatePicker(BuildContext context, String imei) async {
    List<DateTime>? dateTimeList = await showOmniDateTimeRangePicker(
      context: context,
      startInitialDate: DateTime.now(),
      startFirstDate: DateTime(1600).subtract(const Duration(days: 3652)),
      startLastDate: DateTime.now().add(
        const Duration(days: 3652),
      ),
      endInitialDate: DateTime.now(),
      endFirstDate: DateTime(1600).subtract(const Duration(days: 3652)),
      endLastDate: DateTime.now().add(
        const Duration(days: 3652),
      ),
      is24HourMode: true,
      isShowSeconds: false,
      minutesInterval: 1,
      secondsInterval: 1,
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      constraints: const BoxConstraints(
        maxWidth: 350,
        maxHeight: 650,
      ),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1.drive(
            Tween(
              begin: 0,
              end: 1,
            ),
          ),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
      barrierDismissible: true,
      selectableDayPredicate: (dateTime) {
        // Disable 25th Feb 2023
        if (dateTime == DateTime(2023, 2, 25)) {
          return false;
        } else {
          return true;
        }
      },
    );

    if (dateTimeList != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Traget(
            imei: imei,
            startDate: dateTimeList[0],
            endDate: dateTimeList[1],
          ),
        ),
      );
    }
  }
}

Widget component2(
    {required String name,
    required String plateNumber,
    required String imageUrl,
    required int carNumber,
    required int power}) {
  return ClipRRect(
    borderRadius: const BorderRadius.all(Radius.circular(8.0)),
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          height: 44,
          color: Color.fromARGB(206, 40, 102, 218),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                Icons.power,
                color: power == 0 ? Colors.red : Colors.green,
              ),
              Text(
                name, // Correct usage here
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              Text(
                "$carNumber",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ],
          ),
        ),
        Stack(
          children: [
            Image.network(
              imageUrl,
              width: double.infinity,
              height: 146,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/placeholder.png',
                  width: double.infinity,
                  height: 146,
                );
              },
            ),
          ],
        ),
      ],
    ),
  );
}

Widget explainText(String title, String subtitle,
    {Color subtitleColor = Colors.grey}) {
  return Column(
    children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        subtitle,
        style: TextStyle(
          fontSize: 16,
          color: subtitleColor,
        ),
      ),
    ],
  );
}

Widget multipleLineText(String title, String line1, String line2) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      const SizedBox(height: 6),
      Text(
        line1,
        style: const TextStyle(fontSize: 16, color: Colors.black87),
      ),
      const SizedBox(height: 4),
      Text(
        line2,
        style: const TextStyle(fontSize: 14, color: Colors.black54),
      ),
    ],
  );
}
