# builders-starter

A lean, production-shaped **Rails 8** starter for shipping a product fast — passwordless auth,
multi-tenant-ready accounts, subscription billing, transactional email, and a marketing funnel.
Every integration is **wired but idle until you add its key**, so the app runs the moment you clone it.

Rails 8.1 · Ruby 3.4 · Hotwire · Tailwind v4 · PostgreSQL · Solid Queue/Cache/Cable · Kamal.

## Quick start

```bash
bin/setup     # installs deps, lets you choose Doppler or a local .env, prepares the database
bin/dev       # http://localhost:3100
```

Sign in at `/session/new` — it emails a 6-digit code (in development the code is printed to the log
and the email opens in your browser).

## Secrets: Doppler (recommended) or .env

Everything is optional. `bin/setup` walks you through two options:

- **Local `.env`** — simplest. Copy `.env.example` → `.env`, fill in what you need. Loaded automatically.
- **Doppler** — no secrets on disk, syncs local → prod, and feeds your AI coding agent too:

  ```bash
  doppler run -- bin/dev        # the app gets your keys
  doppler run -- claude         # your agent gets them too
  ```

See `.env.example` for every key and where to get it. Nothing set? The app still boots — each
integration just stays off.

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

## Commands

```bash
bin/rails test     # Minitest (+ PARALLEL_WORKERS=1 if pg forking misbehaves)
bin/rubocop        # omakase style
bin/rails stripe:setup                      # create the Pro product + price in Stripe
bin/rails "stripe:webhook[https://host]"    # create the webhook, print its signing secret
```

## Deploy

Kamal (`config/deploy.yml`) → any Docker host; the production database config is Supabase-pooler-ready.
Fill in the host/domain/registry and run `kamal setup`.

## Conventions

Read **[AGENTS.md](AGENTS.md)** and **[STYLE.md](STYLE.md)** — vanilla Rails, thin controllers,
rich models, CRUD-only controllers, omakase style.
