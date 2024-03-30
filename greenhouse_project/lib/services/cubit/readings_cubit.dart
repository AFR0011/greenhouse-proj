part of 'greenhouse_cubit.dart';

class ReadingsCubit extends GreenhouseCubit {
  final CollectionReference readings =
      FirebaseFirestore.instance.collection('readings');

  ReadingsCubit() : super(ReadingsLoading()) {
    _fetchReadingInfo();
  }

  _fetchReadingInfo() {
    readings
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      final List<ReadingData> readings =
          snapshot.docs.map((doc) => ReadingData.fromFirestore(doc)).toList();

      emit(ReadingsLoaded([...readings]));
    });
  }
}

class ReadingData {
  final double gas;
  final double humidity;
  final double lightIntensity;
  final double soilMoisture;
  final double temperature;
  final bool intruder;
  final Timestamp timestamp;

  ReadingData({
    required this.gas,
    required this.humidity,
    required this.lightIntensity,
    required this.soilMoisture,
    required this.temperature,
    required this.intruder,
    required this.timestamp,
  });

  factory ReadingData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReadingData(
      gas: data['gas'],
      humidity: data['humidity'],
      lightIntensity: data['lightIntensity'],
      soilMoisture: data['soilMoisture'],
      temperature: data['temprature'],
      intruder: data['intruder'],
      timestamp: (data['timestamp'] as Timestamp),
    );
  }
}
