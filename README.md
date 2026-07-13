# Freedoom: Phase 1 (Doom-engine) — Ato game capsule

A static-web "click and play" capsule for [Ato](https://ato.run): a Dockerfile
that serves a browser emulator + the game's freely-licensed ROM/WAD. Emulation
runs client-side (WebAssembly).

License: BSD-3 game data (Freedoom) + GPL-2.0 engine (Chocolate Doom WASM). Full attributions in `site/licenses/`.
The ROM/WAD is NOT stored here — the Dockerfile fetches it at build time from the
author's official distribution point and verifies its checksum.

Not affiliated with, endorsed by, or connected to Nintendo / id Software / Bethesda.
