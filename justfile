_default:
    @just --justfile {{source_file()}} --list

# Run the hook, linter, commit check and consistency tests
test:
    tests/session-start.sh
    tests/lint-docs.sh
    tests/check-commits.sh
    tests/consistency.sh

# Check shell scripts, docs and unpushed commits, and validate the plugin and marketplace manifests
lint:
    shellcheck plugin/scripts/*.sh plugin/conventions/templates/*.sh tests/*.sh
    plugin/conventions/templates/lint-docs.sh
    plugin/conventions/templates/check-commits.sh
    claude plugin validate .
    claude plugin validate plugin

# Lint and test, as CI would
check: lint test

# Add this checkout as a local marketplace and install the plugin from it
install:
    #!/usr/bin/env bash
    set -euo pipefail
    source=$(claude plugin marketplace list | grep -A1 ' devkit$' | sed -n 's/.*Source: //p')
    if [[ -n "$source" && "$source" != "Folder ({{justfile_directory()}})" ]]; then
      echo "devkit is installed from $source. Remove it first with:" >&2
      echo "  claude plugin uninstall devkit@devkit && claude plugin marketplace remove devkit" >&2
      exit 1
    fi
    [[ -n "$source" ]] || claude plugin marketplace add {{justfile_directory()}}
    claude plugin install devkit@devkit

# Start a session with the plugin loaded from this checkout, without installing it
run *args:
    claude --plugin-dir plugin {{args}}
