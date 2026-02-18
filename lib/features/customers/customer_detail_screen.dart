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

class CustomerDetailScreen extends ConsumerStatefulWidget {
  const CustomerDetailScreen({
    super.key,
    required this.customerId,
  });

  final String customerId;

  @override
  ConsumerState<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends ConsumerState<CustomerDetailScreen> {
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
  bool _isInitialLoading = true;
  bool _obscurePassword = true;
  Map<String, dynamic>? _servicesData;
  List<Map<String, dynamic>> _domains = [];
  List<Map<String, dynamic>> _hostings = [];
  List<Map<String, dynamic>> _ssls = [];

  @override
  void initState() {
    super.initState();
    _loadCustomer();
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

  Future<void> _loadCustomer() async {
    setState(() => _isInitialLoading = true);
    try {
      final api = ref.read(apiClientProvider);
      final res = await api.getJson('/customers/${widget.customerId}');
      final item = (res['item'] as Map?)?.cast<String, dynamic>() ?? {};
      _servicesData = res['services'] as Map<String, dynamic>?;
      
      // Load services lists
      _domains = ((_servicesData?['domains'] as List?) ?? []).cast<Map<String, dynamic>>();
      _hostings = ((_servicesData?['hostings'] as List?) ?? []).cast<Map<String, dynamic>>();
      _ssls = ((_servicesData?['ssls'] as List?) ?? []).cast<Map<String, dynamic>>();

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
      if (mounted) setState(() => _isInitialLoading = false);
    }
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

      final response = await api.patchJson('/customers/${widget.customerId}', data: data);

      final okValue = response['ok'];
      if (okValue == true || okValue == 'true' || okValue == 1) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.customerUpdated),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        // Reload data
        await _loadCustomer();
      } else {
        if (!mounted) return;
        String errorMsg = response['error']?.toString() ?? context.l10n.error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      if (e is DioException && e.response != null) {
        final data = e.response?.data;
        if (data is Map) {
          final okValue = data['ok'];
          if (okValue == true || okValue == 'true' || okValue == 1) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.l10n.customerUpdated),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
            await _loadCustomer();
            return;
          }
        }
      }
      
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

  void _showServicesDrawer(BuildContext context, String type, List<Map<String, dynamic>> services) {
    if (services.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Henüz $type hizmeti bulunmuyor')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Text(
                    type == 'domains' ? context.l10n.domainsTitle : 
                    type == 'hostings' ? context.l10n.hostingsTitle : 
                    context.l10n.sslsTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  for (final service in services)
                    Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text((service['domain_name'] ?? '').toString()),
                        subtitle: Text('${context.l10n.endDate}: ${service['end_date'] ?? ''}'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.of(context).pop();
                          final serviceId = (service['id'] ?? '').toString();
                          if (type == 'domains') {
                            context.push('/domains/$serviceId');
                          } else if (type == 'hostings') {
                            context.push('/hostings/$serviceId');
                          } else if (type == 'ssls') {
                            context.push('/ssls/$serviceId');
                          }
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoading) {
      return Scaffold(
        appBar: AppHeader(title: Text(context.l10n.customersTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppHeader(
        title: Text(context.l10n.customersTitle),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _submit,
              tooltip: context.l10n.save,
            ),
        ],
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
                  decoration: InputDecoration(labelText: context.l10n.customerNo),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 16),

                // Şifre
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: context.l10n.customerPassword,
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

                // E-posta 1
                TextFormField(
                  controller: _email1Controller,
                  decoration: InputDecoration(labelText: context.l10n.email1),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if ((v ?? '').trim().isEmpty) return context.l10n.fieldRequired;
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // E-posta 2
                TextFormField(
                  controller: _email2Controller,
                  decoration: InputDecoration(labelText: context.l10n.email2),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // E-posta 3
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
                  maxLines: 3,
                ),
                const SizedBox(height: 24),

                // Hizmetler
                Text(context.l10n.servicesTitle, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                _ServiceSection(
                  title: context.l10n.domainsTitle,
                  count: _domains.length,
                  onTap: () => _showServicesDrawer(context, 'domains', _domains),
                ),
                _ServiceSection(
                  title: context.l10n.hostingsTitle,
                  count: _hostings.length,
                  onTap: () => _showServicesDrawer(context, 'hostings', _hostings),
                ),
                _ServiceSection(
                  title: context.l10n.sslsTitle,
                  count: _ssls.length,
                  onTap: () => _showServicesDrawer(context, 'ssls', _ssls),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ServiceSection extends StatelessWidget {
  const _ServiceSection({
    required this.title,
    required this.count,
    required this.onTap,
  });

  final String title;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(count.toString()),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
