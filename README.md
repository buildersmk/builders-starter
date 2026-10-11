# builders-starter

A lean, production-shaped **Rails 8** starter for shipping a product fast — passwordless auth,
multi-tenant-ready accounts, subscription billing, transactional email, and a marketing funnel.
Every integration is **wired but idle until you add its key**, so the app runs the moment you clone it.

Rails 8.1 · Ruby 3.4 · Hotwire · Tailwind v4 · installable PWA · SQLite (dev) / PostgreSQL (prod) · Solid Queue/Cache/Cable · Kamal.

> **Prerequisites (one-time, per machine):** Ruby 3.4 and [Claude Code](https://claude.com/claude-code).
> No database to install — development runs on SQLite. Once those are set up, every project is
> `git clone` → `bin/setup` → `bin/dev`.

## Quick start

```bash
bin/setup     # installs deps, sets up your .env, prepares the database
bin/dev       # http://localhost:3100
```

That's it — `bin/dev` works on a fresh clone with no keys at all. Open it and you'll land on a
**welcome checklist**; `/guide` is a short, visual how-to. Sign in at `/session/new`: it emails a
6-digit code (in development the code is **shown right on the sign-in page**). The first person to
sign up becomes the owner.

## Secrets

Every key is optional — the app boots without any, each integration just stays off until you add
its key. Copy `.env.example` → `.env` and fill in what you need; it's gitignored and loaded
automatically by `bin/dev`. See `.env.example` for the full list and where to get each one.

> Prefer a secrets manager (e.g. Doppler) for a team? Any tool that injects env vars works —
> run the app through it (`<tool> run -- bin/dev`). Not needed to build solo.

## What's inside

| Area | What |
|---|---|
| **Auth** | Passwordless 6-digit codes (no passwords) |
| **Tenancy** | Account / Identity / User / Session; single-tenant by default, `MULTI_TENANT=true` for subdomain multi-tenancy |
| **Billing** | Stripe subscription — hosted checkout + customer portal + webhook (`bin/rails stripe:setup`) |
| **Email** | Resend over SMTP |
| **Leads** | Kit (ConvertKit) — capture → subscribe + tag |
| **AI** | OpenRouter client (any LLM) |
| **Scraping** | Apify client (sync + async) |
| **PWA** | Installable app — manifest, service worker, offline page, "Add to home screen" |
| **Push** | Self-hosted web push (VAPID) — `bin/rails vapid:generate` |

## Commands

```bash
bin/rails test     # Minitest (runs on SQLite — nothing to set up)
bin/rubocop        # omakase style
bin/rails stripe:setup                      # create the Pro product + price in Stripe
bin/rails "stripe:webhook[https://host]"    # create the webhook, print its signing secret
```

## Deploy

Kamal (`config/deploy.yml`) → any Docker host. In production your **business data** is PostgreSQL
(Supabase-pooler-ready); **jobs, cache and cable** run on SQLite files on a persisted disk volume
(fast, and no remote-DB polling bill). Fill in the host/domain/registry and run `kamal setup`.

## Conventions

Read **[AGENTS.md](AGENTS.md)** and **[STYLE.md](STYLE.md)** — vanilla Rails, thin controllers,
rich models, CRUD-only controllers, omakase style.
