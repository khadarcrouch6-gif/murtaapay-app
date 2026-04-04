import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/app_colors.dart';
import '../../core/models/message_model.dart';
import '../../core/responsive_utils.dart';

class PersonalInfoShareScreen extends StatefulWidget {
  final Function(PersonalInfoShare) onInfoShared;

  const PersonalInfoShareScreen({
    super.key,
    required this.onInfoShared,
  });

  @override
  State<PersonalInfoShareScreen> createState() => _PersonalInfoShareScreenState();
}

class _PersonalInfoShareScreenState extends State<PersonalInfoShareScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController(text: 'Ahmed Hassan');
  final _emailController = TextEditingController(text: 'ahmed@example.com');
  final _phoneController = TextEditingController(text: '+252 61 123 4567');
  final _addressController = TextEditingController(text: '123 Main St');
  final _cityController = TextEditingController(text: 'Mogadishu');
  final _countryController = TextEditingController(text: 'Somalia');
  final _postalCodeController = TextEditingController(text: '12345');

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Share Personal Info'),
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.textTheme.titleLarge?.color,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(context.horizontalPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Review information to share',
                style: TextStyle(
                  fontSize: 18 * context.fontSizeFactor,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.titleLarge?.color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This information will be shared with the current conversation.',
                style: TextStyle(
                  fontSize: 14 * context.fontSizeFactor,
                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 24),
              _buildTextField(
                context: context,
                theme: theme,
                controller: _nameController,
                label: 'Full Name',
                icon: FontAwesomeIcons.user,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                context: context,
                theme: theme,
                controller: _emailController,
                label: 'Email',
                icon: FontAwesomeIcons.envelope,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                context: context,
                theme: theme,
                controller: _phoneController,
                label: 'Phone Number',
                icon: FontAwesomeIcons.phone,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                context: context,
                theme: theme,
                controller: _addressController,
                label: 'Address',
                icon: FontAwesomeIcons.locationDot,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      context: context,
                      theme: theme,
                      controller: _cityController,
                      label: 'City',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      context: context,
                      theme: theme,
                      controller: _postalCodeController,
                      label: 'Postal Code',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                context: context,
                theme: theme,
                controller: _countryController,
                label: 'Country',
                icon: FontAwesomeIcons.globe,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 54 * context.fontSizeFactor,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentTeal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Share Information',
                    style: TextStyle(
                      fontSize: 16 * context.fontSizeFactor,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required ThemeData theme,
    required TextEditingController controller,
    required String label,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14 * context.fontSizeFactor,
            fontWeight: FontWeight.w500,
            color: theme.textTheme.titleMedium?.color,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: TextStyle(color: theme.textTheme.bodyLarge?.color),
          decoration: InputDecoration(
            prefixIcon: icon != null
                ? Icon(icon, size: 18 * context.fontSizeFactor, color: AppColors.accentTeal)
                : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            filled: true,
            fillColor: theme.colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.accentTeal, width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter $label';
            }
            return null;
          },
        ),
      ],
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final info = PersonalInfoShare(
        fullName: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        city: _cityController.text,
        country: _countryController.text,
        postalCode: _postalCodeController.text,
      );
      widget.onInfoShared(info);
      Navigator.pop(context);
    }
  }
}
