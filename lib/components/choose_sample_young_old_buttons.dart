import 'package:agro_k/theme/colors.dart';
import 'package:flutter/material.dart';

class ChooseSampleYoungAndOldButtons extends StatefulWidget {
  final void Function(bool isYoung, bool isOld)? onChanged;
  final bool isYoung;
  final bool isOld;
  const ChooseSampleYoungAndOldButtons({super.key, required this.onChanged, required this.isYoung, required this.isOld});

  @override
  State<ChooseSampleYoungAndOldButtons> createState() => _ChooseSampleYoungAndOldButtonsState();
}

class _ChooseSampleYoungAndOldButtonsState extends State<ChooseSampleYoungAndOldButtons> {
  late bool isYoung;
  late bool isOld;

  @override
  void initState() {
    super.initState();

    isYoung = widget.isYoung;
    isOld = widget.isOld;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: widget.onChanged != null ? () {
              setState(() {
                isYoung = !isYoung;
              });
              widget.onChanged!(isYoung, isOld);
            } : null,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(60),
                  bottomLeft: Radius.circular(60),
                ),
                border: Border.all(color: widget.onChanged != null ? AppColors.appPrimaryGreen : Colors.grey),
                color: widget.onChanged == null ? Colors.grey : isYoung ? AppColors.appPrimaryGreen : Colors.white,
              ),
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isYoung)
                    ...[const Icon(Icons.check_circle_outlined, color: Colors.white, size: 20,), const SizedBox(width: 8)],
                  Text('Young', style: TextStyle(color: isYoung ? Colors.white : AppColors.appPrimaryGreen),),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 1,),
        Expanded(
          child: InkWell(
            onTap: widget.onChanged != null ? () {
              setState(() {
                isOld = !isOld;
              });
              widget.onChanged!(isYoung, isOld);
            } : null,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(60),
                  bottomRight: Radius.circular(60),
                ),
                border: Border.all(color: widget.onChanged != null ? AppColors.appPrimaryGreen : Colors.grey),
                color: widget.onChanged == null ? Colors.grey : isOld ? AppColors.appPrimaryGreen : Colors.white,
              ),
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isOld)
                    ...[const Icon(Icons.check_circle_outlined, color: Colors.white, size: 20,), const SizedBox(width: 8)],
                  Text('Old', style: TextStyle(color: isOld ? Colors.white : AppColors.appPrimaryGreen),),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
