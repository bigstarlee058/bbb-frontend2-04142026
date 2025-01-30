// import 'package:bbb/pages/ExerciseView/widgets/notes_slideout.dart';
// import 'package:bbb/pages/login_page.dart';
// import 'package:bbb/providers/exercise_history_provider.dart';
// import 'package:bbb/providers/user_data_provider.dart';
// import 'package:expansion_tile_group/expansion_tile_group.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
//
// import '../../../components/button_widget.dart';
// import '../../../components/timer_with_progress.dart';
// import '../../../utils/screen_util.dart';
// import '../../../values/app_colors.dart';
//
// class ExerciseSetCard extends StatefulWidget {
//   const ExerciseSetCard({
//     super.key,
//     required this.title,
//     required this.isOpened,
//     required this.exercise,
//     required this.set,
//     required this.weight,
//     required this.reps,
//     required this.repsInReverse,
//     required this.restDuration,
//     required this.load,
//     required this.index,
//     required this.subIndex,
//     required this.type,
//     required this.exerciseName, required this.isTimerRunning
//   });
//
//   final String title;
//   final String exerciseName;
//   final bool isOpened;
//   final int exercise;
//   final int set;
//   final int weight;
//   final int reps;
//   final int repsInReverse;
//   final int restDuration;
//   final int load;
//   final int index;
//   final int subIndex;
//   final int type;
//   final bool isTimerRunning;
//
//   @override
//   State<ExerciseSetCard> createState() => _ExerciseSetCardState();
// }
//
// class _ExerciseSetCardState extends State<ExerciseSetCard> with AutomaticKeepAliveClientMixin {
//
//     @override
//   bool get wantKeepAlive => true;
//
//   int curExpandedIdx = 0;
//   bool _isExpanded = false;
//   bool _timerCompleted = false;
//   int weight = 5;
//   int reps = 5;
//   int effort = 100;
//   int _restDuration = 30;
//   bool _showTimer = false;
//   late TextEditingController _weightController;
//   late TextEditingController _repsController;
//   UserDataProvider? userData;
//   int load = 0;
//
//   List<String> effortValue = ["0", "1", "2", "3", "4+"];
//
//   late ExerciseHistoryProvider exerciseHistoryProvider;
//
//   @override
//   void initState() {
//     super.initState();
//     debugPrint("this si normal set page ${widget.repsInReverse}");
//     exerciseHistoryProvider =
//         Provider.of<ExerciseHistoryProvider>(context, listen: false);
//     _isExpanded = widget.isOpened;
//     userData = Provider.of<UserDataProvider>(context, listen: false);
//     _showTimer = widget.isTimerRunning;
//     weight = widget.weight;
//     _weightController = TextEditingController(text: '$weight');
//     reps = widget.reps;
//     _repsController = TextEditingController(text: '$reps');
//     effort = widget.repsInReverse;
//     _restDuration = widget.restDuration;
//     load = widget.load;
//   }
//
//   updateHistoryData() {
//     Map<String, dynamic> data = {
//       "date": DateFormat('dd/MM/yyy').format(DateTime.now()),
//       "monthIndex": userData?.currentMonth,
//       "weekIndex": userData?.currentWeek,
//       "dayId": userData!.currentDayObj.id,
//       "exerciseId": userData!.currentExercise.id,
//       "reps": reps,
//       "weight": weight,
//       "rest": _restDuration,
//       "load": load,
//       'rir': effort,
//       "type": widget.type,
//       "split_type": userData?.selectedDaySplit ?? 3,
//       "index": widget.index,
//       "subIndex": widget.subIndex,
//     };
//     exerciseHistoryProvider.updatedObject(data);
//
//     userData?.updateTodayHistoryData(widget.index, widget.subIndex, {
//       'index': widget.index,
//       'subIndex': widget.subIndex,
//       'reps': reps,
//       'weight': weight,
//       'rir': effort,
//       'rest': _restDuration
//     });
//   }
//
//   void _handleTimerComplete() {
//     WidgetsBinding.instance.addPostFrameCallback(
//       (timeStamp) {
//         setState(() {
//           _timerCompleted = true;
//         });
//         updateHistoryData();
//       },
//     );
//   }
//
//   void incrementWeight() {
//     setState(() {
//       int weight1 = int.tryParse(_weightController.text) ?? 0;
//       weight = weight1 + 5;
//       _weightController.text = '$weight';
//     });
//     userData?.saveNormalSetWeight(weight);
//     updateHistoryData();
//   }
//
//   void decrementWeight() {
//     setState(() {
//       int weight1 = int.tryParse(_weightController.text) ?? 0;
//       weight = (weight1 > 5) ? weight1 - 5 : 0;
//       _weightController.text = '$weight';
//     });
//     userData?.saveNormalSetWeight(weight);
//     updateHistoryData();
//   }
//
//   void incrementReps() {
//     setState(() {
//       int reps1 = int.tryParse(_repsController.text) ?? 0;
//       reps = reps1 + 5;
//       _repsController.text = '$reps';
//     });
//     userData?.saveNormalSetReps(reps);
//     updateHistoryData();
//   }
//
//   void decrementReps() {
//     setState(() {
//       int reps1 = int.tryParse(_repsController.text) ?? 0;
//       reps = (reps1 > 5) ? reps1 - 5 : 0;
//       _repsController.text = '$reps';
//     });
//     userData?.saveNormalSetReps(reps);
//     updateHistoryData();
//   }
//
//   void selectEffort(int value) {
//     setState(() {
//       effort = value;
//     });
//     updateHistoryData();
//   }
//
//   void _handleCloseTimer() {
//     WidgetsBinding.instance.addPostFrameCallback(
//       (timeStamp) {
//         setState(() {
//           _showTimer = false;
//           userData?.setShowTimerIndex(-1,-1,-1);
//         });
//         updateHistoryData();
//       },
//     );
//   }
//
//   void decrementLoad() {
//     setState(() {
//       load = (load > 5) ? load - 5 : 0;
//     });
//     updateHistoryData();
//   }
//
//   void incrementLoad() {
//     setState(() {
//       load = load + 5;
//     });
//     updateHistoryData();
//   }
//
//   void _saveData() {
//     // if(effort == 100) {
//     //   showBottomAlert(context, "Select Reps in Reserve Value");
//     // } else {
//     setState(() {
//       reps = int.tryParse(_repsController.text) ?? 0;
//       weight = int.tryParse(_weightController.text) ?? 0;
//       exerciseHistoryProvider
//           .saveExercise(widget.subIndex);
//       userData?.updateOrAddExerciseData(
//           widget.exercise,
//           widget.set,
//           weight,
//           reps,
//           effort,
//           widget.exerciseName);
//       userData?.setShowTimerIndex(widget.index,widget.subIndex,widget.exercise);
//       // _restDuration=widget.set;
//       _showTimer = true;
//     });
//     // }
//   }
//     @override
//   void dispose() {
//     _weightController.dispose();
//     _repsController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     return SingleChildScrollView(
//       child: Consumer<UserDataProvider>(
//         builder: (context, value, child) {
//           _isExpanded =
//               "${widget.index}:${widget.subIndex}" == value.currentExpandedItem;
//           return Column(children: [
//             ExpansionTileGroup(
//               toggleType: ToggleType.expandOnlyCurrent,
//               spaceBetweenItem: 20,
//               onExpansionItemChanged: (idx, isExpand) {
//                 curExpandedIdx = idx;
//               },
//               children: [
//                 ExpansionTileItem(
//                   tilePadding: EdgeInsets.symmetric(
//                     horizontal: ScreenUtil.horizontalScale(4),
//                     vertical: ScreenUtil.verticalScale(0.3),
//                   ),
//                   title: Row(
//                     children: [
//                       Expanded(
//                         child: Row(
//                           children: [
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   widget.title,
//                                   style: GoogleFonts.plusJakartaSans(
//                                     color: AppColors.primaryColor,
//                                     fontSize: 13,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(width: 30),
//                             if (!_isExpanded)
//                               Text(
//                                 '${widget.weight} lbs       ${widget.reps} reps',
//                                 style: GoogleFonts.plusJakartaSans(
//                                   color: Colors.black38,
//                                   fontSize: 13,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ),
//                       if (_timerCompleted)
//                         InkWell(
//                           child: Container(
//                             padding: EdgeInsets.all(
//                               ScreenUtil.verticalScale(0.5),
//                             ),
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               border: Border.all(
//                                 color: AppColors.primaryColor,
//                                 width: 3,
//                               ),
//                               color: AppColors.primaryColor,
//                             ),
//                             child: Icon(
//                               Icons.check,
//                               size: ScreenUtil.verticalScale(2.2),
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                   backgroundColor: const Color(0xFF0D0D0D),
//                   collapsedBackgroundColor: const Color(0xFF0D0D0D),
//                   decoration: _showTimer
//                       ? const BoxDecoration(
//                           borderRadius: BorderRadius.only(
//                             topLeft: Radius.circular(30),
//                             topRight: Radius.circular(30),
//                             bottomLeft: Radius
//                                 .zero, // Set the bottom-left radius to zero
//                             bottomRight: Radius
//                                 .zero, // Set the bottom-right radius to zero
//                           ),
//                           color: Color.fromARGB(255, 248, 248, 248),
//                         )
//                       : BoxDecoration(
//                           borderRadius: BorderRadius.circular(30),
//                           color: const Color.fromARGB(255, 248, 248, 248),
//                         ),
//                   iconColor: const Color(0xFFFAFAFA),
//                   collapsedIconColor: AppColors.primaryColor,
//                   initiallyExpanded: _isExpanded,
//                   onExpansionChanged: (bool expanded) {
//                     value.updateExpandedItem(
//                         expanded ? "${widget.index}:${widget.subIndex}" : "");
//                     value.setShowTimerIndex(-1,-1,-1);
//                     setState(() {
//                       _isExpanded = expanded;
//                     });
//                   },
//                   trailing: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Container(
//                         decoration: const BoxDecoration(
//                             color: AppColors.primaryColor,
//                             borderRadius:
//                                 BorderRadius.all(Radius.circular(25))),
//                         child: Icon(
//                           _isExpanded
//                               ? Icons.keyboard_arrow_up_outlined
//                               : Icons.keyboard_arrow_down_outlined,
//                           color: Colors.white,
//                           size: 33,
//                         ),
//                       ),
//                     ],
//                   ),
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 5),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               const Text(
//                                 'LOAD :',
//                                 style: TextStyle(
//                                     color: Colors.black54, fontSize: 13),
//                               ),
//                               Text(
//                                 ' $load%',
//                                 style: const TextStyle(
//                                     color: Colors.black54, fontSize: 14),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 20),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   const Text(
//                                     'WEIGHT (LB)',
//                                     style: TextStyle(
//                                         color: Colors.black54, fontSize: 13),
//                                   ),
//                                   const SizedBox(height: 8),
//                                   Container(
//                                     decoration: BoxDecoration(
//                                       color: Colors.white,
//                                       boxShadow: [
//                                         BoxShadow(
//                                           color: Colors.black.withOpacity(0.03),
//                                           spreadRadius: 2,
//                                           blurRadius: 5,
//                                           offset: const Offset(0, 3),
//                                         ),
//                                       ],
//                                     ),
//                                     padding: EdgeInsets.symmetric(
//                                       horizontal:
//                                           ScreenUtil.horizontalScale(1.5),
//                                       vertical: ScreenUtil.verticalScale(0.3),
//                                     ),
//                                     child: Row(
//                                       children: [
//                                         IconButton(
//                                           icon: const Icon(Icons.remove),
//                                           color: AppColors.primaryColor,
//                                           onPressed: decrementWeight,
//                                         ),
//                                         SizedBox(
//                                           width: 25,
//                                           child: TextField(
//                                             key: Key('weight-${widget.index}:${widget.subIndex}1'),
//                                             controller: _weightController,
//                                             keyboardType: const TextInputType.numberWithOptions(decimal: false),
//                                             textAlign: TextAlign.center,
//                                             decoration: const InputDecoration(
//                                               border: InputBorder.none,
//                                             ),
//                                             inputFormatters: [
//                                               FilteringTextInputFormatter.digitsOnly, // Allow only digits
//                                               TextInputFormatter.withFunction((oldValue, newValue) {
//                                                 // Remove leading zeros if the input is not empty
//                                                 String newText = newValue.text;
//                                                 if (newText.isNotEmpty) {
//                                                   newText = newText.replaceFirst(RegExp(r'^0+'), ''); // Remove leading zeros
//                                                 }
//                                                 return TextEditingValue(
//                                                   text: newText,
//                                                   selection: TextSelection.collapsed(offset: newText.length),
//                                                 );
//                                               }),
//                                             ],
//                                           ),
//                                         ),
//                                         IconButton(
//                                           icon: const Icon(Icons.add),
//                                           color: AppColors.primaryColor,
//                                           onPressed: incrementWeight,
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   const Text(
//                                     'REPS',
//                                     style: TextStyle(
//                                         color: Colors.black54, fontSize: 13),
//                                   ),
//                                   const SizedBox(height: 8),
//                                   Container(
//                                     padding: EdgeInsets.symmetric(
//                                       horizontal:
//                                           ScreenUtil.horizontalScale(1.5),
//                                       vertical: ScreenUtil.verticalScale(0.3),
//                                     ),
//                                     decoration: BoxDecoration(
//                                       color: Colors.white,
//                                       boxShadow: [
//                                         BoxShadow(
//                                           color: Colors.black.withOpacity(0.03),
//                                           spreadRadius: 2,
//                                           blurRadius: 5,
//                                           offset: const Offset(0, 3),
//                                         ),
//                                       ],
//                                     ),
//                                     child: Row(
//                                       children: [
//                                         IconButton(
//                                           icon: const Icon(Icons.remove),
//                                           color: AppColors.primaryColor,
//                                           onPressed: decrementReps,
//                                         ),
//                                         SizedBox(
//                                           width: 25,
//                                           child: TextField(
//                                             key: Key('weight-${widget.index}:${widget.subIndex}2'),
//                                             controller: _repsController,
//                                             keyboardType: const TextInputType.numberWithOptions(decimal: false),
//                                             textAlign: TextAlign.center,
//                                             decoration: const InputDecoration(
//                                               border: InputBorder.none,
//                                             ),
//                                             inputFormatters: [
//                                               FilteringTextInputFormatter.digitsOnly, // Allow only digits
//                                               TextInputFormatter.withFunction((oldValue, newValue) {
//                                                 // Remove leading zeros if the input is not empty
//                                                 String newText = newValue.text;
//                                                 if (newText.isNotEmpty) {
//                                                   newText = newText.replaceFirst(RegExp(r'^0+'), ''); // Remove leading zeros
//                                                 }
//                                                 return TextEditingValue(
//                                                   text: newText,
//                                                   selection: TextSelection.collapsed(offset: newText.length),
//                                                 );
//                                               }),
//                                             ],
//                                           ),
//                                         ),
//                                         IconButton(
//                                           icon: const Icon(Icons.add),
//                                           color: AppColors.primaryColor,
//                                           onPressed: incrementReps,
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 24),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               const Text(
//                                 'REPS IN RESERVE',
//                                 style:
//                                 TextStyle(color: Colors.black54, fontSize: 13),
//                               ),
//                               GestureDetector(
//                                 onTap: () {
//                                   showModalBottomSheet(
//                                     backgroundColor: Colors.white,
//                                     context: context,
//                                     isScrollControlled: true, // This makes the modal expand fully
//                                     builder: (BuildContext context) {
//                                       return const NotesSlideout();
//                                     },
//                                   );
//                                 },
//                                 child:  const Text(
//                                   "WHAT'S RIR?",
//                                   style:
//                                   TextStyle(color: AppColors.skipDayColor, fontSize: 13,),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 10),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: List.generate(5, (index) {
//                               return ChoiceChip(
//                                 label: Text(effortValue[index]),
//                                 selected: effort == index,
//                                 onSelected: (bool selected) {
//                                   selectEffort(selected ? index : 100);
//                                 },
//                                 padding: EdgeInsets.symmetric(
//                                   horizontal: ScreenUtil.horizontalScale(2),
//                                   vertical: ScreenUtil.verticalScale(2),
//                                 ),
//                                 shape: const RoundedRectangleBorder(
//                                   side: BorderSide(color: Colors.white),
//                                 ),
//                                 backgroundColor: Colors.white,
//                                 selectedColor: AppColors.primaryColor,
//                                 labelStyle: TextStyle(
//                                   color: effort == index
//                                       ? Colors.white
//                                       : Colors.black,
//                                 ),
//                                 checkmarkColor: Colors.white,
//                                 // Set checkmark (icon) color to white when selected
//                                 showCheckmark:
//                                     true, // Ensure the checkmark is displayed when selected
//                               );
//                             }),
//                           ),
//                           const SizedBox(height: 30),
//                           ButtonWidget(
//                             text: "Save & start rest timer",
//                             textColor: Colors.white,
//                             onPress: () {
//                               _saveData();
//                             },
//                             color: AppColors.primaryColor,
//                             isLoading: false,
//                           ),
//                         ],
//                       ),
//                     ),
//                     SizedBox(
//                       height: ScreenUtil.verticalScale(2),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             if (_showTimer) ...[
//               TimerWithProgressBar(
//                 isTimerRunning: widget.isTimerRunning,
//                 currentTime: userData?.timePassed ?? "0",
//                 initialDuration: _restDuration,
//                 onClose: _handleCloseTimer,
//                 onComplete: _handleTimerComplete,
//               ),
//             ],
//           ]);
//         },
//       ),
//     );
//   }
// }
