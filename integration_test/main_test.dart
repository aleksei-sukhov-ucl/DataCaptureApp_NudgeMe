import 'package:mockito/mockito.dart';
import 'package:nudge_me/model/friends_model.dart';
import 'package:nudge_me/model/user_model.dart';
import 'into_pages_test.dart';
import 'wellbeing_page_test.dart';

void main() {
  introPagesIntegrationTest();
  wellbeingPageIntegrationTest();
}

class MockedFriendDB extends Mock implements FriendDB {}

class MockedUserWellbeingDB extends Mock implements UserWellbeingDB {}
