## Comments and documentation

**The default is no comment.** Names, types, and structure carry the meaning; when they don't, fix them rather than explain them. Delete the comment and read the code cold: if the intent is still recoverable, it stays deleted. Keep only a _why_ the code can't show — a non-local constraint, an external quirk, a deliberate tradeoff, a safety invariant — and put it at the line it explains, not in a header.

Never: a restatement of the code (appending "so that…" doesn't rescue it), types the type system already states, or history ("was X, now Y").

Documentation lives in the guides, not in comments. What a signature can't express — what a method raises, ordering guarantees, what an implementer must honour — is documented there.
