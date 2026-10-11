# Style

Vanilla Rails, 37signals/omakase house style. Read this before writing Ruby.

## Architecture

- **Thin controllers, rich models.** Controllers call intention-revealing model methods
  (`account.grant_pro!`); they don't orchestrate logic. Behavior lives on the model, composed of small
  concerns namespaced under it (`Account::Billable` in `app/models/account/billable.rb`).
- **Services are boundaries, not a logic dumping ground.** A class earns a place in `app/services/`
  only as an external adapter (`Billing`, `KitTagger`, `OpenRouterClient`, `ApifyClient`) — never
  because a model method felt big.
- **CRUD-only controllers.** When an action doesn't map to a standard REST verb, introduce a new
  resource instead of a custom action (`resource :subscription` → `SubscriptionsController#create`).
- **`_later` / `_now` jobs.** The model enqueues via `x_later`; the shallow job's `perform` calls `x_now`.

## Ruby

- Omakase via `rubocop-rails-omakase`: double quotes, `params.expect`, two-space indent.
- Method order: class methods → public (`initialize` first) → private. Order by invocation flow.
- **No blank line under `private`, and indent the methods beneath it** (the 37signals tell).
- Prefer expanded conditionals over guard clauses, except an early return at the very top of a method.
- `!` only when there's a non-bang counterpart; not just to flag a destructive action.
- snake_case files/methods, CamelCase classes/modules.

## Hotwire / JS

- Prefer `turbo_stream` over full reloads. Keep Stimulus controllers small; `const` by default.

## Tests

- Minitest + fixtures + Capybara system tests. No RSpec/FactoryBot.
- Don't ship a behavior change without at least one covering test.
- Tests run on SQLite (dev/test) — nothing to set up; just `bin/rails test`.

## Integrations

- Every integration is **idle until keyed**: read its ENV key, and no-op (or log a warning and return
  nil) when it's absent, so the app always boots and runs. Update `.env.example` whenever you add a key.
