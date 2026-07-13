# Freedoom: Phase 1 as a static web capsule.
# Data: Freedoom WADs (BSD-3-Clause). Engine: cloudflare/doom-wasm
# (Chocolate Doom, GPL-2.0) built from a pinned commit with emscripten.
# The WAD is fetched at page load (createPreloadedFile) - no id Software data.
FROM emscripten/emsdk:3.1.28 AS engine
RUN apt-get update && apt-get install -y --no-install-recommends \
      automake autoconf libtool pkg-config python3 && rm -rf /var/lib/apt/lists/*
RUN git clone https://github.com/cloudflare/doom-wasm.git /doom \
 && cd /doom && git checkout 65e0d3ae2ffa0d5b724cece5a9114b13c6cd5643 || git checkout 65e0d3ae2ffa
RUN cd /doom && bash scripts/build.sh && ls -la src/websockets-doom.*

FROM alpine:3.20 AS wad
RUN apk add --no-cache curl unzip
RUN curl -fsSL -o freedoom.zip https://github.com/freedoom/freedoom/releases/download/v0.13.0/freedoom-0.13.0.zip \
 && echo "3f9b264f3e3ce503b4fb7f6bdcb1f419d93c7b546f4df3e874dd878db9688f59  freedoom.zip" | sha256sum -c - \
 && unzip -q freedoom.zip

FROM python:3.12-alpine
COPY site/ /www/
COPY default.cfg /www/default.cfg
COPY --from=engine /doom/src/websockets-doom.js /www/websockets-doom.js
COPY --from=engine /doom/src/websockets-doom.wasm /www/websockets-doom.wasm
COPY --from=wad /freedoom-0.13.0/freedoom1.wad /www/freedoom1.wad
COPY --from=wad /freedoom-0.13.0/COPYING.txt /www/licenses/FREEDOOM-COPYING.txt
COPY --from=wad /freedoom-0.13.0/CREDITS.txt /www/licenses/FREEDOOM-CREDITS.txt
EXPOSE 8080
CMD ["python","-m","http.server","8080","--directory","/www","--bind","0.0.0.0"]
