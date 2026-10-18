#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

killall "Aggregate Device Volume" 2>/dev/null || true
rm -rf "${PROJECT_DIR}/build" "${PROJECT_DIR}/DerivedData"
