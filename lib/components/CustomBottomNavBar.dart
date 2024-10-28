import 'package:blackgps/constants/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:molten_navigationbar_flutter/molten_navigationbar_flutter.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        child: MoltenBottomNavigationBar(
          barColor: Colors.blue,
          domeCircleColor: Colors.white,
          selectedIndex: currentIndex,
          onTabChange: onTap,
          tabs: [
            MoltenTab(
              icon: Icon(
                Boxicons.bx_home,
                color: currentIndex == 0
                    ? CustomColors.blueColor
                    : CustomColors.unselectedColor,
                size: 30,
              ),
            ),
            MoltenTab(
              icon: Icon(
                Boxicons.bx_car,
                color: currentIndex == 1
                    ? CustomColors.blueColor
                    : CustomColors.unselectedColor,
                size: 30,
              ),
            ),
            MoltenTab(
              icon: Icon(
                Boxicons.bx_bar_chart_alt,
                color: currentIndex == 2
                    ? CustomColors.blueColor
                    : CustomColors.unselectedColor,
                size: 30,
              ),
            ),
            MoltenTab(
              icon: Icon(
                Boxicons.bx_cog,
                color: currentIndex == 3
                    ? CustomColors.blueColor
                    : CustomColors.unselectedColor,
                size: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
