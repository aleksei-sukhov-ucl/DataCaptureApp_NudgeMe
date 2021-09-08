import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nudge_me/model/friends_model.dart';
import 'package:nudge_me/model/user_model.dart';
import 'into_pages_test.dart';
import 'wellbeing_page_test.dart';
import 'package:nudge_me/pages/support_page.dart';
import 'package:nudge_me/shared/friend_graph.dart';
import '../test/widget_test.dart';

void main() {
  // introPagesIntegrationTest();
  // wellbeingPageIntegrationTest();

  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized()
      as IntegrationTestWidgetsFlutterBinding;

  // simulate the way flutter actually responds to animations
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;
}

class MockedFriendDB extends Mock implements FriendDB {}

class MockedUserWellbeingDB extends Mock implements UserWellbeingDB {}
