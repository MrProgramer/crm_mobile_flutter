import 'package:shamsi_date/shamsi_date.dart';
import 'package:intl/intl.dart';

String toPersianDigits(dynamic input) {
  if (input == null) return '';
  final str = input.toString();
  const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const persian = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
  var result = str;
  for (var i = 0; i < english.length; i++) {
    result = result.replaceAll(english[i], persian[i]);
  }
  return result;
}

String toEnglishDigits(String input) {
  const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const persian = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
  const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  var result = input;
  for (var i = 0; i < 10; i++) {
    result = result.replaceAll(persian[i], english[i]).replaceAll(arabic[i], english[i]);
  }
  return result;
}

String formatPrice(num? amount, {bool showUnit = false, bool persianDigits = true}) {
  if (amount == null) return persianDigits ? '۰' : '0';
  final formatter = NumberFormat('#,###', 'en_US');
  final formatted = formatter.format(amount.round());
  final result = persianDigits ? toPersianDigits(formatted) : formatted;
  return showUnit ? '$result تومان' : result;
}

String getCurrentPersianDate() {
  final now = Jalali.now();
  final f = now.formatter;
  return '${f.yyyy}/${f.mm}/${f.dd}';
}

String getCurrentPersianTime() {
  final now = DateTime.now();
  return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
}

String formatPersianDateTime(DateTime dt) {
  final j = Jalali.fromDateTime(dt);
  final f = j.formatter;
  return '${f.yyyy}/${f.mm}/${f.dd} - ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

String normalizePersianText(String? text) {
  if (text == null) return '';
  return text
      .trim()
      .toLowerCase()
      .replaceAll('ي', 'ی')
      .replaceAll('ك', 'ک')
      .replaceAll('ة', 'ه')
      .replaceAll('۰', '0')
      .replaceAll('۱', '1')
      .replaceAll('۲', '2')
      .replaceAll('۳', '3')
      .replaceAll('۴', '4')
      .replaceAll('۵', '5')
      .replaceAll('۶', '6')
      .replaceAll('۷', '7')
      .replaceAll('۸', '8')
      .replaceAll('۹', '9');
}

String formatStockBreakdown(int totalPieces, int piecesPerCarton, {String unitTitle = 'عدد'}) {
  if (piecesPerCarton <= 1) {
    return '${toPersianDigits(totalPieces)} $unitTitle';
  }
  final cartons = totalPieces ~/ piecesPerCarton;
  final extra = totalPieces % piecesPerCarton;

  if (cartons > 0 && extra > 0) {
    return '${toPersianDigits(cartons)} کارتن و ${toPersianDigits(extra)} $unitTitle';
  } else if (cartons > 0) {
    return '${toPersianDigits(cartons)} کارتن';
  } else {
    return '${toPersianDigits(extra)} $unitTitle';
  }
}

String numberToPersianWords(num number) {
  int n = number.round().abs();
  if (n == 0) return 'صفر تومان';

  final ones = ['', 'یک', 'دو', 'سه', 'چهار', 'پنج', 'شش', 'هفت', 'هشت', 'نه'];
  final teens = ['ده', 'یازده', 'دوازده', 'سیزده', 'چهارده', 'پانزده', 'شانزده', 'هفده', 'هجده', 'نوزده'];
  final tens = ['', '', 'بیست', 'سی', 'چهل', 'پنجاه', 'شصت', 'هفتاد', 'هشتاد', 'نود'];
  final hundreds = ['', 'یکصد', 'دویست', 'سیصد', 'چهارصد', 'پانصد', 'ششصد', 'هفتصد', 'هشتصد', 'نهصد'];
  final scales = ['', 'هزار', 'میلیون', 'میلیارد', 'تریلیون'];

  String convertGroup(int numGroup) {
    int h = numGroup ~/ 100;
    int t = (numGroup % 100) ~/ 10;
    int o = numGroup % 10;
    List<String> parts = [];

    if (h > 0) parts.add(hundreds[h]);

    if (t == 1) {
      parts.add(teens[o]);
    } else {
      if (t > 1) parts.add(tens[t]);
      if (o > 0) parts.add(ones[o]);
    }

    return parts.join(' و ');
  }

  List<String> groupsWords = [];
  int scaleIdx = 0;

  while (n > 0) {
    int grp = n % 1000;
    if (grp > 0) {
      String groupText = convertGroup(grp);
      if (scaleIdx > 0 && scales[scaleIdx].isNotEmpty) {
        groupText = '$groupText ${scales[scaleIdx]}';
      }
      groupsWords.insert(0, groupText);
    }
    n ~/= 1000;
    scaleIdx++;
  }

  return '${groupsWords.join(' و ')} تومان';
}
