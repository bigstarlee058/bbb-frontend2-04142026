import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HeightPicker extends StatefulWidget {
  final double initialHeight;
  final HeightUnit initialSelectedHeightUnit;
  final bool showSeparationText;
  final bool canConvertUnit;
  final Function(double) onHeightChanged;

  const HeightPicker({
    super.key,
    required this.initialHeight,
    required this.initialSelectedHeightUnit,
    required this.showSeparationText,
    required this.canConvertUnit,
    required this.onHeightChanged,
  });

  @override
  State<HeightPicker> createState() => _HeightPickerState();
}

class _HeightPickerState extends State<HeightPicker> {
  late double _cmValue;
  bool _isConverting = false;
  late HeightUnit _currentUnitSelected;
  late final FixedExtentScrollController _mainScrollController;
  late final FixedExtentScrollController _secondaryScrollController;
  late final FixedExtentScrollController _unitScrollController;
  int get _feetPart => (_cmValue / 2.54) ~/ 12;
  int get _inchesPart => ((_cmValue / 2.54) % 12).floor();
  int get _cmWholeValue => _cmValue.floor();
  int get _cmDecimalValue => ((_cmValue - _cmValue.truncate()) * 10).round();
  double _convertInchesToCm(int feet, int inches) {
    int inchesTotal = (feet * 12) + inches;
    return inchesTotal * 2.54;
  }

  @override
  void initState() {
    _cmValue = widget.initialHeight;
    _currentUnitSelected = widget.initialSelectedHeightUnit;
    if (widget.initialSelectedHeightUnit == HeightUnit.inches) {
      _mainScrollController =
          FixedExtentScrollController(initialItem: _feetPart - 1);
      _secondaryScrollController =
          FixedExtentScrollController(initialItem: _inchesPart);
      _unitScrollController = FixedExtentScrollController(initialItem: 0);
    } else {
      _mainScrollController =
          FixedExtentScrollController(initialItem: _cmWholeValue - 1);
      _secondaryScrollController =
          FixedExtentScrollController(initialItem: _cmDecimalValue);
      _unitScrollController = FixedExtentScrollController(initialItem: 1);
    }
    super.initState();
  }

  @override
  void dispose() {
    _mainScrollController.dispose();
    _secondaryScrollController.dispose();
    _unitScrollController.dispose();
    super.dispose();
  }

  Future<void> onHeightUnitChanged(int index) async {
    if (index == 0 && _currentUnitSelected != HeightUnit.inches) {
      setState(() {
        _isConverting = true;
        _currentUnitSelected = HeightUnit.inches;
      });
      _mainScrollController.animateToItem(
        _feetPart - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      await _secondaryScrollController.animateToItem(
        _inchesPart,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      setState(() {
        _isConverting = false;
      });
    }
    if (index == 1 && _currentUnitSelected != HeightUnit.cm) {
      setState(() {
        _isConverting = true;
        _currentUnitSelected = HeightUnit.cm;
      });
      _mainScrollController.animateToItem(
        _cmWholeValue - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      await _secondaryScrollController.animateToItem(
        _cmDecimalValue,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      setState(() {
        _isConverting = false;
      });
    }
  }

  void onMainSelectedItemChanged(int index) {
    if (_isConverting) return;
    if (_currentUnitSelected == HeightUnit.inches) {
      _cmValue = _convertInchesToCm(
          index + 1, _secondaryScrollController.selectedItem);
    }
    setState(() {});
    // widget.onHeightChanged(_cmValue);
  }

  void onSecondarySelectedItemChanged(int index) {
    if (_isConverting) return;
    if (_currentUnitSelected == HeightUnit.inches) {
      _cmValue =
          _convertInchesToCm(_mainScrollController.selectedItem + 1, index);
    }
    setState(() {});
    // widget.onHeightChanged(_cmValue);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(
                right: ScreenUtil.horizontalScale(6),
                top: ScreenUtil.verticalScale(2)),
            child: Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(
                  Icons.close,
                  color: Theme.of(context).textTheme.bodyLarge!.color!,
                  size: 22,
                ),
              ),
            ),
          ),
          Center(
            child: SizedBox(
              height: 180,
              width: ScreenUtil.horizontalScale(73),
              child: Center(
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoPicker(
                        itemExtent: 32,
                        scrollController: _mainScrollController,
                        selectionOverlay:
                            const CupertinoPickerDefaultSelectionOverlay(
                          capEndEdge: false,
                        ),
                        onSelectedItemChanged: onMainSelectedItemChanged,
                        children: List.generate(
                          9,
                          (index) => Center(
                            child: Text(
                              "${index + 1}",
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (widget.showSeparationText)
                      Expanded(
                        child: SizedBox(
                          height: 32,
                          child: Stack(
                            children: [
                              const CupertinoPickerDefaultSelectionOverlay(
                                capStartEdge: false,
                                capEndEdge: false,
                              ),
                              Center(
                                child: Text(
                                  "Feet",
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    Expanded(
                      child: CupertinoPicker(
                        itemExtent: 32,
                        scrollController: _secondaryScrollController,
                        selectionOverlay:
                            const CupertinoPickerDefaultSelectionOverlay(
                          capStartEdge: false,
                          capEndEdge: false,
                        ),
                        onSelectedItemChanged: onSecondarySelectedItemChanged,
                        children: List.generate(
                          12,
                          (index) => Center(
                            child: Text(
                              "$index",
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (widget.canConvertUnit)
                      Expanded(
                        child: CupertinoPicker(
                          itemExtent: 32,
                          scrollController: _unitScrollController,
                          selectionOverlay:
                              const CupertinoPickerDefaultSelectionOverlay(
                            capStartEdge: false,
                          ),
                          onSelectedItemChanged: onHeightUnitChanged,
                          children: [
                            Center(
                              child: Text(
                                "Inches     ",
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding:
                EdgeInsets.only(bottom: ScreenUtil.verticalScale(3), top: 10),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
                widget.onHeightChanged(_cmValue);
              },
              child: Container(
                width: ScreenUtil.horizontalScale(73),
                padding: EdgeInsets.all(ScreenUtil.verticalScale(1.3)),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(
                    ScreenUtil.verticalScale(1.5),
                  ),
                ),
                child: Center(
                  child: Text(
                    "Select",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

enum HeightUnit { inches, cm }

Future<void> showCupertinoHeightPicker({
  Key? key,
  required BuildContext context,
  required Function(double) onHeightChanged,
  double initialHeight = 150.0,
  HeightUnit initialSelectedHeightUnit = HeightUnit.inches,
  bool canConvertUnit = true,
  bool showSeparationText = true,
  double modalHeight = 300,
  double? maxModalWidth,
  Color? modalBackgroundColor,
  Color barrierColor = kCupertinoModalBarrierColor,
}) async {
  return await showCupertinoModalPopup<void>(
    context: context,
    barrierColor: barrierColor,
    builder: (context) {
      return Theme(
        data: Theme.of(context)
            .copyWith(primaryColor: Theme.of(context).cardColor),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(ScreenUtil.verticalScale(2.5)),
            topRight: Radius.circular(ScreenUtil.verticalScale(2.5)),
          ),
          child: SizedBox(
            height: modalHeight,
            width: maxModalWidth ?? double.infinity,
            child: ColoredBox(
              color: Theme.of(context).cardColor,
              child: HeightPicker(
                key: key,
                initialHeight: initialHeight,
                initialSelectedHeightUnit: initialSelectedHeightUnit,
                showSeparationText: showSeparationText,
                canConvertUnit: canConvertUnit,
                onHeightChanged: onHeightChanged,
              ),
            ),
          ),
        ),
      );
    },
  );
}
