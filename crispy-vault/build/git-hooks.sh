#!/bin/bash

# Git integration helper for the Crispy Kitsune versioned build system
# Provides subcommands for validation, release commits, and hook setup

set -e

VAULT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSIONS_FILE="${VAULT_ROOT}/versions.json"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# ============================================================================
# VALIDATE SUBCOMMAND
# ============================================================================
validate() {
  echo "Validating versions.json..."

  if [[ ! -f "$VERSIONS_FILE" ]]; then
    echo -e "${RED}✗ versions.json not found at: $VERSIONS_FILE${NC}"
    return 1
  fi

  # Check if file is valid JSON
  if ! jq empty "$VERSIONS_FILE" 2>/dev/null; then
    echo -e "${RED}✗ versions.json is not valid JSON${NC}"
    jq . "$VERSIONS_FILE" 2>&1 | head -20
    return 1
  fi

  # Check for required top-level fields
  local required_fields=("metadata" "production" "build" "layers" "releases")
  local missing_fields=()

  for field in "${required_fields[@]}"; do
    if ! jq -e ".$field" "$VERSIONS_FILE" > /dev/null 2>&1; then
      missing_fields+=("$field")
    fi
  done

  if [[ ${#missing_fields[@]} -gt 0 ]]; then
    echo -e "${RED}✗ versions.json is missing required fields: ${missing_fields[*]}${NC}"
    return 1
  fi

  echo -e "${GREEN}✓ versions.json is valid and has all required fields${NC}"
  return 0
}

# ============================================================================
# COMMIT-RELEASE SUBCOMMAND
# ============================================================================
commit_release() {
  local tag="$1"

  if [[ -z "$tag" ]]; then
    echo -e "${RED}✗ TAG argument required${NC}"
    echo "Usage: ./git-hooks.sh commit-release TAG"
    return 1
  fi

  echo "Preparing release commit for tag: $tag"

  # Verify versions.json is valid
  if ! validate; then
    echo -e "${RED}✗ Cannot commit: versions.json validation failed${NC}"
    return 1
  fi

  # Check if release directory exists
  local release_dir="${VAULT_ROOT}/releases/${tag}"
  if [[ ! -d "$release_dir" ]]; then
    echo -e "${YELLOW}⚠ Warning: releases/${tag}/ directory does not exist${NC}"
  fi

  # Stage versions.json
  git -C "$VAULT_ROOT" add versions.json
  echo "Staged: versions.json"

  # Stage all _overview.md files in stack/
  if [[ -d "${VAULT_ROOT}/stack" ]]; then
    local overview_files=$(find "${VAULT_ROOT}/stack" -name "_overview.md" 2>/dev/null || true)
    if [[ -n "$overview_files" ]]; then
      git -C "$VAULT_ROOT" add $overview_files
      echo "Staged: layer overview files"
    fi
  fi

  # Stage release directory
  if [[ -d "$release_dir" ]]; then
    git -C "$VAULT_ROOT" add "releases/${tag}/"
    echo "Staged: releases/${tag}/"
  fi

  # Commit with specified user
  echo "Creating commit..."
  git -C "$VAULT_ROOT" \
    -c user.name="FancyKat" \
    -c user.email="paumar559@gmail.com" \
    commit -m "build: release ${tag}"

  echo -e "${GREEN}✓ Release commit created for tag: ${tag}${NC}"
  return 0
}

# ============================================================================
# SETUP-HOOKS SUBCOMMAND
# ============================================================================
setup_hooks() {
  echo "Setting up git hooks..."

  local hooks_dir="${VAULT_ROOT}/.git/hooks"
  local pre_commit_hook="${hooks_dir}/pre-commit"

  if [[ ! -d "$hooks_dir" ]]; then
    echo -e "${RED}✗ .git/hooks directory not found. Is this a git repository?${NC}"
    return 1
  fi

  # Create pre-commit hook script
  cat > "$pre_commit_hook" << 'HOOK_EOF'
#!/bin/bash
# Pre-commit hook: validate versions.json before committing

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
VALIDATE_SCRIPT="${SCRIPT_DIR}/build/git-hooks.sh"

if [[ ! -f "$VALIDATE_SCRIPT" ]]; then
  echo "Error: git-hooks.sh not found at $VALIDATE_SCRIPT"
  exit 1
fi

"$VALIDATE_SCRIPT" validate
exit $?
HOOK_EOF

  chmod +x "$pre_commit_hook"
  echo -e "${GREEN}✓ Pre-commit hook installed at: ${pre_commit_hook}${NC}"
  echo "   Validates versions.json before each commit"
  return 0
}

# ============================================================================
# CHECK-NOTES SUBCOMMAND
# ============================================================================
check_notes() {
  echo "Checking for modified stack files since last build..."

  if [[ ! -f "$VERSIONS_FILE" ]]; then
    echo -e "${RED}✗ versions.json not found${NC}"
    return 1
  fi

  # Extract last build timestamp
  local last_build_timestamp=$(jq -r '.build.last_build // empty' "$VERSIONS_FILE")

  if [[ -z "$last_build_timestamp" ]]; then
    echo -e "${YELLOW}⚠ No last_build timestamp found in versions.json${NC}"
    echo "Showing all stack files:"
  else
    echo "Last build: $last_build_timestamp"
    echo ""
  fi

  # Find modified files in stack/ (excluding _overview.md)
  local declare -A modified_by_layer

  if [[ -d "${VAULT_ROOT}/stack" ]]; then
    while IFS= read -r file; do
      # Skip _overview.md files
      if [[ "$file" == *"_overview.md" ]]; then
        continue
      fi

      # Check if file is newer than last_build (if available)
      if [[ -n "$last_build_timestamp" ]]; then
        local file_mtime=$(stat -f %Sm -t "%Y-%m-%dT%H:%M:%SZ" "$file" 2>/dev/null || date -d @$(stat -c %Y "$file") +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || echo "")
        if [[ -z "$file_mtime" ]] || [[ "$file_mtime" < "$last_build_timestamp" ]]; then
          continue
        fi
      fi

      # Extract layer name from path (stack/LAYER/file.md)
      local layer=$(basename $(dirname "$file"))
      if [[ -z "${modified_by_layer[$layer]}" ]]; then
        modified_by_layer[$layer]="$file"
      else
        modified_by_layer[$layer]="${modified_by_layer[$layer]}"$'\n'"$file"
      fi
    done < <(find "${VAULT_ROOT}/stack" -type f -name "*.md" 2>/dev/null)
  fi

  # Display results
  if [[ ${#modified_by_layer[@]} -eq 0 ]]; then
    echo -e "${GREEN}✓ No modified files found${NC}"
    return 0
  fi

  echo -e "${YELLOW}Modified files by layer:${NC}"
  echo ""

  for layer in $(echo "${!modified_by_layer[@]}" | tr ' ' '\n' | sort); do
    echo -e "${GREEN}${layer}:${NC}"
    while IFS= read -r file; do
      echo "  - $(basename "$file")"
    done <<< "${modified_by_layer[$layer]}"
  done

  echo ""
  echo -e "${YELLOW}Suggested next build tags:${NC}"
  for layer in $(echo "${!modified_by_layer[@]}" | tr ' ' '\n' | sort); do
    echo "  build: release ${layer}-$(date +%Y%m%d)"
  done

  return 0
}

# ============================================================================
# MAIN
# ============================================================================
main() {
  local command="$1"
  shift || true

  case "$command" in
    validate)
      validate "$@"
      ;;
    commit-release)
      commit_release "$@"
      ;;
    setup-hooks)
      setup_hooks "$@"
      ;;
    check-notes)
      check_notes "$@"
      ;;
    *)
      echo "Git Hooks Helper for Crispy Kitsune Versioning System"
      echo ""
      echo "Usage: $(basename "$0") COMMAND [ARGS]"
      echo ""
      echo "Commands:"
      echo "  validate              Validate versions.json structure and required fields"
      echo "  commit-release TAG    Stage and commit a release with tag"
      echo "  setup-hooks           Install pre-commit hook for validation"
      echo "  check-notes           Show modified files since last build, grouped by layer"
      echo ""
      return 1
      ;;
  esac
}

main "$@"
