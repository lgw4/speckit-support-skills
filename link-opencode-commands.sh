#!/usr/bin/env sh
# link-opencode-commands.sh -- link this repo's OpenCode command wrappers
# into another repository's .opencode/commands/, one symlink per wrapper,
# and make sure that repository's .opencode/opencode.json registers this
# repo's skills/ directory (the wrappers cannot load their skills without
# it).
#
# Usage: link-opencode-commands.sh <target-repo>
#
# Existing entries in the target's commands directory are never touched:
# a name that already exists (a real file, or a symlink pointing
# elsewhere) is skipped with a warning. Re-running the script is safe.

set -eu

prog_name=${0##*/}

usage() {
    printf 'usage: %s <target-repo>\n' "$prog_name"
}

die() {
    printf '%s: %s\n' "$prog_name" "$1" >&2
    exit 1
}

warn() {
    printf '%s: warning: %s\n' "$prog_name" "$1" >&2
}

# --- locate this repo from the script's own path --------------------------

case ${1:-} in
    -h|--help)
        usage
        exit 0
        ;;
esac

if [ $# -ne 1 ]; then
    usage >&2
    exit 2
fi

self=$0
case $self in
    */*) ;;
    *)
        # invoked through a PATH lookup
        self=$(command -v "$self") || die "cannot locate this script"
        ;;
esac
while [ -L "$self" ]; do
    link=$(readlink "$self")
    case $link in
        /*) self=$link ;;
        *)  self=$(dirname "$self")/$link ;;
    esac
done
src_repo=$(CDPATH='' cd -P "$(dirname "$self")" && pwd)
src_commands=$src_repo/.opencode/commands
src_skills=$src_repo/skills

[ -d "$src_commands" ] ||
    die "no .opencode/commands/ found next to this script (looked in $src_repo)"
[ -d "$src_skills" ] ||
    die "no skills/ found next to this script (looked in $src_repo)"

# --- resolve and check the target ------------------------------------------

[ -d "$1" ] || die "target is not a directory: $1"
target=$(CDPATH='' cd -P "$1" && pwd)

if [ "$target" = "$src_repo" ]; then
    die "target is this repository itself; nothing to link"
fi

dst_opencode=$target/.opencode
dst_commands=$dst_opencode/commands
mkdir -p "$dst_commands"

# --- link each wrapper -------------------------------------------------------

linked=0
already=0
skipped=0

for src in "$src_commands"/*.md; do
    [ -e "$src" ] || continue   # no wrappers matched the glob
    name=${src##*/}
    dst=$dst_commands/$name

    if [ -L "$dst" ]; then
        if [ "$(readlink "$dst")" = "$src" ]; then
            already=$((already + 1))
        else
            warn "skipping $name: existing symlink points elsewhere"
            skipped=$((skipped + 1))
        fi
    elif [ -e "$dst" ]; then
        warn "skipping $name: a real file already exists at $dst"
        skipped=$((skipped + 1))
    else
        ln -s "$src" "$dst"
        linked=$((linked + 1))
    fi
done

# --- make sure opencode.json registers the skills directory ------------------

config=$dst_opencode/opencode.json
config_state=
if [ ! -e "$config" ]; then
    cat > "$config" <<EOF
{
  "\$schema": "https://opencode.ai/config.json",
  "skills": ["$src_skills"]
}
EOF
    config_state=created
elif grep -qF "$src_skills" "$config"; then
    config_state=registered
else
    config_state=remind
fi

# --- report --------------------------------------------------------------------

printf 'commands: linked %d, already linked %d, skipped %d (in %s)\n' \
    "$linked" "$already" "$skipped" "$dst_commands"

case $config_state in
    created)
        printf 'config: created %s with skills entry\n' "$config"
        ;;
    registered)
        printf 'config: %s already registers %s\n' "$config" "$src_skills"
        ;;
    remind)
        cat <<EOF

NOTE: $config already exists. Add this repo's skills directory to it
so the linked commands can load their skills:

  "skills": ["$src_skills"]

EOF
        ;;
esac

if [ "$skipped" -gt 0 ]; then
    printf '%s\n' "skipped names were left untouched; move them aside and re-run to link them"
fi

printf '%s\n' "run 'opencode service restart' to pick up the changes"
