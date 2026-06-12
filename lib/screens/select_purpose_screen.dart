import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/purpose_model.dart';
import '../providers/auth_provider.dart';
import '../providers/scanner_provider.dart';
import '../routes/app_routes.dart';
import '../services/api_service.dart';
import '../utils/app_theme.dart';
import '../widgets/app_logo.dart';
import '../widgets/primary_gradient_button.dart';

class SelectPurposeScreen extends StatefulWidget {
  const SelectPurposeScreen({super.key});

  @override
  State<SelectPurposeScreen> createState() => _SelectPurposeScreenState();
}

class _SelectPurposeScreenState extends State<SelectPurposeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _employeeCodeController = TextEditingController();
  final _campusCodeController = TextEditingController();

  List<PurposeModel> _purposes = [];
  PurposeModel? _selectedPurpose;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    final scannerProvider = context.read<ScannerProvider>();
    _selectedPurpose = scannerProvider.selectedPurpose;
    if (scannerProvider.employeeCodeInput != null) {
      _employeeCodeController.text = scannerProvider.employeeCodeInput!;
    }
    if (scannerProvider.campusCodeInput != null) {
      _campusCodeController.text = scannerProvider.campusCodeInput!;
    }
    _loadPurposes();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_employeeCodeController.text.isEmpty) {
        final employee = context.read<AuthProvider>().employee;
        if (employee != null) {
          _employeeCodeController.text = employee.paycode;
        }
      }
    });
  }

  @override
  void dispose() {
    _employeeCodeController.dispose();
    _campusCodeController.dispose();
    super.dispose();
  }

  Future<void> _loadPurposes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiService = context.read<ApiService>();
      final purposes = await apiService.fetchPurposes();
      if (mounted) {
        setState(() {
          _purposes = purposes;
          _isLoading = false;
          // If we had a selected purpose loaded from storage, ensure we match
          // the instance from the fetched list
          if (_selectedPurpose != null) {
            _selectedPurpose = purposes.firstWhere(
              (p) => p.id == _selectedPurpose!.id,
              orElse: () => _selectedPurpose!,
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _submit() {
    if (_selectedPurpose == null) return;
    if (!_formKey.currentState!.validate()) return;

    context.read<ScannerProvider>().setSelectedPurposeWithInputs(
      _selectedPurpose,
      _employeeCodeController.text.trim(),
      _campusCodeController.text.trim(),
    );
    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final cardWidth = width > 620 ? 520.0 : width - 32;

    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEFF4FF), Color(0xFFF8FAFC)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              if (canPop)
                Positioned(
                  left: 16,
                  top: 16,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    tooltip: 'Back',
                    onPressed: () => Navigator.of(context).pop(),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      elevation: 1,
                      shadowColor: Colors.black.withValues(alpha: 0.1),
                    ),
                  ),
                ),
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 64,
                  ),
                  child: SizedBox(
                    width: cardWidth,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 24,
                          ),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppTheme.accent, Color(0xFFFFA84A)],
                            ),
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(8),
                            ),
                          ),
                          child: const Center(child: AppLogo(compact: true)),
                        ),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(28, 30, 28, 28),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    'Select Purpose',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0,
                                        ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Please select the scanner purpose and confirm the required codes.',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: Colors.black54),
                                  ),
                                  const SizedBox(height: 28),
                                  if (_isLoading)
                                    const Center(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 24.0,
                                        ),
                                        child: Column(
                                          children: [
                                            CircularProgressIndicator(),
                                            SizedBox(height: 16),
                                            Text(
                                              'Loading scanner purposes...',
                                              style: TextStyle(
                                                color: Colors.black54,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  else if (_error != null)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16.0,
                                      ),
                                      child: Column(
                                        children: [
                                          const Icon(
                                            Icons.error_outline_rounded,
                                            color: AppTheme.danger,
                                            size: 48,
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            _error!.replaceFirst(
                                              'Exception: ',
                                              '',
                                            ),
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: AppTheme.danger,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 18),
                                          OutlinedButton.icon(
                                            onPressed: _loadPurposes,
                                            icon: const Icon(
                                              Icons.refresh_rounded,
                                            ),
                                            label: const Text(
                                              'Retry Connection',
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  else ...[
                                    DropdownButtonFormField<PurposeModel>(
                                      key: const ValueKey('purpose_dropdown'),
                                      initialValue: _selectedPurpose,
                                      hint: const Text('Choose a purpose'),
                                      decoration: const InputDecoration(
                                        prefixIcon: Icon(Icons.stars_outlined),
                                      ),
                                      icon: const Icon(
                                        Icons.arrow_drop_down_rounded,
                                        size: 28,
                                      ),
                                      items: _purposes.map((purpose) {
                                        return DropdownMenuItem<PurposeModel>(
                                          value: purpose,
                                          child: Text(purpose.purpose),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedPurpose = value;
                                        });
                                      },
                                    ),
                                    if (_selectedPurpose != null) ...[
                                      const SizedBox(height: 18),
                                      TextFormField(
                                        controller: _employeeCodeController,
                                        decoration: InputDecoration(
                                          labelText: _selectedPurpose!.input1,
                                          prefixIcon: const Icon(
                                            Icons.badge_outlined,
                                          ),
                                        ),
                                        validator: (val) {
                                          if (val == null ||
                                              val.trim().isEmpty) {
                                            return '${_selectedPurpose!.input1} is required';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 18),
                                      TextFormField(
                                        controller: _campusCodeController,
                                        decoration: InputDecoration(
                                          labelText: _selectedPurpose!.input2,
                                          prefixIcon: const Icon(
                                            Icons.location_city_outlined,
                                          ),
                                        ),
                                        validator: (val) {
                                          if (val == null ||
                                              val.trim().isEmpty) {
                                            return '${_selectedPurpose!.input2} is required';
                                          }
                                          return null;
                                        },
                                      ),
                                    ],
                                    const SizedBox(height: 28),
                                    PrimaryGradientButton(
                                      key: const ValueKey('continue_button'),
                                      label: 'CONTINUE',
                                      icon: Icons.arrow_forward_rounded,
                                      onPressed: _selectedPurpose != null
                                          ? _submit
                                          : null,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
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
}
