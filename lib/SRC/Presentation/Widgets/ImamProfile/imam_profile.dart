import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mosque_finder/SRC/Application/Cubit/Imam/imam_cubit.dart';
import 'package:mosque_finder/SRC/Data/Resources/Export/exports.dart';
import 'package:mosque_finder/SRC/Data/repositories/ImamModel/imam_model.dart';

class ImamProfile extends StatelessWidget {
  const ImamProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Profile',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onPrimary,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
      ),
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
          child: BlocConsumer<ImamCubit, ImamState>(
            listener: (context, state) {
              if (state is ImamProfileUpdateSuccess) {
                CustomSnackBar.showSuccess(context, 'Profile updated successfully ✅');
              }
              if (state is ImamProfileUpdateError) {
                CustomSnackBar.showError(context, state.message);
              }
            },
            builder: (context, state) {
              if (state is ImamLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is ImamLoaded ||
                  state is ImamProfileUpdateSuccess ||
                  state is ImamProfileUpdateError) {
                // If we are in a success/error state, we still want to show the profile
                // The Cubit refreshes getImamData() after success, so ImamLoaded will follow.
                // For now, we need to handle the case where we might not have the 'imam' object
                // in the intermediate states if they don't carry it.
                // However, since we used BlocConsumer and getImamData() is called immediately,
                // the UI will quickly return to ImamLoaded.

                // A better approach is to ensure the cubit state carries the last known data
                // or just let it fall through to a placeholder if needed.
                final imam = state is ImamLoaded ? state.imam : null;

                if (imam == null && state is! ImamLoading) {
                  // Trigger a reload if we somehow lost the data
                  context.read<ImamCubit>().getImamData();
                  return const Center(child: CircularProgressIndicator());
                }

                if (imam != null) {
                  return SingleChildScrollView(
                    padding:
                        EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                    child: Column(
                      children: [
                        // Profile Header
                        CircleAvatar(
                          radius: 60,
                          backgroundColor:
                              theme.colorScheme.primary.withOpacity(0.2),
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Text(
                          imam.imamName,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          imam.email,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.onPrimary.withOpacity(0.7),
                          ),
                        ),
                        SizedBox(height: 30.h),

                        // Information Cards
                        _buildInfoTile(
                          context,
                          icon: Icons.mosque_outlined,
                          label: 'Mosque Name',
                          value: imam.mosqueName,
                        ),
                        _buildInfoTile(
                          context,
                          icon: Icons.location_city,
                          label: 'City',
                          value: imam.city,
                        ),
                        _buildInfoTile(
                          context,
                          icon: Icons.location_on_outlined,
                          label: 'Coordinates',
                          value:
                              '${imam.latitude.toStringAsFixed(4)}, ${imam.longitude.toStringAsFixed(4)}',
                        ),

                        SizedBox(height: 40.h),

                        ElevatedButton.icon(
                          onPressed: () => _showEditSheet(context, imam),
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit Profile'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            foregroundColor: theme.colorScheme.onPrimary,
                            minimumSize: Size(double.infinity, 50.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              }

              if (state is ImamError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        state.message,
                        style: TextStyle(color: theme.colorScheme.onPrimary),
                      ),
                      SizedBox(height: 20.h),
                      ElevatedButton(
                        onPressed: () =>
                            context.read<ImamCubit>().getImamData(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  void _showEditSheet(BuildContext context, ImamModel imam) {
    final nameController = TextEditingController(text: imam.imamName);
    final mosqueController = TextEditingController(text: imam.mosqueName);
    final cityController = TextEditingController(text: imam.city);
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: Colors.indigo.shade900,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Profile',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 24.h),
              _buildTextField(
                controller: nameController,
                label: 'Full Name',
                icon: Icons.person_outline,
              ),
              SizedBox(height: 16.h),
              _buildTextField(
                controller: mosqueController,
                label: 'Mosque Name',
                icon: Icons.mosque_outlined,
              ),
              SizedBox(height: 16.h),
              _buildTextField(
                controller: cityController,
                label: 'City',
                icon: Icons.location_city,
              ),
              SizedBox(height: 32.h),
              ElevatedButton(
                onPressed: () {
                  context.read<ImamCubit>().updateProfile(
                        fullName: nameController.text.trim(),
                        mosqueName: mosqueController.text.trim(),
                        city: cityController.text.trim(),
                      );
                  Navigator.pop(bottomSheetContext);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50.h),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Save Changes'),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
        prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
      ),
    );
  }

  Widget _buildInfoTile(BuildContext context,
      {required IconData icon, required String label, required String value}) {
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.onPrimary, size: 28),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimary.withOpacity(0.6),
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
