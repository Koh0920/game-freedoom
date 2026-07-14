# Freedoom: Phase 1 as a static web capsule.
# Data: Freedoom WADs (BSD-3-Clause). Engine: cloudflare/doom-wasm
# (Chocolate Doom, GPL-2.0) built from a pinned commit with emscripten.
# The WAD is fetched at page load (createPreloadedFile) - no id Software data.
FROM emscripten/emsdk:3.1.28@sha256:5637bba16c0ff5de29ad35d777e32689f3cf66821047231c7ae3987575c8c662 AS engine
RUN apt-get update && apt-get install -y --no-install-recommends \
      automake autoconf libtool pkg-config python3 && rm -rf /var/lib/apt/lists/*
RUN git clone https://github.com/cloudflare/doom-wasm.git /doom \
 && cd /doom \
 && git checkout --detach 65e0d3ae2ffa604155eebd96ed40da6567bd08f4 \
 && test "$(git rev-parse HEAD)" = "65e0d3ae2ffa604155eebd96ed40da6567bd08f4"
RUN cd /doom && bash scripts/build.sh && ls -la src/websockets-doom.*

FROM alpine:3.20@sha256:d9e853e87e55526f6b2917df91a2115c36dd7c696a35be12163d44e6e2a4b6bc AS wad
RUN apk add --no-cache curl unzip
RUN curl -fsSL -o freedoom.zip https://github.com/freedoom/freedoom/releases/download/v0.13.0/freedoom-0.13.0.zip \
 && echo "3f9b264f3e3ce503b4fb7f6bdcb1f419d93c7b546f4df3e874dd878db9688f59  freedoom.zip" | sha256sum -c - \
 && unzip -q freedoom.zip

FROM python:3.12-alpine@sha256:6d43704baacd1bfbe7c295d7f13079d5d8104ed33568873133f8fc69980419df
COPY site/ /www/
COPY default.cfg /www/default.cfg
COPY --from=engine /doom/src/websockets-doom.js /www/websockets-doom.js
COPY --from=engine /doom/src/websockets-doom.wasm /www/websockets-doom.wasm
COPY --from=wad /freedoom-0.13.0/freedoom1.wad /www/freedoom1.wad
COPY --from=wad /freedoom-0.13.0/COPYING.txt /www/licenses/FREEDOOM-COPYING.txt
COPY --from=wad /freedoom-0.13.0/CREDITS.txt /www/licenses/FREEDOOM-CREDITS.txt
COPY --from=engine /doom/COPYING.md /www/licenses/DOOM-WASM-GPL-2.0.md
EXPOSE 8080
CMD ["python","-m","http.server","8080","--directory","/www","--bind","0.0.0.0"]
