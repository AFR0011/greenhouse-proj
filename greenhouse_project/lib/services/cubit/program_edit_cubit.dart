import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'program_edit_state.dart';

class ProgramEditCubit extends Cubit<List<String>> {
  ProgramEditCubit() : super(["", "", ""]);

  void updateDropdown(List<String> values){
    emit([...values]);
  }
}
