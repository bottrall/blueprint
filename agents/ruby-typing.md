## Ruby typing

- Steep runs `D::Ruby.all_error`: every diagnostic is an error. Fix the annotation or the code; never disable a diagnostic in the Steepfile. The only escape is a targeted inline suppression with a comment saying why.
- Annotate every method in `lib/` with rbs-inline doc style: one `# @rbs name: Type` per param plus `# @rbs return: Type`, never the one-line method-type or `#:` method form. Constants and `attr_reader`s rbs-inline can't infer take a trailing `#: Type` on the same line; one on the line above is ignored.
- An `attr_reader`/`attr_writer` needs a `# @dynamic name` line directly above it, or Steep reports `MethodDefinitionMissing`.
- Declare an interface only when different objects satisfy it — two or more implementers, or a contract a consumer implements — or when a boundary forbids naming the one class. When only one class is ever passed, annotate that class; a test fake is not a second implementer.
- `sig/generated/` is written by `bin/generate` from the inline annotations: never hand-edit it, and commit it with the `lib/` change that moved it.
- `sig/manual/` mirrors `lib/` for hand-written signatures rbs-inline can't generate: interfaces, and the `extend self` re-declaration every `extend self` module needs (rbs-inline drops `extend self`). A type alias may instead be declared inline with `# @rbs!` beside the code that uses it.
- `sig/_private/` holds stubs for gaps in stdlib and third-party signatures, one file per gem or library (`open3.rbs`). Check the gem's own RBS and gem_rbs_collection before writing one, and delete the stub once real signatures exist. RBS skips `_`-prefixed directories in library mode, so the stubs never reach projects that install this one.
