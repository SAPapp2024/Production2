import 'package:agro_k/models/company/company_model.dart';
import 'package:agro_k/theme/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CompanyCard extends StatelessWidget {
  final CompanyModel company;
  final EdgeInsets padding;
  final bool showRemainingBarcodesCount;
  const CompanyCard({super.key, required this.company, required this.padding, this.showRemainingBarcodesCount = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20))),
      elevation: 15,
      color: Colors.white,
      child: Padding(
        padding: padding,
        child: Column(
          children: [
            ConstrainedBox(
                constraints: const BoxConstraints(
                    maxHeight: 200, minHeight: 50),
                child: Image.asset("images/imgCompany.png")),
            const SizedBox(height: 30,),
            Flexible(
              flex: 0,
              child: Text(
                company.name,
                style: const TextStyle(
                    color: Colors.black,
                    
                    fontSize: 28,
                    fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8,),
            Text(
              company.address,
              style: const TextStyle(
                color: AppColors.subtitleGray,
                fontSize: 18,
                fontWeight: FontWeight.normal,
                
              ),
            ),
            if (showRemainingBarcodesCount)
              ...[
                const SizedBox(height: 36,),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Barcodes remaining:",
                      style: TextStyle(
                        color: AppColors.subtitleGray,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        
                      ),
                    ),
                    const SizedBox(width: 8,),
                    Text(
                      "${company.availableBarcodesCount}",
                      style: const TextStyle(
                        color: AppColors.appPrimaryGreen,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        
                      ),
                    ),
                  ],
                ),
              ]
          ],
        ),
      ),
    );
  }
}
