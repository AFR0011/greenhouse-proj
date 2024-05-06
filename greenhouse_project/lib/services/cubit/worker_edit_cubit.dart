import "package:flutter_bloc/flutter_bloc.dart";

class WorkerEditCubit extends Cubit<String> {
  WorkerEditCubit() : super("worker");

  updateDropdown(String value) {
    emit(value);
  }
}
