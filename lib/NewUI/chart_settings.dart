double maxYaxis(int initialIndex) {
  switch (initialIndex) {
    case 0:
      return 20;
    case 1:
      return 10;
    case 2:
      return 6;
    case 3:
      return 80;
    case 4:
      return 6;
    default:
      return 10;
  }
}

double stepSize(int cardId) {
  switch (cardId) {
    case 0:
      return 5;
    case 1:
      return 2;
    case 2:
      return 1;
    case 3:
      return 20;
    case 4:
      return 1;
    default:
      return 1;
  }
}
