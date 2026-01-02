#!/bin/bash
# Delete a skill from a Skillport marketplace repo
# Usage: bash scripts/delete-skill.sh <skill-name>

set -e

SKILL_NAME="$1"

if [ -z "$SKILL_NAME" ]; then
    echo "Usage: bash scripts/delete-skill.sh <skill-name>"
    exit 1
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

# Find the skill directory
SKILL_DIR=$(find plugins -path "*/skills/$SKILL_NAME" -type d 2>/dev/null | head -1)

if [ -z "$SKILL_DIR" ]; then
    echo "Error: Skill '$SKILL_NAME' not found in plugins/*/skills/"
    exit 1
fi

# Extract plugin name from path (plugins/<plugin-name>/skills/<skill-name>)
PLUGIN_NAME=$(echo "$SKILL_DIR" | cut -d'/' -f2)
PLUGIN_DIR="plugins/$PLUGIN_NAME"

echo "Found skill: $SKILL_DIR"
echo "Plugin: $PLUGIN_NAME"

# Count skill directories in this plugin
SKILL_COUNT=$(find "$PLUGIN_DIR/skills" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')

echo "Skills in plugin: $SKILL_COUNT"

if [ "$SKILL_COUNT" -eq 1 ]; then
    # Last skill - delete entire plugin directory
    echo "This is the last skill in the plugin. Deleting entire plugin directory..."
    rm -rf "$PLUGIN_DIR"
    echo "Deleted: $PLUGIN_DIR"

    # Remove from marketplace.json
    MARKETPLACE_FILE=".claude-plugin/marketplace.json"
    if [ -f "$MARKETPLACE_FILE" ]; then
        # Use jq if available, otherwise use sed
        if command -v jq &> /dev/null; then
            jq --arg name "$PLUGIN_NAME" '.plugins = [.plugins[] | select(.name != $name)]' "$MARKETPLACE_FILE" > "$MARKETPLACE_FILE.tmp"
            mv "$MARKETPLACE_FILE.tmp" "$MARKETPLACE_FILE"
            echo "Removed '$PLUGIN_NAME' from marketplace.json"
        else
            echo "Warning: jq not installed. Please manually remove '$PLUGIN_NAME' from $MARKETPLACE_FILE"
        fi
    fi
else
    # Multiple skills - just delete the skill directory
    echo "Deleting skill directory..."
    rm -rf "$SKILL_DIR"
    echo "Deleted: $SKILL_DIR"
    echo "Plugin '$PLUGIN_NAME' retained (has other skills)"
fi

echo ""
echo "Done. Skill '$SKILL_NAME' has been deleted."
