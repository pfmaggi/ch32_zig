#!/usr/bin/env bash

base_dir=$(dirname "$0")
root_dir=$(realpath "${base_dir}/..")

echo "Build all firmwares"

for dir in "${root_dir}/examples/"*/; do
  if [ -f "${dir}build.zig" ]; then
    echo "Building: ${dir}"
    (cd "${dir}" && zig build)
  fi
done

echo "Build all tools"

for dir in "${root_dir}/tools/"*/; do
  if [ -f "${dir}build.zig" ]; then
    echo "Building: ${dir}"
    (cd "${dir}" && zig build)
  fi
done
