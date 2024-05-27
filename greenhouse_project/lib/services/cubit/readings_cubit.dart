part of 'greenhouse_cubit.dart';

class ReadingsCubit extends GreenhouseCubit {
  final CollectionReference readings =
      FirebaseFirestore.instance.collection('readings');

  bool _isActive = true;

  ReadingsCubit() : super(ReadingsLoading()) {
    _fetchReadingInfo();
  }

  _fetchReadingInfo() {
    if (!_isActive) return;
    readings.snapshots().listen((snapshot) {
      final List<ReadingsData> readings =
          snapshot.docs.map((doc) => ReadingsData.fromFirestore(doc)).toList();
      if (_isActive) emit(ReadingsLoaded([...readings]));
    }, onError: (error) {
      if (_isActive) emit(ReadingsError(error.toString()));
    });
  }

  @override
  Future<void> close() {
    _isActive = false;
    return super.close();
  }
}

class ReadingsData {
  final Map<String, dynamic> allReadings;

  ReadingsData({required this.allReadings});

  factory ReadingsData.fromFirestore(DocumentSnapshot doc) {
    
    LinkedHashMap<String, dynamic> databaseReadings =
        doc.data() as LinkedHashMap<String, dynamic>;
    print("databasereadings $databaseReadings");
    // Converting LinkedHashMap to a list of maps preserving keys
    Map<String, dynamic> readingsList = databaseReadings.entries
        .map(
          (boardReading) => {
            boardReading.key: boardReading.value,
          },
        )
        .toSet().first;
        print("READINGSLIST $readingsList");
    return ReadingsData(allReadings: readingsList);
  }
}
