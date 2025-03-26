#!/usr/bin/env bash

base_dir=$(dirname "$0")
root_dir=$(realpath "${base_dir}/..")

echo "Clean all firmwares"

for dir in "${root_dir}/examples/"*/; do
  if [ -f "${dir}build.zig" ]; then
    echo "Clean: ${dir}"
    (cd "${dir}" && rm -rf .zig-cache zig-out)
  fi
done

echo "Clean all tools"

for dir in "${root_dir}/tools/"*/; do
  if [ -f "${dir}build.zig" ]; then
    echo "Clean: ${dir}"
    (cd "${dir}" && rm -rf .zig-cache zig-out)
  fi
done
