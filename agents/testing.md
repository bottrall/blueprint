## Testing

- Every module of behaviour gets a test file, even if it's only a smoke test. A unit with no behaviour — pure constants, data definitions, types — needs no test file.
- Only test what can change. Static code — generated files, constants, trivial accessors — gets at most a smoke test. Generated code is pinned at its generator: test the generator, not each generated output.
- A test file tests only the concerns of the unit it's mapped to. If testing X requires driving Y's entry point, either the behaviour belongs in X's own file with collaborators injected, or Y's file is covering for a missing X test. A behaviour belongs to the unit whose contract it is, even when observing it means calling through an object that unit returns. A composer's tests assert the composer's outcomes only — never a collaborator's branches, which are pinned in the collaborator's own file.
- Order tests the way the code is ordered: they follow the source's structure, and within a routine they follow execution order (validation behaviour first).
- Test all branches in reason: every early return, conditional, and error path gets a test — unless the branch is dead or a programmer-error tripwire.
- One assertion per test: each `it` makes exactly one `assert_*` or `expect`. A test that wants two is two tests.
- Never mock code you own. Don't patch a module, method or import to change what it does (`vi.mock`, `vi.spyOn`, `Minitest::Mock`, `stub`); pass the unit a fake through the parameters it already takes its collaborators by.
