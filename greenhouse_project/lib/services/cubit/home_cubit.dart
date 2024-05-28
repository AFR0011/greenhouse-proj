///
/// TODO:
/// - Configure notifications for IOS and Android
/// - (then) write code to send notifications when they occur
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'home_state.dart';
part 'user_info_cubit.dart';
part 'notifications_cubit.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(super.initialState);
}
