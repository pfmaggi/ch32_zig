#!/usr/bin/env bash

echo "Build all firmwares"

for dir in */; do
  if [ -f "${dir}build.zig" ]; then
    echo "Building: ${dir}"
    (cd "${dir}" && zig build --release=small)
  fi
done

echo "Build all tools"

for dir in tools/*/; do
  if [ -f "${dir}build.zig" ]; then
    echo "Building: ${dir}"
    (cd "${dir}" && zig build)
  fi
done
