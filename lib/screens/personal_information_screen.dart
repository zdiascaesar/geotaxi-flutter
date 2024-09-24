import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../theme/app_colors.dart';
import '../services/user_service.dart';
import 'car_information_screen.dart';
import 'home_screen.dart';

class PersonalInformationScreen extends StatefulWidget {
  final int userRole; // 0 for passenger, 1 for driver

  const PersonalInformationScreen({Key? key, required this.userRole}) : super(key: key);

  @override
  _PersonalInformationScreenState createState() => _PersonalInformationScreenState();
}

class _PersonalInformationScreenState extends State<PersonalInformationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _familyNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _familyNameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(localizations.personalInformation, style: TextStyle(color: AppColors.textDark)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SvgPicture.asset(
              'lib/assets/header-registration.svg',
              width: MediaQuery.of(context).size.width,
              height: 275,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      localizations.fillUpYourInformation,
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: localizations.name),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return localizations.pleaseEnterName;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _familyNameController,
                      decoration: InputDecoration(labelText: localizations.familyName),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return localizations.pleaseEnterFamilyName;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneNumberController,
                      decoration: InputDecoration(labelText: localizations.phoneNumber),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return localizations.pleaseEnterPhoneNumber;
                        }
                        // Add more specific phone number validation if needed
                        return null;
                      },
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      style: AppTheme.confirmEmailButtonStyle,
                      onPressed: _isLoading ? null : _handleNext,
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(localizations.next),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleNext() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final personalInfo = {
            'name': _nameController.text,
            'familyName': _familyNameController.text,
            'phoneNumber': _phoneNumberController.text,
            'role': widget.userRole,
          };

          // Check if the user exists in Firestore
          final existingUser = await UserService.getUser(user.uid);
          if (existingUser == null) {
            // If the user doesn't exist, create a new user document
            await UserService.createUser(user.uid, personalInfo);
          } else {
            // If the user exists, update their information
            await UserService.updateUser(user.uid, personalInfo);
          }

          if (widget.userRole == 1) { // Driver
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => CarInformationScreen()),
            );
          } else { // Passenger
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          }
        } else {
          throw Exception('User not found');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating user information: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}