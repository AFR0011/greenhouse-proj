import 'package:flutter_bloc/flutter_bloc.dart';

class FooterNavCubit extends Cubit<int> {
  FooterNavCubit() : super(2); // Initialize with default index

  void updateSelectedIndex(int index) {
    emit(index);
  }
}
