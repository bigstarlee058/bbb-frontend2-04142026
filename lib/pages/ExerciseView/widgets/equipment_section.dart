// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// import '../../../providers/user_data_provider.dart';
// import '../../../utils/screen_util.dart';
// import '../../../values/app_colors.dart';
//
// class EquipmentSection extends StatefulWidget {
//   const EquipmentSection({super.key});
//
//   @override
//   State<EquipmentSection> createState() => _EquipmentSectionState();
// }
//
// class _EquipmentSectionState extends State<EquipmentSection> {
//   @override
//   Widget build(BuildContext context) {
//     final media = MediaQuery.of(context).size;
//     return Column(
//       children: [
//         const SizedBox(height: 40),
//         Container(
//           height: 0.5,
//           margin: const EdgeInsets.symmetric(horizontal: 40),
//           width: media.width,
//           color: Colors.black12,
//         ),
//         const SizedBox(height: 40),
//         Container(
//           margin: const EdgeInsets.symmetric(horizontal: 20),
//           child: const Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Equipment used',
//                 style: TextStyle(
//                   color: AppColors.primaryColor,
//                   fontSize: 25,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(
//                 height: 15,
//               ),
//               Text(
//                 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
//                 style: TextStyle(
//                   color: Colors.black54,
//                 ),
//               )
//             ],
//           ),
//         ),
//         const SizedBox(
//           height: 20,
//         ),
//         Consumer<UserDataProvider>(
//           builder: (context, userData, child) {
//             if (userData.allExercises.isNotEmpty) {
//               return Column(
//                 children: List.generate(
//                   userData.currentExerciseObj.usedEquipments.length,
//                   (index) => Column(
//                     children: [
//                       equipmentCard(
//                           userData.currentExerciseObj.usedEquipments[index].title,
//                           userData.currentExerciseObj.usedEquipments[index].description,
//                           userData.currentExerciseObj.usedEquipments[index].link,
//                           userData.currentExerciseObj.usedEquipments[0].thumbnail),
//                       if (index < userData.currentExerciseObj.usedEquipments.length - 1) const SizedBox(height: 20),
//                     ],
//                   ),
//                 ),
//               );
//             } else {
//               return const SizedBox();
//             }
//           },
//         ),
//       ],
//     );
//   }
//
//   Widget equipmentCard(String title, String description, String link, String image) {
//     return GestureDetector(
//         onTap: () {
//           _launchURL(link); // Launch the external URL when tapped
//         },
//         child: Container(
//           width: ScreenUtil.horizontalScale(100),
//           height: ScreenUtil.verticalScale(11),
//           margin: const EdgeInsets.symmetric(vertical: 10),
//           // Padding around the background
//           decoration: BoxDecoration(
//             color: AppColors.primaryColor,
//             borderRadius: BorderRadius.all(
//               Radius.circular(ScreenUtil.verticalScale(7)),
//             ),
//           ),
//           child: Row(
//             children: [
//               Container(
//                 height: ScreenUtil.verticalScale(11),
//                 width: ScreenUtil.verticalScale(12),
//
//                 // Padding around the background
//                 decoration: BoxDecoration(
//                   color: AppColors.blackColor,
//                   borderRadius: BorderRadius.only(
//                     topLeft: Radius.circular(ScreenUtil.verticalScale(7)),
//                     bottomLeft: Radius.circular(ScreenUtil.verticalScale(7)),
//                   ),
//                   image: DecorationImage(
//                     image: image.isNotEmpty
//                         ? NetworkImage(image.startsWith('https://storage.cloud.google.com/')
//                             ? image.replaceFirst('https://storage.cloud.google.com/', 'https://storage.googleapis.com/')
//                             : image)
//                         : const AssetImage('assets/img/back.jpg'),
//                     fit: BoxFit.cover,
//                     opacity: 1,
//                   ),
//                 ),
//               ),
//               const SizedBox(
//                 width: 10,
//               ),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     title,
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: ScreenUtil.verticalScale(2),
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   Text(
//                     description,
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: ScreenUtil.verticalScale(1.5),
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//               const Spacer(),
//               CircleAvatar(
//                 backgroundColor: Colors.white,
//                 radius: ScreenUtil.verticalScale(2.5),
//                 child: Center(
//                   child: Icon(
//                     Icons.arrow_forward_ios_rounded,
//                     size: ScreenUtil.horizontalScale(6),
//                     color: AppColors.primaryColor,
//                   ),
//                 ),
//               ),
//               SizedBox(
//                 width: ScreenUtil.horizontalScale(5),
//               ),
//             ],
//           ), // Ensure the background takes up all available space
//         ));
//   }
//
//   Future<void> _launchURL(String url) async {
//     if (await canLaunchUrl(Uri.parse(url))) {
//       await launchUrl(Uri.parse(url));
//     } else {
//       throw 'Could not launch $url';
//     }
//   }
// }
