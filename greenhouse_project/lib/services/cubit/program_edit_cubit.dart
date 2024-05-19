import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

part 'program_edit_state.dart';

class ProgramEditCubit extends Cubit<List<String>> {
  bool _isActive = true;
  ProgramEditCubit() : super(["", "", ""]);

  void updateDropdown(List<String> values) {
    if (!_isActive) return;
    emit([...values]);
  }

  @override
  Future<void> close() {
    _isActive = false;
    return super.close();
  }
}
