import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
part 'inventory_edit_state.dart';

class InventoryEditCubit extends Cubit<List<bool>> {
  InventoryEditCubit() : super([true, true, true]);

  bool updateState(List<bool> validation) {
    emit([...validation]);
    if (validation.contains(false)) {
      return false;
    } else {
      return true;
    }
  }
}
