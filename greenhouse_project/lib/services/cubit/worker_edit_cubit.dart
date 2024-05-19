import "package:flutter_bloc/flutter_bloc.dart";

class WorkerEditCubit extends Cubit<String> {
  bool _isActive = true;
  WorkerEditCubit() : super("worker");

  updateDropdown(String value) {
    if (!_isActive) return;
    emit(value);
  }

  @override
  Future<void> close() {
    _isActive = false;
    return super.close();
  }
}
