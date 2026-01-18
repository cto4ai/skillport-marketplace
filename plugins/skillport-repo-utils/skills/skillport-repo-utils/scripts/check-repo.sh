#!/bin/bash
# Validate a Skillport marketplace repo for consistency
# Usage: bash scripts/check-repo.sh [--fix]

set -e

FIX_MODE=false
if [ "$1" = "--fix" ]; then
    FIX_MODE=true
fi

# Find repo root (look for .claude-plugin/marketplace.json)
REPO_ROOT=""
DIR="$(pwd)"
while [ "$DIR" != "/" ]; do
    if [ -f "$DIR/.claude-plugin/marketplace.json" ]; then
        REPO_ROOT="$DIR"
        break
    fi
    DIR="$(dirname "$DIR")"
done

if [ -z "$REPO_ROOT" ]; then
    echo "Error: Not in a Skillport marketplace repo (no .claude-plugin/marketplace.json found)"
    exit 1
fi

cd "$REPO_ROOT"
MARKETPLACE_FILE=".claude-plugin/marketplace.json"

echo "Checking: $REPO_ROOT"
echo "==========================================="
echo ""

ERRORS=0
WARNINGS=0

error() {
    echo "[ERROR] $1"
    ERRORS=$((ERRORS + 1))
}

warn() {
    echo "[WARN]  $1"
    WARNINGS=$((WARNINGS + 1))
}

ok() {
    echo "[OK]    $1"
}

# Check if jq is available
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required for this script"
    exit 1
fi

# Validate marketplace.json is valid JSON
if ! jq '.' "$MARKETPLACE_FILE" > /dev/null 2>&1; then
    error "marketplace.json is not valid JSON"
    exit 1
fi

echo "## Marketplace Structure"
echo ""

# Check required fields in marketplace.json
MARKETPLACE_NAME=$(jq -r '.name // empty' "$MARKETPLACE_FILE")
if [ -z "$MARKETPLACE_NAME" ]; then
    error "marketplace.json missing 'name' field"
else
    ok "Marketplace name: $MARKETPLACE_NAME"
fi

# Check for duplicate plugin entries
echo ""
echo "## Duplicate Check"
echo ""

PLUGIN_NAMES=$(jq -r '.plugins[].name' "$MARKETPLACE_FILE")
DUPLICATE_NAMES=$(echo "$PLUGIN_NAMES" | sort | uniq -d)

if [ -n "$DUPLICATE_NAMES" ]; then
    for DUP in $DUPLICATE_NAMES; do
        COUNT=$(echo "$PLUGIN_NAMES" | grep -c "^${DUP}$")
        error "Duplicate plugin entry: '$DUP' appears $COUNT times"
    done
else
    ok "No duplicate plugin entries"
fi

# Check each plugin in marketplace.json
echo ""
echo "## Plugin Validation"
echo ""

PLUGIN_COUNT=$(jq '.plugins | length' "$MARKETPLACE_FILE")

for i in $(seq 0 $((PLUGIN_COUNT - 1))); do
    PLUGIN_NAME=$(jq -r ".plugins[$i].name" "$MARKETPLACE_FILE")
    PLUGIN_SOURCE=$(jq -r ".plugins[$i].source" "$MARKETPLACE_FILE")
    PLUGIN_VERSION=$(jq -r ".plugins[$i].version // empty" "$MARKETPLACE_FILE")

    echo "--- $PLUGIN_NAME ---"

    # Check source directory exists
    if [ ! -d "$PLUGIN_SOURCE" ]; then
        error "Plugin '$PLUGIN_NAME': source directory not found: $PLUGIN_SOURCE"
        continue
    fi

    # Check plugin.json exists
    PLUGIN_JSON="$PLUGIN_SOURCE/.claude-plugin/plugin.json"
    if [ ! -f "$PLUGIN_JSON" ]; then
        error "Plugin '$PLUGIN_NAME': missing .claude-plugin/plugin.json"
        continue
    fi

    # Validate plugin.json is valid JSON
    if ! jq '.' "$PLUGIN_JSON" > /dev/null 2>&1; then
        error "Plugin '$PLUGIN_NAME': plugin.json is not valid JSON"
        continue
    fi

    # Check version consistency
    FILE_VERSION=$(jq -r '.version // empty' "$PLUGIN_JSON")
    if [ -n "$PLUGIN_VERSION" ] && [ -n "$FILE_VERSION" ]; then
        if [ "$PLUGIN_VERSION" != "$FILE_VERSION" ]; then
            error "Plugin '$PLUGIN_NAME': version mismatch - marketplace.json: $PLUGIN_VERSION, plugin.json: $FILE_VERSION"
        else
            ok "Version consistent: $FILE_VERSION"
        fi
    elif [ -z "$FILE_VERSION" ]; then
        warn "Plugin '$PLUGIN_NAME': plugin.json missing 'version' field"
    elif [ -z "$PLUGIN_VERSION" ]; then
        warn "Plugin '$PLUGIN_NAME': marketplace.json missing 'version' field"
    fi

    # Check name consistency
    FILE_NAME=$(jq -r '.name // empty' "$PLUGIN_JSON")
    if [ -n "$FILE_NAME" ] && [ "$FILE_NAME" != "$PLUGIN_NAME" ]; then
        error "Plugin '$PLUGIN_NAME': name mismatch - marketplace.json: $PLUGIN_NAME, plugin.json: $FILE_NAME"
    fi

    # Check skills directory exists
    SKILLS_DIR="$PLUGIN_SOURCE/skills"
    if [ ! -d "$SKILLS_DIR" ]; then
        error "Plugin '$PLUGIN_NAME': missing skills/ directory"
        continue
    fi

    # Check each skill
    SKILL_COUNT=0
    for SKILL_DIR in "$SKILLS_DIR"/*/; do
        if [ ! -d "$SKILL_DIR" ]; then
            continue
        fi

        SKILL_NAME=$(basename "$SKILL_DIR")
        SKILL_COUNT=$((SKILL_COUNT + 1))

        # Check SKILL.md exists
        SKILL_MD="$SKILL_DIR/SKILL.md"
        if [ ! -f "$SKILL_MD" ]; then
            error "Skill '$SKILL_NAME': missing SKILL.md"
            continue
        fi

        # Check SKILL.md has frontmatter
        if ! head -1 "$SKILL_MD" | grep -q "^---$"; then
            error "Skill '$SKILL_NAME': SKILL.md missing frontmatter (must start with ---)"
            continue
        fi

        # Extract and validate frontmatter (between first and second ---)
        FRONTMATTER=$(awk '/^---$/{if(++c==2)exit}c==1' "$SKILL_MD")

        # Check for name in frontmatter
        if ! echo "$FRONTMATTER" | grep -q "^name:"; then
            error "Skill '$SKILL_NAME': SKILL.md frontmatter missing 'name' field"
        else
            FM_NAME=$(echo "$FRONTMATTER" | grep "^name:" | sed 's/^name:[[:space:]]*//')
            if [ "$FM_NAME" != "$SKILL_NAME" ]; then
                warn "Skill '$SKILL_NAME': frontmatter name '$FM_NAME' doesn't match directory name"
            fi
        fi

        # Check for description in frontmatter
        if ! echo "$FRONTMATTER" | grep -q "^description:"; then
            error "Skill '$SKILL_NAME': SKILL.md frontmatter missing 'description' field"
        fi

        # Check for non-compliant .claude-plugin at skill level
        if [ -d "$SKILL_DIR/.claude-plugin" ]; then
            error "Skill '$SKILL_NAME': has .claude-plugin/ folder (non-compliant - belongs at plugin level only)"
        fi

        ok "Skill '$SKILL_NAME': valid"
    done

    if [ "$SKILL_COUNT" -eq 0 ]; then
        error "Plugin '$PLUGIN_NAME': no skills found in skills/ directory"
    fi

    echo ""
done

# Check for unpublished plugins (in filesystem but not in marketplace.json)
echo "## Unpublished Plugins"
echo ""

if [ -d "plugins" ]; then
    UNPUBLISHED_COUNT=0
    for PLUGIN_DIR in plugins/*/; do
        if [ ! -d "$PLUGIN_DIR" ]; then
            continue
        fi

        DIR_NAME=$(basename "$PLUGIN_DIR")

        # Check if this plugin is in marketplace.json
        if ! jq -e --arg name "$DIR_NAME" '.plugins[] | select(.name == $name)' "$MARKETPLACE_FILE" > /dev/null 2>&1; then
            echo "[INFO]  Unpublished: plugins/$DIR_NAME"
            UNPUBLISHED_COUNT=$((UNPUBLISHED_COUNT + 1))
        fi
    done

    if [ "$UNPUBLISHED_COUNT" -eq 0 ]; then
        ok "All plugins are published"
    else
        echo ""
        echo "        ($UNPUBLISHED_COUNT unpublished plugin(s) - this is normal for work in progress)"
    fi
fi

# Surface Tag Validation
echo ""
echo "## Surface Tag Validation"
echo ""

VALID_SURFACE_TAGS="surface:CC surface:CD surface:CAI surface:CDAI surface:CALL"

for i in $(seq 0 $((PLUGIN_COUNT - 1))); do
    PLUGIN_NAME=$(jq -r ".plugins[$i].name" "$MARKETPLACE_FILE")
    HAS_TAGS=$(jq -e ".plugins[$i].tags" "$MARKETPLACE_FILE" 2>/dev/null) || true
    
    if [ $? -ne 0 ]; then
        # No tags array at all
        warn "Plugin '$PLUGIN_NAME': no tags array (surface tags recommended)"
        continue
    fi
    
    # Check for surface tags
    SURFACE_TAGS=$(jq -r ".plugins[$i].tags[]? | select(startswith(\"surface:\"))" "$MARKETPLACE_FILE" 2>/dev/null)
    
    if [ -z "$SURFACE_TAGS" ]; then
        warn "Plugin '$PLUGIN_NAME': no surface tags (recommended: surface:CC, surface:CD, surface:CAI, surface:CDAI, or surface:CALL)"
    else
        # Validate each surface tag
        INVALID_FOUND=false
        for TAG in $SURFACE_TAGS; do
            if ! echo "$VALID_SURFACE_TAGS" | grep -qw "$TAG"; then
                error "Plugin '$PLUGIN_NAME': invalid surface tag '$TAG' (valid: CC, CD, CAI, CDAI, CALL)"
                INVALID_FOUND=true
            fi
        done
        if [ "$INVALID_FOUND" = false ]; then
            ok "Plugin '$PLUGIN_NAME': valid surface tags ($SURFACE_TAGS)"
        fi
    fi
done

# Summary
echo ""
echo "==========================================="
echo "Summary: $ERRORS error(s), $WARNINGS warning(s)"
echo ""

if [ "$ERRORS" -gt 0 ]; then
    exit 1
elif [ "$WARNINGS" -gt 0 ]; then
    exit 0
else
    echo "All checks passed!"
    exit 0
fi
