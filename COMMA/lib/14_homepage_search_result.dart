// import 'package:flutter/material.dart';
// import 'components.dart';

// class SearchingScreen extends StatelessWidget {
//   const SearchingScreen({super.key});

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
//         backgroundColor: Colors.white,
//         elevation: 0,
//         title: SizedBox(
//           height: 45,
//           child: TextField(
//             decoration: InputDecoration(
//               filled: true,
//               fillColor: const Color.fromRGBO(228, 240, 231, 100),
//               hintText: '검색할 파일명을 입력하세요.',
//               hintStyle: const TextStyle(
//                 color: Color(0xFF36AE92),
//                 fontSize: 15,
//               ),
//               prefixIcon: const Icon(
//                 Icons.search,
//                 color: Color(0xFF36AE92),
//               ),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//                 borderSide: BorderSide.none,
//               ),
//               contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
//             ),
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(25.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     '강의 폴더',
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
//               const SizedBox(height: 32),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     '콜론 폴더',
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
