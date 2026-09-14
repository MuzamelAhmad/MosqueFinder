import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mosque_finder/SRC/Application/Cubit/Imam/imam_cubit.dart';
import 'package:mosque_finder/SRC/Data/Resources/Export/exports.dart';
import 'package:mosque_finder/SRC/Presentation/Widgets/Auth/signup/pray_timer.dart';

class CompleteProfileScreen extends StatefulWidget {
  final String userId;
  final String email;
  final String fullName;

  const CompleteProfileScreen({
    super.key,
    required this.userId,
    required this.email,
    required this.fullName,
  });

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen>
    with WidgetsBindingObserver {
  double? _latitude;
  double? _longitude;
  String _cityName = '';
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _latitude == null) {
      context.read<ImamCubit>().pickLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textController = context.read<TextFieldController>();

    return BlocListener<ImamCubit, ImamState>(
      listener: (context, state) {
        if (state is ImamLocationLoaded) {
          setState(() {
            _latitude = state.latitude;
            _longitude = state.longitude;
            _cityName = state.city;
          });
        }
        if (state is ImamSignupSuccess) {
          // Success: Profile saved, now set prayer times
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PrayTimer(userId: widget.userId),
            ),
          );
        }
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: AppColors.bgColors,
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                  SizedBox(height: 20.h),
                  Text(
                    'Almost There!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Provide mosque details to finish your profile.',
                    style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 40.h),
                  
                  // Mosque Name
                  TextFromFieldCommon(
                    controller: textController.mosqueName,
                    validator: (val) => val!.isEmpty ? 'Mosque name required' : null,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    hintTitle: 'Mosque Name',
                    isIconShow: true,
                    iConData: Icons.mosque_outlined,
                    onTap: () => textController.mosqueNameClearText(),
                  ),
                  SizedBox(height: 24.h),

                  // Location Picker
                  BlocBuilder<ImamCubit, ImamState>(
                    builder: (context, state) {
                      final isLoading = state is ImamLocationLoading;
                      return GestureDetector(
                        onTap: isLoading ? null : () => context.read<ImamCubit>().pickLocation(),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            border: Border.all(
                              color: _latitude != null ? Colors.greenAccent : Colors.white24,
                              width: 1.5.w,
                            ),
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              isLoading
                                  ? SizedBox(
                                      width: 20.w,
                                      height: 20.h,
                                      child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : Icon(
                                      _latitude != null ? Icons.location_on_rounded : Icons.location_searching_rounded,
                                      color: _latitude != null ? Colors.greenAccent : Colors.white,
                                      size: 22.r,
                                    ),
                              SizedBox(width: 12.w),
                              Text(
                                _latitude != null ? '📍 $_cityName' : 'Detect Mosque Location',
                                style: TextStyle(
                                  color: _latitude != null ? Colors.greenAccent : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  
                  SizedBox(height: 48.h),

                  // Finish Button
                  BlocBuilder<ImamCubit, ImamState>(
                    builder: (context, state) {
                      final isLoading = state is ImamLoading;
                      return isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : CustomBotton(
                              text: 'Finish Setup',
                              onTap: () {
                                if (!_formKey.currentState!.validate()) {
                                  return;
                                }

                                if (_latitude == null) {
                                  CustomSnackBar.showError(context, 'Please detect mosque location');
                                  return;
                                }

                                // We use signUp method but with social info
                                context.read<ImamCubit>().signUp(
                                  email: widget.email,
                                  password: 'OAUTH_USER', // Placeholder
                                  fullName: widget.fullName,
                                  mosqueName: textController.mosqueName.text.trim(),
                                  latitude: _latitude!,
                                  longitude: _longitude!,
                                  city: _cityName,
                                );
                              },
                            );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    )
    );
    }
}
