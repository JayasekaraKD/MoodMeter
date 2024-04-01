import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'filter_provider.dart'; // Import your FilterModel

// class FilterSidebar extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final filterModel = Provider.of<FilterModel>(context);

//     return Drawer(
//       child: Container(
//         padding: EdgeInsets.zero,
//         color: Colors.white,
//         child: ListView(
//           children: <Widget>[
//             SizedBox(height: 16.0),
//             ListTile(
//               title: Text(
//                 'Date',
//                 style: TextStyle(
//                   fontSize: 20.0,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             // Date filters displayed in a row with space between them
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: <Widget>[
//                 _buildCurvedButton(
//                   context,
//                   text: 'Day',
//                   onTap: () {
//                     filterModel.updateDateFilter('Day');
//                   },
//                   selected: filterModel.selectedDateFilter == 'Day',
//                 ),
//                 _buildCurvedButton(
//                   context,
//                   text: 'Week',
//                   onTap: () {
//                     filterModel.updateDateFilter('Week');
//                   },
//                   selected: filterModel.selectedDateFilter == 'Week',
//                 ),
//                 _buildCurvedButton(
//                   context,
//                   text: 'Month',
//                   onTap: () {
//                     filterModel.updateDateFilter('Month');
//                   },
//                   selected: filterModel.selectedDateFilter == 'Month',
//                 ),
//                 // Add more options for different date filters...
//               ],
//             ),
//             SizedBox(height: 24.0),
//             ListTile(
//               title: Text(
//                 'Categories',
//                 style: TextStyle(
//                   fontSize: 20.0,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             SizedBox(height: 16.0),
//             // Buttons for specific categories displayed in a row
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: <Widget>[
//                 _buildCategoryButton(
//                   context,
//                   text: 'Work',
//                   onTap: () {
//                     filterModel.updateCategoryFilter('Work');
//                   },
//                   selected: filterModel.selectedCategoryFilter == 'Work',
//                 ),
//                 _buildCategoryButton(
//                   context,
//                   text: 'Food',
//                   onTap: () {
//                     filterModel.updateCategoryFilter('Food');
//                   },
//                   selected: filterModel.selectedCategoryFilter == 'Food',
//                 ),
//                 _buildCategoryButton(
//                   context,
//                   text: 'Workout',
//                   onTap: () {
//                     filterModel.updateCategoryFilter('Workout');
//                   },
//                   selected: filterModel.selectedCategoryFilter == 'Workout',
//                 ),
//                 _buildCategoryButton(
//                   context,
//                   text: 'Study',
//                   onTap: () {
//                     filterModel.updateCategoryFilter('Study');
//                   },
//                   selected: filterModel.selectedCategoryFilter == 'Study',
//                 ),
//                 _buildCategoryButton(
//                   context,
//                   text: 'Others',
//                   onTap: () {
//                     filterModel.updateCategoryFilter('Others');
//                   },
//                   selected: filterModel.selectedCategoryFilter == 'Others',
//                 ),
//                 // Add more buttons for different categories...
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCurvedButton(BuildContext context,
//       {required String text,
//       required VoidCallback onTap,
//       required bool selected}) {
//     return SizedBox(
//       width: 80.0, // Adjust button width as needed
//       child: ElevatedButton(
//         onPressed: onTap,
//         child: Text(
//           text,
//           style: TextStyle(
//             fontSize: 16.0,
//             color: selected ? Colors.white : Colors.black.withOpacity(0.5),
//           ),
//         ),
//         style: ElevatedButton.styleFrom(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20.0),
//           ),
//           padding: EdgeInsets.symmetric(vertical: 12.0),
//           primary:
//               selected ? Color.fromARGB(255, 172, 0, 94) : Colors.transparent,
//         ),
//       ),
//     );
//   }

//   Widget _buildCategoryButton(BuildContext context,
//       {required String text,
//       required VoidCallback onTap,
//       required bool selected}) {
//     return SizedBox(
//       width: 80.0, // Adjust button width as needed
//       child: OutlinedButton(
//         onPressed: onTap,
//         child: Text(
//           text,
//           style: TextStyle(
//             fontSize: 16.0,
//             color: selected ? Colors.white : Colors.blue,
//           ),
//         ),
//         style: ElevatedButton.styleFrom(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20.0),
//           ),
//           padding: EdgeInsets.symmetric(vertical: 12.0),
//           primary:
//               selected ? Color.fromARGB(255, 172, 0, 94) : Colors.transparent,
//           side: BorderSide(color: Colors.blue),
//         ),
//       ),
//     );
//   }
// }

class FilterSidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      // Your sidebar UI code here
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              // Handle Weekly filtering logic here
              _applyFilter(context, 'Weekly');
            },
            child: Text('Weekly'),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle Monthly filtering logic here
              _applyFilter(context, 'Monthly');
            },
            child: Text('Monthly'),
          ),
        ],
      ),
    );
  }

  void _applyFilter(BuildContext context, String filter) {
    // Implement your filtering logic here based on the selected option
    print('Applying $filter filter');
    // You can perform actions based on the selected filter, like updating UI or fetching data.
    Navigator.pop(context); // Close the bottom sheet after applying the filter
  }
}
