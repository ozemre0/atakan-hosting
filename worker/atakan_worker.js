export default {
  async fetch(request, env, ctx) {
    try {
      // Ensure required tables exist. This prevents "no such table" runtime errors.
      await ensureSchema(env);

      const url = new URL(request.url);
      const path = url.pathname.replace(/\/+$/, "") || "/";
      const method = request.method.toUpperCase();

      // CORS preflight
      if (method === "OPTIONS") return cors(new Response(null, { status: 204 }));

      if (path === "/health") return cors(json({ ok: true, service: "atakan-api" }));

      // --- Public: setup + login (admin gate is handled here, per PDF) ---
      if (path === "/setup/admin" && method === "POST") {
        const body = await readJson(request);
        const username = String(body?.username || "").trim();
        const password = String(body?.password || "").trim();
        if (!username || !password) return cors(json({ ok: false, error: "INVALID_FIELDS" }, 400));

        const existing = await env.DB.prepare("SELECT username FROM admins LIMIT 1").first();
        if (existing) return cors(json({ ok: false, error: "ADMIN_ALREADY_SET" }, 409));

        await env.DB.prepare("INSERT INTO admins(username, password) VALUES(?,?)")
          .bind(username, password)
          .run();

        return cors(json({ ok: true }));
      }

      if (path === "/auth/login" && method === "POST") {
        const body = await readJson(request);
        const username = String(body?.username || "").trim();
        const password = String(body?.password || "").trim();
        if (!username || !password) return cors(json({ ok: false, error: "INVALID_FIELDS" }, 400));

        const anyAdmin = await env.DB.prepare("SELECT 1 AS x FROM admins LIMIT 1").first();
        if (!anyAdmin) return cors(json({ ok: false, error: "ADMIN_NOT_SET" }, 400));

        const row = await env.DB.prepare("SELECT password FROM admins WHERE username=?")
          .bind(username)
          .first();
        if (!row) return cors(json({ ok: false, error: "INVALID_CREDENTIALS" }, 401));

        // NOTE: User requested plaintext password stored in DB (not recommended).
        if (String(row.password) !== password) return cors(json({ ok: false, error: "INVALID_CREDENTIALS" }, 401));

        // Generate secure token and store it
        const token = generateToken();
        const expiresAt = new Date();
        expiresAt.setDate(expiresAt.getDate() + 30); // 30 days expiry
        const expiresAtIso = expiresAt.toISOString().replace("T", " ").slice(0, 19);

        // Delete old tokens for this user (optional: keep only latest)
        await env.DB.prepare("DELETE FROM admin_tokens WHERE username=?").bind(username).run();

        // Insert new token
        await env.DB.prepare("INSERT INTO admin_tokens(token, username, expires_at) VALUES(?,?,?)")
          .bind(token, username, expiresAtIso)
          .run();

        return cors(json({ ok: true, token }));
      }

      // --- Auth required below ---
      const admin = await requireAdmin(env, request);
      if (!admin) return cors(json({ ok: false, error: "UNAUTHORIZED" }, 401));

      if (path === "/auth/logout" && method === "POST") {
        // Delete token from DB
        const token = getBearerToken(request);
        if (token) {
          await env.DB.prepare("DELETE FROM admin_tokens WHERE token=?").bind(token).run();
        }
        return cors(json({ ok: true }));
      }

      // SETTINGS: SMTP (PDF)
      if (path === "/settings/smtp") {
        if (method === "GET") {
          const smtp = await getSmtp(env);
          return cors(json({ ok: true, smtp }));
        }
        if (method === "PUT") {
          const body = await readJson(request);
          const smtp = {
            host: String(body?.host || ""),
            port: Number(body?.port || 0),
            secure: Boolean(body?.secure || false),
            username: String(body?.username || ""),
            password: String(body?.password || ""),
          };
          if (!smtp.host || !smtp.port) return cors(json({ ok: false, error: "INVALID_SMTP" }, 400));
          await setSetting(env, "smtp_settings", JSON.stringify(smtp));
          return cors(json({ ok: true }));
        }
        return cors(json({ ok: false, error: "METHOD_NOT_ALLOWED" }, 405));
      }

      // DASHBOARD (PDF: aktif/exp sayıları)
      if (path === "/dashboard" && method === "GET") {
        const today = isoDateToday();
        const customersTotal = await scalar(env, "SELECT COUNT(1) FROM customers");
        const hostingActive = await scalar(env, "SELECT COUNT(1) FROM hostings WHERE status=1");
        const hostingExpired = await scalar(env, "SELECT COUNT(1) FROM hostings WHERE status=1 AND end_date < ?", [today]);
        const domainActive = await scalar(env, "SELECT COUNT(1) FROM domains WHERE status=1");
        const domainExpired = await scalar(env, "SELECT COUNT(1) FROM domains WHERE status=1 AND end_date < ?", [today]);
        const sslActive = await scalar(env, "SELECT COUNT(1) FROM ssls WHERE status=1");
        const sslExpired = await scalar(env, "SELECT COUNT(1) FROM ssls WHERE status=1 AND end_date < ?", [today]);

        const expired = {
          hostings: await topExpired(env, "hostings", today),
          domains: await topExpired(env, "domains", today),
          ssls: await topExpired(env, "ssls", today),
        };

        return cors(
          json({
            ok: true,
            today,
            customers: { total: customersTotal },
            hosting: { active: hostingActive, expired: hostingExpired },
            domains: { active: domainActive, expired: domainExpired },
            ssls: { active: sslActive, expired: sslExpired },
            expired,
          })
        );
      }

      // RENEWALS (PDF: tarih aralığında bitecekler)
      if (path === "/renewals" && method === "GET") {
        const type = (url.searchParams.get("type") || "all").toLowerCase(); // hosting|domain|ssl|all
        const start = url.searchParams.get("start");
        const end = url.searchParams.get("end");
        if (!isIsoDate(start) || !isIsoDate(end)) return cors(json({ ok: false, error: "INVALID_DATE_RANGE" }, 400));

        const list = [];
        if (type === "hosting" || type === "all") list.push(...(await listExpiring(env, "hostings", start, end)));
        if (type === "domain" || type === "all") list.push(...(await listExpiring(env, "domains", start, end)));
        if (type === "ssl" || type === "all") list.push(...(await listExpiring(env, "ssls", start, end)));

        return cors(json({ ok: true, items: list }));
      }

      // EXPORT CSV (PDF: excel/csv export)
      if (path.startsWith("/export/") && method === "GET") {
        const table = path.split("/")[2] || "";
        const allowed = new Set(["customers", "domains", "hostings", "ssls", "incomes", "expenses"]);
        if (!allowed.has(table)) return cors(json({ ok: false, error: "INVALID_TABLE" }, 400));

        const { results } = await env.DB.prepare(`SELECT * FROM ${table}`).all();
        const csv = toCsv(results || []);
        return cors(
          new Response(csv, {
            status: 200,
            headers: {
              "content-type": "text/csv; charset=utf-8",
              "content-disposition": `attachment; filename="${table}.csv"`,
            },
          })
        );
      }

      // CRUD routes
      const seg = path.split("/").filter(Boolean);

      // /customers
      if (seg[0] === "customers") {
        if (seg.length === 1) {
          if (method === "GET") return cors(await customersList(env, url));
          if (method === "POST") return cors(await customersCreate(env, request));
        }
        if (seg.length === 2) {
          const id = seg[1];
          if (method === "GET") return cors(await customersGet(env, id));
          if (method === "PATCH") return cors(await customersUpdate(env, id, request));
          if (method === "DELETE") return cors(await customersDelete(env, id));
        }
      }

      // /domains
      if (seg[0] === "domains") {
        if (seg.length === 1) {
          if (method === "GET") return cors(await serviceList(env, url, "domains"));
          if (method === "POST") return cors(await serviceCreate(env, request, "domains"));
        }
        if (seg.length === 2) {
          const id = seg[1];
          if (method === "GET") return cors(await serviceGet(env, id, "domains"));
          if (method === "PATCH") return cors(await serviceUpdate(env, id, request, "domains"));
          if (method === "DELETE") return cors(await serviceDelete(env, id, "domains"));
        }
      }

      // /hostings
      if (seg[0] === "hostings") {
        if (seg.length === 1) {
          if (method === "GET") return cors(await serviceList(env, url, "hostings"));
          if (method === "POST") return cors(await serviceCreate(env, request, "hostings"));
        }
        if (seg.length === 2) {
          const id = seg[1];
          if (method === "GET") return cors(await serviceGet(env, id, "hostings"));
          if (method === "PATCH") return cors(await serviceUpdate(env, id, request, "hostings"));
          if (method === "DELETE") return cors(await serviceDelete(env, id, "hostings"));
        }
      }

      // /ssls
      if (seg[0] === "ssls") {
        if (seg.length === 1) {
          if (method === "GET") return cors(await serviceList(env, url, "ssls"));
          if (method === "POST") return cors(await serviceCreate(env, request, "ssls"));
        }
        if (seg.length === 2) {
          const id = seg[1];
          if (method === "GET") return cors(await serviceGet(env, id, "ssls"));
          if (method === "PATCH") return cors(await serviceUpdate(env, id, request, "ssls"));
          if (method === "DELETE") return cors(await serviceDelete(env, id, "ssls"));
        }
      }

      // /incomes
      if (seg[0] === "incomes") {
        if (seg.length === 1) {
          if (method === "GET") return cors(await simpleList(env, url, "incomes"));
          if (method === "POST") return cors(await simpleCreate(env, request, "incomes"));
        }
        if (seg.length === 2) {
          const id = seg[1];
          if (method === "GET") return cors(await simpleGet(env, id, "incomes"));
          if (method === "PATCH") return cors(await simpleUpdate(env, id, request, "incomes"));
          if (method === "DELETE") return cors(await simpleDelete(env, id, "incomes"));
        }
      }

      // /expenses
      if (seg[0] === "expenses") {
        if (seg.length === 1) {
          if (method === "GET") return cors(await simpleList(env, url, "expenses"));
          if (method === "POST") return cors(await simpleCreate(env, request, "expenses"));
        }
        if (seg.length === 2) {
          const id = seg[1];
          if (method === "GET") return cors(await simpleGet(env, id, "expenses"));
          if (method === "PATCH") return cors(await simpleUpdate(env, id, request, "expenses"));
          if (method === "DELETE") return cors(await simpleDelete(env, id, "expenses"));
        }
      }

      return cors(json({ ok: false, error: "NOT_FOUND" }, 404));
    } catch (err) {
      return cors(json({ ok: false, error: "SERVER_ERROR", message: String(err?.message || err) }, 500));
    }
  },
};

// ---------- Auth helpers ----------
function getBearerToken(request) {
  const h = request.headers.get("authorization") || "";
  const m = h.match(/^Bearer\s+(.+)$/i);
  return m ? m[1].trim() : null;
}

function generateToken() {
  const b = new Uint8Array(32);
  crypto.getRandomValues(b);
  return [...b].map((x) => x.toString(16).padStart(2, "0")).join("");
}

async function requireAdmin(env, request) {
  const token = getBearerToken(request);
  if (!token) return null;

  // Check token in admin_tokens table
  const row = await env.DB.prepare(
    "SELECT username FROM admin_tokens WHERE token=? AND expires_at > datetime('now') LIMIT 1"
  )
    .bind(token)
    .first();
  if (!row) return null;

  return { username: String(row.username) };
}

// ---------- Response helpers ----------
function cors(res) {
  const h = new Headers(res.headers);
  h.set("access-control-allow-origin", "*");
  h.set("access-control-allow-methods", "GET,POST,PUT,PATCH,DELETE,OPTIONS");
  h.set("access-control-allow-headers", "authorization,content-type");
  return new Response(res.body, { status: res.status, headers: h });
}

function json(obj, status = 200) {
  return new Response(JSON.stringify(obj, null, 2), {
    status,
    headers: { "content-type": "application/json; charset=utf-8" },
  });
}

async function readJson(request) {
  const ct = request.headers.get("content-type") || "";
  if (!ct.includes("application/json")) return null;
  return await request.json();
}

// ---------- General helpers ----------
function isoDateToday() {
  const d = new Date();
  const yyyy = d.getUTCFullYear();
  const mm = String(d.getUTCMonth() + 1).padStart(2, "0");
  const dd = String(d.getUTCDate()).padStart(2, "0");
  return `${yyyy}-${mm}-${dd}`;
}

function isIsoDate(s) {
  return typeof s === "string" && /^\d{4}-\d{2}-\d{2}$/.test(s);
}

function addOneYear(iso) {
  const d = new Date(`${iso}T00:00:00Z`);
  const y = d.getUTCFullYear() + 1;
  const m = String(d.getUTCMonth() + 1).padStart(2, "0");
  const day = String(d.getUTCDate()).padStart(2, "0");
  return `${y}-${m}-${day}`;
}

async function scalar(env, sql, params = []) {
  const stmt = env.DB.prepare(sql).bind(...params);
  const row = await stmt.first();
  if (!row) return 0;
  const k = Object.keys(row)[0];
  return Number(row[k] ?? 0);
}

function uuid() {
  const b = new Uint8Array(16);
  crypto.getRandomValues(b);
  b[6] = (b[6] & 0x0f) | 0x40;
  b[8] = (b[8] & 0x3f) | 0x80;
  const h = [...b].map((x) => x.toString(16).padStart(2, "0")).join("");
  return `${h.slice(0, 8)}-${h.slice(8, 12)}-${h.slice(12, 16)}-${h.slice(16, 20)}-${h.slice(20)}`;
}

function toCsv(rows) {
  if (!rows.length) return "";
  const cols = Object.keys(rows[0]);
  const esc = (v) => {
    const s = v == null ? "" : String(v);
    if (/[,"\\n]/.test(s)) return `"${s.replace(/"/g, '""')}"`;
    return s;
  };
  return [cols.join(","), ...rows.map((r) => cols.map((c) => esc(r[c])).join(","))].join("\\n");
}

async function getSetting(env, key) {
  const row = await env.DB.prepare("SELECT value FROM app_settings WHERE key=?").bind(key).first();
  return row?.value || null;
}

async function setSetting(env, key, value) {
  await env.DB.prepare(
    "INSERT INTO app_settings(key,value,updated_at) VALUES(?,?,datetime('now')) " +
      "ON CONFLICT(key) DO UPDATE SET value=excluded.value, updated_at=datetime('now')"
  )
    .bind(key, value)
    .run();
}

async function getSmtp(env) {
  const raw = await getSetting(env, "smtp_settings");
  return raw ? JSON.parse(raw) : null;
}

async function ensureSchema(env) {
  // admins table (only username+password)
  await env.DB.prepare(
    "CREATE TABLE IF NOT EXISTS admins (username TEXT PRIMARY KEY, password TEXT NOT NULL)"
  ).run();

  // admin_tokens table for secure token-based auth
  await env.DB.prepare(
    "CREATE TABLE IF NOT EXISTS admin_tokens (token TEXT PRIMARY KEY, username TEXT NOT NULL, expires_at TEXT NOT NULL, created_at TEXT NOT NULL DEFAULT (datetime('now')))"
  ).run();

  await env.DB.prepare(
    "CREATE TABLE IF NOT EXISTS app_settings (key TEXT PRIMARY KEY, value TEXT NOT NULL, updated_at TEXT NOT NULL DEFAULT (datetime('now')))"
  ).run();

  await env.DB.prepare(`
    CREATE TABLE IF NOT EXISTS customers (
      id TEXT PRIMARY KEY,
      customer_no INTEGER NOT NULL UNIQUE,
      password TEXT NOT NULL,
      first_name TEXT NOT NULL,
      last_name TEXT NOT NULL,
      company TEXT NOT NULL,
      registration_date TEXT NOT NULL,
      email1 TEXT NOT NULL,
      email2 TEXT,
      email3 TEXT,
      phone1 TEXT NOT NULL,
      phone2 TEXT,
      address TEXT,
      city TEXT,
      tax_office TEXT,
      tax_no INTEGER,
      description TEXT
    )
  `).run();

  await env.DB.prepare(`
    CREATE TABLE IF NOT EXISTS domains (
      id TEXT PRIMARY KEY,
      customer_id TEXT NOT NULL,
      domain_name TEXT NOT NULL,
      paid_amount REAL NOT NULL DEFAULT 0,
      start_date TEXT NOT NULL,
      end_date TEXT NOT NULL,
      ns1 TEXT,
      ns2 TEXT,
      renewal_count INTEGER NOT NULL DEFAULT 0,
      renewal_dates TEXT NOT NULL DEFAULT '[]',
      description TEXT,
      status INTEGER NOT NULL DEFAULT 1
    )
  `).run();

  await env.DB.prepare(`
    CREATE TABLE IF NOT EXISTS hostings (
      id TEXT PRIMARY KEY,
      customer_id TEXT NOT NULL,
      domain_name TEXT NOT NULL,
      paid_amount REAL NOT NULL DEFAULT 0,
      start_date TEXT NOT NULL,
      end_date TEXT NOT NULL,
      ftp_username TEXT,
      ftp_password TEXT,
      renewal_count INTEGER NOT NULL DEFAULT 0,
      renewal_dates TEXT NOT NULL DEFAULT '[]',
      description TEXT,
      status INTEGER NOT NULL DEFAULT 1
    )
  `).run();

  await env.DB.prepare(`
    CREATE TABLE IF NOT EXISTS ssls (
      id TEXT PRIMARY KEY,
      customer_id TEXT NOT NULL,
      domain_name TEXT NOT NULL,
      url TEXT,
      paid_amount REAL NOT NULL DEFAULT 0,
      start_date TEXT NOT NULL,
      end_date TEXT NOT NULL,
      renewal_count INTEGER NOT NULL DEFAULT 0,
      renewal_dates TEXT NOT NULL DEFAULT '[]',
      description TEXT,
      status INTEGER NOT NULL DEFAULT 1
    )
  `).run();

  await env.DB.prepare(`
    CREATE TABLE IF NOT EXISTS incomes (
      id TEXT PRIMARY KEY,
      date TEXT NOT NULL,
      description TEXT NOT NULL,
      amount REAL NOT NULL
    )
  `).run();

  await env.DB.prepare(`
    CREATE TABLE IF NOT EXISTS expenses (
      id TEXT PRIMARY KEY,
      date TEXT NOT NULL,
      description TEXT NOT NULL,
      amount REAL NOT NULL
    )
  `).run();
}

async function topExpired(env, table, today) {
  const sql = `
    SELECT
      t.id,
      t.domain_name,
      t.end_date,
      t.status,
      (c.first_name || ' ' || c.last_name) AS customer_name
    FROM ${table} t
    JOIN customers c ON c.id = t.customer_id
    WHERE t.status=1 AND t.end_date < ?
    ORDER BY t.end_date ASC
    LIMIT 5
  `;
  const { results } = await env.DB.prepare(sql).bind(today).all();
  return results || [];
}

function genCustomerPassword() {
  // PDF: en az 8, büyük/küçük/rakam alfa numerik
  const alphabet = "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz0123456789";
  const pick = (n) => {
    const b = new Uint8Array(n);
    crypto.getRandomValues(b);
    let s = "";
    for (let i = 0; i < n; i++) s += alphabet[b[i] % alphabet.length];
    return s;
  };
  return pick(12);
}

// ---------- Customers ----------
async function customersList(env, url) {
  const q = (url.searchParams.get("q") || "").trim().toLowerCase();
  const sort = (url.searchParams.get("sort") || "name").toLowerCase(); // name|company|customer_no|renewals
  const dir = (url.searchParams.get("dir") || "asc").toLowerCase() === "desc" ? "DESC" : "ASC";
  const limit = Math.min(Number(url.searchParams.get("limit") || 50), 200);
  const offset = Math.max(Number(url.searchParams.get("offset") || 0), 0);

  let where = "";
  const params = [];
  if (q) {
    where = `
      WHERE
        CAST(c.customer_no AS TEXT) LIKE ? OR
        LOWER(c.first_name) LIKE ? OR
        LOWER(c.last_name) LIKE ? OR
        LOWER(c.company) LIKE ? OR
        LOWER(c.email1) LIKE ? OR
        LOWER(COALESCE(c.email2,'')) LIKE ? OR
        LOWER(COALESCE(c.email3,'')) LIKE ? OR
        LOWER(c.phone1) LIKE ? OR
        LOWER(COALESCE(c.phone2,'')) LIKE ?
    `;
    const like = `%${q}%`;
    params.push(like, like, like, like, like, like, like, like, like);
  }

  const orderBy = (() => {
    if (sort === "company") return `c.company ${dir}`;
    if (sort === "customer_no") return `c.customer_no ${dir}`;
    if (sort === "renewals") return `total_renewals ${dir}`;
    return `full_name ${dir}`;
  })();

  const sql = `
    SELECT
      c.*,
      (c.first_name || ' ' || c.last_name) AS full_name,
      (
        COALESCE((SELECT SUM(renewal_count) FROM hostings h WHERE h.customer_id=c.id),0) +
        COALESCE((SELECT SUM(renewal_count) FROM domains d WHERE d.customer_id=c.id),0) +
        COALESCE((SELECT SUM(renewal_count) FROM ssls s WHERE s.customer_id=c.id),0)
      ) AS total_renewals
    FROM customers c
    ${where}
    ORDER BY ${orderBy}
    LIMIT ? OFFSET ?
  `;
  params.push(limit, offset);

  const { results } = await env.DB.prepare(sql).bind(...params).all();
  return json({ ok: true, items: results || [], limit, offset });
}

async function customersCreate(env, request) {
  const body = await readJson(request);
  if (!body) return json({ ok: false, error: "INVALID_JSON" }, 400);

  const id = uuid();
  let customer_no = body.customer_no != null ? Number(body.customer_no) : null;
  if (!Number.isFinite(customer_no)) {
    const next = await scalar(env, "SELECT COALESCE(MAX(customer_no),0)+1 FROM customers");
    customer_no = next;
  }

  const password = String(body.password || "").trim() || genCustomerPassword();

  const row = {
    id,
    customer_no,
    password,
    first_name: String(body.first_name || "").trim(),
    last_name: String(body.last_name || "").trim(),
    company: String(body.company || "").trim(),
    registration_date: String(body.registration_date || "").trim(),
    email1: String(body.email1 || "").trim(),
    email2: body.email2 ? String(body.email2).trim() : null,
    email3: body.email3 ? String(body.email3).trim() : null,
    phone1: String(body.phone1 || "").trim(),
    phone2: body.phone2 ? String(body.phone2).trim() : null,
    address: body.address ? String(body.address).trim() : null,
    city: body.city ? String(body.city).trim() : null,
    tax_office: body.tax_office ? String(body.tax_office).trim() : null,
    tax_no: body.tax_no != null ? Number(body.tax_no) : null,
    description: body.description ? String(body.description).trim() : null,
  };

  if (!row.first_name || !row.last_name || !row.company) return json({ ok: false, error: "MISSING_NAME_FIELDS" }, 400);
  const regDate = String(row.registration_date || "").trim();
  if (!regDate || !isIsoDate(regDate)) {
    return json({ ok: false, error: "INVALID_REGISTRATION_DATE", received: regDate }, 400);
  }
  row.registration_date = regDate; // Use trimmed version
  if (!row.email1 || !row.phone1) return json({ ok: false, error: "MISSING_CONTACT" }, 400);

  await env.DB.prepare(`
    INSERT INTO customers(
      id, customer_no, password, first_name, last_name, company, registration_date,
      email1, email2, email3, phone1, phone2, address, city, tax_office, tax_no, description
    ) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
  `).bind(
    row.id, row.customer_no, row.password, row.first_name, row.last_name, row.company, row.registration_date,
    row.email1, row.email2, row.email3, row.phone1, row.phone2, row.address, row.city, row.tax_office, row.tax_no, row.description
  ).run();

  return json({ ok: true, item: row, generated_password: body.password ? null : password }, 201);
}

async function customersGet(env, id) {
  const customer = await env.DB.prepare("SELECT * FROM customers WHERE id=?").bind(id).first();
  if (!customer) return json({ ok: false, error: "NOT_FOUND" }, 404);

  const { results: domains } = await env.DB.prepare("SELECT * FROM domains WHERE customer_id=?").bind(id).all();
  const { results: hostings } = await env.DB.prepare("SELECT * FROM hostings WHERE customer_id=?").bind(id).all();
  const { results: ssls } = await env.DB.prepare("SELECT * FROM ssls WHERE customer_id=?").bind(id).all();

  return json({ ok: true, item: customer, services: { domains: domains || [], hostings: hostings || [], ssls: ssls || [] } });
}

async function customersUpdate(env, id, request) {
  const body = await readJson(request);
  if (!body) return json({ ok: false, error: "INVALID_JSON" }, 400);

  const existing = await env.DB.prepare("SELECT id FROM customers WHERE id=?").bind(id).first();
  if (!existing) return json({ ok: false, error: "NOT_FOUND" }, 404);

  const fields = [];
  const params = [];
  const set = (k, v) => {
    fields.push(`${k}=?`);
    params.push(v);
  };

  if (body.customer_no != null) set("customer_no", Number(body.customer_no));
  if (body.password != null) set("password", String(body.password));
  if (body.first_name != null) set("first_name", String(body.first_name));
  if (body.last_name != null) set("last_name", String(body.last_name));
  if (body.company != null) set("company", String(body.company));
  if (body.registration_date != null) set("registration_date", String(body.registration_date));
  if (body.email1 != null) set("email1", String(body.email1));
  if (body.email2 !== undefined) set("email2", body.email2 ? String(body.email2) : null);
  if (body.email3 !== undefined) set("email3", body.email3 ? String(body.email3) : null);
  if (body.phone1 != null) set("phone1", String(body.phone1));
  if (body.phone2 !== undefined) set("phone2", body.phone2 ? String(body.phone2) : null);
  if (body.address !== undefined) set("address", body.address ? String(body.address) : null);
  if (body.city !== undefined) set("city", body.city ? String(body.city) : null);
  if (body.tax_office !== undefined) set("tax_office", body.tax_office ? String(body.tax_office) : null);
  if (body.tax_no !== undefined) set("tax_no", body.tax_no != null ? Number(body.tax_no) : null);
  if (body.description !== undefined) set("description", body.description ? String(body.description) : null);

  if (!fields.length) return json({ ok: true });

  params.push(id);
  await env.DB.prepare(`UPDATE customers SET ${fields.join(", ")} WHERE id=?`).bind(...params).run();
  return json({ ok: true });
}

async function customersDelete(env, id) {
  const r = await env.DB.prepare("DELETE FROM customers WHERE id=?").bind(id).run();
  if (!r.success) return json({ ok: false, error: "DELETE_FAILED" }, 400);
  return json({ ok: true });
}

// ---------- Services (domains/hostings/ssls) ----------
async function serviceList(env, url, table) {
  const q = (url.searchParams.get("q") || "").trim().toLowerCase();
  const status = (url.searchParams.get("status") || "all").toLowerCase(); // active|passive|all
  const sort = (url.searchParams.get("sort") || "end_date").toLowerCase(); // domain_name|customer|renewal_count|end_date
  const dir = (url.searchParams.get("dir") || "asc").toLowerCase() === "desc" ? "DESC" : "ASC";
  const limit = Math.min(Number(url.searchParams.get("limit") || 50), 200);
  const offset = Math.max(Number(url.searchParams.get("offset") || 0), 0);

  const today = isoDateToday();

  const params = [];
  const where = [];
  if (q) {
    where.push(`(LOWER(t.domain_name) LIKE ? OR LOWER(COALESCE(t.description,'')) LIKE ?)`);
    const like = `%${q}%`;
    params.push(like, like);
  }
  if (status === "active") where.push("t.status=1");
  if (status === "passive") where.push("t.status=0");

  const orderBy = (() => {
    if (sort === "domain_name") return `t.domain_name ${dir}`;
    if (sort === "customer") return `customer_name ${dir}`;
    if (sort === "renewal_count") return `t.renewal_count ${dir}`;
    return `t.end_date ${dir}`;
  })();

  const sql = `
    SELECT
      t.*,
      (c.first_name || ' ' || c.last_name) AS customer_name,
      c.customer_no AS customer_no,
      CASE WHEN t.end_date < ? THEN 1 ELSE 0 END AS is_expired
    FROM ${table} t
    JOIN customers c ON c.id = t.customer_id
    ${where.length ? "WHERE " + where.join(" AND ") : ""}
    ORDER BY ${orderBy}
    LIMIT ? OFFSET ?
  `;
  params.unshift(today);
  params.push(limit, offset);

  const { results } = await env.DB.prepare(sql).bind(...params).all();
  return json({ ok: true, items: results || [], limit, offset, today });
}

async function serviceCreate(env, request, table) {
  const body = await readJson(request);
  if (!body) return json({ ok: false, error: "INVALID_JSON" }, 400);

  const id = uuid();
  const customer_id = String(body.customer_id || "").trim();
  if (!customer_id) return json({ ok: false, error: "CUSTOMER_REQUIRED" }, 400); // PDF: tahsis zorunlu

  const domain_name = String(body.domain_name || "").trim();
  const paid_amount = Number(body.paid_amount || 0);
  const start_date = String(body.start_date || "").trim();
  const end_date = String(body.end_date || "").trim() || addOneYear(start_date);

  if (!domain_name) return json({ ok: false, error: "DOMAIN_REQUIRED" }, 400);
  if (!isIsoDate(start_date)) return json({ ok: false, error: "INVALID_START_DATE" }, 400);
  if (!isIsoDate(end_date)) return json({ ok: false, error: "INVALID_END_DATE" }, 400);

  const common = {
    id,
    customer_id,
    domain_name,
    paid_amount: Number.isFinite(paid_amount) ? paid_amount : 0,
    start_date,
    end_date,
    renewal_count: Number(body.renewal_count || 0) || 0,
    renewal_dates: body.renewal_dates ? String(body.renewal_dates).trim() : "",
    description: body.description ? String(body.description) : null,
    status: body.status === 0 || body.status === "0" || body.status === false ? 0 : 1,
  };

  if (table === "domains") {
    const ns1 = body.ns1 ? String(body.ns1) : null;
    const ns2 = body.ns2 ? String(body.ns2) : null;

    await env.DB.prepare(`
      INSERT INTO domains(id, customer_id, domain_name, paid_amount, start_date, end_date, ns1, ns2, renewal_count, renewal_dates, description, status)
      VALUES(?,?,?,?,?,?,?,?,?,?,?,?)
    `).bind(
      common.id, common.customer_id, common.domain_name, common.paid_amount, common.start_date, common.end_date,
      ns1, ns2, common.renewal_count, common.renewal_dates, common.description, common.status
    ).run();

    return json({ ok: true, item: { ...common, ns1, ns2 } }, 201);
  }

  if (table === "hostings") {
    const ftp_username = body.ftp_username ? String(body.ftp_username) : null;
    const ftp_password = body.ftp_password ? String(body.ftp_password) : null;

    await env.DB.prepare(`
      INSERT INTO hostings(id, customer_id, domain_name, paid_amount, start_date, end_date, ftp_username, ftp_password, renewal_count, renewal_dates, description, status)
      VALUES(?,?,?,?,?,?,?,?,?,?,?,?)
    `).bind(
      common.id, common.customer_id, common.domain_name, common.paid_amount, common.start_date, common.end_date,
      ftp_username, ftp_password, common.renewal_count, common.renewal_dates, common.description, common.status
    ).run();

    return json({ ok: true, item: { ...common, ftp_username, ftp_password } }, 201);
  }

  if (table === "ssls") {
    const url = body.url ? String(body.url) : null;

    await env.DB.prepare(`
      INSERT INTO ssls(id, customer_id, domain_name, url, paid_amount, start_date, end_date, renewal_count, renewal_dates, description, status)
      VALUES(?,?,?,?,?,?,?,?,?,?,?)
    `).bind(
      common.id, common.customer_id, common.domain_name, url, common.paid_amount, common.start_date, common.end_date,
      common.renewal_count, common.renewal_dates, common.description, common.status
    ).run();

    return json({ ok: true, item: { ...common, url } }, 201);
  }

  return json({ ok: false, error: "INVALID_TABLE" }, 400);
}

async function serviceGet(env, id, table) {
  const item = await env.DB.prepare(`SELECT * FROM ${table} WHERE id=?`).bind(id).first();
  if (!item) return json({ ok: false, error: "NOT_FOUND" }, 404);

  const customer = await env.DB.prepare("SELECT * FROM customers WHERE id=?").bind(item.customer_id).first();
  return json({ ok: true, item, customer });
}

async function serviceUpdate(env, id, request, table) {
  const body = await readJson(request);
  if (!body) return json({ ok: false, error: "INVALID_JSON" }, 400);

  const existing = await env.DB.prepare(`SELECT id FROM ${table} WHERE id=?`).bind(id).first();
  if (!existing) return json({ ok: false, error: "NOT_FOUND" }, 404);

  const fields = [];
  const params = [];
  const set = (k, v) => {
    fields.push(`${k}=?`);
    params.push(v);
  };

  if (body.customer_id != null) set("customer_id", String(body.customer_id));
  if (body.domain_name != null) set("domain_name", String(body.domain_name));
  if (body.paid_amount != null) set("paid_amount", Number(body.paid_amount));
  if (body.start_date != null) set("start_date", String(body.start_date));
  if (body.end_date != null) set("end_date", String(body.end_date));
  if (body.renewal_count != null) set("renewal_count", Number(body.renewal_count));
  if (body.renewal_dates !== undefined) set("renewal_dates", body.renewal_dates ? String(body.renewal_dates).trim() : "");
  if (body.description !== undefined) set("description", body.description ? String(body.description) : null);
  if (body.status !== undefined) set("status", body.status === 0 || body.status === "0" || body.status === false ? 0 : 1);

  if (table === "domains") {
    if (body.ns1 !== undefined) set("ns1", body.ns1 ? String(body.ns1) : null);
    if (body.ns2 !== undefined) set("ns2", body.ns2 ? String(body.ns2) : null);
  }
  if (table === "hostings") {
    if (body.ftp_username !== undefined) set("ftp_username", body.ftp_username ? String(body.ftp_username) : null);
    if (body.ftp_password !== undefined) set("ftp_password", body.ftp_password ? String(body.ftp_password) : null);
  }
  if (table === "ssls") {
    if (body.url !== undefined) set("url", body.url ? String(body.url) : null);
  }

  if (!fields.length) return json({ ok: true });

  params.push(id);
  await env.DB.prepare(`UPDATE ${table} SET ${fields.join(", ")} WHERE id=?`).bind(...params).run();
  return json({ ok: true });
}

async function serviceDelete(env, id, table) {
  const r = await env.DB.prepare(`DELETE FROM ${table} WHERE id=?`).bind(id).run();
  if (!r.success) return json({ ok: false, error: "DELETE_FAILED" }, 400);
  return json({ ok: true });
}

async function listExpiring(env, table, start, end) {
  const sql = `
    SELECT
      t.*,
      (c.first_name || ' ' || c.last_name) AS customer_name,
      c.customer_no AS customer_no
    FROM ${table} t
    JOIN customers c ON c.id = t.customer_id
    WHERE t.end_date BETWEEN ? AND ?
    ORDER BY t.end_date ASC
  `;
  const { results } = await env.DB.prepare(sql).bind(start, end).all();
  return (results || []).map((r) => ({ ...r, service_type: table }));
}

// ---------- Incomes/Expenses ----------
async function simpleList(env, url, table) {
  const start = url.searchParams.get("start");
  const end = url.searchParams.get("end");
  const where = [];
  const params = [];
  if (isIsoDate(start)) {
    where.push("date >= ?");
    params.push(start);
  }
  if (isIsoDate(end)) {
    where.push("date <= ?");
    params.push(end);
  }
  const sql = `SELECT * FROM ${table} ${where.length ? "WHERE " + where.join(" AND ") : ""} ORDER BY date DESC`;
  const { results } = await env.DB.prepare(sql).bind(...params).all();
  return json({ ok: true, items: results || [] });
}

async function simpleCreate(env, request, table) {
  const body = await readJson(request);
  if (!body) return json({ ok: false, error: "INVALID_JSON" }, 400);
  const id = uuid();
  const date = String(body.date || "").trim();
  const description = String(body.description || "").trim();
  const amount = Number(body.amount || 0);
  if (!isIsoDate(date) || !description || !Number.isFinite(amount)) return json({ ok: false, error: "INVALID_FIELDS" }, 400);

  await env.DB.prepare(`INSERT INTO ${table}(id,date,description,amount) VALUES(?,?,?,?)`).bind(id, date, description, amount).run();
  return json({ ok: true, item: { id, date, description, amount } }, 201);
}

async function simpleGet(env, id, table) {
  const item = await env.DB.prepare(`SELECT * FROM ${table} WHERE id=?`).bind(id).first();
  if (!item) return json({ ok: false, error: "NOT_FOUND" }, 404);
  return json({ ok: true, item });
}

async function simpleUpdate(env, id, request, table) {
  const body = await readJson(request);
  if (!body) return json({ ok: false, error: "INVALID_JSON" }, 400);

  const existing = await env.DB.prepare(`SELECT id FROM ${table} WHERE id=?`).bind(id).first();
  if (!existing) return json({ ok: false, error: "NOT_FOUND" }, 404);

  const fields = [];
  const params = [];
  const set = (k, v) => {
    fields.push(`${k}=?`);
    params.push(v);
  };

  if (body.date != null) set("date", String(body.date));
  if (body.description != null) set("description", String(body.description));
  if (body.amount != null) set("amount", Number(body.amount));

  if (!fields.length) return json({ ok: true });

  params.push(id);
  await env.DB.prepare(`UPDATE ${table} SET ${fields.join(", ")} WHERE id=?`).bind(...params).run();
  return json({ ok: true });
}

async function simpleDelete(env, id, table) {
  const r = await env.DB.prepare(`DELETE FROM ${table} WHERE id=?`).bind(id).run();
  if (!r.success) return json({ ok: false, error: "DELETE_FAILED" }, 400);
  return json({ ok: true });
}


