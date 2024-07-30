import 'package:agro_k/components/custom_card.dart';
import 'package:agro_k/theme/colors.dart';
import 'package:agro_k/utilities/utility_models/info_row.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CardWithInfoRows extends StatelessWidget {
  final List<InfoRow> infoRows;
  final ValueChanged<int> onTap; 

  const CardWithInfoRows({super.key, required this.infoRows, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
        padding: const EdgeInsets.only(
            left: 20.0, right: 20.0, top: 8.0, bottom: 8.0),
        child: ListView.separated(
            itemCount: infoRows.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (context, index) {
              return const Divider(
                color: AppColors.appGray,
                thickness: 1,
              );
            },
            itemBuilder: (context, index) {
              var item = infoRows[index];
              return 
              GestureDetector(onTap: () {
                onTap(index);
              }, child:Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: InfoRowPresentation(item: item, id: index),
              ));
            }));
  }
}

class InfoRowPresentation extends StatelessWidget {
  final InfoRow item;
  final int id;

  const InfoRowPresentation({super.key, required this.item, required this.id});

  @override
  Widget build(BuildContext context) {
    return Row(
      key: ValueKey(id),
      children: [
        Text(item.title,
            style: const TextStyle(
                color: AppColors.subtitleGray,
                fontWeight: FontWeight.w500,
                fontSize: 14)),
        const SizedBox(
          width: 16,
        ),
        Expanded(
            child: Text(
              item.value,
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
            )),
      ],
    );
  }
}