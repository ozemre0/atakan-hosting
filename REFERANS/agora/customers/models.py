from django.db import models
from django.utils import timezone

class Customer(models.Model):
    company_name = models.CharField(max_length=200, verbose_name='Firma Adı')
    contact_name = models.CharField(max_length=200, verbose_name='İletişim Kişisi')
    email = models.EmailField(verbose_name='E-posta')
    email2 = models.EmailField(verbose_name='E-posta 2', blank=True, null=True)
    email3 = models.EmailField(verbose_name='E-posta 3', blank=True, null=True)
    phone = models.CharField(max_length=20, verbose_name='Telefon')
    address = models.TextField(verbose_name='Adres', blank=True, null=True)
    tax_office = models.CharField(max_length=200, verbose_name='Vergi Dairesi', blank=True, null=True)
    tax_number = models.CharField(max_length=50, verbose_name='Vergi Numarası', blank=True, null=True)
    registration_date = models.DateField(verbose_name='Kayıt Tarihi')
    notes = models.TextField(blank=True, null=True, verbose_name='Notlar')
    created_at = models.DateTimeField(default=timezone.now, verbose_name='Oluşturulma Tarihi')
    
    def __str__(self):
        return self.company_name

    class Meta:
        verbose_name = 'Müşteri'
        verbose_name_plural = 'Müşteriler'

class Domain(models.Model):
    customer = models.ForeignKey(Customer, on_delete=models.CASCADE, verbose_name='Müşteri')
    name = models.CharField(max_length=200, verbose_name='Domain Adı')
    registration_date = models.DateField(verbose_name='Kayıt Tarihi')
    expiration_date = models.DateField(verbose_name='Bitiş Tarihi')
    is_active = models.BooleanField(default=True, verbose_name='Aktif mi?')
    nameserver1 = models.CharField(max_length=200, verbose_name='Nameserver 1')
    nameserver2 = models.CharField(max_length=200, verbose_name='Nameserver 2')
    nameserver3 = models.CharField(max_length=200, blank=True, null=True, verbose_name='Nameserver 3')
    nameserver4 = models.CharField(max_length=200, blank=True, null=True, verbose_name='Nameserver 4')

    def __str__(self):
        return self.name

    class Meta:
        verbose_name = 'Domain'
        verbose_name_plural = 'Domainler'

class HostingService(models.Model):
    customer = models.ForeignKey(Customer, on_delete=models.CASCADE, verbose_name='Müşteri')
    domain = models.OneToOneField(Domain, on_delete=models.CASCADE, verbose_name='Domain')
    package = models.CharField(max_length=100, verbose_name='Paket')
    status = models.CharField(max_length=20, choices=[
        ('active', 'Aktif'),
        ('suspended', 'Askıya Alındı'),
        ('cancelled', 'İptal Edildi')
    ], verbose_name='Durum')
    start_date = models.DateField(verbose_name='Başlangıç Tarihi')
    expiration_date = models.DateField(verbose_name='Bitiş Tarihi')
    renewal_count = models.IntegerField(default=0, verbose_name='Yenileme Sayısı')
    notes = models.TextField(blank=True, null=True, verbose_name='Notlar')

    def __str__(self):
        return f"{self.domain.name} - {self.customer.company_name}"

    class Meta:
        verbose_name = 'Hosting Hizmeti'
        verbose_name_plural = 'Hosting Hizmetleri'

class SSLCertificate(models.Model):
    customer = models.ForeignKey(Customer, on_delete=models.CASCADE, verbose_name='Müşteri')
    domain = models.OneToOneField(Domain, on_delete=models.CASCADE, verbose_name='Domain')
    start_date = models.DateField(verbose_name='Başlangıç Tarihi')
    expiration_date = models.DateField(verbose_name='Bitiş Tarihi')
    is_active = models.BooleanField(default=True, verbose_name='Aktif mi?')

    def __str__(self):
        return f"{self.domain.name} SSL"

    class Meta:
        verbose_name = 'SSL Sertifikası'
        verbose_name_plural = 'SSL Sertifikaları'

class Invoice(models.Model):
    PAYMENT_STATUS = [
        ('paid', 'Ödendi'),
        ('pending', 'Beklemede'),
        ('overdue', 'Gecikmiş'),
    ]
    
    PAYMENT_METHODS = [
        ('bank_transfer', 'Banka Havalesi'),
        ('credit_card', 'Kredi Kartı'),
        ('other', 'Diğer'),
    ]

    customer = models.ForeignKey(Customer, on_delete=models.CASCADE, verbose_name='Müşteri')
    invoice_number = models.CharField(max_length=50, unique=True, verbose_name='Fatura No')
    description = models.TextField(verbose_name='Açıklama')
    amount = models.DecimalField(max_digits=10, decimal_places=2, verbose_name='Tutar')
    issue_date = models.DateField(verbose_name='Fatura Tarihi')
    due_date = models.DateField(verbose_name='Son Ödeme Tarihi')
    payment_status = models.CharField(max_length=10, choices=PAYMENT_STATUS, default='pending', verbose_name='Ödeme Durumu')
    payment_date = models.DateField(null=True, blank=True, verbose_name='Ödeme Tarihi')
    payment_method = models.CharField(max_length=20, choices=PAYMENT_METHODS, null=True, blank=True, verbose_name='Ödeme Yöntemi')
    payment_notes = models.TextField(blank=True, null=True, verbose_name='Ödeme Notları')
    notes = models.TextField(blank=True, null=True, verbose_name='Notlar')

    def __str__(self):
        return f"{self.invoice_number} - {self.customer.company_name}"

    class Meta:
        verbose_name = 'Fatura'
        verbose_name_plural = 'Faturalar'
