import 'package:blackgps/components/CustomBottomNavBar.dart';
import 'package:blackgps/constants/colors.dart';
import 'package:blackgps/providers/commonProviders.dart';
import 'package:blackgps/providers/homeProviders.dart';
import 'package:blackgps/providers/settingsProviders.dart';
import 'package:blackgps/utils/TokenManagement.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends ConsumerStatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  @override
  void initState() {
    super.initState();
    ref.read(fetchUserProvider);
  }

  Future<void> changeNotificationState(WidgetRef ref, bool notif) async {
    final apiService = ref.read(apiServiceProvider);

    final tokens = await TokenStorage().loadTokens();

    if (tokens == null) {
      print("Token is null");
      return;
    }

    try {
      await apiService.put('app/users', data: {
        "is_notification": true
      }, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${tokens['accessToken']}'
      });

      ref.read(isNotificationProvider.notifier).state = notif;
    } catch (e) {
      print('Error updating notification state: $e');
    }
  }

  Future<void> updateUserProfile(WidgetRef ref) async {
    final apiService = ref.read(apiServiceProvider);

    final tokens = await TokenStorage().loadTokens();
    if (tokens == null) {
      print("Token is null");
      return;
    }

    try {
      final data = {
        "first_name": ref.read(firstNameControllerProvider).text,
        "last_name": ref.read(lastNameControllerProvider).text,
        "phone": ref.read(phoneControllerProvider).text,
      };
      await apiService.put('app/users', data: data, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${tokens['accessToken']}'
      });
      Navigator.pop(context);
    } catch (e) {
      print('Error updating profile: $e');
    }
  }

  Future<void> changePassword(WidgetRef ref) async {
    final apiService = ref.read(apiServiceProvider);
    final tokens = await TokenStorage().loadTokens();

    if (tokens == null) {
      print("Token is null");
      return;
    }

    if (ref.read(newPasswordControllerProvider).text !=
        ref.read(confirmPasswordControllerProvider).text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('settings.passwordnotmatch'.tr()),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pop(context);
      return;
    }

    try {
      final data = {
        "password": ref.read(newPasswordControllerProvider).text,
      };
      await apiService.put('app/users', data: data, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${tokens['accessToken']}'
      });
      Navigator.pop(context);
    } catch (e) {
      print('Error changing password: $e');
    }
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
        break;
      default:
    }

    ref.read(selectedIndexProvider.notifier).state = index;
  }

  void _changeLanguage(Locale locale) {
    context.setLocale(locale);
  }

  void _showLanguageBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.0),
              topRight: Radius.circular(15.0),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.language),
                title: Text('English'),
                onTap: () {
                  _changeLanguage(Locale('en', 'US'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.language),
                title: Text('Français'),
                onTap: () {
                  _changeLanguage(Locale('fr', 'FR'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.language),
                title: Text('العربية'),
                onTap: () {
                  _changeLanguage(Locale('ar', 'AR'));
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditProfileBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: ref.read(firstNameControllerProvider),
                decoration: InputDecoration(
                  labelText: 'settings.firstname'.tr(),
                ),
              ),
              TextField(
                controller: ref.read(lastNameControllerProvider),
                decoration: InputDecoration(
                  labelText: 'settings.lastname'.tr(),
                ),
              ),
              TextField(
                controller: ref.read(phoneControllerProvider),
                decoration: InputDecoration(
                  labelText: 'settings.phone'.tr(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => updateUserProfile(ref),
                child: Text('settings.save'.tr()),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showChangePasswordBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: ref.read(newPasswordControllerProvider),
                decoration: InputDecoration(
                  labelText: 'settings.newpassword'.tr(),
                ),
                obscureText: true,
              ),
              TextField(
                controller: ref.read(confirmPasswordControllerProvider),
                decoration: InputDecoration(
                  labelText: 'settings.confirmpassword'.tr(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => changePassword(ref),
                child: Text('settings.save'.tr()),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isNotification = ref.watch(isNotificationProvider);
    final selectedIndex = ref.watch(selectedIndexProvider);

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('settings.settings'.tr(),
              style: TextStyle(color: CustomColors.whiteColor)),
          backgroundColor: CustomColors.blueColor,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Account Section
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text('settings.account'.tr(),
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      ListTile(
                        leading: Icon(Icons.person),
                        title: Text('settings.profile'.tr()),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          _showEditProfileBottomSheet(context);
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.security),
                        title: Text('settings.password'.tr()),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          _showChangePasswordBottomSheet(context);
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                // Notifications Section
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text('settings.notifications'.tr(),
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      SwitchListTile(
                        title: Text('settings.in_app_notifications'.tr()),
                        value: isNotification,
                        onChanged: (bool value) =>
                            changeNotificationState(ref, value),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                // Other Settings Section
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text('settings.other_settings'.tr(),
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      ListTile(
                        leading: Icon(Icons.language),
                        title: Text('settings.language'.tr()),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          _showLanguageBottomSheet(context);
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.help),
                        title: Text('settings.help_support'.tr()),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          // Navigate to Help & Support
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
