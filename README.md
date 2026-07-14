# Freedoom: Phase 1 (Doom-engine) — Ato game capsule

A static-web "click and play" capsule for [Ato](https://ato.run): a Dockerfile
that serves a browser emulator + the game's freely-licensed WAD. Emulation runs
client-side (WebAssembly).

License: BSD-3 game data (Freedoom) + GPL-2.0 engine (Chocolate Doom WASM). Full
attributions in `site/licenses/`.

The WAD is NOT stored here. The Dockerfile fetches Freedoom v0.13.0 from the
project's GitHub release and verifies SHA-256
`3f9b264f3e3ce503b4fb7f6bdcb1f419d93c7b546f4df3e874dd878db9688f59`.

The engine is built from cloudflare/doom-wasm commit
`65e0d3ae2ffa604155eebd96ed40da6567bd08f4`; checkout is detached and its
resolved HEAD is checked before the build. All Docker base images are pinned by
immutable digest. Build-only autotools come from the HTTPS Ubuntu snapshot
`20260701T000000Z` with exact package versions, so a failed live mirror cannot
silently leave the build without candidates. The page sets
`Module.noInitialRun = true` and starts the engine only from
`onRuntimeInitialized`, after preloaded files are ready. It preserves the pinned
upstream browser launch contract's `-nomusic` flag so SDL music initialization
cannot block startup. The capsule ships the doom-wasm/Chocolate Doom GPL-2.0
text alongside the Freedoom license and credits.

Run `tests/verify-reproducibility.sh` for the repository's static supply-chain
and startup-contract checks.

Not affiliated with, endorsed by, or connected to Nintendo / id Software / Bethesda.
