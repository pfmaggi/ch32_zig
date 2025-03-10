#!/usr/bin/env bash

echo "Clean all firmwares"

for dir in basic/*/; do
  if [ -f "${dir}build.zig" ]; then
    echo "Clean: ${dir}"
    (cd "${dir}" && rm -rf .zig-cache zig-out)
  fi
done

echo "Clean all tools"

for dir in tools/*/; do
  if [ -f "${dir}build.zig" ]; then
    echo "Clean: ${dir}"
    (cd "${dir}" && rm -rf .zig-cache zig-out)
  fi
done
