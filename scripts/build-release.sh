#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="${PROJECT_DIR}/build"
OUTPUT_DIR="${BUILD_DIR}/output"
ZIP_FILE="${BUILD_DIR}/AggregateVolumeMenu.zip"

mkdir -p "${BUILD_DIR}"

xcodebuild clean build \
  -project "${PROJECT_DIR}/AggregateVolumeMenu.xcodeproj" \
  -scheme "AggregateVolumeMenu" \
  -configuration "Release" \
  -derivedDataPath "${BUILD_DIR}/derivedData" \
  CONFIGURATION_BUILD_DIR="${OUTPUT_DIR}"

(
  cd "${OUTPUT_DIR}"
  zip -qry "${ZIP_FILE}" "AggregateVolumeMenu.app"
)

shasum -a 256 "${ZIP_FILE}" >"${ZIP_FILE}.sha256"
cat "${ZIP_FILE}.sha256"
