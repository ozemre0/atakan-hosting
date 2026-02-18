import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/auth/auth_providers.dart';
import '../../app/l10n/l10n_ext.dart';
import '../../app/widgets/app_header.dart';
import 'service_type.dart';

class ServiceDetailScreen extends ConsumerStatefulWidget {
  const ServiceDetailScreen({
    super.key,
    required this.type,
    required this.serviceId,
  });

  final ServiceType type;
  final String serviceId;

  @override
  ConsumerState<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends ConsumerState<ServiceDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerIdController = TextEditingController();
  final _domainNameController = TextEditingController();
  final _paidAmountController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _renewalCountController = TextEditingController();
  final _renewalDatesController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  // Hosting specific
  final _ftpUsernameController = TextEditingController();
  final _ftpPasswordController = TextEditingController();
  
  // Domain specific
  final _ns1Controller = TextEditingController();
  final _ns2Controller = TextEditingController();
  
  // SSL specific
  final _urlController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedCustomerId;
  String? _selectedCustomerName;
  bool _isActive = true;
  bool _isLoading = false;
  bool _isInitialLoading = true;
  bool _isLoadingCustomers = false;
  List<Map<String, dynamic>> _customers = [];
  Map<String, dynamic>? _customerData;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
    _loadService();
  }

  @override
  void dispose() {
    _customerIdController.dispose();
    _domainNameController.dispose();
    _paidAmountController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _renewalCountController.dispose();
    _renewalDatesController.dispose();
    _descriptionController.dispose();
    _ftpUsernameController.dispose();
    _ftpPasswordController.dispose();
    _ns1Controller.dispose();
    _ns2Controller.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    setState(() => _isLoadingCustomers = true);
    try {
      final api = ref.read(apiClientProvider);
      final res = await api.getJson('/customers', queryParameters: {'limit': 200});
      final items = (res['items'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      setState(() {
        _customers = items;
      });
    } finally {
      if (mounted) setState(() => _isLoadingCustomers = false);
    }
  }

  Future<void> _loadService() async {
    setState(() => _isInitialLoading = true);
    try {
      final api = ref.read(apiClientProvider);
      final res = await api.getJson('${widget.type.apiCollectionPath}/${widget.serviceId}');
      final item = (res['item'] as Map?)?.cast<String, dynamic>() ?? {};
      _customerData = (res['customer'] as Map?)?.cast<String, dynamic>();

      _selectedCustomerId = (item['customer_id'] ?? '').toString();
      if (_customerData != null) {
        final name = '${_customerData!['first_name'] ?? ''} ${_customerData!['last_name'] ?? ''}'.trim();
        final company = (_customerData!['company'] ?? '').toString();
        _selectedCustomerName = name.isEmpty ? company : '$name ($company)';
        _customerIdController.text = _selectedCustomerName ?? '';
      }

      _domainNameController.text = (item['domain_name'] ?? '').toString();
      _paidAmountController.text = (item['paid_amount'] ?? '').toString();
      _startDateController.text = (item['start_date'] ?? '').toString();
      _endDateController.text = (item['end_date'] ?? '').toString();
      _renewalCountController.text = (item['renewal_count'] ?? '0').toString();
      
      // Parse renewal_dates - handle both JSON array and plain text
      final renewalDatesJson = (item['renewal_dates'] ?? '[]').toString();
      try {
        final decoded = jsonDecode(renewalDatesJson);
        if (decoded is List) {
          _renewalDatesController.text = decoded.map((e) => e.toString()).join('\n');
        } else {
          _renewalDatesController.text = renewalDatesJson.replaceAll(RegExp(r'[\[\]"]'), '').replaceAll(',', '\n').trim();
        }
      } catch (_) {
        _renewalDatesController.text = renewalDatesJson.replaceAll(RegExp(r'[\[\]"]'), '').replaceAll(',', '\n').trim();
      }
      
      _descriptionController.text = (item['description'] ?? '').toString();
      _isActive = (item['status'] ?? 1) == 1;

      if (widget.type == ServiceType.hostings) {
        _ftpUsernameController.text = (item['ftp_username'] ?? '').toString();
        _ftpPasswordController.text = (item['ftp_password'] ?? '').toString();
      } else if (widget.type == ServiceType.domains) {
        _ns1Controller.text = (item['ns1'] ?? '').toString();
        _ns2Controller.text = (item['ns2'] ?? '').toString();
      } else if (widget.type == ServiceType.ssls) {
        _urlController.text = (item['url'] ?? '').toString();
      }

      final startDateStr = (item['start_date'] ?? '').toString();
      if (startDateStr.isNotEmpty) {
        try {
          _startDate = DateTime.parse(startDateStr);
        } catch (_) {}
      }
      final endDateStr = (item['end_date'] ?? '').toString();
      if (endDateStr.isNotEmpty) {
        try {
          _endDate = DateTime.parse(endDateStr);
        } catch (_) {}
      }
    } finally {
      if (mounted) setState(() => _isInitialLoading = false);
    }
  }

  Future<void> _selectCustomer(BuildContext context) async {
    if (_isLoadingCustomers) return;
    
    final selected = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.selectCustomer),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _customers.length,
            itemBuilder: (context, index) {
              final c = _customers[index];
              final name = '${c['first_name'] ?? ''} ${c['last_name'] ?? ''}'.trim();
              final company = (c['company'] ?? '').toString();
              return ListTile(
                title: Text(name.isEmpty ? company : name),
                subtitle: Text(company),
                onTap: () => Navigator.of(context).pop(c),
              );
            },
          ),
        ),
      ),
    );

    if (selected != null) {
      setState(() {
        _selectedCustomerId = (selected['id'] ?? '').toString();
        final name = '${selected['first_name'] ?? ''} ${selected['last_name'] ?? ''}'.trim();
        final company = (selected['company'] ?? '').toString();
        _selectedCustomerName = name.isEmpty ? company : '$name ($company)';
        _customerIdController.text = _selectedCustomerName ?? '';
      });
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        _startDateController.text = DateFormat('yyyy-MM-dd').format(picked);
        if (_endDate == null) {
          final endDate = DateTime(picked.year + 1, picked.month, picked.day);
          _endDate = endDate;
          _endDateController.text = DateFormat('yyyy-MM-dd').format(endDate);
        }
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
        _endDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCustomerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.customerRequired)),
      );
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _isLoading = true);

    try {
      final api = ref.read(apiClientProvider);
      final data = <String, dynamic>{
        'customer_id': _selectedCustomerId,
        'domain_name': _domainNameController.text.trim(),
        'start_date': _startDateController.text.trim(),
        'end_date': _endDateController.text.trim(),
        'status': _isActive ? 1 : 0,
      };

      final paidAmount = double.tryParse(_paidAmountController.text.trim());
      if (paidAmount != null) {
        data['paid_amount'] = paidAmount;
      }
      if (_renewalCountController.text.trim().isNotEmpty) {
        data['renewal_count'] = int.tryParse(_renewalCountController.text.trim()) ?? 0;
      }
      if (_renewalDatesController.text.trim().isNotEmpty) {
        data['renewal_dates'] = _renewalDatesController.text.trim();
      }
      if (_descriptionController.text.trim().isNotEmpty) {
        data['description'] = _descriptionController.text.trim();
      }

      if (widget.type == ServiceType.hostings) {
        if (_ftpUsernameController.text.trim().isNotEmpty) {
          data['ftp_username'] = _ftpUsernameController.text.trim();
        }
        if (_ftpPasswordController.text.trim().isNotEmpty) {
          data['ftp_password'] = _ftpPasswordController.text.trim();
        }
      } else if (widget.type == ServiceType.domains) {
        if (_ns1Controller.text.trim().isNotEmpty) {
          data['ns1'] = _ns1Controller.text.trim();
        }
        if (_ns2Controller.text.trim().isNotEmpty) {
          data['ns2'] = _ns2Controller.text.trim();
        }
      } else if (widget.type == ServiceType.ssls) {
        if (_urlController.text.trim().isNotEmpty) {
          data['url'] = _urlController.text.trim();
        }
      }

      final response = await api.patchJson('${widget.type.apiCollectionPath}/${widget.serviceId}', data: data);

      final okValue = response['ok'];
      if (okValue == true || okValue == 'true' || okValue == 1) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.serviceUpdated),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        await _loadService();
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
                content: Text(context.l10n.serviceUpdated),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
            await _loadService();
            return;
          }
        }
      }
      
      String errorMsg = context.l10n.error;
      if (e is DioException && e.response != null) {
        final data = e.response?.data;
        if (data is Map) {
          final error = data['error']?.toString();
          if (error == 'CUSTOMER_REQUIRED') {
            errorMsg = context.l10n.customerRequired;
          } else if (error == 'DOMAIN_REQUIRED') {
            errorMsg = 'Domain adı zorunludur';
          } else if (error == 'INVALID_START_DATE' || error == 'INVALID_END_DATE') {
            errorMsg = 'Geçersiz tarih formatı (YYYY-MM-DD olmalı)';
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
    if (_isInitialLoading) {
      return Scaffold(
        appBar: AppHeader(title: Text(widget.type.title(context))),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppHeader(
        title: Text(widget.type.title(context)),
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
                // Müşteri Seçimi
                TextFormField(
                  controller: _customerIdController,
                  decoration: InputDecoration(
                    labelText: context.l10n.selectCustomer,
                    suffixIcon: const Icon(Icons.arrow_drop_down),
                  ),
                  readOnly: true,
                  onTap: () => _selectCustomer(context),
                  validator: (v) {
                    if (_selectedCustomerId == null) return context.l10n.customerRequired;
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Domain Adı
                TextFormField(
                  controller: _domainNameController,
                  decoration: InputDecoration(labelText: context.l10n.domainName),
                  validator: (v) {
                    if ((v ?? '').trim().isEmpty) return context.l10n.fieldRequired;
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Ödenen Miktar
                TextFormField(
                  controller: _paidAmountController,
                  decoration: InputDecoration(labelText: context.l10n.paidAmount),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                ),
                const SizedBox(height: 16),

                // Başlangıç Tarihi
                TextFormField(
                  controller: _startDateController,
                  decoration: InputDecoration(
                    labelText: context.l10n.startDate,
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () => _selectStartDate(context),
                  validator: (v) {
                    if ((v ?? '').trim().isEmpty) return context.l10n.fieldRequired;
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Bitiş Tarihi
                TextFormField(
                  controller: _endDateController,
                  decoration: InputDecoration(
                    labelText: context.l10n.endDate,
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () => _selectEndDate(context),
                  validator: (v) {
                    if ((v ?? '').trim().isEmpty) return context.l10n.fieldRequired;
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Durum
                SwitchListTile(
                  title: Text(context.l10n.status),
                  value: _isActive,
                  onChanged: (v) => setState(() => _isActive = v),
                  secondary: Icon(_isActive ? Icons.check_circle : Icons.cancel),
                ),
                const SizedBox(height: 16),

                // Hosting specific fields
                if (widget.type == ServiceType.hostings) ...[
                  TextFormField(
                    controller: _ftpUsernameController,
                    decoration: InputDecoration(labelText: context.l10n.ftpUsername),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _ftpPasswordController,
                    decoration: InputDecoration(labelText: context.l10n.ftpPassword),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                ],

                // Domain specific fields
                if (widget.type == ServiceType.domains) ...[
                  TextFormField(
                    controller: _ns1Controller,
                    decoration: InputDecoration(labelText: context.l10n.ns1),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _ns2Controller,
                    decoration: InputDecoration(labelText: context.l10n.ns2),
                  ),
                  const SizedBox(height: 16),
                ],

                // SSL specific fields
                if (widget.type == ServiceType.ssls) ...[
                  TextFormField(
                    controller: _urlController,
                    decoration: InputDecoration(labelText: context.l10n.urlLabel),
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 16),
                ],

                // Yenileme Sayısı
                TextFormField(
                  controller: _renewalCountController,
                  decoration: InputDecoration(labelText: context.l10n.renewalCount),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 16),

                // Yenileme Tarihleri
                TextFormField(
                  controller: _renewalDatesController,
                  decoration: InputDecoration(
                    labelText: context.l10n.renewalDates,
                    helperText: 'Her satıra bir tarih (YYYY-MM-DD formatında)',
                  ),
                  maxLines: 5,
                  minLines: 3,
                ),
                const SizedBox(height: 16),

                // Açıklama
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: context.l10n.description),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
