// import 'package:flutter/material.dart';
// import 'components.dart';

// class HomePageNoRecent extends StatefulWidget {
//   const HomePageNoRecent({super.key});

//   @override
//   _HomePageNoRecentState createState() => _HomePageNoRecentState();
// }

// class _HomePageNoRecentState extends State<HomePageNoRecent> {
//   int _selectedIndex = 0;

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.grey[200],
//         iconTheme: const IconThemeData(
//           color: Color(0xFF36AE92),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(
//               Icons.search_rounded,
//             ),
//             onPressed: () {
//               print('search button is clicked');
//             },
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(25.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 '안녕하세요, 이화연 님',
//                 style: TextStyle(
//                   color: Colors.black,
//                   fontSize: 24,
//                   fontFamily: 'DM Sans',
//                   fontWeight: FontWeight.w700,
//                   height: 1.5,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     '최근에 학습한 강의 파일이에요.',
//                     style: TextStyle(
//                       color: Color(0xFF575757),
//                       fontSize: 13,
//                       fontFamily: 'Raleway',
//                       fontWeight: FontWeight.w500,
//                       height: 1.5,
//                     ),
//                   ),
//                   GestureDetector(
//                     onTap: () {
//                       print('view all button is clicked');
//                     },
//                     child: const Row(
//                       children: [
//                         Text(
//                           '전체 보기',
//                           style: TextStyle(
//                             color: Color(0xFF36AE92),
//                             fontSize: 12,
//                             fontFamily: 'Mulish',
//                             fontWeight: FontWeight.w800,
//                             height: 1.5,
//                           ),
//                         ),
//                         SizedBox(width: 2),
//                         Icon(
//                           Icons.arrow_forward_ios_rounded,
//                           size: 12,
//                           color: Color(0xFF36AE92),
//                         )
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 20),
//               const Text(
//                 '  최근에 학습한 강의 자료가 없어요.',
//                 style: TextStyle(
//                   color: Colors.black,
//                   fontSize: 13,
//                   fontFamily: 'Raleway',
//                   fontWeight: FontWeight.w700,
//                   height: 1.5,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               const SizedBox(height: 32),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     '최근에 학습한 콜론 파일이에요.',
//                     style: TextStyle(
//                       color: Color(0xFF575757),
//                       fontSize: 13,
//                       fontFamily: 'Raleway',
//                       fontWeight: FontWeight.w500,
//                       height: 1.5,
//                     ),
//                   ),
//                   GestureDetector(
//                     onTap: () {
//                       print('view all2 button is clicked');
//                     },
//                     child: const Row(
//                       children: [
//                         Text(
//                           '전체 보기',
//                           style: TextStyle(
//                             color: Color(0xFF36AE92),
//                             fontSize: 12,
//                             fontFamily: 'Mulish',
//                             fontWeight: FontWeight.w800,
//                             height: 1.5,
//                           ),
//                         ),
//                         SizedBox(width: 2),
//                         Icon(
//                           Icons.arrow_forward_ios_rounded,
//                           size: 12,
//                           color: Color(0xFF36AE92),
//                         )
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 20),
//               const Text(
//                 '  최근 조회한 콜론이 없어요.',
//                 style: TextStyle(
//                   color: Colors.black,
//                   fontSize: 13,
//                   fontFamily: 'Raleway',
//                   fontWeight: FontWeight.w700,
//                   height: 1.5,
//                 ),
//               ),
//               const SizedBox(height: 10),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: buildBottomNavigationBar(context, _selectedIndex, _onItemTapped),
//     );
//   }
// }

// void main() {
//   runApp(const MaterialApp(
//     home: Scaffold(
//       body: HomePageNoRecent(),
//     ),
//   ));
// }
