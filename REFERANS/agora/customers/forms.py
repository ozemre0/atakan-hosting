from django import forms
from .models import Customer, Domain, HostingService, SSLCertificate, Invoice
from django.utils import timezone

class CustomerForm(forms.ModelForm):
    class Meta:
        model = Customer
        fields = ['company_name', 'contact_name', 'email', 'email2', 'email3', 'phone', 'address', 'tax_office', 'tax_number', 'registration_date', 'notes']
        widgets = {
            'registration_date': forms.DateInput(attrs={'type': 'date'}),
        }

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        if not self.instance.pk:  # Yeni kayıt ise
            self.fields['registration_date'].initial = timezone.now().date()

class DomainForm(forms.ModelForm):
    class Meta:
        model = Domain
        fields = ['customer', 'name', 'registration_date', 'expiration_date', 'is_active', 'nameserver1', 'nameserver2', 'nameserver3', 'nameserver4']
        widgets = {
            'registration_date': forms.DateInput(attrs={'type': 'date'}),
            'expiration_date': forms.DateInput(attrs={'type': 'date'}),
        }

class HostingServiceForm(forms.ModelForm):
    domain_name = forms.CharField(max_length=200, required=False, label='Domain Adı (Manuel)')

    class Meta:
        model = HostingService
        fields = ['customer', 'domain', 'domain_name', 'package', 'status', 'start_date', 'expiration_date', 'notes']
        widgets = {
            'start_date': forms.DateInput(attrs={'type': 'date'}),
            'expiration_date': forms.DateInput(attrs={'type': 'date'}),
            'notes': forms.Textarea(attrs={'rows': 3}),
        }

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.fields['domain'].required = False

    def clean(self):
        cleaned_data = super().clean()
        domain = cleaned_data.get('domain')
        domain_name = cleaned_data.get('domain_name')
        customer = cleaned_data.get('customer')

        if not domain and not domain_name:
            raise forms.ValidationError('Domain seçin veya manuel olarak domain adı girin.')

        if domain_name:
            # Manuel girilen domain adı için yeni Domain oluştur
            domain = Domain.objects.create(
                customer=customer,
                name=domain_name,
                registration_date=cleaned_data.get('start_date'),
                expiration_date=cleaned_data.get('expiration_date'),
                is_active=True,
                nameserver1='ns1.example.com',
                nameserver2='ns2.example.com'
            )
            cleaned_data['domain'] = domain

        return cleaned_data

class SSLCertificateForm(forms.ModelForm):
    domain_name = forms.CharField(max_length=200, required=False, label='Domain Adı (Manuel)')

    class Meta:
        model = SSLCertificate
        fields = ['customer', 'domain', 'domain_name', 'start_date', 'expiration_date', 'is_active']
        widgets = {
            'start_date': forms.DateInput(attrs={'type': 'date'}),
            'expiration_date': forms.DateInput(attrs={'type': 'date'}),
        }

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.fields['domain'].required = False

    def clean(self):
        cleaned_data = super().clean()
        domain = cleaned_data.get('domain')
        domain_name = cleaned_data.get('domain_name')
        customer = cleaned_data.get('customer')

        if not domain and not domain_name:
            raise forms.ValidationError('Domain seçin veya manuel olarak domain adı girin.')

        if domain_name:
            # Manuel girilen domain adı için yeni Domain oluştur
            domain = Domain.objects.create(
                customer=customer,
                name=domain_name,
                registration_date=cleaned_data.get('start_date'),
                expiration_date=cleaned_data.get('expiration_date'),
                is_active=True,
                nameserver1='ns1.example.com',
                nameserver2='ns2.example.com'
            )
            cleaned_data['domain'] = domain

        return cleaned_data

class InvoiceForm(forms.ModelForm):
    class Meta:
        model = Invoice
        fields = ['customer', 'invoice_number', 'amount', 'issue_date', 'due_date', 
                 'payment_status', 'payment_method', 'payment_date', 'notes']
        widgets = {
            'customer': forms.Select(attrs={'class': 'form-select'}),
            'invoice_number': forms.TextInput(attrs={'class': 'form-control'}),
            'amount': forms.NumberInput(attrs={'class': 'form-control'}),
            'issue_date': forms.DateInput(attrs={'class': 'form-control', 'type': 'date'}),
            'due_date': forms.DateInput(attrs={'class': 'form-control', 'type': 'date'}),
            'payment_status': forms.Select(attrs={'class': 'form-select'}),
            'payment_method': forms.Select(attrs={'class': 'form-select'}),
            'payment_date': forms.DateInput(attrs={'class': 'form-control', 'type': 'date'}),
            'notes': forms.Textarea(attrs={'class': 'form-control', 'rows': 3}),
        } 