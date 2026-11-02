# NixOS

* Read existing config and follow its patterns before changing anything.
* Reuse existing modules, options, variables, aliases, scripts, and tooling.
* Use my aliases and shell functions when applicable instead of recreating commands.
* Never put any comments in the code and if you find any, remove them from the code.
* Do not invent NixOS options, package names, attributes, or APIs. Verify uncertain details.
* Keep changes minimal and avoid unrelated refactors.
* Prefer the existing flake/module structure; do not introduce architectural changes without need.
* Validate changes before applying them.
* Test changes on the live system when reasonably safe and practical.
* Prefer `nixtest` before `nixall/nixos/nixup` when testing a system change.
* Verify actual runtime behavior, not just successful evaluation/builds.
* Inspect logs and service state when relevant.
* Never claim a change works unless it was actually tested.
* Preserve uncommitted user changes.
* Do not commit, revert, reset, stash, reboot, garbage-collect, or remove generations unless explicitly requested.
* Never expose or hardcode secrets.
