import 'package:blackgps/components/CustomBottomNavBar.dart';
import 'package:blackgps/constants/colors.dart';
import 'package:blackgps/providers/homeProviders.dart';
import 'package:blackgps/providers/myCarsProviders.dart';
import 'package:blackgps/screens/main/traget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class MyCars extends ConsumerStatefulWidget {
  @override
  _MyCarsState createState() => _MyCarsState();
}

class _MyCarsState extends ConsumerState<MyCars> {
  String? selectedDate;

  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        GoRouter.of(context).push('/home');
        break;
      case 1:
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

  Future<void> sendCommand(String phone, String commande) async {
    final Uri smsLaunchUri = Uri(
      scheme: 'sms',
      path: phone,
      queryParameters: {
        'body': commande,
      },
    );

    if (!await launchUrl(smsLaunchUri)) {
      throw Exception('Could not launch $smsLaunchUri');
    }
  }

  @override
  void initState() {
    super.initState();
    ref.read(fetchCarsFutureProvider);
  }

  void _showCommandsCar(BuildContext context, String phonenumber) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 10.0, // space between buttons
            runSpacing: 10.0, // space between lines
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  sendCommand(phonenumber, 'ggps');
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                ),
                child: Column(
                  children: [
                    Image.asset('assets/placeholder.png',
                        width: 40, height: 40), // Replace with your image asset
                    SizedBox(height: 10),
                    Text('mycars.getposition'.tr(),
                        style: TextStyle(fontSize: 10)),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  sendCommand(phonenumber, 'checkimei');
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                ),
                child: Column(
                  children: [
                    Image.asset('assets/reboot.png',
                        width: 40, height: 40), // Replace with your image asset
                    SizedBox(height: 10),
                    Text('mycars.reboot'.tr(), style: TextStyle(fontSize: 10)),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  sendCommand(phonenumber, 'setdigout0');
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                ),
                child: Column(
                  children: [
                    Image.asset('assets/play.png',
                        width: 40, height: 40), // Replace with your image asset
                    SizedBox(height: 10),
                    Text('mycars.startengine'.tr(),
                        style: TextStyle(fontSize: 10)),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  sendCommand(phonenumber, 'setdigout1');
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                ),
                child: Column(
                  children: [
                    Image.asset('assets/stop.png',
                        width: 40, height: 40), // Replace with your image asset
                    SizedBox(height: 10),
                    Text('mycars.stopengine'.tr(),
                        style: TextStyle(fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardata = ref.watch(cardataProvider);

    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        extendBody: true,
        appBar: AppBar(
          backgroundColor: CustomColors.blueColor,
          automaticallyImplyLeading: false,
          title: Text(
            'mycars.mycars'.tr(),
            style: TextStyle(
              color: CustomColors.whiteColor,
              fontSize: 24,
            ),
          ),
        ),
        body: ref.watch(fetchCarsFutureProvider).when(
              data: (_) {
                return ListView.builder(
                  itemCount: cardata.length,
                  itemBuilder: (context, index) {
                    print("contecxt  sad : ${cardata}");
                    String imei = cardata.keys.elementAt(index);
                    List<dynamic>? carInfo = cardata[imei];

                    if (carInfo == null || carInfo.length < 5) {
                      return ListTile(
                        title: Text('Data not available'),
                      );
                    }

                    String name = carInfo[0] ?? 'Unknown';
                    int carNumber = carInfo[1] ?? 'Unknown';
                    String plateNumber = carInfo[2] ?? 'Unknown';
                    String gpsdevicePhoneNumber = carInfo[9] ?? 'Unknown';
                    String imageUrl = carInfo[3] != null
                        ? "https://mobile.blackgps.xyz${carInfo[3]}"
                        : 'assets/placeholder.png';

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      elevation: 5.0,
                      margin: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 15.0),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: GestureDetector(
                            onTap: () {
                              context.go(
                                ('/tracking/$imei/${carInfo[11]}/${carInfo[12]}'),
                              );
                            },
                            child: Image.network(
                              imageUrl, // Ensure you have an image asset with this path
                              width: 76,
                              height: 76,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/placeholder.png',
                                  width: 76,
                                  height: 76,
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                          ),
                        ),
                        title: Text(
                          "${carNumber} - ${name}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        subtitle: Text(
                          plateNumber,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                Boxicons.bx_cog,
                                color: CustomColors.redColor,
                              ),
                              onPressed: () {
                                _showCommandsCar(context, gpsdevicePhoneNumber);
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                Boxicons.bx_map,
                                color: CustomColors.greenColor,
                              ),
                              onPressed: () {
                                _showDatePicker(context, imei);
                              },
                            ),
                          ],
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 16.0,
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
