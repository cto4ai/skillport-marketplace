#!/bin/bash
# Copy a skill from another Skillport marketplace repo to this one
# Usage: bash scripts/copy-skill.sh <source-repo-path> <skill-name>

set -e

SOURCE_REPO="$1"
SKILL_NAME="$2"

if [ -z "$SOURCE_REPO" ] || [ -z "$SKILL_NAME" ]; then
    echo "Usage: bash scripts/copy-skill.sh <source-repo-path> <skill-name>"
    echo "Example: bash scripts/copy-skill.sh ../skillport-marketplace skillport-repo-utils"
    exit 1
fi

# Resolve source repo to absolute path
SOURCE_REPO=$(cd "$SOURCE_REPO" 2>/dev/null && pwd) || {
    echo "Error: Source repo '$1' not found"
    exit 1
}

# Find target repo root (look for .claude-plugin/marketplace.json)
TARGET_REPO=""
DIR="$(pwd)"
while [ "$DIR" != "/" ]; do
    if [ -f "$DIR/.claude-plugin/marketplace.json" ]; then
        TARGET_REPO="$DIR"
        break
    fi
    DIR="$(dirname "$DIR")"
done

if [ -z "$TARGET_REPO" ]; then
    echo "Error: Not in a Skillport marketplace repo (no .claude-plugin/marketplace.json found)"
    exit 1
fi

# Verify source repo has marketplace.json
if [ ! -f "$SOURCE_REPO/.claude-plugin/marketplace.json" ]; then
    echo "Error: Source repo doesn't appear to be a Skillport marketplace (no .claude-plugin/marketplace.json)"
    exit 1
fi

# Find the skill in source repo
SOURCE_SKILL_DIR=$(find "$SOURCE_REPO/plugins" -path "*/skills/$SKILL_NAME" -type d 2>/dev/null | head -1)

if [ -z "$SOURCE_SKILL_DIR" ]; then
    echo "Error: Skill '$SKILL_NAME' not found in $SOURCE_REPO/plugins/*/skills/"
    exit 1
fi

# Extract plugin name from path
SOURCE_PLUGIN_NAME=$(echo "$SOURCE_SKILL_DIR" | sed "s|$SOURCE_REPO/plugins/||" | cut -d'/' -f1)
SOURCE_PLUGIN_DIR="$SOURCE_REPO/plugins/$SOURCE_PLUGIN_NAME"

echo "Source skill: $SOURCE_SKILL_DIR"
echo "Source plugin: $SOURCE_PLUGIN_NAME"
echo "Target repo: $TARGET_REPO"

# Check if plugin already exists in target
TARGET_PLUGIN_DIR="$TARGET_REPO/plugins/$SOURCE_PLUGIN_NAME"

if [ -d "$TARGET_PLUGIN_DIR" ]; then
    # Plugin exists - check if skill exists
    if [ -d "$TARGET_PLUGIN_DIR/skills/$SKILL_NAME" ]; then
        echo "Error: Skill '$SKILL_NAME' already exists in target repo"
        exit 1
    fi
    echo "Plugin '$SOURCE_PLUGIN_NAME' exists in target, adding skill to it..."

    # Just copy the skill directory
    mkdir -p "$TARGET_PLUGIN_DIR/skills"
    cp -r "$SOURCE_SKILL_DIR" "$TARGET_PLUGIN_DIR/skills/"
    echo "Copied skill to: $TARGET_PLUGIN_DIR/skills/$SKILL_NAME"
else
    # Plugin doesn't exist - copy entire plugin directory
    echo "Copying entire plugin '$SOURCE_PLUGIN_NAME'..."
    cp -r "$SOURCE_PLUGIN_DIR" "$TARGET_PLUGIN_DIR"
    echo "Copied plugin to: $TARGET_PLUGIN_DIR"

    # Add to marketplace.json
    MARKETPLACE_FILE="$TARGET_REPO/.claude-plugin/marketplace.json"

    # Get plugin info from source marketplace.json
    if command -v jq &> /dev/null; then
        PLUGIN_ENTRY=$(jq --arg name "$SOURCE_PLUGIN_NAME" '.plugins[] | select(.name == $name)' "$SOURCE_REPO/.claude-plugin/marketplace.json")

        if [ -n "$PLUGIN_ENTRY" ]; then
            # Add entry to target marketplace
            jq --argjson entry "$PLUGIN_ENTRY" '.plugins += [$entry]' "$MARKETPLACE_FILE" > "$MARKETPLACE_FILE.tmp"
            mv "$MARKETPLACE_FILE.tmp" "$MARKETPLACE_FILE"
            echo "Added '$SOURCE_PLUGIN_NAME' to marketplace.json"
        else
            echo "Warning: Plugin not found in source marketplace.json. Please add manually."
        fi
    else
        echo "Warning: jq not installed. Please manually add '$SOURCE_PLUGIN_NAME' to marketplace.json"
    fi
fi

echo ""
echo "Done. Skill '$SKILL_NAME' has been copied to this repo."
