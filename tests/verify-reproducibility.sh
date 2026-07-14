#!/bin/sh
set -eu

fail() {
  printf 'verification failed: %s\n' "$1" >&2
  exit 1
}

expect_in() {
  grep -F -- "$1" "$2" >/dev/null || fail "$2 is missing: $1"
}

from_count=$(grep -c '^FROM ' Dockerfile)
pinned_from_count=$(grep -Ec '^FROM [^ ]+@sha256:[0-9a-f]{64}( AS [[:alnum:]_.-]+)?$' Dockerfile)
[ "$from_count" -eq 3 ] || fail "expected 3 build stages"
[ "$pinned_from_count" -eq "$from_count" ] || fail "every base image must use a sha256 digest"
[ "$(grep -c 'sha256sum -c -' Dockerfile)" -eq 1 ] || fail "expected the WAD archive checksum check"

expect_in 'emscripten/emsdk:3.1.28@sha256:5637bba16c0ff5de29ad35d777e32689f3cf66821047231c7ae3987575c8c662' Dockerfile
expect_in 'UBUNTU_SNAPSHOT=20260701T000000Z' Dockerfile
expect_in 'https://snapshot.ubuntu.com/ubuntu/${UBUNTU_SNAPSHOT} jammy main' Dockerfile
expect_in 'automake=1:1.16.5-1.3' Dockerfile
expect_in 'autoconf=2.71-2' Dockerfile
expect_in 'libtool=2.4.6-15build2' Dockerfile
expect_in 'pkg-config=0.29.2-1ubuntu3' Dockerfile
if grep -E 'https?://(archive|security)\.ubuntu\.com' Dockerfile >/dev/null; then
  fail "live Ubuntu repositories must not replace the pinned snapshot"
fi
expect_in 'alpine:3.20@sha256:d9e853e87e55526f6b2917df91a2115c36dd7c696a35be12163d44e6e2a4b6bc' Dockerfile
expect_in 'python:3.12-alpine@sha256:6d43704baacd1bfbe7c295d7f13079d5d8104ed33568873133f8fc69980419df' Dockerfile
expect_in 'git checkout --detach 65e0d3ae2ffa604155eebd96ed40da6567bd08f4' Dockerfile
expect_in 'test "$(git rev-parse HEAD)" = "65e0d3ae2ffa604155eebd96ed40da6567bd08f4"' Dockerfile
if grep -F -- '|| git checkout' Dockerfile >/dev/null; then
  fail "git checkout fallback must not bypass the pinned commit"
fi
expect_in '3f9b264f3e3ce503b4fb7f6bdcb1f419d93c7b546f4df3e874dd878db9688f59  freedoom.zip' Dockerfile
expect_in '/www/licenses/DOOM-WASM-GPL-2.0.md' Dockerfile
expect_in 'noInitialRun: true' site/index.html
expect_in 'onRuntimeInitialized:' site/index.html
expect_in 'callMain(commonArgs)' site/index.html
expect_in 'href="DOOM-WASM-GPL-2.0.md"' site/licenses/index.html

printf 'reproducibility checks passed\n'
