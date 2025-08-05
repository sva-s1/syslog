#!/usr/bin/env bash
# llmstatus.sh — regenerate llm_status.txt for LLM digestion (Bash-3-safe)

set -euo pipefail

###############################################################################
# USER-TUNABLE SETTINGS
###############################################################################
OUT_FILE="llm_status.txt"          # flat-file we generate
MAX_BYTES=$((1024 * 1024))         # skip bodies larger than 1 MiB

# extensions we want (without leading dot)
WANTED_EXTS=(yaml yml json txt templ conf md sh py js ts css html sql)

# filenames we want even with no extension
WANTED_NAMES=(Dockerfile Makefile .gitignore .env)

# folders to ignore by default (add more on the CLI)
DEFAULT_IGNORES=(.git node_modules)
###############################################################################

SCRIPT_NAME="$(basename "$0")"

# Merge CLI-supplied ignores and make sure script + output are excluded
IGNORES=("${DEFAULT_IGNORES[@]}" "$@" "$SCRIPT_NAME" "$OUT_FILE")

# ───────────────────────── helper functions ──────────────────────────
is_wanted() {
    local basename="${1##*/}"
    local ext="${basename##*.}"
    [[ "$basename" == "$ext" ]] && ext=""   # bare filename → no ext

    for n in "${WANTED_NAMES[@]}"; do [[ "$basename" == "$n" ]] && return 0; done
    for e in "${WANTED_EXTS[@]}";  do [[ "$ext"      == "$e" ]] && return 0; done
    return 1
}

should_skip_body() {
    local size
    size=$(wc -c < "$1")
    [ "$size" -gt "$MAX_BYTES" ]
}

# ───────────── add .gitignore patterns to ignore list (if present) ───────────
if [ -f .gitignore ]; then
    while IFS= read -r line; do
        [[ -z "$line" || "$line" == \#* ]] && continue
        IGNORES+=("$line")
    done < .gitignore
fi

# glob for tree’s -I (pipe-separated list of patterns)
IGNORE_GLOB=$(printf '%s|' "${IGNORES[@]}" | sed 's/|$//')

# ───────────────────────── header section ───────────────────────────
{
    echo "# UPDATED Project Content"
    echo
    echo "pwd"
    pwd
    echo
    echo "tree (restricted)"
    tree -a --dirsfirst -I "$IGNORE_GLOB"
} > "$OUT_FILE"

# ───────────────────────── file scanning ────────────────────────────
find . -type f | LC_ALL=C sort | while IFS= read -r file; do
    # 1) skip ignored paths (includes script + output file now)
    for skip in "${IGNORES[@]}"; do
        case "$file" in
            ./"$skip"/*|./"$skip") continue 2 ;;
        esac
    done

    # 2) only include wanted extensions / names
    is_wanted "$file" || continue

    echo >> "$OUT_FILE"
    echo "${file#./}:" >> "$OUT_FILE"

    if should_skip_body "$file"; then
        printf "<skipped – file larger than %s bytes>\n" "$MAX_BYTES" >> "$OUT_FILE"
        continue
    fi

    if [ "$(basename "$file")" = ".env" ]; then
        # mask any variable whose name contains TOKEN (case-insensitive)
        sed -E 's/^([^=[:space:]]*[Tt][Oo][Kk][Ee][Nn][^=]*)=.*/\1=***TOKEN_PLACEHOLDER***/' "$file" \
            >> "$OUT_FILE"
    else
        cat "$file" >> "$OUT_FILE"
    fi
done

# ───────────────────────────── summary ─────────────────────────────
echo "✅  Wrote $(du -h "$OUT_FILE" | cut -f1) → $OUT_FILE"
echo "   Ignored paths: ${IGNORES[*]}"
echo "   Allowed extensions: ${WANTED_EXTS[*]}"
echo "   Allowed bare names: ${WANTED_NAMES[*]}"

