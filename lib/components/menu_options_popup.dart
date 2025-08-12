import 'package:agro_k/components/custom_card.dart';
import 'package:agro_k/theme/colors.dart';
import 'package:flutter/material.dart';

class MenuOptionsPopup<T extends Enum> extends StatelessWidget {
  final List<T> options;
  final Function(T) onSelected;
  final String Function(T) presentation;

  const MenuOptionsPopup(
      {super.key,
      required this.options,
      required this.onSelected,
      required this.presentation});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: CustomCard(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Select an option',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: AppColors.strongGray)),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final option = options[index];
                    return ListTile(
                      title: Text(presentation(option)),
                      onTap: () {
                        Navigator.pop(context);
                        onSelected(option);
                      },
                    );
                  },
                  separatorBuilder: (context, index) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Divider(
                        height: 0,
                        color: AppColors.grayTextColor,
                      ),
                    );
                  },
                  itemCount: options.length)
            ],
          )),
        ),
      ),
    );
  }
}
