import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/utils/email_verifier.dart';
import '../auth/auth_service.dart';

class SetupWizardScreen extends ConsumerStatefulWidget {
  const SetupWizardScreen({super.key});

  @override
  ConsumerState<SetupWizardScreen> createState() => _SetupWizardScreenState();
}

class _SetupWizardScreenState extends ConsumerState<SetupWizardScreen> {
  final _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;

  // Form Controllers
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _displayNameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _educationCtrl = TextEditingController();
  final _otherJobCtrl = TextEditingController();
  final _otherHobbyCtrl = TextEditingController();
  final _projectsCtrl = TextEditingController();

  // Dropdown Selections
  String? _selectedJob;
  String? _selectedHobby;

  static const List<String> kAvailableJobs = [
    'Software Engineer',
    'Product Designer',
    'Data Scientist',
    'Product Manager',
    'Student / Researcher',
    'Founder / Entrepreneur',
    'Marketing Specialist',
    'Financial Analyst',
    'Doctor / Healthcare',
    'Lawyer / Legal Counsel',
    'Artist / Creator',
    'Other (Specify)',
  ];

  static const List<String> kAvailableHobbies = [
    'Coding & Open Source',
    'Reading & Literature',
    'Gaming & Esports',
    'Fitness & Weightlifting',
    'Hiking & Outdoors',
    'Music & Production',
    'Photography & Film',
    'Cooking & Culinary Arts',
    'Chess & Strategy Games',
    'Traveling & Exploring',
    'Writing & Blogging',
    'Other (Specify)',
  ];

  // Validation Error Strings
  String? _emailError;
  String? _passwordError;
  String? _usernameError;
  String? _displayNameError;
  String? _ageError;
  String? _bioError;
  String? _educationError;
  String? _jobError;
  String? _hobbyError;

  @override
  void dispose() {
    _pageController.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _usernameCtrl.dispose();
    _ageCtrl.dispose();
    _displayNameCtrl.dispose();
    _bioCtrl.dispose();
    _educationCtrl.dispose();
    _otherJobCtrl.dispose();
    _otherHobbyCtrl.dispose();
    _projectsCtrl.dispose();
    super.dispose();
  }

  void _clearErrors() {
    setState(() {
      _emailError = null;
      _passwordError = null;
      _usernameError = null;
      _displayNameError = null;
      _ageError = null;
      _bioError = null;
      _educationError = null;
      _jobError = null;
      _hobbyError = null;
    });
  }

  Future<bool> _validateStep(int step) async {
    _clearErrors();
    bool isValid = true;

    if (step == 0) {
      // Validate Email using EmailVerifier (format, domain blocklist, TLD check, live DNS verification)
      final email = _emailCtrl.text.trim();
      if (email.isEmpty) {
        _emailError = 'Email is required.';
        isValid = false;
      } else {
        final verification = await EmailVerifier.verifyEmailLive(email);
        if (!verification.isValid) {
          _emailError = verification.errorMessage;
          isValid = false;
        }
      }

      // Validate Password
      final pass = _passwordCtrl.text;
      if (pass.isEmpty) {
        _passwordError = 'Password is required.';
        isValid = false;
      } else if (pass.length < 6) {
        _passwordError = 'Password must be at least 6 characters.';
        isValid = false;
      } else if (!RegExp(r'[0-9]').hasMatch(pass) || !RegExp(r'[a-zA-Z]').hasMatch(pass)) {
        _passwordError = 'Password must include both letters and numbers.';
        isValid = false;
      }

      // Validate Username
      final user = _usernameCtrl.text.trim();
      if (user.isEmpty) {
        _usernameError = 'Username is required.';
        isValid = false;
      } else if (user.length < 3) {
        _usernameError = 'Username must be at least 3 characters.';
        isValid = false;
      }
    } else if (step == 1) {
      // Validate Display Name
      final name = _displayNameCtrl.text.trim();
      if (name.isEmpty) {
        _displayNameError = 'Display Name is required.';
        isValid = false;
      } else if (name.length < 2) {
        _displayNameError = 'Display Name must be at least 2 characters.';
        isValid = false;
      }

      // Validate Age & Compare with Email Birth Year
      final ageText = _ageCtrl.text.trim();
      final age = int.tryParse(ageText);
      if (ageText.isEmpty) {
        _ageError = 'Age is required.';
        isValid = false;
      } else if (age == null || age < 5 || age > 120) {
        _ageError = 'Enter a valid age between 5 and 120 (e.g. 21).';
        isValid = false;
      } else {
        // Cross-check age against email birth year (e.g. alex2010@gmail.com vs entered age 25)
        final email = _emailCtrl.text.trim();
        final ageMismatch = EmailVerifier.verifyAgeMatch(email: email, enteredAge: age);
        if (ageMismatch != null) {
          _ageError = ageMismatch;
          isValid = false;
        }
      }

      // Validate Bio
      final bio = _bioCtrl.text.trim();
      if (bio.isEmpty) {
        _bioError = 'Please tell us a short bio.';
        isValid = false;
      }
    } else if (step == 2) {
      // Validate Education
      final edu = _educationCtrl.text.trim();
      if (edu.isEmpty) {
        _educationError = 'Education is required (e.g. MIT, High School, Self-Taught).';
        isValid = false;
      }

      // Validate Job Selection
      if (_selectedJob == null) {
        _jobError = 'Please select your profession from the dropdown.';
        isValid = false;
      } else if (_selectedJob == 'Other (Specify)' && _otherJobCtrl.text.trim().isEmpty) {
        _jobError = 'Please specify your profession.';
        isValid = false;
      }
    } else if (step == 3) {
      // Validate Hobby Selection
      if (_selectedHobby == null) {
        _hobbyError = 'Please select a primary interest/hobby from the dropdown.';
        isValid = false;
      } else if (_selectedHobby == 'Other (Specify)' && _otherHobbyCtrl.text.trim().isEmpty) {
        _hobbyError = 'Please specify your interest/hobby.';
        isValid = false;
      }
    }

    setState(() {});
    return isValid;
  }

  Future<void> _nextStep() async {
    setState(() => _isLoading = true);
    final isValid = await _validateStep(_currentStep);
    setState(() => _isLoading = false);

    if (!isValid) {
      return;
    }

    if (_currentStep < 3) {
      _pageController.nextPage(duration: 300.ms, curve: Curves.easeInOut);
    } else {
      _finishSetup();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(duration: 300.ms, curve: Curves.easeInOut);
    }
  }

  Future<void> _finishSetup() async {
    // Validate all steps, jump to first failing one
    for (int i = 0; i <= 3; i++) {
      final isValid = await _validateStep(i);
      if (!isValid) {
        _pageController.jumpToPage(i);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Step ${i + 1} has errors. Please fix them.'),
            backgroundColor: Colors.red,
          ));
        }
        return;
      }
    }

    setState(() => _isLoading = true);
    try {
      final age = int.tryParse(_ageCtrl.text.trim()) ?? 18;
      final finalJob = _selectedJob == 'Other (Specify)' ? _otherJobCtrl.text.trim() : (_selectedJob ?? '');
      final finalHobby = _selectedHobby == 'Other (Specify)' ? _otherHobbyCtrl.text.trim() : (_selectedHobby ?? '');

      await ref.read(authServiceProvider).signUp(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text, // Don't trim passwords
        username: _usernameCtrl.text.trim(),
        age: age,
        displayName: _displayNameCtrl.text.trim(),
        bio: _bioCtrl.text.trim(),
        education: _educationCtrl.text.trim(),
        hobbies: finalHobby.isNotEmpty ? [finalHobby] : [],
        projects: _projectsCtrl.text.isNotEmpty ? _projectsCtrl.text.split(',').map((e) => e.trim()).toList() : [],
        jobs: finalJob.isNotEmpty ? [finalJob] : [],
      );
      if (mounted) context.go('/feed');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Registration Error: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildTextField(
    String label, 
    TextEditingController controller, {
    bool isPassword = false, 
    TextInputType type = TextInputType.text,
    String? errorText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: type,
        onChanged: (_) {
          if (errorText != null) setState(() => _clearErrors());
        },
        decoration: InputDecoration(
          labelText: label,
          errorText: errorText,
          filled: true,
          fillColor: Theme.of(context).cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? errorText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items
            .map((item) => DropdownMenuItem(
                  value: item,
                  child: Text(item, overflow: TextOverflow.ellipsis),
                ))
            .toList(),
        onChanged: (val) {
          onChanged(val);
          _clearErrors();
        },
        decoration: InputDecoration(
          labelText: label,
          errorText: errorText,
          filled: true,
          fillColor: Theme.of(context).cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final steps = [
      // Step 0: The Basics
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Create Account', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Enter your email, password, and username handle.'),
          const SizedBox(height: 32),
          _buildTextField('Email', _emailCtrl, type: TextInputType.emailAddress, errorText: _emailError),
          _buildTextField('Password', _passwordCtrl, isPassword: true, errorText: _passwordError),
          _buildTextField('Username', _usernameCtrl, errorText: _usernameError),
        ],
      ),
      // Step 1: Who are you?
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Profile Details', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Your public name, age, and bio.'),
          const SizedBox(height: 32),
          _buildTextField('Display Name', _displayNameCtrl, errorText: _displayNameError),
          _buildTextField('Age (for content filtering)', _ageCtrl, type: TextInputType.number, errorText: _ageError),
          _buildTextField('Bio (A short intro)', _bioCtrl, errorText: _bioError),
        ],
      ),
      // Step 2: Background
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Background & Experience', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Your education and current occupation.'),
          const SizedBox(height: 32),
          _buildTextField('Education', _educationCtrl, errorText: _educationError),
          _buildDropdownField(
            label: 'Profession / Job',
            value: _selectedJob,
            items: kAvailableJobs,
            onChanged: (val) => setState(() => _selectedJob = val),
            errorText: _jobError,
          ),
          if (_selectedJob == 'Other (Specify)')
            _buildTextField('Specify Profession', _otherJobCtrl, errorText: _jobError),
        ],
      ),
      // Step 3: Interests
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Interests & Projects', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('What do you love working on or doing?'),
          const SizedBox(height: 32),
          _buildDropdownField(
            label: 'Primary Hobby / Interest',
            value: _selectedHobby,
            items: kAvailableHobbies,
            onChanged: (val) => setState(() => _selectedHobby = val),
            errorText: _hobbyError,
          ),
          if (_selectedHobby == 'Other (Specify)')
            _buildTextField('Specify Hobby', _otherHobbyCtrl, errorText: _hobbyError),
          _buildTextField('Projects (Comma separated)', _projectsCtrl),
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: _currentStep > 0 
          ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: _prevStep) 
          : null,
        title: Text('Setup - Step ${_currentStep + 1} of 4'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (idx) => setState(() => _currentStep = idx),
                itemCount: steps.length,
                itemBuilder: (context, index) {
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: steps[index].animate().fade(duration: 300.ms).slideX(begin: 0.1, end: 0),
                    ),
                  );
                },
              ),
              Positioned(
                bottom: 16,
                right: 0,
                left: 0,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: _isLoading ? null : _nextStep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading 
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white))
                          : Text(
                              _currentStep == steps.length - 1 ? 'Finish Registration' : 'Next',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Already have an account? ', style: TextStyle(fontSize: 13, color: Colors.grey)),
                          GestureDetector(
                            onTap: () => context.go('/login'),
                            child: const Text('Sign In', style: TextStyle(color: AppColors.accent, fontSize: 13, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
