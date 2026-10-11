# builders-starter

A lean, production-shaped **Rails 8** starter for shipping a product fast — passwordless auth,
multi-tenant-ready accounts, subscription billing, transactional email, and a marketing funnel.
Every integration is **wired but idle until you add its key**, so the app runs the moment you clone it.

Rails 8.1 · Ruby 3.4 · Hotwire · Tailwind v4 · SQLite (dev) / PostgreSQL (prod) · Solid Queue/Cache/Cable · Kamal.

> **Prerequisites (one-time, per machine):** Ruby 3.4 and [Claude Code](https://claude.com/claude-code).
> No database to install — development runs on SQLite. Once those are set up, every project is
> `git clone` → `bin/setup` → `bin/dev`.

## Quick start

```bash
bin/setup     # installs deps, sets up your .env, prepares the database
bin/dev       # http://localhost:3100
```

That's it — `bin/dev` works on a fresh clone with no keys at all. Sign in at `/session/new`: it
emails a 6-digit code (in development the code is printed to the log and the email opens in your
browser).

## Secrets

Every key is optional — the app boots without any, each integration just stays off until you add
its key. See `.env.example` for the full list and where to get each one.

- **Local `.env`** (default) — copy `.env.example` → `.env`, fill in what you need. Loaded
  automatically by `bin/dev`. Nothing to install.
- **Doppler** (for teams) — no secrets on disk, syncs local → prod, and can feed your AI coding
  agent too. Run the app *through* Doppler, explicitly:

  ```bash
  doppler setup                 # one-time: link this repo to a Doppler project
  doppler run -- bin/dev        # the app gets your keys
  doppler run -- claude         # your agent gets them too
  ```

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
