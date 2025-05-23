import 'dart:developer';

import 'package:bbb/components/button_widget.dart';
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
      _mainScrollController = FixedExtentScrollController(initialItem: _feetPart - 1);
      _secondaryScrollController = FixedExtentScrollController(initialItem: _inchesPart);
      _unitScrollController = FixedExtentScrollController(initialItem: 0);
    } else {
      _mainScrollController = FixedExtentScrollController(initialItem: _cmWholeValue - 1);
      _secondaryScrollController = FixedExtentScrollController(initialItem: _cmDecimalValue);
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
      _cmValue = _convertInchesToCm(index + 1, _secondaryScrollController.selectedItem);
    }
    setState(() {});
    // widget.onHeightChanged(_cmValue);
  }

  void onSecondarySelectedItemChanged(int index) {
    if (_isConverting) return;
    if (_currentUnitSelected == HeightUnit.inches) {
      _cmValue = _convertInchesToCm(_mainScrollController.selectedItem + 1, index);
    }
    setState(() {});
    // widget.onHeightChanged(_cmValue);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  child: CupertinoPicker(
                    itemExtent: 32,
                    scrollController: _mainScrollController,
                    selectionOverlay: const CupertinoPickerDefaultSelectionOverlay(
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
                    selectionOverlay: const CupertinoPickerDefaultSelectionOverlay(
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
                      selectionOverlay: const CupertinoPickerDefaultSelectionOverlay(
                        capStartEdge: false,
                      ),
                      onSelectedItemChanged: onHeightUnitChanged,
                      children: [
                        Center(
                          child: Text(
                            "Inches",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(6), vertical: ScreenUtil.verticalScale(2)),
            child: ButtonWidget(
              text: "Set",
              textColor: Colors.white,
              color: AppColors.primaryColor,
              onPress: () {
                Navigator.pop(context);
                widget.onHeightChanged(_cmValue);
              },
              isLoading: false,
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
        data: Theme.of(context).copyWith(primaryColor: Colors.white),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(ScreenUtil.verticalScale(4)),
            topRight: Radius.circular(ScreenUtil.verticalScale(4)),
          ),
          child: SizedBox(
            height: modalHeight,
            width: maxModalWidth ?? double.infinity,
            child: ColoredBox(
              color: modalBackgroundColor ?? CupertinoColors.systemBackground.resolveFrom(context),
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

Future<void> showCupertinoWaistPicker({
  Key? key,
  required BuildContext context,
  required Function(double) onWaistChanged,
  double initialWaist = 80.0,
  WaistUnit initialSelectedWaistUnit = WaistUnit.cm,
  bool canConvertUnit = true,
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
        data: Theme.of(context).copyWith(primaryColor: Colors.white),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: SizedBox(
            height: modalHeight,
            width: maxModalWidth ?? double.infinity,
            child: ColoredBox(
              color: modalBackgroundColor ?? CupertinoColors.systemBackground.resolveFrom(context),
              child: WaistPicker(
                key: key,
                initialWaist: initialWaist.toInt(),
                initialSelectedWaistUnit: initialSelectedWaistUnit,
                canConvertUnit: canConvertUnit,
                onWaistChanged: onWaistChanged,
              ),
            ),
          ),
        ),
      );
    },
  );
}

Future<void> showCupertinoHipPicker({
  Key? key,
  required BuildContext context,
  required Function(int) onHipChanged,
  double initialHip = 90.0,
  HipUnit initialSelectedHipUnit = HipUnit.cm,
  bool canConvertUnit = true,
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
        data: Theme.of(context).copyWith(primaryColor: Colors.white),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: SizedBox(
            height: modalHeight,
            width: maxModalWidth ?? double.infinity,
            child: ColoredBox(
              color: modalBackgroundColor ?? CupertinoColors.systemBackground.resolveFrom(context),
              child: HipPicker(
                key: key,
                initialHip: initialHip.toInt(),
                initialSelectedHipUnit: initialSelectedHipUnit,
                canConvertUnit: canConvertUnit,
                onHipChanged: onHipChanged,
              ),
            ),
          ),
        ),
      );
    },
  );
}

Future<void> showCupertinoMidThighPicker({
  Key? key,
  required BuildContext context,
  required Function(int) onMidThighChanged,
  double initialMidThigh = 50,
  MidThighUnit initialSelectedMidThighUnit = MidThighUnit.cm,
  bool canConvertUnit = true,
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
        data: Theme.of(context).copyWith(primaryColor: Colors.white),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: SizedBox(
            height: modalHeight,
            width: maxModalWidth ?? double.infinity,
            child: ColoredBox(
              color: modalBackgroundColor ?? CupertinoColors.systemBackground.resolveFrom(context),
              child: MidThighPicker(
                key: key,
                initialMidThigh: initialMidThigh.toInt(),
                initialSelectedMidThighUnit: initialSelectedMidThighUnit,
                canConvertUnit: canConvertUnit,
                onMidThighChanged: onMidThighChanged,
              ),
            ),
          ),
        ),
      );
    },
  );
}

enum WaistUnit { inches, cm }

class WaistPicker extends StatefulWidget {
  final int initialWaist;
  final WaistUnit initialSelectedWaistUnit;
  final bool canConvertUnit;
  final Function(double) onWaistChanged;
  const WaistPicker({
    super.key,
    required this.initialWaist,
    required this.initialSelectedWaistUnit,
    required this.canConvertUnit,
    required this.onWaistChanged,
  });

  @override
  State<WaistPicker> createState() => _WaistPickerState();
}

class _WaistPickerState extends State<WaistPicker> {
  late WaistUnit _currentUnit;
  late FixedExtentScrollController _mainController;
  late FixedExtentScrollController _unitController;

  int _selectedHip = 0;

  @override
  void initState() {
    super.initState();
    _currentUnit = widget.initialSelectedWaistUnit;
    _selectedHip = widget.initialWaist;

    int initialItem = _currentUnit == WaistUnit.cm ? widget.initialWaist - 76 : widget.initialWaist - 30;

    _mainController = FixedExtentScrollController(initialItem: widget.initialWaist);
    _unitController = FixedExtentScrollController(
      initialItem: _currentUnit == WaistUnit.cm ? 1 : 0,
    );
  }

  void _onMainChanged(int index) {
    setState(() {
      _selectedHip = _currentUnit == WaistUnit.cm ? index + 76 : index + 30;
    });
  }

  void _onUnitChanged(int index) {
    setState(() {
      _currentUnit = index == 0 ? WaistUnit.inches : WaistUnit.cm;
      int newIndex = _currentUnit == HipUnit.cm ? (_selectedHip - 76).clamp(0, 76) : (_selectedHip - 30).clamp(0, 30);
      _mainController.jumpToItem(newIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> cmItems = List.generate(
      77,
      (i) => Center(child: Text("${i + 76}", style: const TextStyle(fontSize: 18))),
    );
    final List<Widget> inchItems = List.generate(
      31,
      (i) => Center(child: Text("${i + 30}", style: const TextStyle(fontSize: 18))),
    );

    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  child: CupertinoPicker(
                    itemExtent: 32,
                    scrollController: _mainController,
                    onSelectedItemChanged: _onMainChanged,
                    children: _currentUnit == WaistUnit.cm ? cmItems : inchItems,
                  ),
                ),
                if (widget.canConvertUnit)
                  Expanded(
                    child: CupertinoPicker(
                      itemExtent: 32,
                      scrollController: _unitController,
                      onSelectedItemChanged: _onUnitChanged,
                      children: const [
                        Center(child: Text("Inches", style: TextStyle(fontSize: 18))),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ButtonWidget(
              text: "Set",
              textColor: Colors.white,
              color: AppColors.primaryColor,
              onPress: () {
                Navigator.pop(context);
                widget.onWaistChanged(_selectedHip.toDouble()); // return only the number
              },
              isLoading: false,
            ),
          ),
        ],
      ),
    );
  }
}

enum HipUnit { inches, cm }

class HipPicker extends StatefulWidget {
  final int initialHip; // change to int for clarity
  final HipUnit initialSelectedHipUnit;
  final bool canConvertUnit;
  final Function(int) onHipChanged;

  const HipPicker({
    super.key,
    required this.initialHip,
    required this.initialSelectedHipUnit,
    required this.canConvertUnit,
    required this.onHipChanged,
  });

  @override
  State<HipPicker> createState() => _HipPickerState();
}

class _HipPickerState extends State<HipPicker> {
  late HipUnit _currentUnit;
  late FixedExtentScrollController _mainController;
  late FixedExtentScrollController _unitController;

  int _selectedHip = 0;

  @override
  void initState() {
    super.initState();
    _currentUnit = widget.initialSelectedHipUnit;
    _selectedHip = widget.initialHip;

    int initialItem = _currentUnit == HipUnit.cm ? widget.initialHip - 76 : widget.initialHip - 30;

    _mainController = FixedExtentScrollController(initialItem: widget.initialHip);
    _unitController = FixedExtentScrollController(
      initialItem: _currentUnit == HipUnit.cm ? 1 : 0,
    );
  }

  void _onMainChanged(int index) {
    setState(() {
      _selectedHip = _currentUnit == HipUnit.cm ? index + 76 : index + 30;
    });
  }

  void _onUnitChanged(int index) {
    setState(() {
      _currentUnit = index == 0 ? HipUnit.inches : HipUnit.cm;
      int newIndex = _currentUnit == HipUnit.cm ? (_selectedHip - 76).clamp(0, 76) : (_selectedHip - 30).clamp(0, 30);
      _mainController.jumpToItem(newIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> cmItems = List.generate(
      77,
      (i) => Center(child: Text("${i + 76}", style: const TextStyle(fontSize: 18))),
    );
    final List<Widget> inchItems = List.generate(
      31,
      (i) => Center(child: Text("${i + 30}", style: const TextStyle(fontSize: 18))),
    );

    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  child: CupertinoPicker(
                    itemExtent: 32,
                    scrollController: _mainController,
                    onSelectedItemChanged: _onMainChanged,
                    children: _currentUnit == HipUnit.cm ? cmItems : inchItems,
                  ),
                ),
                if (widget.canConvertUnit)
                  Expanded(
                    child: CupertinoPicker(
                      itemExtent: 32,
                      scrollController: _unitController,
                      onSelectedItemChanged: _onUnitChanged,
                      children: const [
                        Center(child: Text("Inches", style: TextStyle(fontSize: 18))),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ButtonWidget(
              text: "Set",
              textColor: Colors.white,
              color: AppColors.primaryColor,
              onPress: () {
                Navigator.pop(context);
                widget.onHipChanged(_selectedHip); // return only the number
              },
              isLoading: false,
            ),
          ),
        ],
      ),
    );
  }
}

enum MidThighUnit { inches, cm }

class MidThighPicker extends StatefulWidget {
  final int initialMidThigh;
  final MidThighUnit initialSelectedMidThighUnit;
  final bool canConvertUnit;
  final Function(int) onMidThighChanged;

  const MidThighPicker({
    super.key,
    required this.initialMidThigh,
    required this.initialSelectedMidThighUnit,
    required this.canConvertUnit,
    required this.onMidThighChanged,
  });

  @override
  State<MidThighPicker> createState() => _MidThighPickerState();
}

class _MidThighPickerState extends State<MidThighPicker> {
  late int _midThighValue;
  late MidThighUnit _currentUnit;
  late FixedExtentScrollController _mainController;
  late FixedExtentScrollController _unitController;
  bool _isConverting = false;

  @override
  void initState() {
    super.initState();
    _midThighValue = widget.initialMidThigh;
    _currentUnit = widget.initialSelectedMidThighUnit;

    if (_currentUnit == MidThighUnit.inches) {
      _mainController = FixedExtentScrollController(initialItem: _midThighValue - 10);
      _unitController = FixedExtentScrollController(initialItem: 0);
    } else {
      _mainController = FixedExtentScrollController(initialItem: _midThighValue - 20);
      _unitController = FixedExtentScrollController(initialItem: 1);
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  void _onMainChanged(int index) {
    if (_isConverting) return;
    setState(() {
      _midThighValue = _currentUnit == MidThighUnit.inches ? index + 10 : index + 20;
      log('_midThighValue ==> $_midThighValue ($_currentUnit)');
    });
  }

  Future<void> _onUnitChanged(int index) async {
    if (_isConverting) return;
    setState(() {
      _isConverting = true;
    });

    if (index == 0 && _currentUnit != MidThighUnit.inches) {
      _currentUnit = MidThighUnit.inches;
      await _mainController.animateToItem(
        _midThighValue - 10,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else if (index == 1 && _currentUnit != MidThighUnit.cm) {
      _currentUnit = MidThighUnit.cm;
      await _mainController.animateToItem(
        _midThighValue - 20,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }

    setState(() {
      _isConverting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> cmItems = List.generate(
      80,
      (i) => Center(child: Text("${i + 20}", style: const TextStyle(fontSize: 18))),
    );
    final List<Widget> inchItems = List.generate(
      40,
      (i) => Center(child: Text("${i + 10}", style: const TextStyle(fontSize: 18))),
    );

    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  child: CupertinoPicker(
                    itemExtent: 32,
                    scrollController: _mainController,
                    onSelectedItemChanged: _onMainChanged,
                    children: _currentUnit == MidThighUnit.inches ? inchItems : cmItems,
                  ),
                ),
                if (widget.canConvertUnit)
                  Expanded(
                    child: CupertinoPicker(
                      itemExtent: 32,
                      scrollController: _unitController,
                      onSelectedItemChanged: _onUnitChanged,
                      children: const [
                        Center(child: Text("Inches", style: TextStyle(fontSize: 18))),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ButtonWidget(
              text: "Set",
              textColor: Colors.white,
              color: AppColors.primaryColor,
              onPress: () {
                Navigator.pop(context);
                log('_midThighValue========d==>>>>>${_midThighValue}');

                widget.onMidThighChanged(_midThighValue);
              },
              isLoading: false,
            ),
          ),
        ],
      ),
    );
  }
}
