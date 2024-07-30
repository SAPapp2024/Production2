// import 'package:agro_k/redux/app_state.dart';
// import 'package:agro_k/routes.dart';
// import 'package:agro_k/theme/colors.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_redux/flutter_redux.dart';
// import 'package:redux/redux.dart';

// class SeeAllReportScreen extends StatefulWidget  {
//   static const String id = 'see_all_report_screen';

//   const SeeAllReportScreen({Key? key}) : super(key: key);

//   @override
//   _SeeAllReportScreenState createState() => _SeeAllReportScreenState();
// }

// class _SeeAllReportScreenState extends State<SeeAllReportScreen> {

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     Store<AppState>? _store;
//     _store = StoreProvider.of<AppState>(context);
//     ReportScreenArguments args = ModalRoute.of(context)!.settings.arguments as ReportScreenArguments;

//     String productName = args.productName;

    
//     SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
//     return 
//   }

// Widget createReportsView(BuildContext context) {
//   String reportTitle = "WHEAT AGRO-K";
//   String reportId1 = "VF-0095";
//   String reportId2 = "202111031201";

//   String date = "11-01-2021";
//   String locationPlot = "Farm 016";
//   String cultivation = "AK FRI";
//   String crop = "Tree C";
//   String plantPart = "Leaf (young)";
//   String sampleType = "Sap";

//   return Column(
//     children: [
//       Stack(
//         alignment: AlignmentDirectional.topCenter,
//         children: [
//           Container(
//             width: MediaQuery.of(context).size.width - 40,
//             height: 360,
//             decoration: BoxDecoration(color: Colors.white, border: Border.all(width: 1, color: Colors.grey)),
//             child: Column(
//               children: [
//                 const SizedBox(
//                   height: 95,
//                 ),
//                 Row(
//                   children: [
//                     const SizedBox(
//                       width: 20,
//                     ),
//                     const Icon(Icons.timer),
//                     const SizedBox(
//                       width: 5,
//                     ),
//                     const Text(
//                       "Date: ",
//                       style: TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     Text(
//                       date,
//                       style: const TextStyle(color: Colors.black, fontSize: 18),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(
//                   height: 5,
//                 ),
//                 Row(
//                   children: [
//                     const SizedBox(
//                       width: 20,
//                     ),
//                     const Icon(Icons.timer),
//                     const SizedBox(
//                       width: 5,
//                     ),
//                     const Text(
//                       "Location / Plot: ",
//                       style: TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     Text(
//                       locationPlot,
//                       style: const TextStyle(color: Colors.black, fontSize: 18),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(
//                   height: 5,
//                 ),
//                 Row(
//                   children: [
//                     const SizedBox(
//                       width: 20,
//                     ),
//                     const Icon(Icons.timer),
//                     const SizedBox(
//                       width: 5,
//                     ),
//                     const Text(
//                       "Cultivation: ",
//                       style: TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     Text(
//                       cultivation,
//                       style: const TextStyle(color: Colors.black, fontSize: 18),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(
//                   height: 5,
//                 ),
//                 Row(
//                   children: [
//                     const SizedBox(
//                       width: 20,
//                     ),
//                     const Icon(Icons.timer),
//                     const SizedBox(
//                       width: 5,
//                     ),
//                     const Text(
//                       "Crop: ",
//                       style: TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     Text(
//                       crop,
//                       style: const TextStyle(color: Colors.black, fontSize: 18),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(
//                   height: 5,
//                 ),
//                 Row(
//                   children: [
//                     const SizedBox(
//                       width: 20,
//                     ),
//                     const Icon(Icons.timer),
//                     const SizedBox(
//                       width: 5,
//                     ),
//                     const Text(
//                       "Plant Part: ",
//                       style: TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     Text(
//                       plantPart,
//                       style: const TextStyle(color: Colors.black, fontSize: 18),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(
//                   height: 5,
//                 ),
//                 Row(
//                   children: [
//                     const SizedBox(
//                       width: 20,
//                     ),
//                     const Icon(Icons.timer),
//                     const SizedBox(
//                       width: 5,
//                     ),
//                     const Text(
//                       "Sample Type: ",
//                       style: TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     Text(
//                       sampleType,
//                       style: const TextStyle(color: Colors.black, fontSize: 18),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(
//                   height: 30,
//                 ),
//                 Row(
//                   children: [
//                     const SizedBox(
//                       width: 20,
//                     ),
//                     TextButton(
//                         onPressed: () {
//                           Navigator.pushNamed(context, ReportScreen.id, arguments: ReportScreenArguments(productName: reportTitle));
//                         },
//                         child: const Text("See Report"),
//                         style: TextButton.styleFrom(primary: Colors.white, backgroundColor: AppColors.appPrimaryGreen)),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           Stack(alignment: AlignmentDirectional.topCenter, children: [
//             Container(
//               width: MediaQuery.of(context).size.width - 40,
//               height: 75,
//               decoration: BoxDecoration(color: Colors.grey.withOpacity(0.15), border: Border.all(width: 1, color: Colors.grey)),
//             ),
//             Positioned(
//               top: 5,
//               left: 20,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Text(
//                         reportTitle,
//                         style: const TextStyle(fontSize: 20, color: Colors.black),
//                       ),
//                       const SizedBox(
//                         width: 20,
//                       ),
//                       Text(
//                         reportId1,
//                         overflow: TextOverflow.clip,
//                         style: const TextStyle(fontSize: 16, color: Colors.black),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(
//                     height: 5,
//                   ),
//                   Text(
//                     reportId2,
//                     overflow: TextOverflow.clip,
//                     style: const TextStyle(fontSize: 16, color: Colors.black),
//                   )
//                 ],
//               ),
//             ),
//           ]),
//         ],
//       ),
//     ],
//   );
// }
// }