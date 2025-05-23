import 'package:bbb/providers/main_page_provider.dart';
import 'package:bbb/providers/month_provider.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CommonStreakWithNotification extends StatefulWidget {
  const CommonStreakWithNotification({super.key, required this.routeString});
  final String routeString;
  @override
  State<CommonStreakWithNotification> createState() => _CommonStreakWithNotificationState();
}

class _CommonStreakWithNotificationState extends State<CommonStreakWithNotification> {
  MonthProvider? monthProvider;
  late MainPageProvider mainPageProvider;

  @override
  void initState() {
    mainPageProvider = Provider.of<MainPageProvider>(context, listen: false);
    monthProvider = Provider.of<MonthProvider>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final streak = context.watch<MonthProvider>();
    return Row(
      children: [
        IconButton(
          onPressed: () async {
            Navigator.pushNamed(context, '/streak-calendar');
            // monthProvider?.routeString = widget.routeString;
            // Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
            // mainPageProvider.changeTab(4);
          },
          icon: Container(
            height: ScreenUtil.verticalScale(2.2),
            width: ScreenUtil.verticalScale(4.8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: ScreenUtil.verticalScale(2.2),
                  width: ScreenUtil.verticalScale(2.2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white),
                  ),
                  child: Center(
                    child: Text(
                      '${streak.streak}',
                      style: TextStyle(
                        fontSize: ScreenUtil.verticalScale(1.4),
                        height: 0,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Icon(
                    Icons.local_fire_department_outlined,
                    color: Colors.white,
                    size: ScreenUtil.verticalScale(2.5),
                  ),
                )
              ],
            ),
          ),
        ),

        /// UNCOMMENT ICON BUTTON IF PUT NOTIFICATION ICON BACK
        // IconButton(
        //   onPressed: () {
        //     Navigator.pushNamed(context, '/notifications');
        //   },
        //   icon: Icon(
        //     Icons.notifications_none,
        //     color: Colors.white,
        //     size: ScreenUtil.verticalScale(3),
        //   ),
        // )
      ],
    );
  }
}
