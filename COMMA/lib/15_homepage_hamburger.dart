// import 'package:flutter/material.dart';
// import 'components.dart';

// class HomePageNoRecent extends StatelessWidget {
//   const HomePageNoRecent({super.key});

//   @override
//   Widget build(BuildContext context) {
//     int _selectedIndex = 0;

//     void _onItemTapped(int index) {
//       _selectedIndex = index;
//       // Do any additional logic when the item is tapped
//     }

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
//               const SizedBox(height: 8),
//               GestureDetector(
//                 onTap: () {
//                   print('certain lecture is clicked');
//                 },
//                 child: const LectureExample(
//                   lectureName: '정보통신공학',
//                   date: '2024/06/07',
//                 ),
//               ),
//               GestureDetector(
//                 onTap: () {
//                   print('certain lecture is clicked');
//                 },
//                 child: const LectureExample(
//                   lectureName: '컴퓨터알고리즘',
//                   date: '2024/06/10',
//                 ),
//               ),
//               GestureDetector(
//                 onTap: () {
//                   print('certain lecture is clicked');
//                 },
//                 child: const LectureExample(
//                   lectureName: '데이터베이스',
//                   date: '2024/06/15',
//                 ),
//               ),
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
//               const SizedBox(height: 8),
//               GestureDetector(
//                 onTap: () {
//                   print('certain lecture is clicked');
//                 },
//                 child: const LectureExample(
//                   lectureName: '정보통신공학',
//                   date: '2024/06/07',
//                 ),
//               ),
//               GestureDetector(
//                 onTap: () {
//                   print('certain lecture is clicked');
//                 },
//                 child: const LectureExample(
//                   lectureName: '컴퓨터알고리즘',
//                   date: '2024/06/10',
//                 ),
//               ),
//               GestureDetector(
//                 onTap: () {
//                   print('certain lecture is clicked');
//                 },
//                 child: const LectureExample(
//                   lectureName: '데이터베이스',
//                   date: '2024/06/15',
//                 ),
//               ),
//               const SizedBox(height: 32),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: buildBottomNavigationBar(context, _selectedIndex, _onItemTapped),
//     );
//   }
// }
