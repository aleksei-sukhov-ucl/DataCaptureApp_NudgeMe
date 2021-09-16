/// Specifying the Axis for the Bar Graph for different time frames
weekXAxisUnits(double value) {
  switch (value.toInt()) {
    case 1:
      return 'M';
    case 2:
      return 'T';
    case 3:
      return 'W';
    case 4:
      return 'T';
    case 5:
      return 'F';
    case 6:
      return 'S';
    case 7:
      return 'S';
    default:
      return '';
  }
}

monthXAxisUnits(double value) {
  switch (value.toInt()) {
    case 1:
      return '1';
    case 2:
      return '2';
    case 3:
      return '3';
    case 4:
      return '4';
    case 5:
      return '5';
    case 6:
      return '6';
    case 7:
      return '7';
    case 8:
      return '8';
    case 9:
      return '9';
    case 10:
      return '10';
    case 11:
      return '11';
    case 12:
      return '12';
    case 13:
      return '13';
    default:
      return '';
  }
}

String yearXAxisUnits(double value) {
  switch (value.toInt()) {
    case 1:
      return 'J';
    case 2:
      return 'F';
    case 3:
      return 'M';
    case 4:
      return 'A';
    case 5:
      return 'M';
    case 6:
      return 'J';
    case 7:
      return 'J';
    case 8:
      return 'A';
    case 9:
      return 'S';
    case 10:
      return '0';
    case 11:
      return 'N';
    case 12:
      return 'D';
    default:
      return '';
  }
}

String weekDayDescription(group) {
  /// Matching week day index with corresponding name
  switch (group.x.toInt()) {
    case 1:
      return 'Mon';
    case 2:
      return 'Tue';
    case 3:
      return 'Wed';
    case 4:
      return 'Thur';
    case 5:
      return 'Fri';
    case 6:
      return 'Sat';
    case 7:
      return 'Sun';
    default:
      throw Error();
  }
}

String monthWeekDescription(group) {
  switch (group.x.toInt()) {
    case 1:
      return '1';
    case 2:
      return '2';
    case 3:
      return '3';
    case 4:
      return '3';
    case 5:
      return '4';
    case 6:
      return '6';
    case 7:
      return '7';
    case 8:
      return '4';
    default:
      throw Error();
  }
}

String yearMonthDescription(group) {
  switch (group.x.toInt()) {
    case 1:
      return 'Jan';
    case 2:
      return 'Feb';
    case 3:
      return 'Mar';
    case 4:
      return 'Apr';
    case 5:
      return 'May';
    case 6:
      return 'Jun';
    case 7:
      return 'Jul';
    case 8:
      return 'Aug';
    case 9:
      return 'Sep';
    case 10:
      return 'Oct';
    case 11:
      return 'Nov';
    case 12:
      return 'Dec';
    default:
      throw Error();
  }
}

popupUnits(initialIndex) {
  switch (initialIndex) {
    case 0:
      return "K";
    default:
      return "";
  }
}

double maxYaxis({int cardId, int initialIndex, double dynamicMaxValue}) {
  switch (cardId) {
    case 0:
      if (dynamicMaxValue == 0) {
        return 10;
      } else if (initialIndex == 0) {
        // print("MaxY for week");
        return ((dynamicMaxValue / 5).ceil() * 5).toDouble();
      } else if (initialIndex == 1) {
        // print("MaxY for month");
        return ((dynamicMaxValue / 10).ceil() * 10).toDouble();
      } else if (initialIndex == 2) {
        // print("MaxY for year");
        return ((dynamicMaxValue / 10).ceil() * 10).toDouble();
      }
      break;
    case 1:
      return 10;
    case 2:
      return 4;
    case 3:
      return 4;
    case 4:
      return (dynamicMaxValue == 0)
          ? 10
          : ((dynamicMaxValue / 5).ceil() * 5).toDouble();
    default:
      return 10;
  }
}

double stepSize({int cardId, int initialIndex, double dynamicMaxValue}) {
  switch (cardId) {
    case 0:
      if (dynamicMaxValue == 0) {
        return 10;
      } else if (initialIndex == 0) {
        return (dynamicMaxValue / 5).ceil().toDouble();
      } else if (initialIndex == 1) {
        return (dynamicMaxValue / 10).ceil().toDouble();
      } else if (initialIndex == 2) {
        return (dynamicMaxValue / 10).ceil().toDouble();
      }
      break;
    case 1:
      return 2;
    case 2:
      return 1;
    case 3:
      return 1;
    case 4:
      return (dynamicMaxValue == 0)
          ? 2
          : (dynamicMaxValue / 5).ceil().toDouble();
    default:
      return 1;
  }
}
