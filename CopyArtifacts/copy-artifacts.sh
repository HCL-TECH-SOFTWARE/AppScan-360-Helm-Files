#!/bin/bash
set -euo pipefail

# ==========================================================
# FIXED SOURCE CONFIG
# ==========================================================
SRC_REG="hclcr.io"
SRC_IMAGE_PATH="appscan360/as360-k8s-docker-images"
SRC_HELM_PATH="appscan360/as360-k8s-helm-packages"

# ==========================================================
# DEFAULTS
# ==========================================================
ARTIFACTS_FILE="${ARTIFACTS_FILE:-artifactList.txt}"
INCLUDE_SCA="${includeSCA:-false}"
EXCLUDE_DTCS="${excludeDTCS:-false}"

# ==========================================================
# DETECT CONTAINER ENGINE (docker or podman)
# ==========================================================
if command -v docker >/dev/null 2>&1; then
  ENGINE="docker"
elif command -v podman >/dev/null 2>&1; then
  ENGINE="podman"
else
  echo "❌ Neither docker nor podman is installed."
  exit 1
fi

echo "🔎 Using container engine: $ENGINE"

# ==========================================================
# VALIDATE HELM
# ==========================================================
if ! command -v helm >/dev/null 2>&1; then
  echo "❌ Helm is not installed."
  exit 1
fi

# ==========================================================
# INPUT (Supports both interactive & env mode)
# ==========================================================
DST_REG="${DST_REG:-}"
DST_HELM_REG="${DST_HELM_REG:-}"

if [[ -z "$DST_REG" ]]; then
  read -rp "Enter destination registry for Image Push (example: localhost:5000/as360): " DST_REG
fi

if [[ -z "$DST_HELM_REG" ]]; then
  read -rp "Enter destination registry for Helm Package Push (example: localhost:5000/as360): " DST_HELM_REG
fi

if [[ -z "$DST_REG" || -z "$DST_HELM_REG" ]]; then
  echo "❌ Destination registry values are required."
  exit 1
fi

if [[ ! -f "$ARTIFACTS_FILE" ]]; then
  echo "❌ Artifacts file not found: $ARTIFACTS_FILE"
  exit 1
fi

echo
echo "🚀 Starting artifact copy"
echo "Source Registry            : $SRC_REG"
echo "Destination Image Registry : $DST_REG"
echo "Destination Helm Registry  : $DST_HELM_REG"
echo "Artifacts File             : $ARTIFACTS_FILE"
echo "Include SCA                : $INCLUDE_SCA"
echo "Exclude DTCS               : $EXCLUDE_DTCS"
echo "=========================================================="
echo

# ==========================================================
# PROCESS ARTIFACTS
# ==========================================================
MODE=""

while IFS= read -r line || [[ -n "$line" ]]; do
  line="$(echo "$line" | xargs)"
  [[ -z "$line" || "$line" =~ ^# ]] && continue

  if [[ "$line" == "[IMAGES]" ]]; then
    MODE="IMAGES"
    continue
  fi

  if [[ "$line" == "[HELM]" ]]; then
    MODE="HELM"
    continue
  fi

  COMPONENT="${line%%|*}"
  ENTRY="${line#*|}"

  if [[ "$COMPONENT" == "SCA" && "$INCLUDE_SCA" != "true" ]]; then
    echo "⏭ Skipping SCA artifact (includeSCA not enabled)"
    continue
  fi

  # Skip DTCS if exclude flag enabled
if [[ "$COMPONENT" == "DTCS" && "$EXCLUDE_DTCS" == "true" ]]; then
  echo "⏭ Skipping DTCS artifact (excludeDTCS enabled)"
  continue
fi

  # ----------------------------------------------------------
  # IMAGES
  # ----------------------------------------------------------
  if [[ "$MODE" == "IMAGES" ]]; then
    SRC_IMG="$SRC_REG/$SRC_IMAGE_PATH/$ENTRY"
    DST_IMG="$DST_REG/$ENTRY"

    echo "🖼 Copy image [$COMPONENT]"
    echo "    $SRC_IMG → $DST_IMG"

    $ENGINE pull "$SRC_IMG" || { echo "❌ Pull failed"; continue; }
    $ENGINE tag "$SRC_IMG" "$DST_IMG"
    $ENGINE push "$DST_IMG"

    echo
  fi

  # ----------------------------------------------------------
  # HELM (OCI)
  # ----------------------------------------------------------
  if [[ "$MODE" == "HELM" ]]; then
    CHART="${ENTRY%:*}"
    VERSION="${ENTRY##*:}"

    SRC_CHART="oci://$SRC_REG/$SRC_HELM_PATH/$CHART"
    DST_REPO="oci://$DST_HELM_REG"

    echo "📦 Copy helm [$COMPONENT]"
    echo "    $SRC_CHART:$VERSION → $DST_REPO/$CHART:$VERSION"

    helm pull "$SRC_CHART" \
      --version "$VERSION" \
      --destination /tmp || {
        echo "❌ Helm pull failed"
        continue
      }

    helm push "/tmp/$CHART-$VERSION.tgz" "$DST_REPO" || {
      echo "❌ Helm push failed"
      rm -f "/tmp/$CHART-$VERSION.tgz"
      continue
    }

    rm -f "/tmp/$CHART-$VERSION.tgz"
    echo
  fi

done < "$ARTIFACTS_FILE"

echo "=========================================================="
echo "✅ Artifact copy completed successfully"
