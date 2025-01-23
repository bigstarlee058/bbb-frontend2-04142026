import 'package:bbb/models/dayexercise.dart';
import 'package:bbb/models/pump_day_model.dart';
import 'package:bbb/pages/MonthlyView/today_page.dart';
import 'package:flutter/material.dart';
import 'package:mobkit_dashed_border/mobkit_dashed_border.dart';
import '../../utils/screen_util.dart';
import '../../values/app_colors.dart';

class CircuitsView extends StatefulWidget {
  final List<Circuit> circuit;

  const CircuitsView({super.key, required this.circuit});

  @override
  State<CircuitsView> createState() => _CircuitsViewState();
}

class _CircuitsViewState extends State<CircuitsView> {
  int selectedCircuit = 0;
  int completedRound = 0;

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        ///CircuitsBuilder
        ListView.builder(
          itemCount: widget.circuit.length,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, circuitsIndex) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(right: ScreenUtil.verticalScale(3)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Circuits ${circuitsIndex + 1} : ${widget.circuit[circuitsIndex].round} Rounds",
                      style: TextStyle(
                        fontSize: ScreenUtil.horizontalScale(3),
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),

                    ///round indicator
                    Row(
                      children: List.generate(
                        widget.circuit[circuitsIndex].round!,
                        (index) {
                          return GestureDetector(
                            onTap: () {},
                            child: Container(
                              height: ScreenUtil.verticalScale(4),
                              width: ScreenUtil.verticalScale(4),
                              // padding: EdgeInsets.all(ScreenUtil.verticalScale(0.8)),
                              margin: const EdgeInsets.only(left: 10),
                              decoration: BoxDecoration(
                                color: completedRound >= index ? AppColors.primaryColor : Colors.transparent,
                                border: Border.all(color: completedRound >= index ? Colors.transparent : AppColors.primaryColor),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: completedRound >= index
                                    ? Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: ScreenUtil.verticalScale(2.5),
                                      )
                                    : Text(
                                        "${index + 1}",
                                        style: TextStyle(
                                          fontSize: ScreenUtil.horizontalScale(3),
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primaryColor,
                                        ),
                                      ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                width: media.height * 0.14,
                decoration: const BoxDecoration(
                  border: DashedBorder(
                    spaceLength: 5,
                    strokeCap: StrokeCap.round,
                    dashLength: 1,
                    top: BorderSide(color: AppColors.primaryColor, width: 1),
                  ),
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  border: DashedBorder(
                    spaceLength: 5,
                    strokeCap: StrokeCap.round,
                    dashLength: 1.5,
                    left: BorderSide(color: AppColors.primaryColor, width: 1),
                  ),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ExpandablePageView(
                      onPageChanged: (value) {
                        selectedCircuit = value;
                        setState(() {});
                      },

                      ///round builder
                      children: List.generate(
                        widget.circuit[circuitsIndex].round!,
                        (roundIndex) {
                          return Container(
                            margin: EdgeInsets.only(right: ScreenUtil.verticalScale(3)),

                            ///exercisesBuilder
                            child: ListView.builder(
                              itemCount: widget.circuit[circuitsIndex].circuitExercises!.length,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemBuilder: (context, exerciseIndex) {
                                Exercise exercise = widget.circuit[circuitsIndex].circuitExercises![exerciseIndex];

                                return Padding(
                                  padding: EdgeInsets.only(
                                      left: 20,
                                      top: media.height * 0.032,
                                      bottom: exerciseIndex == (widget.circuit[circuitsIndex].circuitExercises!.length-1)
                                          ? media.height * 0.032
                                          : 0),
                                  child: WorkoutCard(
                                    isCircuit: true,
                                    enabled: true,
                                    exerciseIndex: exerciseIndex,
                                    isCompleted: false,
                                    isSkipped: false,
                                    name: exercise.name ?? "Exercise ${exerciseIndex+1}",
                                    onComplete: () {},
                                    onRemove: () {},
                                    openSwapModal: () {},
                                    exerciseData: exercise.exerciseId!,
                                    exercise: DayExercise(
                                      id: exercise.id!,
                                      id_: exercise.exerciseId!,
                                      typeId: exercise.typeId?? 0,
                                      name: exercise.name ?? "",
                                      guide: exercise.guide!,
                                      sets: exercise.sets!,
                                      reps: exercise.reps!,
                                      rest: exercise.rest!,
                                      weight: exercise.weight!,
                                      duration: exercise.rest!.toString(),
                                      formats: exercise.formats!,
                                      extra: exercise.extra!.map((e) => e.toJson(),).toList(),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      bottom: -5,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: media.height * 0.14,
                            decoration: const BoxDecoration(
                              border: DashedBorder(
                                spaceLength: 5,
                                strokeCap: StrokeCap.round,
                                dashLength: 1,
                                top: BorderSide(color: AppColors.primaryColor, width: 1),
                              ),
                            ),
                          ),
                          Row(
                            children: List.generate(
                              widget.circuit[circuitsIndex].round!,
                              (index) => Container(
                                height: 10,
                                width: 10,
                                margin: const EdgeInsets.only(left: 10),
                                decoration: BoxDecoration(
                                  color: selectedCircuit != index ? Colors.transparent : AppColors.primaryColor,
                                  border: Border.all(color: selectedCircuit == index ? Colors.transparent : AppColors.primaryColor),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: media.height * 0.14,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: media.height * 0.05,
              ),
            ],
          ),
        )
      ],
    );
  }
}

class ExpandablePageView extends StatefulWidget {
  final List<Widget> children;
  final Function(int value) onPageChanged;

  const ExpandablePageView({
    super.key,
    required this.children,
    required this.onPageChanged,
  });

  @override
  State<ExpandablePageView> createState() => _ExpandablePageViewState();
}

class _ExpandablePageViewState extends State<ExpandablePageView> with TickerProviderStateMixin {
  late PageController _pageController;
  late List<double> _heights;
  int _currentPage = 0;

  double get _currentHeight => _heights[_currentPage];

  @override
  void initState() {
    _heights = widget.children.map((e) => 0.0).toList();
    super.initState();
    _pageController = PageController()
      ..addListener(() {
        final newPage = _pageController.page?.round() ?? 0;
        if (_currentPage != newPage) {
          setState(() => _currentPage = newPage);
          widget.onPageChanged(_currentPage);
        }
      });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      curve: Curves.easeInOutCubic,
      duration: const Duration(milliseconds: 100),
      tween: Tween<double>(begin: _heights[0], end: _currentHeight),
      builder: (context, value, child) => SizedBox(height: value, child: child),
      child: PageView(
        controller: _pageController,
        pageSnapping: true,
        children: _sizeReportingChildren
            .asMap() //
            .map((index, child) => MapEntry(index, child))
            .values
            .toList(),
      ),
    );
  }

  List<Widget> get _sizeReportingChildren => widget.children
      .asMap() //
      .map(
        (index, child) => MapEntry(
          index,
          OverflowBox(
            //needed, so that parent won't impose its constraints on the children, thus skewing the measurement results.
            minHeight: 0,
            maxHeight: double.infinity,
            alignment: Alignment.topCenter,
            child: SizeReportingWidget(
              onSizeChange: (size) => setState(() => _heights[index] = size.height),
              child: Align(child: child),
            ),
          ),
        ),
      )
      .values
      .toList();
}

class SizeReportingWidget extends StatefulWidget {
  final Widget child;
  final ValueChanged<Size> onSizeChange;

  const SizeReportingWidget({
    super.key,
    required this.child,
    required this.onSizeChange,
  });

  @override
  State<SizeReportingWidget> createState() => _SizeReportingWidgetState();
}

class _SizeReportingWidgetState extends State<SizeReportingWidget> {
  Size? _oldSize;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _notifySize());
    return widget.child;
  }

  void _notifySize() {
    if (!mounted) {
      return;
    }
    final size = context.size;
    if (_oldSize != size && size != null) {
      _oldSize = size;
      widget.onSizeChange(size);
    }
  }
}
