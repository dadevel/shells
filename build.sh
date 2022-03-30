#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

declare -A vars=()
for item in "$@"; do
    IFS='=' read -r key value <<< "${item}"
    vars[${key}]="${value}"
done

find . ! -path ./build.sh ! -path './.git/*' -type f | fzf | while read -r path; do
    text="$(< "${path}")"
    for key in "${!vars[@]}"; do
        value="${vars[${key}]}"
        text="${text//§${key}§/${value}}"
    done
    undefined="$(echo "${text}" | grep -Eo '§[A-Z]+§|$' | sed 's|^§||;s|§$||;' | sort | uniq | paste -sd ,)"
    if [[ -n "${undefined}" ]]; then
        echo "undefined variable: ${undefined}" >&2
        exit 1
    fi
    echo "${text}"
done
