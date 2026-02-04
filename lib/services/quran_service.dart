import 'package:quran/quran.dart' as quran;

class QuranService {
  /// Get list of all Surahs with metadata
  List<Map<String, dynamic>> getAllSurahs() {
    return List.generate(114, (index) {
      int surahNumber = index + 1;
      return {
        "id": surahNumber,
        "name": quran.getSurahName(
          surahNumber,
        ), // Transliterated (e.g. Al-Fatihah)
        "englishMeaning": quran.getSurahNameEnglish(
          surahNumber,
        ), // Meaning (e.g. The Opening)
        "arabicName": quran.getSurahNameArabic(surahNumber),
        "type": quran.getPlaceOfRevelation(surahNumber),
        "ayahs": quran.getVerseCount(surahNumber),
      };
    });
  }

  /// Get specific Surah details
  Map<String, dynamic> getSurahDetails(int surahNumber) {
    return {
      "id": surahNumber,
      "name": quran.getSurahName(surahNumber),
      "englishMeaning": quran.getSurahNameEnglish(surahNumber),
      "arabicName": quran.getSurahNameArabic(surahNumber),
      "type": quran.getPlaceOfRevelation(surahNumber),
      "ayahs": quran.getVerseCount(surahNumber),
    };
  }

  /// Get Arabic text for a specific verse
  String getVerseArabic(int surahNumber, int verseNumber) {
    return quran.getVerse(surahNumber, verseNumber, verseEndSymbol: true);
  }

  /// Get Translation for a specific verse (English by default for now)
  String getVerseTranslation(int surahNumber, int verseNumber) {
    return quran.getVerseTranslation(surahNumber, verseNumber);
  }

  /// Get audio URL for a specific verse (Mishary Alafasy)
  String getAudioUrl(int surahNumber, int verseNumber) {
    return quran.getAudioURLByVerse(surahNumber, verseNumber);
  }

  /// Get Basmala
  String getBasmala() {
    return quran.basmala;
  }

  /// Get list of all Juz (1-30)
  List<Map<String, dynamic>> getAllJuz() {
    return List.generate(30, (index) {
      int juzNumber = index + 1;
      final surahVerses = quran.getSurahAndVersesFromJuz(juzNumber);

      // Get first and last surah names for display
      final surahKeys = surahVerses.keys.toList();
      final firstSurahNum = surahKeys.first;

      final firstSurahName = quran.getSurahName(firstSurahNum);
      final firstVerseNum = surahVerses[firstSurahNum]!.first;

      String description =
          "Starts from Surah $firstSurahName ($firstSurahNum:$firstVerseNum)";

      return {
        "id": juzNumber,
        "name": "Juz $juzNumber",
        "description": description,
        "surahVerses": surahVerses,
      };
    });
  }
}
