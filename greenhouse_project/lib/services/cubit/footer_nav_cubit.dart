import 'package:flutter_bloc/flutter_bloc.dart';

class FooterNavCubit extends Cubit<int> {
  FooterNavCubit() : super(2); // Initialize with default index

  bool _isActive = true;
  void updateSelectedIndex(int index) {
    if (!_isActive) return;
    emit(index);
  }

  @override
  Future<void> close() {
    _isActive = false;
    return super.close();
  }
}
