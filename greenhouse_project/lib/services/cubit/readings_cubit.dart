part of 'greenhouse_cubit.dart';

class ReadingsCubit extends GreenhouseCubit {
  final CollectionReference readings =
      FirebaseFirestore.instance.collection('readings');

  ReadingsCubit() : super(ReadingsLoading()) {
    _fetchReadingInfo();
  }

  _fetchReadingInfo() {
    readings.snapshots().listen((snapshot) {
      final List<ReadingsData> readings =
          snapshot.docs.map((doc) => ReadingsData.fromFirestore(doc)).toList();

      emit(ReadingsLoaded([...readings]));
    }, onError: (error) {
      print(error.toString());
      emit(ReadingsError(error.toString()));
    });
  }
}

class ReadingsData {
  final Set<Map<String, dynamic>> allReadings;

  ReadingsData({required this.allReadings});

  factory ReadingsData.fromFirestore(DocumentSnapshot doc) {
    LinkedHashMap<String, dynamic> databaseReadings =
        doc.data() as LinkedHashMap<String, dynamic>;

    // Converting LinkedHashMap to a list of maps preserving keys
    Set<Map<String, dynamic>> readingsList = databaseReadings.entries
        .map(
          (boardReading) => {
            boardReading.key: boardReading.value,
          },
        )
        .toSet();

    return ReadingsData(allReadings: readingsList);
  }
}
