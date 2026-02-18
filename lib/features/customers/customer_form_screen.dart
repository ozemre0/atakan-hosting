import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/auth/auth_providers.dart';
import '../../app/l10n/l10n_ext.dart';
import '../../app/widgets/app_header.dart';

class CustomerFormScreen extends ConsumerStatefulWidget {
  const CustomerFormScreen({
    super.key,
    this.customerId,
  });

  final String? customerId; // null = new, non-null = edit

  @override
  ConsumerState<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends ConsumerState<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerNoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _companyController = TextEditingController();
  final _registrationDateController = TextEditingController();
  final _email1Controller = TextEditingController();
  final _email2Controller = TextEditingController();
  final _email3Controller = TextEditingController();
  final _phone1Controller = TextEditingController();
  final _phone2Controller = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _taxOfficeController = TextEditingController();
  final _taxNoController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _registrationDate;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    if (widget.customerId != null) {
      _loadCustomer();
    }
  }

  @override
  void dispose() {
    _customerNoController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _companyController.dispose();
    _registrationDateController.dispose();
    _email1Controller.dispose();
    _email2Controller.dispose();
    _email3Controller.dispose();
    _phone1Controller.dispose();
    _phone2Controller.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _taxOfficeController.dispose();
    _taxNoController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _registrationDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _registrationDate = picked;
        _registrationDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _generatePassword() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz0123456789';
    final random = List.generate(12, (i) {
      final index = (DateTime.now().millisecondsSinceEpoch + i).abs() % chars.length;
      return chars[index];
    });
    setState(() {
      _passwordController.text = random.join();
    });
  }

  Future<void> _loadCustomer() async {
    if (widget.customerId == null) return;
    setState(() => _isLoading = true);
    try {
      final api = ref.read(apiClientProvider);
      final res = await api.getJson('/customers/${widget.customerId}');
      final item = (res['item'] as Map?)?.cast<String, dynamic>() ?? {};

      _customerNoController.text = (item['customer_no'] ?? '').toString();
      _passwordController.text = (item['password'] ?? '').toString();
      _firstNameController.text = (item['first_name'] ?? '').toString();
      _lastNameController.text = (item['last_name'] ?? '').toString();
      _companyController.text = (item['company'] ?? '').toString();
      _registrationDateController.text = (item['registration_date'] ?? '').toString();
      _email1Controller.text = (item['email1'] ?? '').toString();
      _email2Controller.text = (item['email2'] ?? '').toString();
      _email3Controller.text = (item['email3'] ?? '').toString();
      _phone1Controller.text = (item['phone1'] ?? '').toString();
      _phone2Controller.text = (item['phone2'] ?? '').toString();
      _addressController.text = (item['address'] ?? '').toString();
      _cityController.text = (item['city'] ?? '').toString();
      _countryController.text = (item['country'] ?? 'Türkiye').toString();
      _taxOfficeController.text = (item['tax_office'] ?? '').toString();
      _taxNoController.text = (item['tax_no'] ?? '').toString();
      _descriptionController.text = (item['description'] ?? '').toString();

      final regDateStr = (item['registration_date'] ?? '').toString();
      if (regDateStr.isNotEmpty) {
        try {
          _registrationDate = DateTime.parse(regDateStr);
        } catch (_) {}
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _isLoading = true);

    try {
      final api = ref.read(apiClientProvider);
      final data = <String, dynamic>{
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'company': _companyController.text.trim(),
        'registration_date': _registrationDateController.text.trim(),
        'email1': _email1Controller.text.trim(),
        'phone1': _phone1Controller.text.trim(),
        'password': _passwordController.text.trim(),
      };

      if (_customerNoController.text.trim().isNotEmpty) {
        data['customer_no'] = int.tryParse(_customerNoController.text.trim());
      }
      if (_email2Controller.text.trim().isNotEmpty) {
        data['email2'] = _email2Controller.text.trim();
      }
      if (_email3Controller.text.trim().isNotEmpty) {
        data['email3'] = _email3Controller.text.trim();
      }
      if (_phone2Controller.text.trim().isNotEmpty) {
        data['phone2'] = _phone2Controller.text.trim();
      }
      if (_addressController.text.trim().isNotEmpty) {
        data['address'] = _addressController.text.trim();
      }
      if (_cityController.text.trim().isNotEmpty) {
        data['city'] = _cityController.text.trim();
      }
      if (_countryController.text.trim().isNotEmpty) {
        data['country'] = _countryController.text.trim();
      }
      if (_taxOfficeController.text.trim().isNotEmpty) {
        data['tax_office'] = _taxOfficeController.text.trim();
      }
      if (_taxNoController.text.trim().isNotEmpty) {
        data['tax_no'] = int.tryParse(_taxNoController.text.trim());
      }
      if (_descriptionController.text.trim().isNotEmpty) {
        data['description'] = _descriptionController.text.trim();
      }

      Map<String, dynamic>? response;
      if (widget.customerId != null) {
        response = await api.patchJson('/customers/${widget.customerId}', data: data);
      } else {
        response = await api.postJson('/customers', data: data);
      }

      // Check if response indicates success (handle both boolean and string 'true')
      final okValue = response['ok'];
      if (okValue == true || okValue == 'true' || okValue == 1) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.customerId == null ? context.l10n.customerAdded : context.l10n.customerUpdated),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        // Navigate to customers list
        if (mounted) {
          context.go('/customers');
        }
        return;
      }

      // If we get here, response indicates failure
      if (!mounted) return;
      String errorMsg = response['error']?.toString() ?? context.l10n.error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg)),
      );
    } catch (e) {
      if (!mounted) return;
      
      // Check if this is actually a success response that was caught as an exception
      if (e is DioException && e.response != null) {
        final data = e.response?.data;
        if (data is Map) {
          final okValue = data['ok'];
          if (okValue == true || okValue == 'true' || okValue == 1) {
            // Success response, show success snackbar and navigate
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(widget.customerId == null ? context.l10n.customerAdded : context.l10n.customerUpdated),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
            // Navigate to customers list
            if (mounted) {
              context.go('/customers');
            }
            return;
          }
        }
      }
      
      // Real error, show error snackbar
      String errorMsg = context.l10n.error;
      if (e is DioException && e.response != null) {
        final data = e.response?.data;
        if (data is Map) {
          final error = data['error']?.toString();
          if (error == 'MISSING_NAME_FIELDS') {
            errorMsg = 'Ad, Soyad ve Firma alanları zorunludur';
          } else if (error == 'INVALID_REGISTRATION_DATE') {
            final received = data['received']?.toString();
            errorMsg = 'Geçersiz kayıt tarihi formatı (YYYY-MM-DD olmalı)${received != null ? ': "$received"' : ''}';
          } else if (error == 'MISSING_CONTACT') {
            errorMsg = 'E-posta 1 ve Telefon 1 alanları zorunludur';
          } else if (error == 'INVALID_JSON') {
            errorMsg = 'Geçersiz veri formatı';
          } else {
            errorMsg = error ?? context.l10n.error;
          }
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg)),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.customerId != null;

    return Scaffold(
      appBar: AppHeader(
        title: Text(isEdit ? context.l10n.editCustomer : context.l10n.newCustomer),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Müşteri No
                TextFormField(
                  controller: _customerNoController,
                  decoration: InputDecoration(
                    labelText: context.l10n.customerNo,
                    helperText: isEdit ? null : 'Boş bırakılırsa otomatik üretilir',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 16),

                // Şifre
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: context.l10n.customerPassword,
                          helperText: context.l10n.customerPasswordHint,
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        obscureText: _obscurePassword,
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: _generatePassword,
                      icon: const Icon(Icons.refresh),
                      label: Text(context.l10n.generatePassword),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Ad
                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(labelText: context.l10n.firstName),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) {
                    if ((v ?? '').trim().isEmpty) return context.l10n.fieldRequired;
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Soyad
                TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(labelText: context.l10n.lastName),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) {
                    if ((v ?? '').trim().isEmpty) return context.l10n.fieldRequired;
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Firma
                TextFormField(
                  controller: _companyController,
                  decoration: InputDecoration(labelText: context.l10n.company),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) {
                    if ((v ?? '').trim().isEmpty) return context.l10n.fieldRequired;
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Kayıt Tarihi
                TextFormField(
                  controller: _registrationDateController,
                  decoration: InputDecoration(
                    labelText: context.l10n.registrationDate,
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  validator: (v) {
                    if ((v ?? '').trim().isEmpty) return context.l10n.fieldRequired;
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email 1
                TextFormField(
                  controller: _email1Controller,
                  decoration: InputDecoration(labelText: context.l10n.email1),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    final value = (v ?? '').trim();
                    if (value.isEmpty) return context.l10n.fieldRequired;
                    if (!value.contains('@') || !value.contains('.')) return context.l10n.invalidEmail;
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email 2
                TextFormField(
                  controller: _email2Controller,
                  decoration: InputDecoration(labelText: context.l10n.email2),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // Email 3
                TextFormField(
                  controller: _email3Controller,
                  decoration: InputDecoration(labelText: context.l10n.email3),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // Telefon 1
                TextFormField(
                  controller: _phone1Controller,
                  decoration: InputDecoration(labelText: context.l10n.phone1),
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    if ((v ?? '').trim().isEmpty) return context.l10n.fieldRequired;
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Telefon 2
                TextFormField(
                  controller: _phone2Controller,
                  decoration: InputDecoration(labelText: context.l10n.phone2),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                // Adres
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(labelText: context.l10n.address),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                // Şehir
                TextFormField(
                  controller: _cityController,
                  decoration: InputDecoration(labelText: context.l10n.city),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),

                // Ülke
                TextFormField(
                  controller: _countryController,
                  decoration: InputDecoration(
                    labelText: context.l10n.country,
                    helperText: 'Varsayılan: Türkiye',
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),

                // Vergi Dairesi
                TextFormField(
                  controller: _taxOfficeController,
                  decoration: InputDecoration(labelText: context.l10n.taxOffice),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),

                // Vergi No
                TextFormField(
                  controller: _taxNoController,
                  decoration: InputDecoration(labelText: context.l10n.taxNo),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 16),

                // Açıklama
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: context.l10n.description),
                  maxLines: 4,
                ),
                const SizedBox(height: 24),

                // Butonlar
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isLoading ? null : () => context.pop(),
                      child: Text(context.l10n.cancel),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _isLoading ? null : _submit,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(isEdit ? context.l10n.update : context.l10n.add),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

