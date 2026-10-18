#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

if [ "${1:-}" = "--lint" ]; then
	echo "Checking Swift formatting..."
	xcrun swift-format lint --strict --parallel --recursive "${PROJECT_DIR}/AggregateDeviceVolume"
else
	echo "Applying Swift formatting in-place..."
	xcrun swift-format format --in-place --parallel --recursive "${PROJECT_DIR}/AggregateDeviceVolume"
fi
