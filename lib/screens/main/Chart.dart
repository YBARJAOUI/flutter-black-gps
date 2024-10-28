// import 'package:blackgps/constants/colors.dart';
// import 'package:blackgps/utils/ApiService.dart';
// import 'package:blackgps/utils/TokenManagement.dart';
// import 'package:flutter/material.dart';

// class Chart extends StatefulWidget {
//   final String imei;

//   Chart({required this.imei});

//   @override
//   _ChartState createState() => _ChartState();
// }

// class _ChartState extends State<Chart> {
//   Map<String, dynamic> historyOdometer = {};
//   bool isLoading = true;
//   double totalKm = 0;
//   int selectedYear = DateTime.now().year;
//   int selectedMonth = DateTime.now().month;

//   void trajetinfo() async {
//     final apiService = ApiService();
//     final token = await TokenStorage().loadTokens();

//     if (token == null) {
//       print("Token is null");
//       setState(() {
//         isLoading = false;
//       });
//       return;
//     }
//     try {
//       final response = await apiService.get(
//           'app/stats/${widget.imei}/$selectedYear/$selectedMonth',
//           headers: {
//             'Content-Type': 'application/json',
//             'Authorization': 'Bearer ${token['accessToken']}'
//           });
//       if (response != null) {
//         print('Response: $response');
//         setState(() {
//           historyOdometer = response.first["total_odometer_summary"];
//           if (historyOdometer.isNotEmpty) {
//             totalKm = historyOdometer.values
//                 .fold(0, (sum, value) => sum + (value as num).toDouble());
//           }
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       showDialog(
//         context: context,
//         builder: (context) {
//           return AlertDialog(
//             title: Text('Erreur'),
//             content: Text('Pas de données pour ce jour : $e'),
//             actions: <Widget>[
//               TextButton(
//                 child: Text('OK'),
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                   Navigator.of(context).pop();
//                 },
//               ),
//             ],
//           );
//         },
//       );
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   // @override
//   // void initState() {
//   //   super.initState();
//   //   trajetinfo();
//   // }

//   void showerror(BuildContext context, Object e) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text('Erreur'),
//           content: Text('Pas de données pour ce jour : $e'),
//           actions: <Widget>[
//             TextButton(
//               child: Text('OK'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<void> _selectDate(BuildContext context) async {
//     return showDialog<void>(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Sélectionner une date'),
//           content: SingleChildScrollView(
//             child: Column(
//               children: <Widget>[
//                 DropdownButton<int>(
//                   value: selectedYear,
//                   onChanged: (int? value) {
//                     setState(() {
//                       selectedYear = value!;
//                     });
//                   },
//                   items: List.generate(
//                           10, (index) => DateTime.now().year - 5 + index)
//                       .map((int year) {
//                     return DropdownMenuItem<int>(
//                       value: year,
//                       child: Text('$year'),
//                     );
//                   }).toList(),
//                 ),
//                 DropdownButton<int>(
//                   value: selectedMonth,
//                   onChanged: (int? value) {
//                     setState(() {
//                       selectedMonth = value!;
//                     });
//                   },
//                   items:
//                       List.generate(12, (index) => index + 1).map((int month) {
//                     return DropdownMenuItem<int>(
//                       value: month,
//                       child: Text('$month'),
//                     );
//                   }).toList(),
//                 ),
//               ],
//             ),
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: Text('OK'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 setState(() {
//                   isLoading = true;
//                 });
//                 trajetinfo();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Analyse KM',
//           style: TextStyle(color: CustomColors.whiteColor, fontSize: 24),
//         ),
//         backgroundColor: CustomColors.blueColor,
//         iconTheme: IconThemeData(color: Colors.white),
//         actions: [
//           IconButton(
//             icon: Icon(
//               Icons.calendar_today,
//               color: Colors.white,
//             ),
//             onPressed: () {
//               _selectDate(context);
//             },
//           ),
//         ],
//       ),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Text(
//                     'trajets pour le mois: ${(totalKm / 1000).toStringAsFixed(2)} KM',
//                     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                   ),
//                 ),
//                 Expanded(
//                   child: SingleChildScrollView(
//                     scrollDirection: Axis.horizontal,
//                     child: SingleChildScrollView(
//                       scrollDirection: Axis.vertical,
//                       child: ConstrainedBox(
//                         constraints: BoxConstraints(
//                           minWidth: MediaQuery.of(context).size.width,
//                         ),
//                         child: DataTable(
//                           columns: const <DataColumn>[
//                             DataColumn(
//                               label: Text(
//                                 'DATE',
//                                 style: TextStyle(fontStyle: FontStyle.italic),
//                               ),
//                             ),
//                             DataColumn(
//                               label: Text(
//                                 'TRAJET(KM)',
//                                 style: TextStyle(fontStyle: FontStyle.italic),
//                               ),
//                             ),
//                           ],
//                           rows: historyOdometer.entries
//                               .map(
//                                 (entry) => DataRow(
//                                   cells: [
//                                     DataCell(Text(entry.key)),
//                                     DataCell(Text(
//                                         '${(entry.value / 1000).toStringAsFixed(2)}')),
//                                   ],
//                                 ),
//                               )
//                               .toList(),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }
// }

import 'package:blackgps/constants/colors.dart';
import 'package:blackgps/utils/ApiService.dart';
import 'package:blackgps/utils/TokenManagement.dart';
import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';

class Chart extends StatefulWidget {
  final String imei;
  final int id;

  Chart({required this.imei, required this.id});

  @override
  _ChartState createState() => _ChartState();
}

class _ChartState extends State<Chart> {
  Map<String, dynamic> historyOdometer = {};
  bool isLoading = true;
  double totalKm = 0;
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;
  double averageSpeed = 0;
  double totalIgnitionTime = 0;
  double averageFuelUse = 0;

  bool tiresIsDone = false;
  bool oilIsDone = false;
  bool distributionChainIsDone = false;
  String? tiresDistance;
  String? nextTiresAlert;
  String? oilDistance;
  String? nextOilAlert;
  String? distributionChain;
  String? nextDistributionChain;
  int countalert = 0;
  @override
  void initState() {
    super.initState();
    trajetinfo();
  }

  void trajetinfo() async {
    final apiService = ApiService();
    final token = await TokenStorage().loadTokens();

    if (token == null) {
      print("Token is null");
      setState(() {
        isLoading = false;
      });
      return;
    }
    try {
      final res = await apiService.get('app/alerts/${widget.id}', headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${token['accessToken']}'
      });
      if (res != null) {
        setState(() {
          tiresIsDone = res[0]['tires_is_done'];
          oilIsDone = res[0]['oil_is_done'];
          distributionChainIsDone = res[0]['distribution_chaine_is_done'];
          tiresDistance = res[0]['tires_distance'];
          nextTiresAlert = res[0]['next_tires_alert'];
          oilDistance = res[0]['oil_distance'];
          nextOilAlert = res[0]['next_oil_alert'];
          distributionChain = res[0]['distribution_chaine'];
          nextDistributionChain = res[0]['next_distribution_chaine'];
          if (tiresIsDone) {
            countalert++;
          }
          if (oilIsDone) {
            countalert++;
          }
          if (distributionChainIsDone) {
            countalert++;
          }
        });
      }

      final response = await apiService.get(
          'app/stats/${widget.imei}/$selectedYear/$selectedMonth',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${token['accessToken']}'
          });
      if (response != null) {
        setState(() {
          historyOdometer = response[0]["total_odometer_summary"];
          print('History Odometer: $historyOdometer');
          totalKm = historyOdometer.values.fold(
              0, (sum, value) => sum + (value["odometer"] as num).toDouble());
          averageSpeed = response[0]["stats"]["average_speed"];
          totalIgnitionTime = response[0]["stats"]["total_ignition_time_hours"];
          averageFuelUse = response[0]["stats"]["average_fuel_use"];
          isLoading = false;
        });
      }
    } catch (e) {
      showerror(context, e);
      setState(() {
        isLoading = false;
        averageSpeed = 0;
        totalIgnitionTime = 0;
        averageFuelUse = 0;
      });
    }
  }

  void showerror(BuildContext context, Object e) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Erreur'),
          content: Text('Pas de données pour ce jour '),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    int tempSelectedYear = selectedYear;
    int tempSelectedMonth = selectedMonth;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Sélectionner une date'),
              content: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    DropdownButton<int>(
                      value: tempSelectedYear,
                      onChanged: (int? value) {
                        setState(() {
                          tempSelectedYear = value!;
                        });
                      },
                      items: List.generate(
                              10, (index) => DateTime.now().year - 5 + index)
                          .map((int year) {
                        return DropdownMenuItem<int>(
                          value: year,
                          child: Text('$year'),
                        );
                      }).toList(),
                    ),
                    DropdownButton<int>(
                      value: tempSelectedMonth,
                      onChanged: (int? value) {
                        setState(() {
                          tempSelectedMonth = value!;
                        });
                      },
                      items: List.generate(12, (index) => index + 1)
                          .map((int month) {
                        return DropdownMenuItem<int>(
                          value: month,
                          child: Text('$month'),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    setState(() {
                      selectedYear = tempSelectedYear;
                      selectedMonth = tempSelectedMonth;
                      isLoading = true;
                    });
                    Navigator.of(context).pop();
                    trajetinfo();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void showAlertDetailsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // This allows the bottom sheet to take full height if necessary
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          child: Wrap(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Alert Details',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  _buildAlertDetailRow(
                      Icons.local_car_wash, 'Tires Distance', tiresDistance),
                  _buildAlertDetailRow(Icons.notification_important,
                      'Next Tires Alert', nextTiresAlert),
                  _buildAlertDetailRow(
                      Icons.oil_barrel, 'Oil Distance', oilDistance),
                  _buildAlertDetailRow(Icons.notification_important,
                      'Next Oil Alert', nextOilAlert),
                  _buildAlertDetailRow(
                      Icons.settings, 'Distribution Chain', distributionChain),
                  _buildAlertDetailRow(Icons.notification_important,
                      'Next Distribution Chain', nextDistributionChain),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Functionality to modify alert details
                      _showModifyAlertDialog(context);
                    },
                    child: Text('Modify'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAlertDetailRow(IconData icon, String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: CustomColors.blueColor),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              '$title: $value',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _showModifyAlertDialog(BuildContext context) {
    // You can add functionality to modify alert details here
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Modify Alert Details'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildModifyAlertField('Tires Distance', tiresDistance,
                    (value) => tiresDistance = value),
                _buildModifyAlertField('Next Tires Alert', nextTiresAlert,
                    (value) => nextTiresAlert = value),
                _buildModifyAlertField('Oil Distance', oilDistance,
                    (value) => oilDistance = value),
                _buildModifyAlertField('Next Oil Alert', nextOilAlert,
                    (value) => nextOilAlert = value),
                _buildModifyAlertField('Distribution Chain', distributionChain,
                    (value) => distributionChain = value),
                _buildModifyAlertField(
                    'Next Distribution Chain',
                    nextDistributionChain,
                    (value) => nextDistributionChain = value),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                setState(() {
                  // Save the modified alert details here
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildModifyAlertField(
      String label, String? initialValue, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        controller: TextEditingController(text: initialValue),
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('STATISTIQUE',
            style: TextStyle(color: Colors.white, fontSize: 24)),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: CustomColors.blueColor,
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_month),
            onPressed: () {
              _selectDate(context);
            },
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [CustomColors.blueColor, Colors.blue],
          ),
        ),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  _buildHeader(),
                  SizedBox(height: 20),
                  Expanded(child: _buildTimeline()),
                ],
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildHeaderItem(
          Icons.local_gas_station,
          'Fuel Usage',
          '$averageFuelUse L',
          () {
            // Action for Fuel Usage icon tap
            print('Fuel Usage tapped');
          },
        ),
        _buildHeaderItem(
          Icons.speed,
          'Average Speed',
          '$averageSpeed km/h',
          () {
            // Action for Average Speed icon tap
            print('Average Speed tapped');
          },
        ),
        _buildHeaderItem(
          Icons.timer,
          'Time of work',
          '${totalIgnitionTime.toStringAsFixed(2)} hrs',
          () {
            // Action for Time of work icon tap
            print('Time of work tapped');
          },
        ),
        _buildHeaderItem(Icons.warning, 'Alerts', '$countalert', () {
          showAlertDetailsBottomSheet(context);
        }),
      ],
    );
  }

  Widget _buildHeaderItem(
      IconData icon, String title, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 30.0,
          ),
          SizedBox(height: 8.0),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    return ListView(
      children: historyOdometer.entries.map((entry) {
        final date = entry.key;
        final formattedDate = _formatDate(date);
        final odometer = entry.value["odometer"] / 1000;
        final ignitionTimeHours = entry.value["ignition_time_hours"];
        final tripInfo =
            'Total: ${odometer.toStringAsFixed(2)} km\nIgnition Time: ${ignitionTimeHours.toStringAsFixed(2)} hrs';

        return _buildTimelineTile(
          date: formattedDate,
          tripInfo: tripInfo,
        );
      }).toList(),
    );
  }

  String _formatDate(String date) {
    final parts = date.split('-');
    return '${parts[1]}-${parts[2]}'; // Format to MM-DD
  }

  Widget _buildTimelineTile({required String date, required String tripInfo}) {
    return TimelineTile(
      alignment: TimelineAlign.manual,
      lineXY: 0.25,
      indicatorStyle: IndicatorStyle(
        width: 40,
        height: 40,
        indicator: Icon(
          Icons.directions_car,
          color: Colors.white,
        ),
        color: Colors.white,
      ),
      beforeLineStyle: LineStyle(
        color: Colors.white,
        thickness: 2,
      ),
      afterLineStyle: LineStyle(
        color: Colors.white,
        thickness: 2,
      ),
      startChild: Container(
        alignment: Alignment.center,
        child: Text(
          date,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
          ),
        ),
      ),
      endChild: Container(
        margin: EdgeInsets.all(8.0),
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Text(
          tripInfo,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
          ),
        ),
      ),
    );
  }
}
