## Code style

- Prefer functional style: enumerable / array methods (`map`, `filter`, `reduce`) over manual loops.
- Favor immutability — return new values rather than mutating arguments.
- Write pure functions where possible; isolate side effects (I/O, DB, network) behind clear boundaries.
- Use a class only when an instance has identity, lifecycle, or mutable state. Otherwise use a module of pure functions. A class whose methods are all static (`self.foo`) is a module wearing pants.
- Default to composition — pass collaborators ("has-a") rather than inheriting from a parent ("is-a"). For shared _shape_, use an interface, structural type, or duck typing. Reserve inheritance for genuine "is-a" with shared _implementation_, or framework-mandated parents (`ApplicationRecord`, `Sidekiq::Worker`, custom `Error` subclasses).
- Don't use thrown exceptions for control flow — return an explicit result type, or follow the pattern this repo already uses. Reserve `throw` / `raise` for truly exceptional circumstances: programmer errors, unrecoverable state, framework-level boundaries.

### Dependency injection

Don't construct or reach for collaborators inside a function or class — accept them as constructor or function parameters, typed as the **smallest interface** that captures what the function actually uses (`Emailer` with a `send` method, not `SendgridEmailService` with its 40-method API). Wire concrete implementations at the **application edge** — `main`, the entry point, a composition root.

**Smell:** a function or class taking 8+ dependencies is doing too much — split it.

**Exempt:** framework globals that ship first-class test seams — Rails `ActiveRecord` (`User.find`, `user.save`), `ActionMailer` (`UserMailer.welcome(user).deliver_later`), `ActiveJob`. The test database, `ActionMailer::TestHelper`, and `perform_enqueued_jobs` already provide the seam DI exists to create, so calling them in place costs none of the testability or swappability the rule protects. The rule still binds collaborators that lack such a seam: third-party clients (`Stripe::Client`, an HTTP or S3 SDK) and this repo's own service objects — inject those.
