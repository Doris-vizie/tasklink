import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';

class ProfileSetupScreen extends StatefulWidget {
  final bool isMandatory;

  const ProfileSetupScreen({super.key, this.isMandatory = false});

  @override
  _ProfileSetupScreenState createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _phoneController = TextEditingController();
  File? _imageFile;
  bool _isUploading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _phoneController.text = authProvider.user?.phone ?? '';
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(String userId) async {
    if (_imageFile == null) return null;

    final supabase = Supabase.instance.client;
    final fileName = '$userId/profile.jpg';
    try {
      final response = await supabase.storage
          .from('profile-photos')
          .upload(fileName, _imageFile!, fileOptions: const FileOptions(upsert: true));

      if (response.isEmpty) {
        throw Exception('Failed to upload image: No response from server');
      }

      final publicUrl = supabase.storage.from('profile-photos').getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user!.id;
      final supabase = Supabase.instance.client;

      String? photoUrl = authProvider.user!.photoUrl;
      if (_imageFile != null) {
        try {
          photoUrl = await _uploadImage(userId);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload photo: $e')),
          );
          photoUrl = null;
        }
      }

      await supabase.from('profiles').update({
        'phone': _phoneController.text,
        if (photoUrl != null) 'photo_url': photoUrl,
      }).eq('id', authProvider.user!.id);

      final updatedUser = AppUser(
        id: authProvider.user!.id,
        name: authProvider.user!.name,
        email: authProvider.user!.email,
        phone: _phoneController.text,
        role: authProvider.user!.role,
        profileStatus: authProvider.user!.profileStatus,
        photoUrl: photoUrl ?? authProvider.user!.photoUrl,
      );
      authProvider.updateUserProfile(updatedUser);

      if (widget.isMandatory) {
        authProvider.navigateToRoleBasedHome(context);
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 100,
                    width: 100,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        "TL",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    widget.isMandatory ? 'Complete Your Profile' : 'Edit Profile',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.isMandatory
                        ? 'Add your details to continue'
                        : 'Update your profile details',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!)
                          : (authProvider.user!.photoUrl != null
                              ? NetworkImage(authProvider.user!.photoUrl!)
                              : null) as ImageProvider?,
                      child: _imageFile == null && authProvider.user!.photoUrl == null
                          ? const Icon(Icons.camera_alt, size: 50)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Tap to upload a profile photo',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: const Icon(Icons.phone),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isUploading ? null : _saveProfile,
                    child: _isUploading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Save Profile'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}