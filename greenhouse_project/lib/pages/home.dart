/// Home page - notifications, welcome message, and search
///
/// TODO:
/// - Add delete notification option (individual and all)
///
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenhouse_project/pages/login.dart';
import 'package:greenhouse_project/services/cubit/auth_cubit.dart';
import 'package:greenhouse_project/services/cubit/footer_nav_cubit.dart';
import 'package:greenhouse_project/services/cubit/home_cubit.dart';
import 'package:greenhouse_project/utils/buttons.dart';
import 'package:greenhouse_project/utils/chart.dart';
import 'package:greenhouse_project/utils/footer_nav.dart';
import 'package:greenhouse_project/utils/appbar.dart';
import 'package:greenhouse_project/utils/text_styles.dart';
import 'package:greenhouse_project/utils/theme.dart';

class HomePage extends StatelessWidget {
  final UserCredential userCredential; // user auth credentials

  const HomePage({super.key, required this.userCredential});

  @override
  Widget build(BuildContext context) {
    // Provide Cubits for state management
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => FooterNavCubit(),
        ),
        BlocProvider(
          create: (context) => NotificationsCubit(userCredential),
        ),
        BlocProvider(
          create: (context) => UserInfoCubit(),
        ),
      ],
      child: _EquipmentPageContent(userCredential: userCredential),
    );
  }
}

class _EquipmentPageContent extends StatefulWidget {
  final UserCredential userCredential; // user auth credentials

  const _EquipmentPageContent({required this.userCredential});

  @override
  State<_EquipmentPageContent> createState() => _EquipmentPageContentState();
}

// Main page content goes here
class _EquipmentPageContentState extends State<_EquipmentPageContent> {
  // User info local variables
  late String _userRole = "";
  late String _userName = "";
  late DocumentReference _userReference;
  late bool _enabled;
  List<bool> _isSelected = [true, false];
  // Custom theme
  final ThemeData customTheme = theme;
  
   Widget _getDisplayWidget() {
    if (_isSelected[0]) {
      return _buildDashbord()
      ;
    } else {
      return _buildNotifications();
    }
  }

  void _onToggle(int index) {
    setState(() {
      for (int i = 0; i < _isSelected.length; i++) {
        _isSelected[i] = i == index;
      }
    });
  }

  int _selectedIndexWidget = 2;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndexWidget = index;
    });
  }


  // Text controllers
  final TextEditingController _searchController = TextEditingController();

  // Index of footer nav selection
  final int _selectedIndex = 2;

  // Dispose (destructor)
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // InitState - get user info state to check authentication later
  @override
  void initState() {
    context.read<UserInfoCubit>().getUserInfo(widget.userCredential);
    context.read<NotificationsCubit>().initNotifications();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // BlocListener for handling footer nav events
    return BlocListener<FooterNavCubit, int>(
      listener: (context, state) {
        navigateToPage(context, state, _userRole, widget.userCredential,
            userReference: _userReference);
      },
      // BlocBuilder for user info
      child: BlocBuilder<UserInfoCubit, HomeState>(
        builder: (context, state) {
          // Show "loading screen" if processing user info
          if (state is UserInfoLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          // Show content once user info is loaded
          else if (state is UserInfoLoaded) {
            // Assign user info to local variables
            _userRole = state.userRole;
            _userName = state.userName;
            _userReference = state.userReference;
            _enabled = state.enabled;

            // Get device token for notifications

            // Call function to create home page
            if (_enabled) {
              return Theme(data: customTheme, child: _createHomePage());
            } else {
              return Center(
                  child: Theme(
                      data: customTheme, child: _createHomePageDisabled()));
            }
          }
          // Show error if there is an issues with user info
          else if (state is UserInfoError) {
            return Center(child: Text('Error: ${state.errorMessage}'));
          }
          // If somehow state doesn't match predefined states;
          // never happens; but, anything can happen
          else {
            return const Center(child: Text('Unexpected State'));
          }
        },
      ),
    );
  }

  // Create greenhouse page function
  Widget _createHomePage() {
    // Get instance of footer nav cubit from main context
    final footerNavCubit = BlocProvider.of<FooterNavCubit>(context);

    // Page content
    return Scaffold(
        // Main appbar (header)
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(80.0),
          child: createMainAppBar(
              context, widget.userCredential, _userReference, "Welcome"),
        ),

      // Call function to build notificaitons list
      body: Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.lightBlueAccent.shade100.withOpacity(0.6),
            Colors.teal.shade100.withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        image: DecorationImage(
          image: const AssetImage('lib/utils/Icons/leaf_pat.jpg'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.white.withOpacity(0.05),
            BlendMode.dstATop,
          ),
        ),
      ),
      child:Column(
        children: [
          Container(
            width: double.maxFinite,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade700, Colors.teal.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                ),
                
            ),
            child: Center(
              child: ToggleButtons(
                  renderBorder: false,
                  fillColor: Colors.teal.withOpacity(1),
                  selectedColor: Colors.white,
                  splashColor: Colors.tealAccent,
                  hoverColor: Colors.tealAccent.withOpacity(0.1),
                  isSelected: _isSelected,
                  onPressed: _onToggle,
                  children: <Widget>[
                      SizedBox(
                        width: MediaQuery.of(context).size.width*0.5,
                        child: const Align(
                          alignment: Alignment.center,
                          child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                              'Dashbord',
                              style: TextStyle(fontSize: 16),
                          ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width*0.5,
                        child: const Align(
                          alignment: Alignment.center,
                          child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                              'Notifications',
                              style: TextStyle(fontSize: 16),
                          ),
                          ),
                        ),
                      ),
                  ],
                  
                  ),

                
            ),
          ),
          _getDisplayWidget()
        ],
      )),

        // Footer nav bar
        bottomNavigationBar: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.green.shade700,
                    Colors.teal.shade400,
                    Colors.blue.shade300
                  ],
                  stops: [0.2, 0.5, 0.9],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                ),
                child:
                    createFooterNav(_selectedIndex, footerNavCubit, _userRole),
              )),
        ));
  }

  Widget _buildNotifications() {
    return Column(
      children: [
        SizedBox(height: 16,),
        // BlocBuilder for notifications
        BlocBuilder<NotificationsCubit, HomeState>(
          builder: (context, state) {
            // Show "loading screen" if processing notification state
            if (state is NotificationsLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            // Show equipment status once notification state is loaded
            else if (state is NotificationsLoaded) {
              List<NotificationData> notificationsList =
                  state.notifications; // notifications list
              // Display nothing if no notifications
              if (notificationsList.isEmpty) {
                return const Center(child: Text("No Notifications..."));
              }
              // Display notifications
              else {
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: notificationsList.length,
                  itemBuilder: (context, index) {
                    NotificationData notification =
                        notificationsList[index]; // notification data
                    // Notification message
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(12,0,12,0),
                      child: Card(
                        
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                        elevation: 4.0,
                        margin: const EdgeInsets.only(bottom: 16.0),
                        child: ListTile(
                          leading: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.cyan.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.notification_important_outlined,
                            color: Colors.orange,
                            size: 30.0,
                          ),
                        ),
                          title: Text(notification.message,style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                ),),
                        ),
                      ),
                    );
                  },
                );
              }
            }
            // Show error message once an error occurs
            else if (state is NotificationsError) {
              return Center(child: Text('Error: ${state.errorMessage}'));
            }
            // If the state is not any of the predefined states;
            // never happens; but, anything can happen
            else {
              return const Center(child: Text('Unexpected State'));
            }
          },
        ),
      ],
    );
  }
  Widget _buildDashbord(){
    return Container(
      height: MediaQuery.of(context).size.height*0.6,
      width: MediaQuery.of(context).size.width*.8,
      
        child:  ChartClass(),
      
    );
  }

  _createHomePageDisabled() {
    UserInfoCubit userInfoCubit = context.read<UserInfoCubit>();
    AuthCubit authCubit = context.read<AuthCubit>();

    // Page content
    return Scaffold(
      // Main appbar (header)
      appBar: AppBar(),

      // Call function to build notificaitons list
      body: Column(
        children: [
          const Text(
              "Your account has been disabled by the greenhouse administration.\n If you don't work here anymore, please delete your account."),
          Row(
            children: [
              GreenElevatedButton(
                  text: "Delete Account",
                  onPressed: () {
                    userInfoCubit.deleteUserAccount(
                        widget.userCredential, _userReference);
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              content: Column(
                                children: [
                                  const Text("All done!"),
                                  Center(
                                      child: GreenElevatedButton(
                                          text: "OK",
                                          onPressed: () => authCubit
                                              .authLogoutRequest()
                                              .then((value) =>
                                                  Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              const LoginPage())))))
                                ],
                              ),
                            ));
                  })
            ],
          )
        ],
      ),
    );
  }
}
