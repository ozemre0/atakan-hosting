from django.urls import path
from . import views

app_name = 'customers'

urlpatterns = [
    path('', views.dashboard, name='dashboard'),
    
    # Müşteri URL'leri
    path('customers/', views.customer_list, name='customer-list'),
    path('customers/add/', views.customer_add, name='customer-add'),
    path('customers/<int:pk>/', views.customer_detail, name='customer-detail'),
    path('customers/<int:pk>/edit/', views.customer_edit, name='customer-edit'),
    path('customers/<int:pk>/delete/', views.customer_delete, name='customer-delete'),
    
    # Hosting URL'leri
    path('hosting/', views.hosting_list, name='hosting-list'),
    path('hosting/add/', views.hosting_add, name='hosting-add'),
    path('hosting/<int:pk>/', views.hosting_detail, name='hosting-detail'),
    path('hosting/<int:pk>/edit/', views.hosting_edit, name='hosting-edit'),
    path('hosting/<int:pk>/delete/', views.hosting_delete, name='hosting-delete'),
    
    # Domain URL'leri
    path('domains/', views.domain_list, name='domain-list'),
    path('domains/add/', views.domain_add, name='domain-add'),
    path('domains/<int:pk>/', views.domain_detail, name='domain-detail'),
    path('domains/<int:pk>/edit/', views.domain_edit, name='domain-edit'),
    path('domains/<int:pk>/delete/', views.domain_delete, name='domain-delete'),
    
    # SSL URL'leri
    path('ssl/', views.ssl_list, name='ssl-list'),
    path('ssl/add/', views.ssl_add, name='ssl-add'),
    path('ssl/<int:pk>/', views.ssl_detail, name='ssl-detail'),
    path('ssl/<int:pk>/edit/', views.ssl_edit, name='ssl-edit'),
    path('ssl/<int:pk>/delete/', views.ssl_delete, name='ssl-delete'),
    
    # Fatura URL'leri
    path('invoices/', views.invoice_list, name='invoice-list'),
    path('invoices/add/', views.invoice_add, name='invoice-add'),
    path('invoices/<int:pk>/', views.invoice_detail, name='invoice-detail'),
    path('invoices/<int:pk>/edit/', views.invoice_edit, name='invoice-edit'),
    path('invoices/<int:pk>/delete/', views.invoice_delete, name='invoice-delete'),
] 