from django.contrib import admin
from .models import Customer, Domain, HostingService, SSLCertificate, Invoice

@admin.register(Customer)
class CustomerAdmin(admin.ModelAdmin):
    list_display = ['company_name', 'contact_name', 'email', 'phone', 'registration_date']
    list_filter = ['registration_date']
    search_fields = ['company_name', 'contact_name', 'email']

@admin.register(Domain)
class DomainAdmin(admin.ModelAdmin):
    list_display = ['name', 'customer', 'registration_date', 'expiration_date', 'is_active']
    list_filter = ['is_active', 'registration_date']
    search_fields = ['name', 'customer__company_name']

@admin.register(HostingService)
class HostingServiceAdmin(admin.ModelAdmin):
    list_display = ['customer', 'domain', 'package', 'status', 'start_date', 'expiration_date']
    list_filter = ['status', 'package']
    search_fields = ['customer__company_name', 'domain__name']
    date_hierarchy = 'start_date'

@admin.register(SSLCertificate)
class SSLCertificateAdmin(admin.ModelAdmin):
    list_display = ['domain', 'start_date', 'expiration_date', 'is_active']
    list_filter = ['is_active']
    search_fields = ['domain__name']

@admin.register(Invoice)
class InvoiceAdmin(admin.ModelAdmin):
    list_display = ['invoice_number', 'customer', 'amount', 'issue_date', 'due_date', 'payment_status']
    list_filter = ['payment_status', 'payment_method']
    search_fields = ['invoice_number', 'customer__company_name']
