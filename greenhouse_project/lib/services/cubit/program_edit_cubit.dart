import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

part 'program_edit_state.dart';

class ProgramEditCubit extends Cubit<List<String>> {
  ProgramEditCubit() : super(["", "", ""]);

  void updateDropdown(List<String> values) {
    emit([...values]);
  }
}
