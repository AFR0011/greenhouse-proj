part of 'greenhouse_cubit.dart';

class ProgramsCubit extends GreenhouseCubit {
  final CollectionReference programs =
      FirebaseFirestore.instance.collection('Programs');

  ProgramsCubit() : super(ProgramsLoading()) {
    _fetchProgramInfo();
  }

  _fetchProgramInfo() {
    programs
        .orderBy('creationDate', descending: true)
        .snapshots()
        .listen((snapshot) {
      final List<ProgramData> programs =
          snapshot.docs.map((doc) => ProgramData.fromFirestore(doc)).toList();

      emit(ProgramsLoaded([...programs]));
    });
  }
}

class ProgramData {
  final Map<String, String> actions;
  final Map<String, String> conditions;
  final DateTime creationDate;
  final String title;

  ProgramData({
    required this.actions,
    required this.conditions,
    required this.creationDate,
    required this.title,
  });

  factory ProgramData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProgramData(
      actions: data['actions'],
      conditions: data['conditions'],
      title: data['title'],
      creationDate: data['creationDate'],
    );
  }
}
