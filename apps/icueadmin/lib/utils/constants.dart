const months = [
  {'name': 'Jan', 'val': '01'},
  {'name': 'Feb', 'val': '02'},
  {'name': 'Mar', 'val': '03'},
  {'name': 'Apr', 'val': '04'},
  {'name': 'May', 'val': '05'},
  {'name': 'Jun', 'val': '06'},
  {'name': 'Jul', 'val': '07'},
  {'name': 'Aug', 'val': '08'},
  {'name': 'Sep', 'val': '09'},
  {'name': 'Oct', 'val': '10'},
  {'name': 'Nov', 'val': '11'},
  {'name': 'Dec', 'val': '12'},
];

List<int> generateYears() {
  final startYear = 2023;
  final currentYear = DateTime.now().year;
  final List<int> years = [];

  for (int year = startYear; year <= currentYear; year++) {
    years.add(year);
  }

  return years;
}

/// Which filter mode the user has chosen.
enum FilterMode { bydate, bymonth, byperiod }
