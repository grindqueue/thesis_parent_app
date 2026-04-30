import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class AddChildScreen extends StatefulWidget {
  const AddChildScreen({super.key});

  @override
  State<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _deviceIdCtrl = TextEditingController();
  String _selectedNationality = 'Nigerian';
  bool _isLoading = false;
  bool _idPhotoUploaded = false;
  String? _idPhotoPath;

  final List<String> _nationalities = [
    'Nigerian', 'Ghanaian', 'Kenyan', 'South African', 'American',
    'British', 'Canadian', 'Other',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _deviceIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickIdPhoto(ImageSource source) async {
    // TODO: Use image_picker package
    // final picker = ImagePicker();
    // final file = await picker.pickImage(source: source);
    // if (file != null) setState(() { _idPhotoUploaded = true; _idPhotoPath = file.path; });

    // Simulated for UI preview
    setState(() {
      _idPhotoUploaded = true;
      _idPhotoPath = 'mock_id_photo.jpg';
    });
    Navigator.pop(context); // close bottom sheet
  }

  void _showPhotoSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Upload National ID Photo',
                style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            const Text(
              'The ID must be a valid government-issued national identity card.',
              style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 13,
                  color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            _SheetOption(
              icon: Icons.camera_alt_outlined,
              label: 'Take a Photo',
              onTap: () => _pickIdPhoto(ImageSource.camera),
            ),
            const SizedBox(height: 12),
            _SheetOption(
              icon: Icons.photo_library_outlined,
              label: 'Choose from Gallery',
              onTap: () => _pickIdPhoto(ImageSource.gallery),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_idPhotoUploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please upload the child\'s national ID photo')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // TODO: Upload ID photo first, then submit child registration
    // final uploadRes = await ApiService.uploadNationalId(filePath: _idPhotoPath!);
    // final res = await ApiService.registerChild(
    //   name: _nameCtrl.text.trim(),
    //   age: int.parse(_ageCtrl.text.trim()),
    //   deviceId: _deviceIdCtrl.text.trim(),
    //   nationality: _selectedNationality,
    //   nationalIdUrl: uploadRes.url,
    // );

    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Child profile created successfully!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Register Child'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassCard(
                borderColor: AppColors.primary.withOpacity(0.3),
                child: Row(
                  children: const [
                    Icon(Icons.info_outline_rounded,
                        color: AppColors.primary, size: 18),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'The child\'s national ID is used to verify age and identity. This data is securely stored and only accessible to authorized systems.',
                        style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Child\'s Full Name',
                        prefixIcon: Icon(Icons.child_care_rounded,
                            color: AppColors.textMuted),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Name is required'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Age
                    TextFormField(
                      controller: _ageCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Age',
                        prefixIcon: Icon(Icons.cake_outlined,
                            color: AppColors.textMuted),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Age is required';
                        final age = int.tryParse(v);
                        if (age == null || age < 1 || age > 17) {
                          return 'Enter a valid age (1–17)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Nationality dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedNationality,
                      items: _nationalities
                          .map((n) => DropdownMenuItem(value: n, child: Text(n)))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedNationality = v!),
                      decoration: const InputDecoration(
                        labelText: 'Nationality',
                        prefixIcon: Icon(Icons.flag_outlined,
                            color: AppColors.textMuted),
                      ),
                      dropdownColor: AppColors.card,
                      style: const TextStyle(
                          fontFamily: 'Outfit',
                          color: AppColors.textPrimary,
                          fontSize: 15),
                    ),
                    const SizedBox(height: 16),

                    // Device ID
                    TextFormField(
                      controller: _deviceIdCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Device ID',
                        hintText: 'e.g. device-abc-001 (provided by child app)',
                        prefixIcon: Icon(Icons.phone_android_rounded,
                            color: AppColors.textMuted),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Device ID is required'
                          : null,
                    ),
                    const SizedBox(height: 24),

                    // National ID photo upload
                    const Text('National ID Photo',
                        style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    const Text(
                      'Upload a clear photo of the child\'s valid national identity card.',
                      style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 13,
                          color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _showPhotoSourceSheet,
                      child: Container(
                        height: 140,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.inputFill,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _idPhotoUploaded
                                ? AppColors.accent.withOpacity(0.5)
                                : AppColors.cardBorder,
                            width: 1.5,
                          ),
                        ),
                        child: _idPhotoUploaded
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.accent.withOpacity(0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.check_circle_rounded,
                                        color: AppColors.accent, size: 32),
                                  ),
                                  const SizedBox(height: 10),
                                  const Text('ID Photo Uploaded',
                                      style: TextStyle(
                                          fontFamily: 'Outfit',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.accent)),
                                  const SizedBox(height: 4),
                                  const Text('Tap to change',
                                      style: TextStyle(
                                          fontFamily: 'Outfit',
                                          fontSize: 12,
                                          color: AppColors.textMuted)),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.upload_file_rounded,
                                      color: AppColors.textMuted, size: 36),
                                  SizedBox(height: 10),
                                  Text('Tap to upload ID photo',
                                      style: TextStyle(
                                          fontFamily: 'Outfit',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textSecondary)),
                                  SizedBox(height: 4),
                                  Text('JPG, PNG · Max 5MB',
                                      style: TextStyle(
                                          fontFamily: 'Outfit',
                                          fontSize: 12,
                                          color: AppColors.textMuted)),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    PrimaryButton(
                      label: 'Register Child',
                      onPressed: _onSubmit,
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Placeholder enum (use image_picker's ImageSource in real code)
enum ImageSource { camera, gallery }

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SheetOption(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.inputFill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder, width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(width: 14),
            Text(label,
                style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}
