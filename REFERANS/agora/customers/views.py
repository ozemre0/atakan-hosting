from django.shortcuts import render, get_object_or_404, redirect
from django.contrib.auth.decorators import login_required
from django.contrib import messages
from django.db.models import Sum, Count, Q
from django.utils import timezone
from datetime import timedelta
from .models import Customer, HostingService, Domain, SSLCertificate, Invoice
from .forms import CustomerForm, HostingServiceForm, DomainForm, SSLCertificateForm, InvoiceForm
from django.views.generic import CreateView
from django.urls import reverse_lazy

# Müşteri Views
@login_required
def customer_list(request):
    customers = Customer.objects.all().order_by('company_name')
    return render(request, 'customers/customer_list.html', {'customers': customers})

@login_required
def customer_add(request):
    if request.method == 'POST':
        form = CustomerForm(request.POST)
        if form.is_valid():
            form.save()
            messages.success(request, 'Müşteri başarıyla eklendi.')
            return redirect('customers:customer-list')
    else:
        form = CustomerForm()
    return render(request, 'customers/customer_form.html', {'form': form, 'title': 'Yeni Müşteri Ekle'})

@login_required
def customer_edit(request, pk):
    customer = get_object_or_404(Customer, pk=pk)
    if request.method == 'POST':
        form = CustomerForm(request.POST, instance=customer)
        if form.is_valid():
            form.save()
            messages.success(request, 'Müşteri başarıyla güncellendi.')
            return redirect('customers:customer-detail', pk=pk)
    else:
        form = CustomerForm(instance=customer)
    return render(request, 'customers/customer_form.html', {'form': form, 'title': 'Müşteri Düzenle'})

@login_required
def customer_delete(request, pk):
    customer = get_object_or_404(Customer, pk=pk)
    if request.method == 'POST':
        customer.delete()
        messages.success(request, 'Müşteri başarıyla silindi.')
        return redirect('customers:customer-list')
    return render(request, 'customers/customer_confirm_delete.html', {'customer': customer})

@login_required
def customer_detail(request, pk):
    customer = get_object_or_404(Customer, pk=pk)
    
    # Müşteriye ait hosting hizmetleri
    hosting_services = HostingService.objects.filter(customer=customer)
    
    # Müşteriye ait domainler
    domains = Domain.objects.filter(customer=customer)
    
    # Müşteriye ait SSL sertifikaları
    ssl_certificates = SSLCertificate.objects.filter(domain__customer=customer)
    
    # Müşteriye ait faturalar
    invoices = Invoice.objects.filter(customer=customer).order_by('-issue_date')
    
    # Fatura istatistikleri
    invoice_stats = {
        'total': invoices.aggregate(
            count=Count('id'),
            amount=Sum('amount')
        ),
        'paid': invoices.filter(payment_status='paid').aggregate(
            count=Count('id'),
            amount=Sum('amount')
        ),
        'pending': invoices.filter(payment_status='pending').aggregate(
            count=Count('id'),
            amount=Sum('amount')
        ),
        'overdue': invoices.filter(
            payment_status='pending',
            due_date__lt=timezone.now()
        ).aggregate(
            count=Count('id'),
            amount=Sum('amount')
        ),
    }
    
    context = {
        'customer': customer,
        'hosting_services': hosting_services,
        'domains': domains,
        'ssl_certificates': ssl_certificates,
        'invoices': invoices,
        'invoice_stats': invoice_stats,
    }
    
    return render(request, 'customers/customer_detail.html', context)

# Hosting Views
@login_required
def hosting_add(request):
    if request.method == 'POST':
        form = HostingServiceForm(request.POST)
        if form.is_valid():
            hosting = form.save()
            messages.success(request, 'Hosting hizmeti başarıyla eklendi.')
            return redirect('customers:hosting-detail', pk=hosting.pk)
    else:
        form = HostingServiceForm()
    return render(request, 'customers/hosting_form.html', {'form': form, 'title': 'Yeni Hosting Ekle'})

@login_required
def hosting_edit(request, pk):
    hosting = get_object_or_404(HostingService, pk=pk)
    if request.method == 'POST':
        form = HostingServiceForm(request.POST, instance=hosting)
        if form.is_valid():
            form.save()
            messages.success(request, 'Hosting hizmeti başarıyla güncellendi.')
            return redirect('customers:hosting-detail', pk=pk)
    else:
        form = HostingServiceForm(instance=hosting)
    return render(request, 'customers/hosting_form.html', {'form': form, 'title': 'Hosting Düzenle'})

@login_required
def hosting_delete(request, pk):
    hosting = get_object_or_404(HostingService, pk=pk)
    if request.method == 'POST':
        customer_pk = hosting.customer.pk
        hosting.delete()
        messages.success(request, 'Hosting hizmeti başarıyla silindi.')
        return redirect('customers:customer-detail', pk=customer_pk)
    return render(request, 'customers/hosting_confirm_delete.html', {'hosting': hosting})

@login_required
def hosting_list(request):
    hosting_services = HostingService.objects.all()
    return render(request, 'customers/hosting_list.html', {'hosting_services': hosting_services})

@login_required
def hosting_detail(request, pk):
    hosting = get_object_or_404(HostingService, pk=pk)
    return render(request, 'customers/hosting_detail.html', {'hosting': hosting})

# Domain Views
@login_required
def domain_add(request):
    if request.method == 'POST':
        form = DomainForm(request.POST)
        if form.is_valid():
            domain = form.save()
            messages.success(request, 'Domain başarıyla eklendi.')
            return redirect('customers:domain-detail', pk=domain.pk)
    else:
        form = DomainForm()
    return render(request, 'customers/domain_form.html', {'form': form, 'title': 'Yeni Domain Ekle'})

@login_required
def domain_edit(request, pk):
    domain = get_object_or_404(Domain, pk=pk)
    if request.method == 'POST':
        form = DomainForm(request.POST, instance=domain)
        if form.is_valid():
            form.save()
            messages.success(request, 'Domain başarıyla güncellendi.')
            return redirect('customers:domain-detail', pk=pk)
    else:
        form = DomainForm(instance=domain)
    return render(request, 'customers/domain_form.html', {'form': form, 'title': 'Domain Düzenle'})

@login_required
def domain_delete(request, pk):
    domain = get_object_or_404(Domain, pk=pk)
    if request.method == 'POST':
        customer_pk = domain.customer.pk
        domain.delete()
        messages.success(request, 'Domain başarıyla silindi.')
        return redirect('customers:customer-detail', pk=customer_pk)
    return render(request, 'customers/domain_confirm_delete.html', {'domain': domain})

@login_required
def domain_list(request):
    domains = Domain.objects.all().select_related('customer')
    
    # Domain istatistikleri
    stats = {
        'active': domains.filter(is_active=True),
        'expired': domains.filter(expiration_date__lt=timezone.now()),
        'expiring_soon': domains.filter(
            is_active=True,
            expiration_date__lte=timezone.now() + timedelta(days=30)
        ),
    }
    
    return render(request, 'customers/domain_list.html', {
        'domains': domains,
        'stats': stats,
    })

@login_required
def domain_detail(request, pk):
    domain = get_object_or_404(Domain, pk=pk)
    return render(request, 'customers/domain_detail.html', {'domain': domain})

# SSL Views
@login_required
def ssl_add(request):
    if request.method == 'POST':
        form = SSLCertificateForm(request.POST)
        if form.is_valid():
            ssl = form.save()
            messages.success(request, 'SSL sertifikası başarıyla eklendi.')
            return redirect('customers:ssl-detail', pk=ssl.pk)
    else:
        form = SSLCertificateForm()
    return render(request, 'customers/ssl_form.html', {'form': form, 'title': 'Yeni SSL Ekle'})

@login_required
def ssl_edit(request, pk):
    ssl = get_object_or_404(SSLCertificate, pk=pk)
    if request.method == 'POST':
        form = SSLCertificateForm(request.POST, instance=ssl)
        if form.is_valid():
            form.save()
            messages.success(request, 'SSL sertifikası başarıyla güncellendi.')
            return redirect('customers:ssl-detail', pk=pk)
    else:
        form = SSLCertificateForm(instance=ssl)
    return render(request, 'customers/ssl_form.html', {'form': form, 'title': 'SSL Düzenle'})

@login_required
def ssl_delete(request, pk):
    ssl = get_object_or_404(SSLCertificate, pk=pk)
    if request.method == 'POST':
        domain_pk = ssl.domain.pk
        ssl.delete()
        messages.success(request, 'SSL sertifikası başarıyla silindi.')
        return redirect('customers:domain-detail', pk=domain_pk)
    return render(request, 'customers/ssl_confirm_delete.html', {'ssl': ssl})

@login_required
def ssl_list(request):
    ssl_certificates = SSLCertificate.objects.all().select_related('domain', 'domain__customer')
    
    # SSL istatistikleri
    stats = {
        'active': ssl_certificates.filter(is_active=True),
        'expired': ssl_certificates.filter(expiration_date__lt=timezone.now()),
        'expiring_soon': ssl_certificates.filter(
            is_active=True,
            expiration_date__lte=timezone.now() + timedelta(days=30)
        ),
    }
    
    return render(request, 'customers/ssl_list.html', {
        'ssl_certificates': ssl_certificates,
        'stats': stats,
    })

@login_required
def ssl_detail(request, pk):
    ssl = get_object_or_404(SSLCertificate, pk=pk)
    return render(request, 'customers/ssl_detail.html', {'ssl': ssl})

# Invoice Views
@login_required
def invoice_add(request):
    if request.method == 'POST':
        form = InvoiceForm(request.POST)
        if form.is_valid():
            invoice = form.save()
            messages.success(request, 'Fatura başarıyla eklendi.')
            return redirect('customers:invoice-detail', pk=invoice.pk)
    else:
        form = InvoiceForm()
    return render(request, 'customers/invoice_form.html', {'form': form, 'title': 'Yeni Fatura Ekle'})

@login_required
def invoice_edit(request, pk):
    invoice = get_object_or_404(Invoice, pk=pk)
    if request.method == 'POST':
        form = InvoiceForm(request.POST, instance=invoice)
        if form.is_valid():
            form.save()
            messages.success(request, 'Fatura başarıyla güncellendi.')
            return redirect('customers:invoice-detail', pk=pk)
    else:
        form = InvoiceForm(instance=invoice)
    return render(request, 'customers/invoice_form.html', {'form': form, 'title': 'Fatura Düzenle'})

@login_required
def invoice_delete(request, pk):
    invoice = get_object_or_404(Invoice, pk=pk)
    if request.method == 'POST':
        customer_pk = invoice.customer.pk
        invoice.delete()
        messages.success(request, 'Fatura başarıyla silindi.')
        return redirect('customers:customer-detail', pk=customer_pk)
    return render(request, 'customers/invoice_confirm_delete.html', {'invoice': invoice})

@login_required
def invoice_list(request):
    invoices = Invoice.objects.all().select_related('customer')
    
    # Fatura istatistikleri
    stats = {
        'all': invoices,
        'paid': invoices.filter(payment_status='paid'),
        'pending': invoices.filter(payment_status='pending'),
        'overdue': invoices.filter(
            payment_status='pending',
            due_date__lt=timezone.now()
        ),
    }
    
    return render(request, 'customers/invoice_list.html', {
        'invoices': invoices,
        'stats': stats,
    })

@login_required
def invoice_detail(request, pk):
    invoice = get_object_or_404(Invoice, pk=pk)
    return render(request, 'customers/invoice_detail.html', {'invoice': invoice})

@login_required
def dashboard(request):
    # Son 30 günlük istatistikler
    thirty_days_ago = timezone.now() - timedelta(days=30)
    
    # Müşteri istatistikleri
    customer_stats = {
        'total': Customer.objects.count(),
        'new': Customer.objects.filter(created_at__gte=thirty_days_ago).count(),
    }
    
    # Hosting istatistikleri
    hosting_stats = {
        'total': HostingService.objects.count(),
        'active': HostingService.objects.filter(status='active').count(),
        'suspended': HostingService.objects.filter(status='suspended').count(),
        'expired': HostingService.objects.filter(status='expired').count(),
        'expiring_soon': HostingService.objects.filter(
            status='active',
            expiration_date__lte=timezone.now() + timedelta(days=30)
        ).count(),
    }
    
    # Domain istatistikleri
    domain_stats = {
        'total': Domain.objects.count(),
        'active': Domain.objects.filter(is_active=True).count(),
        'expired': Domain.objects.filter(
            expiration_date__lt=timezone.now()
        ).count(),
        'expiring_soon': Domain.objects.filter(
            is_active=True,
            expiration_date__lte=timezone.now() + timedelta(days=30)
        ).count(),
    }
    
    # SSL istatistikleri
    ssl_stats = {
        'total': SSLCertificate.objects.count(),
        'active': SSLCertificate.objects.filter(is_active=True).count(),
        'expired': SSLCertificate.objects.filter(
            expiration_date__lt=timezone.now()
        ).count(),
        'expiring_soon': SSLCertificate.objects.filter(
            is_active=True,
            expiration_date__lte=timezone.now() + timedelta(days=30)
        ).count(),
    }
    
    # Fatura istatistikleri
    invoice_stats = {
        'total': Invoice.objects.aggregate(
            count=Count('id'),
            amount=Sum('amount')
        ),
        'paid': Invoice.objects.filter(payment_status='paid').aggregate(
            count=Count('id'),
            amount=Sum('amount')
        ),
        'pending': Invoice.objects.filter(payment_status='pending').aggregate(
            count=Count('id'),
            amount=Sum('amount')
        ),
        'overdue': Invoice.objects.filter(
            payment_status='pending',
            due_date__lt=timezone.now()
        ).aggregate(
            count=Count('id'),
            amount=Sum('amount')
        ),
    }
    
    # Son eklenen müşteriler
    recent_customers = Customer.objects.order_by('-created_at')[:5]
    
    # Yakında bitecek hizmetler
    expiring_services = {
        'hosting': HostingService.objects.filter(
            status='active',
            expiration_date__lte=timezone.now() + timedelta(days=30)
        ).order_by('expiration_date')[:5],
        'domains': Domain.objects.filter(
            is_active=True,
            expiration_date__lte=timezone.now() + timedelta(days=30)
        ).order_by('expiration_date')[:5],
        'ssl': SSLCertificate.objects.filter(
            is_active=True,
            expiration_date__lte=timezone.now() + timedelta(days=30)
        ).order_by('expiration_date')[:5],
    }
    
    # Ödenmemiş faturalar
    pending_invoices = Invoice.objects.filter(
        payment_status='pending'
    ).order_by('due_date')[:5]
    
    context = {
        'customer_stats': customer_stats,
        'hosting_stats': hosting_stats,
        'domain_stats': domain_stats,
        'ssl_stats': ssl_stats,
        'invoice_stats': invoice_stats,
        'recent_customers': recent_customers,
        'expiring_services': expiring_services,
        'pending_invoices': pending_invoices,
    }
    
    return render(request, 'customers/dashboard.html', context)

class HostingCreateView(CreateView):
    model = HostingService
    form_class = HostingServiceForm
    template_name = 'customers/hosting_form.html'
    success_url = reverse_lazy('customers:hosting-list')

class DomainCreateView(CreateView):
    model = Domain
    form_class = DomainForm
    template_name = 'customers/domain_form.html'
    success_url = reverse_lazy('customers:domain-list')

class SSLCreateView(CreateView):
    model = SSLCertificate
    form_class = SSLCertificateForm
    template_name = 'customers/ssl_form.html'
    success_url = reverse_lazy('customers:ssl-list')
