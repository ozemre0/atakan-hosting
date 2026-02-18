geçe-- Görüntüleme için SELECT komutları
-- Bu komutları Cloudflare D1'de çalıştırarak mevcut verileri görebilirsiniz

-- Müşterileri görüntüle
SELECT * FROM customers ORDER BY customer_no;

-- Hosting hizmetlerini görüntüle
SELECT 
  h.*,
  c.first_name || ' ' || c.last_name AS customer_name,
  c.company AS customer_company
FROM hostings h
JOIN customers c ON c.id = h.customer_id
ORDER BY h.end_date DESC;

-- Domain hizmetlerini görüntüle
SELECT 
  d.*,
  c.first_name || ' ' || c.last_name AS customer_name,
  c.company AS customer_company
FROM domains d
JOIN customers c ON c.id = d.customer_id
ORDER BY d.end_date DESC;

-- SSL hizmetlerini görüntüle
SELECT 
  s.*,
  c.first_name || ' ' || c.last_name AS customer_name,
  c.company AS customer_company
FROM ssls s
JOIN customers c ON c.id = s.customer_id
ORDER BY s.end_date DESC;

-- Müşteri detayı (ID ile değiştirin)
-- SELECT * FROM customers WHERE id = 'CUSTOMER_ID_HERE';

-- Hosting detayı (ID ile değiştirin)
-- SELECT * FROM hostings WHERE id = 'HOSTING_ID_HERE';

-- Domain detayı (ID ile değiştirin)
-- SELECT * FROM domains WHERE id = 'DOMAIN_ID_HERE';

-- SSL detayı (ID ile değiştirin)
-- SELECT * FROM ssls WHERE id = 'SSL_ID_HERE';

