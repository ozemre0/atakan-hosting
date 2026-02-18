import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/auth/auth_providers.dart';
import '../../app/l10n/l10n_ext.dart';
import '../../app/widgets/app_header.dart';

class SslFormScreen extends ConsumerStatefulWidget {
  const SslFormScreen({
    super.key,
    this.sslId,
  });

  final String? sslId; // null = new, non-null = edit

  @override
  ConsumerState<SslFormScreen> createState() => _SslFormScreenState();
}

class _SslFormScreenState extends ConsumerState<SslFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerIdController = TextEditingController();
  final _domainNameController = TextEditingController();
  final _urlController = TextEditingController();
  final _paidAmountController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _renewalCountController = TextEditingController();
  final _renewalDatesController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedCustomerId;
  String? _selectedCustomerName;
  bool _isActive = true;
  bool _isLoading = false;
  bool _isLoadingCustomers = false;
  List<Map<String, dynamic>> _customers = [];

  @override
  void initState() {
    super.initState();
    _loadCustomers();
    if (widget.sslId != null) {
      _loadSsl();
    }
  }

  @override
  void dispose() {
    _customerIdController.dispose();
    _domainNameController.dispose();
    _urlController.dispose();
    _paidAmountController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _renewalCountController.dispose();
    _renewalDatesController.dispose();
    _descriptionController.dispose();
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
        // Auto-set end date to 1 year later
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
      initialDate: _endDate ?? (_startDate?.add(const Duration(days: 365)) ?? DateTime.now()),
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

  Future<void> _selectCustomer(BuildContext context) async {
    final selected = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(context.l10n.selectCustomer, style: Theme.of(context).textTheme.titleLarge),
              ),
              const Divider(height: 1),
              Expanded(
                child: _isLoadingCustomers
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: _customers.length,
                        itemBuilder: (context, i) {
                          final c = _customers[i];
                          final name = '${c['first_name'] ?? ''} ${c['last_name'] ?? ''}'.trim();
                          final company = (c['company'] ?? '').toString();
                          final displayName = name.isEmpty ? company : '$name ($company)';
                          return ListTile(
                            title: Text(displayName),
                            subtitle: Text('${context.l10n.customerNo}: ${c['customer_no'] ?? ''}'),
                            onTap: () => Navigator.pop(context, c),
                          );
                        },
                      ),
              ),
            ],
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
        _customerIdController.text = _selectedCustomerName!;
      });
    }
  }

  Future<void> _loadSsl() async {
    if (widget.sslId == null) return;
    setState(() => _isLoading = true);
    try {
      final api = ref.read(apiClientProvider);
      final res = await api.getJson('/ssls/${widget.sslId}');
      final item = (res['item'] as Map?)?.cast<String, dynamic>() ?? {};
      final customer = (res['customer'] as Map?)?.cast<String, dynamic>() ?? {};

      _selectedCustomerId = (item['customer_id'] ?? '').toString();
      final name = '${customer['first_name'] ?? ''} ${customer['last_name'] ?? ''}'.trim();
      final company = (customer['company'] ?? '').toString();
      _selectedCustomerName = name.isEmpty ? company : '$name ($company)';
      _customerIdController.text = _selectedCustomerName ?? '';

      _domainNameController.text = (item['domain_name'] ?? '').toString();
      _urlController.text = (item['url'] ?? '').toString();
      _paidAmountController.text = (item['paid_amount'] ?? '').toString();
      _startDateController.text = (item['start_date'] ?? '').toString();
      _endDateController.text = (item['end_date'] ?? '').toString();
      _renewalCountController.text = (item['renewal_count'] ?? '0').toString();
      // Parse renewal_dates - handle both JSON array and plain text
      final renewalDatesJson = (item['renewal_dates'] ?? '[]').toString();
      try {
        // Try to parse as JSON array first
        final decoded = jsonDecode(renewalDatesJson);
        if (decoded is List) {
          _renewalDatesController.text = decoded.map((e) => e.toString()).join('\n');
        } else {
          // If not a list, treat as plain text
          _renewalDatesController.text = renewalDatesJson.replaceAll(RegExp(r'[\[\]"]'), '').replaceAll(',', '\n').trim();
        }
      } catch (_) {
        // If JSON parse fails, treat as plain text and clean up
        _renewalDatesController.text = renewalDatesJson.replaceAll(RegExp(r'[\[\]"]'), '').replaceAll(',', '\n').trim();
      }
      _descriptionController.text = (item['description'] ?? '').toString();
      _isActive = (item['status'] ?? 1) == 1;

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
      if (mounted) setState(() => _isLoading = false);
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
      if (_urlController.text.trim().isNotEmpty) {
        data['url'] = _urlController.text.trim();
      }
      if (_renewalCountController.text.trim().isNotEmpty) {
        data['renewal_count'] = int.tryParse(_renewalCountController.text.trim()) ?? 0;
      }
      // Save renewal dates as plain text (one per line)
      if (_renewalDatesController.text.trim().isNotEmpty) {
        // Store as plain text, one date per line
        data['renewal_dates'] = _renewalDatesController.text.trim();
      }
      if (_descriptionController.text.trim().isNotEmpty) {
        data['description'] = _descriptionController.text.trim();
      }

      Map<String, dynamic>? response;
      if (widget.sslId != null) {
        response = await api.patchJson('/ssls/${widget.sslId}', data: data);
      } else {
        response = await api.postJson('/ssls', data: data);
      }

      // Check if response indicates success (handle both boolean and string 'true')
      final okValue = response['ok'];
      if (okValue == true || okValue == 'true' || okValue == 1) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.sslId == null ? context.l10n.serviceAdded : context.l10n.serviceUpdated),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        // Navigate to ssls list
        if (mounted) {
          context.go('/ssls');
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
                content: Text(widget.sslId == null ? context.l10n.serviceAdded : context.l10n.serviceUpdated),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
            // Navigate to ssls list
            if (mounted) {
              context.go('/ssls');
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
    final isEdit = widget.sslId != null;

    return Scaffold(
      appBar: AppHeader(
        title: Text(isEdit ? context.l10n.editSsl : context.l10n.newSsl),
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

                // URL
                TextFormField(
                  controller: _urlController,
                  decoration: InputDecoration(labelText: context.l10n.urlLabel),
                  keyboardType: TextInputType.url,
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
                    helperText: context.l10n.autoGenerate,
                  ),
                  readOnly: true,
                  onTap: () => _selectEndDate(context),
                  validator: (v) {
                    if ((v ?? '').trim().isEmpty) return context.l10n.fieldRequired;
                    return null;
                  },
                ),
                const SizedBox(height: 16),

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
                  maxLines: 4,
                ),
                const SizedBox(height: 16),

                // Durum
                SwitchListTile(
                  value: _isActive,
                  onChanged: (v) => setState(() => _isActive = v),
                  title: Text(context.l10n.status),
                  subtitle: Text(_isActive ? context.l10n.statusActive : context.l10n.statusPassive),
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

