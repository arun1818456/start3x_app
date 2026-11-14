import 'package:start3x_app/exports.dart';

class BottomController extends GetxController {
  var selectedIndex = 0;

  final List<Widget> pages = const [
    HomeScreen(),
    ToDoScreen(),
    GroupScreen(showBackButton: false),
    InsightsScreen(),
  ];

  void onItemTapped(int index) {
    selectedIndex = index;
    update();
  }
}
