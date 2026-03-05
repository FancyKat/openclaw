#!/bin/bash
#
# Crispy Kitsune Build Orchestrator
# Manages versioned builds, layer tracking, and release generation
#

set -euo pipefail

# ============================================================================
# CONFIGURATION & GLOBALS
# ============================================================================

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Determine VAULT_ROOT (parent of this script's directory)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VAULT_ROOT="$(dirname "$SCRIPT_DIR")"

VERSIONS_FILE="${VAULT_ROOT}/versions.json"
RELEASES_DIR="${VAULT_ROOT}/releases"
DIST_DIR="${VAULT_ROOT}/dist"
BUILD_SCRIPT="${VAULT_ROOT}/build/scripts/build-config.js"

# Track options
LAYERS_TO_BUILD=()
FORCE_BUILD=false
AUTO_DETECT=false
COMMIT_RELEASE=false
PROD_MILESTONE=""
DRY_RUN=false
YES_MODE=false

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

log_info() {
    echo -e "${BLUE}[INFO]${NC} $*" >&2
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $*" >&2
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*" >&2
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

log_section() {
    echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}" >&2
    echo -e "${CYAN}  $*${NC}" >&2
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n" >&2
}

# Check if jq is available
check_jq() {
    if ! command -v jq &> /dev/null; then
        log_error "jq is required but not installed. Install it and try again."
        exit 1
    fi
}

# Validate versions.json exists
validate_versions_file() {
    if [[ ! -f "$VERSIONS_FILE" ]]; then
        log_error "versions.json not found at $VERSIONS_FILE"
        exit 1
    fi
}

# Parse version string "X.Y.Z" into parts
parse_version() {
    local version="$1"
    local major="${version%%.*}"
    local rest="${version#*.}"
    local minor="${rest%%.*}"
    local patch="${rest##*.}"

    echo "$major $minor $patch"
}

# Increment patch version
bump_patch_version() {
    local version="$1"
    local parts=($(parse_version "$version"))
    local major="${parts[0]}"
    local minor="${parts[1]}"
    local patch="${parts[2]}"

    patch=$((patch + 1))
    echo "${major}.${minor}.${patch}"
}

# Get current value from versions.json using jq
get_json_value() {
    local path="$1"
    jq -r "$path" "$VERSIONS_FILE" 2>/dev/null || echo ""
}

# Get all layer names
get_all_layers() {
    jq -r '.layers | keys[]' "$VERSIONS_FILE" | sort
}

# Validate that specified layers exist
validate_layers() {
    local valid_layers=($(get_all_layers))

    for layer in "$@"; do
        local found=false
        for valid in "${valid_layers[@]}"; do
            if [[ "$layer" == "$valid" ]]; then
                found=true
                break
            fi
        done

        if [[ "$found" == false ]]; then
            log_error "Invalid layer: $layer"
            log_info "Valid layers: ${valid_layers[*]}"
            exit 1
        fi
    done
}

# Auto-detect changed layers using git
auto_detect_layers() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log_warn "Not in a git repository; cannot auto-detect changes"
        return
    fi

    local changed_layers=()
    local all_layers=($(get_all_layers))

    for layer in "${all_layers[@]}"; do
        local layer_dir="${VAULT_ROOT}/stack/${layer}-*"
        if git diff --name-only HEAD -- "$layer_dir" | grep -q . 2>/dev/null; then
            changed_layers+=("$layer")
        fi
    done

    if [[ ${#changed_layers[@]} -eq 0 ]]; then
        log_warn "No changed layers detected in git"
    else
        log_success "Auto-detected changed layers: ${changed_layers[*]}"
        LAYERS_TO_BUILD=("${changed_layers[@]}")
    fi
}

# Get layer overview file path
get_layer_overview_file() {
    local layer="$1"
    local pattern="${VAULT_ROOT}/stack/${layer}-*/_overview.md"
    local files=($pattern)

    if [[ -f "${files[0]}" ]]; then
        echo "${files[0]}"
    else
        echo ""
    fi
}

# Update version in layer's _overview.md frontmatter
update_layer_version() {
    local layer="$1"
    local new_version="$2"
    local overview_file=$(get_layer_overview_file "$layer")

    if [[ -z "$overview_file" ]]; then
        log_warn "No _overview.md found for layer $layer"
        return
    fi

    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY-RUN] Would update $overview_file with version $new_version"
        return
    fi

    # Parse version components
    local parts=($(parse_version "$new_version"))
    local major="${parts[0]}"
    local minor="${parts[1]}"
    local patch="${parts[2]}"

    # Read current change count and increment
    local current_changes=$(grep "^version_changes:" "$overview_file" | awk '{print $2}')
    current_changes=${current_changes:-0}
    local new_changes=$((current_changes + 1))

    # Update YAML frontmatter using sed (no backup file to avoid sandbox permission issues)
    local tmp_file="${overview_file}.tmp"
    sed \
        -e "s/^version_major: .*/version_major: $major/" \
        -e "s/^version_minor: .*/version_minor: $minor/" \
        -e "s/^version_patch: .*/version_patch: $patch/" \
        -e "s/^version_full: \".*\"/version_full: \"$new_version\"/" \
        -e "s/^version_changes: .*/version_changes: $new_changes/" \
        -e "s/^version_last_build: .*/version_last_build: $next_build/" \
        "$overview_file" > "$tmp_file" && mv "$tmp_file" "$overview_file"
    log_success "Updated $layer version to $new_version (change #$new_changes, build $next_build)"
}

# ============================================================================
# BUILD FUNCTIONS
# ============================================================================

# Calculate next build number
calculate_next_build_number() {
    local current=$(get_json_value '.build.current')
    echo $((current + 1))
}

# Pad build number to 3 digits
pad_build_number() {
    local num="$1"
    printf "%03d" "$num"
}

# Generate version tag
generate_version_tag() {
    local prod="$1"
    local build="$2"
    local layers="$3"

    local build_padded=$(pad_build_number "$build")

    if [[ -z "$layers" ]] || [[ "$layers" == "INIT" ]]; then
        echo "v${prod}.${build_padded}+INIT"
    elif [[ "$layers" == "PROD" ]]; then
        echo "v${prod}.${build_padded}+PROD"
    else
        echo "v${prod}.${build_padded}+${layers}"
    fi
}

# Build the project
run_build() {
    local version_tag="$1"

    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY-RUN] Would run: node $BUILD_SCRIPT --version-tag $version_tag"
        return
    fi

    if [[ ! -f "$BUILD_SCRIPT" ]]; then
        log_error "Build script not found: $BUILD_SCRIPT"
        exit 1
    fi

    log_info "Running build with version tag: $version_tag"

    if ! node "$BUILD_SCRIPT" --version-tag "$version_tag"; then
        log_error "Build script failed"
        exit 1
    fi

    log_success "Build completed successfully"
}

# Create release directory and copy dist contents
create_release_directory() {
    local version_tag="$1"
    local release_dir="${RELEASES_DIR}/${version_tag}"

    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY-RUN] Would create release directory: $release_dir"
        echo "$release_dir"
        return 0
    fi

    if [[ -d "$release_dir" ]]; then
        log_warn "Release directory already exists: $release_dir"
        echo "$release_dir"
        return 0
    fi

    mkdir -p "$release_dir"
    log_success "Created release directory: $release_dir"

    # Copy dist contents
    if [[ -d "$DIST_DIR" ]]; then
        cp -r "$DIST_DIR"/* "$release_dir/" 2>/dev/null || true
        log_success "Copied dist contents to release directory"
    fi

    echo "$release_dir"
}

# Generate CHANGELOG.md for release
generate_changelog() {
    local release_dir="$1"
    local version_tag="$2"
    local changed_layers=("${@:3}")

    local changelog_file="${release_dir}/CHANGELOG.md"

    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY-RUN] Would generate: $changelog_file"
        return
    fi

    local date=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
    local layers_str=$(IFS=', '; echo "${changed_layers[*]}")

    # Start with version header
    cat > "$changelog_file" <<HEADER
# Release ${version_tag}

| Field | Value |
|-------|-------|
| **Version Tag** | ${version_tag} |
| **Build Date** | ${date} |
| **Changed Layers** | ${layers_str} |

---

HEADER

    # Pull recent changes from root CHANGELOG.md if it exists
    local root_changelog="${VAULT_ROOT}/CHANGELOG.md"
    if [[ -f "$root_changelog" ]]; then
        # Extract the most recent entry (from first ## to second ##)
        local recent_entry
        recent_entry=$(awk '/^## \[/{if(found) exit; found=1} found{print}' "$root_changelog")
        if [[ -n "$recent_entry" ]]; then
            echo "## Recent Changes (from root CHANGELOG)" >> "$changelog_file"
            echo "" >> "$changelog_file"
            echo "$recent_entry" >> "$changelog_file"
            echo "" >> "$changelog_file"
        fi
    fi

    # Pull from layer changelogs for each changed layer
    for layer in "${changed_layers[@]}"; do
        local layer_lower=$(echo "$layer" | tr '[:upper:]' '[:lower:]')
        # Find the layer's CHANGELOG.md
        local layer_changelog
        layer_changelog=$(find "${VAULT_ROOT}/stack" -maxdepth 2 -name "CHANGELOG.md" -path "*${layer_lower}*" 2>/dev/null | head -1)
        if [[ -n "$layer_changelog" && -f "$layer_changelog" ]]; then
            local layer_entry
            layer_entry=$(awk '/^## \[/{if(found) exit; found=1} found{print}' "$layer_changelog")
            if [[ -n "$layer_entry" ]]; then
                echo "## ${layer} Changes" >> "$changelog_file"
                echo "" >> "$changelog_file"
                echo "$layer_entry" >> "$changelog_file"
                echo "" >> "$changelog_file"
            fi
        fi
    done

    echo "## Files Included" >> "$changelog_file"
    echo "" >> "$changelog_file"
    echo "See README.md for the complete file manifest." >> "$changelog_file"

    log_success "Generated CHANGELOG.md (with real changes from vault changelogs)"
}

# Generate README.md for release
generate_readme() {
    local release_dir="$1"
    local version_tag="$2"

    local readme_file="${release_dir}/README.md"

    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY-RUN] Would generate: $readme_file"
        return
    fi

    cat > "$readme_file" <<EOF
# Release: $version_tag

## Deployment Quickstart

1. **Extract Release**: Unpack the release archive to your deployment target
2. **Review Versions**: Check VERSION.txt and layer version information below
3. **Run Configuration**: Execute the included build configuration
4. **Verify Installation**: Test each layer's functionality

## Layer Version Summary

| Layer | Name | Version |
|-------|------|---------|
EOF

    # Add layer versions from versions.json
    local all_layers=($(get_all_layers))
    for layer in "${all_layers[@]}"; do
        local layer_name=$(jq -r ".layers.${layer}.name" "$VERSIONS_FILE")
        local layer_version=$(jq -r ".layers.${layer}.version" "$VERSIONS_FILE")
        echo "| $layer | $layer_name | $layer_version |" >> "$readme_file"
    done

    cat >> "$readme_file" <<'EOF'

## File Manifest

```
releases/VERSION_TAG/
├── CHANGELOG.md          # Detailed change log
├── README.md            # This file
├── VERSION.txt          # Version tag reference
├── openclaw.json        # Configuration
├── LAYERS-MANIFEST.json # Layer metadata
└── context-files/       # Context and support files
    └── ...
```

## Setup Instructions

1. Review CHANGELOG.md for changes and migration notes
2. Compare VERSION.txt with your current version
3. Deploy using your normal release procedure
4. Verify all layers are functioning correctly

## Support

For issues or questions, refer to the project documentation.
EOF

    log_success "Generated README.md"
}

# Generate VERSION.txt
generate_version_file() {
    local release_dir="$1"
    local version_tag="$2"

    local version_file="${release_dir}/VERSION.txt"

    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY-RUN] Would create: $version_file"
        return
    fi

    echo "$version_tag" > "$version_file"
    log_success "Generated VERSION.txt"
}

# ============================================================================
# VERSIONS.JSON UPDATE FUNCTIONS
# ============================================================================

# Update versions.json with new build information
update_versions_json() {
    local version_tag="$1"
    local build_number="$2"
    local changed_layers=("${@:3}")

    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY-RUN] Would update versions.json with build $build_number"
        return
    fi

    # Use jq to update the JSON (write to local temp, then cp to avoid cross-device mv issues)
    local temp_file="${VERSIONS_FILE}.tmp"

    jq --arg build "$build_number" \
       --arg tag "$version_tag" \
       --argjson layers "$(printf '%s\n' "${changed_layers[@]}" | jq -sR 'split("\n")[:-1]')" \
       '.metadata.lastUpdated = (now | todate) |
        .build.current = ($build | tonumber) |
        .build.counter = ($build | tonumber) |
        .releases += [{
          "tag": $tag,
          "date": (now | todate),
          "build": ($build | tonumber),
          "changedLayers": $layers
        }]' \
       "$VERSIONS_FILE" > "$temp_file"

    cp "$temp_file" "$VERSIONS_FILE" && rm -f "$temp_file" 2>/dev/null || true
    log_success "Updated versions.json with new build"
}

# Count .md files in a layer directory
count_layer_files() {
    local layer="$1"
    local layer_dir="${VAULT_ROOT}/stack/${layer}-*"
    local dirs=($layer_dir)

    if [[ -d "${dirs[0]}" ]]; then
        find "${dirs[0]}" -name "*.md" | wc -l | tr -d ' '
    else
        echo "0"
    fi
}

# Update individual layer version in versions.json
update_layer_in_json() {
    local layer="$1"
    local new_version="$2"
    local file_count=$(count_layer_files "$layer")

    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY-RUN] Would update layer $layer to version $new_version (files: $file_count) in versions.json"
        return
    fi

    local temp_file="${VERSIONS_FILE}.tmp"

    jq --arg layer "$layer" \
       --arg version "$new_version" \
       --argjson build "$next_build" \
       --argjson files "$file_count" \
       ".layers[\$layer].version = \$version | .layers[\$layer].changes += 1 | .layers[\$layer].lastBuild = \$build | .layers[\$layer].files = \$files" \
       "$VERSIONS_FILE" > "$temp_file"

    cp "$temp_file" "$VERSIONS_FILE" && rm -f "$temp_file" 2>/dev/null || true
    log_info "$layer file count: $file_count"
}

# ============================================================================
# STATUS & REPORTING
# ============================================================================

show_status() {
    log_section "Build System Status"

    local prod=$(get_json_value '.production.current')
    local build=$(get_json_value '.build.current')

    echo -e "${CYAN}Production Milestone:${NC} ${GREEN}${prod}${NC}"
    echo -e "${CYAN}Current Build:${NC} ${GREEN}${build}${NC}"
    echo -e "${CYAN}Next Build:${NC} ${GREEN}$((build + 1))${NC}"

    echo ""
    echo -e "${CYAN}Layer Versions:${NC}"

    local all_layers=($(get_all_layers))
    printf "%-8s %-20s %-10s %-8s %-10s %-8s\n" "Layer" "Name" "Version" "Changes" "LastBuild" "Files"
    printf "%-8s %-20s %-10s %-8s %-10s %-8s\n" "-----" "----" "-------" "-------" "---------" "-----"

    for layer in "${all_layers[@]}"; do
        local name=$(get_json_value ".layers.${layer}.name")
        local version=$(get_json_value ".layers.${layer}.version")
        local changes=$(get_json_value ".layers.${layer}.changes")
        local lastbuild=$(get_json_value ".layers.${layer}.lastBuild")
        local json_files=$(get_json_value ".layers.${layer}.files")
        local actual_files=$(count_layer_files "$layer")

        local files_display="$json_files"
        if [[ "$json_files" != "$actual_files" ]]; then
            files_display="${json_files}→${actual_files}"
        fi

        printf "%-8s %-20s %-10s %-8s %-10s %-8s\n" "$layer" "$name" "$version" "$changes" "$lastbuild" "$files_display"
    done

    echo ""
    echo -e "${CYAN}Recent Releases:${NC}"

    local releases_count=$(jq '.releases | length' "$VERSIONS_FILE")
    if [[ "$releases_count" -gt 0 ]]; then
        jq -r '.releases[-5:] | .[] | "\(.tag) - \(.date)"' "$VERSIONS_FILE" | while read -r line; do
            echo "  $line"
        done
    else
        echo "  (No releases yet)"
    fi
}

# ============================================================================
# GIT OPERATIONS
# ============================================================================

commit_release() {
    local version_tag="$1"

    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY-RUN] Would commit release $version_tag"
        return
    fi

    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log_warn "Not in a git repository; skipping commit"
        return
    fi

    log_info "Committing release to git..."

    # Stage files
    git add "$VERSIONS_FILE" "stack/L*/_overview.md" "releases/${version_tag}/" 2>/dev/null || true

    # Commit
    if git diff --cached --quiet; then
        log_warn "No changes to commit"
    else
        git commit -m "build: release ${version_tag}" || log_warn "Commit failed or nothing to commit"
    fi

    log_success "Release committed"
}

# ============================================================================
# PRODUCTION MILESTONE
# ============================================================================

bump_production() {
    local message="$1"

    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY-RUN] Would bump production milestone with message: $message"
        return
    fi

    log_section "Bumping Production Milestone"

    local current_prod=$(get_json_value '.production.current')
    local next_prod=$((current_prod + 1))

    local temp_file="${VERSIONS_FILE}.tmp"

    # Bump production, reset build counter, update all layer change counters
    jq --arg prod "$next_prod" \
       ".production.current = (\$prod | tonumber) | \
        .build.current = 0 | \
        .build.counter = 0 | \
        .layers |= map(.changes = 0)" \
       "$VERSIONS_FILE" > "$temp_file"

    cp "$temp_file" "$VERSIONS_FILE" && rm -f "$temp_file" 2>/dev/null || true

    log_success "Production bumped from $current_prod to $next_prod"
    log_info "Reset build counter and layer change tracking"
}

# ============================================================================
# MAIN WORKFLOW
# ============================================================================

main() {
    log_section "Crispy Kitsune Build Orchestrator"

    # Validate environment
    check_jq
    validate_versions_file

    log_success "Environment validated"

    # Handle --status flag specially
    if [[ "$DRY_RUN" == false && -z "$PROD_MILESTONE" && "${#LAYERS_TO_BUILD[@]}" -eq 0 && "$FORCE_BUILD" == false && "$AUTO_DETECT" == false ]]; then
        # No build flags provided, show status
        show_status
        return 0
    fi

    # Show status
    show_status

    # Handle --prod separately (doesn't build, just bumps milestone)
    if [[ -n "$PROD_MILESTONE" ]]; then
        bump_production "$PROD_MILESTONE"
        if [[ "$COMMIT_RELEASE" == true ]]; then
            commit_release "milestone-${PROD_MILESTONE}"
        fi
        return 0
    fi

    # Determine which layers to build
    if [[ "$FORCE_BUILD" == true ]]; then
        log_info "Force build: building all layers"
        LAYERS_TO_BUILD=($(get_all_layers))
    elif [[ "$AUTO_DETECT" == true ]]; then
        auto_detect_layers
    fi

    # Validate specified layers
    if [[ ${#LAYERS_TO_BUILD[@]} -gt 0 ]]; then
        validate_layers "${LAYERS_TO_BUILD[@]}"
    fi

    # If no layers to build, show warning and exit
    if [[ ${#LAYERS_TO_BUILD[@]} -eq 0 ]]; then
        log_warn "No layers specified for build"
        log_info "Use --layers, --force, or --auto to build"
        return 0
    fi

    log_section "Building Layers"
    echo -e "${CYAN}Layers to build:${NC} ${GREEN}${LAYERS_TO_BUILD[*]}${NC}"

    # Get current version info
    local prod=$(get_json_value '.production.current')
    local current_build=$(get_json_value '.build.current')
    next_build=$(calculate_next_build_number)

    echo -e "${CYAN}Production:${NC} ${GREEN}${prod}${NC}"
    echo -e "${CYAN}Current Build:${NC} ${GREEN}${current_build}${NC}"
    echo -e "${CYAN}Next Build:${NC} ${GREEN}${next_build}${NC}"

    # Calculate and display new versions for each layer
    log_section "Version Updates"

    local -A new_versions
    for layer in "${LAYERS_TO_BUILD[@]}"; do
        local current_version=$(get_json_value ".layers.${layer}.version")
        local new_version=$(bump_patch_version "$current_version")
        new_versions["$layer"]="$new_version"

        echo -e "${CYAN}${layer}:${NC} ${current_version} → ${GREEN}${new_version}${NC}"
    done

    # Generate version tag
    local layers_tag=$(IFS='.'; echo "${LAYERS_TO_BUILD[*]}")
    local version_tag=$(generate_version_tag "$prod" "$next_build" "$layers_tag")

    echo ""
    echo -e "${CYAN}Version Tag:${NC} ${GREEN}${version_tag}${NC}"

    if [[ "$DRY_RUN" == true ]]; then
        log_section "Dry Run Summary"
        echo "No files will be modified during dry run."
        return 0
    fi

    # Confirm before proceeding (skip if --yes)
    if [[ "$YES_MODE" != true ]]; then
        echo ""
        echo -e "${YELLOW}Proceed with build? [y/N]${NC}"
        read -r confirm
        if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
            log_warn "Build cancelled"
            return 0
        fi
    else
        log_info "Auto-confirmed (--yes mode)"
    fi

    # Update layer versions in frontmatter
    log_section "Updating Layer Metadata"
    for layer in "${LAYERS_TO_BUILD[@]}"; do
        update_layer_version "$layer" "${new_versions[$layer]}"
    done

    # Run build script
    log_section "Executing Build"
    run_build "$version_tag"

    # Create release directory
    log_section "Creating Release Package"
    local release_dir=$(create_release_directory "$version_tag")

    # Generate release documentation
    generate_changelog "$release_dir" "$version_tag" "${LAYERS_TO_BUILD[@]}"
    generate_readme "$release_dir" "$version_tag"
    generate_version_file "$release_dir" "$version_tag"

    # Update versions.json
    log_section "Updating Version Manifest"
    update_versions_json "$version_tag" "$next_build" "${LAYERS_TO_BUILD[@]}"

    # Update individual layer entries
    for layer in "${LAYERS_TO_BUILD[@]}"; do
        update_layer_in_json "$layer" "${new_versions[$layer]}"
    done

    # Commit release if requested
    if [[ "$COMMIT_RELEASE" == true ]]; then
        log_section "Git Operations"
        commit_release "$version_tag"
    fi

    log_section "Build Complete"
    echo -e "${GREEN}✓ Release generated: ${version_tag}${NC}"
    echo -e "${CYAN}Location: ${release_dir}${NC}"
}

# ============================================================================
# ARGUMENT PARSING
# ============================================================================

show_usage() {
    cat <<'EOF'
Crispy Kitsune Build Orchestrator

Usage: ./build.sh [OPTIONS]

Options:
  --layers L1 L2 ...      Build specific layers (space-separated)
  --force                 Rebuild all layers (treat all as changed)
  --auto                  Auto-detect changed layers via git diff
  --commit                Auto-commit the release to git after build
  --prod "MESSAGE"        Bump production milestone (resets build counter)
  --status                Show current version state
  --dry-run              Preview actions without writing files
  --yes, -y              Skip confirmation prompt (non-interactive mode)
  -h, --help             Show this help message

Examples:
  ./build.sh --layers L2 L6           # Build layers L2 and L6
  ./build.sh --force                  # Rebuild all layers
  ./build.sh --auto --commit          # Auto-detect and commit
  ./build.sh --auto --yes --commit    # Auto-detect, no prompt, commit
  ./build.sh --prod "First boot"      # Bump production, reset counters
  ./build.sh --status                 # Show current versions
  ./build.sh --dry-run --layers L1    # Preview build of L1

EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --layers)
            shift
            while [[ $# -gt 0 && ! "$1" =~ ^-- ]]; do
                LAYERS_TO_BUILD+=("$1")
                shift
            done
            continue
            ;;
        --force)
            FORCE_BUILD=true
            shift
            ;;
        --auto)
            AUTO_DETECT=true
            shift
            ;;
        --commit)
            COMMIT_RELEASE=true
            shift
            ;;
        --prod)
            shift
            PROD_MILESTONE="$1"
            shift
            ;;
        --status)
            validate_versions_file
            check_jq
            show_status
            exit 0
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --yes|-y)
            YES_MODE=true
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Execute main workflow
main
