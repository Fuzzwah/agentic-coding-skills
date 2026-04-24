#!/usr/bin/env bash

set -euo pipefail

REPO_OWNER="Fuzzwah"
REPO_NAME="agentic-coding-skills"
REPO_REF="${AGENTIC_SKILLS_REF:-main}"
BASE_URL="${AGENTIC_SKILLS_BASE_URL:-https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${REPO_REF}}"
PROMPT_INPUT="${AGENTIC_SKILLS_PROMPT_INPUT:-/dev/tty}"
PROMPT_OUTPUT="${AGENTIC_SKILLS_PROMPT_OUTPUT:-/dev/tty}"

PLATFORMS=(claude copilot codex)
SKILLS=(
  adversarial-review
  architecture-planning
  create-agents-file
  dependency-audit
  documentation-writer
  incident-review
  migration-assistant
  onboarding-guide
  performance-review
  refactoring-guide
  security-audit
  support-engineer
  test-generation
)

log() {
  printf '%s\n' "$*"
}

log_tty() {
  printf '%s\n' "$*" >"${PROMPT_OUTPUT}"
}

fail() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

require_tty() {
  [[ -r "${PROMPT_INPUT}" && -w "${PROMPT_OUTPUT}" ]] || fail "interactive prompts require a TTY; run this command from a terminal"
}

prompt() {
  local message="$1"
  local response

  printf '%s' "${message}" >"${PROMPT_OUTPUT}"
  IFS= read -r response <"${PROMPT_INPUT}" || fail "unable to read your selection"
  printf '%s' "${response}"
}

add_unique() {
  local item="$1"
  local -n target_array="$2"
  local existing

  for existing in "${target_array[@]:-}"; do
    [[ "${existing}" == "${item}" ]] && return
  done

  target_array+=("${item}")
}

detect_default_platforms() {
  DETECTED_PLATFORMS=()

  [[ -d ".claude" ]] && add_unique "claude" DETECTED_PLATFORMS
  ([[ -d ".copilot" ]] || [[ -d ".github" ]]) && add_unique "copilot" DETECTED_PLATFORMS
  [[ -d ".codex" ]] && add_unique "codex" DETECTED_PLATFORMS

  return 0
}

platform_label() {
  case "$1" in
    claude) printf 'Claude Code (.claude → .claude/skills)' ;;
    copilot) printf 'GitHub Copilot (.copilot/.github → .github/skills)' ;;
    codex) printf 'OpenAI Codex (.codex → .codex/skills)' ;;
    *) return 1 ;;
  esac
}

platform_destination() {
  case "$1" in
    claude) printf '.claude/skills' ;;
    copilot) printf '.github/skills' ;;
    codex) printf '.codex/skills' ;;
    *) return 1 ;;
  esac
}

parse_platforms() {
  local input="$1"
  local normalized token

  PARSED_PLATFORMS=()
  normalized="$(printf '%s' "${input}" | tr '[:upper:]' '[:lower:]' | tr ',' ' ')"

  for token in ${normalized}; do
    case "${token}" in
      1|claude) add_unique "claude" PARSED_PLATFORMS ;;
      2|copilot|github) add_unique "copilot" PARSED_PLATFORMS ;;
      3|codex) add_unique "codex" PARSED_PLATFORMS ;;
      all)
        PARSED_PLATFORMS=("${PLATFORMS[@]}")
        return 0
        ;;
      *)
        return 1
        ;;
    esac
  done

  [[ ${#PARSED_PLATFORMS[@]} -gt 0 ]]
}

parse_skills() {
  local input="$1"
  local normalized token

  PARSED_SKILLS=()
  normalized="$(printf '%s' "${input}" | tr '[:upper:]' '[:lower:]' | tr ',' ' ')"

  for token in ${normalized}; do
    case "${token}" in
      1|adversarial-review) add_unique "adversarial-review" PARSED_SKILLS ;;
      2|architecture-planning) add_unique "architecture-planning" PARSED_SKILLS ;;
      3|create-agents-file) add_unique "create-agents-file" PARSED_SKILLS ;;
      4|dependency-audit) add_unique "dependency-audit" PARSED_SKILLS ;;
      5|documentation-writer) add_unique "documentation-writer" PARSED_SKILLS ;;
      6|incident-review) add_unique "incident-review" PARSED_SKILLS ;;
      7|migration-assistant) add_unique "migration-assistant" PARSED_SKILLS ;;
      8|onboarding-guide) add_unique "onboarding-guide" PARSED_SKILLS ;;
      9|performance-review) add_unique "performance-review" PARSED_SKILLS ;;
      10|refactoring-guide) add_unique "refactoring-guide" PARSED_SKILLS ;;
      11|security-audit) add_unique "security-audit" PARSED_SKILLS ;;
      12|support-engineer) add_unique "support-engineer" PARSED_SKILLS ;;
      13|test-generation) add_unique "test-generation" PARSED_SKILLS ;;
      all)
        PARSED_SKILLS=("${SKILLS[@]}")
        return 0
        ;;
      *)
        return 1
        ;;
    esac
  done

  [[ ${#PARSED_SKILLS[@]} -gt 0 ]]
}

choose_platforms() {
  local response
  local index
  local marker
  local platform
  local detected
  local claude_status="no"
  local copilot_status="no"
  local codex_status="no"

  [[ -d ".claude" ]] && claude_status="yes (.claude)"
  if [[ -d ".copilot" && -d ".github" ]]; then
    copilot_status="yes (.copilot and .github; installs to .github/skills)"
  elif [[ -d ".github" ]]; then
    copilot_status="yes (.github)"
  elif [[ -d ".copilot" ]]; then
    copilot_status="yes (.copilot detected; installs to .github/skills)"
  fi
  [[ -d ".codex" ]] && codex_status="yes (.codex)"

  while true; do
    log_tty ""
    log_tty "Install agentic-coding-skills into: ${PWD}"
    log_tty ""
    log_tty "Detected project markers:"
    log_tty "  - Claude: ${claude_status}"
    log_tty "  - Copilot: ${copilot_status}"
    log_tty "  - Codex: ${codex_status}"
    log_tty ""
    log_tty "Choose platforms to install for:"

    index=1
    for platform in "${PLATFORMS[@]}"; do
      marker=" "
      for detected in "${DETECTED_PLATFORMS[@]:-}"; do
        if [[ "${detected}" == "${platform}" ]]; then
          marker="x"
          break
        fi
      done
      log_tty "  [${marker}] ${index}) $(platform_label "${platform}")"
      index=$((index + 1))
    done

    if [[ ${#DETECTED_PLATFORMS[@]} -gt 0 ]]; then
      response="$(prompt "Platform selection (comma-separated, 'all', or Enter for detected defaults): ")"
      if [[ -z "${response}" ]]; then
        SELECTED_PLATFORMS=("${DETECTED_PLATFORMS[@]}")
        return 0
      fi
    else
      response="$(prompt "Platform selection (comma-separated or 'all'): ")"
    fi

    if parse_platforms "${response}"; then
      SELECTED_PLATFORMS=("${PARSED_PLATFORMS[@]}")
      return 0
    fi

    log_tty "Invalid selection. Please choose 1-3, platform names, or 'all'."
  done
}

choose_skills() {
  local response
  local index
  local skill

  while true; do
    log_tty ""
    log_tty "Available skills:"

    index=1
    for skill in "${SKILLS[@]}"; do
      log_tty "  ${index}) ${skill}"
      index=$((index + 1))
    done

    response="$(prompt "Skill selection (comma-separated, 'all', or Enter for all): ")"

    if [[ -z "${response}" ]]; then
      SELECTED_SKILLS=("${SKILLS[@]}")
      return 0
    fi

    if parse_skills "${response}"; then
      SELECTED_SKILLS=("${PARSED_SKILLS[@]}")
      return 0
    fi

    log_tty "Invalid selection. Please choose skill numbers, names, or 'all'."
  done
}

download_file() {
  local url="$1"
  local output_path="$2"

  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "${url}" -o "${output_path}"
  elif command -v wget >/dev/null 2>&1; then
    wget -qO "${output_path}" "${url}"
  else
    fail "curl or wget is required to download skills"
  fi
}

install_skill() {
  local platform="$1"
  local skill="$2"
  local destination_root
  local destination_dir
  local temp_file
  local url

  destination_root="$(platform_destination "${platform}")"
  destination_dir="${destination_root}/${skill}"
  url="${BASE_URL}/${skill}/SKILL.md"
  temp_file="$(mktemp)"

  mkdir -p "${destination_dir}"

  if ! download_file "${url}" "${temp_file}"; then
    rm -f "${temp_file}"
    fail "failed to download ${skill} from ${url}"
  fi

  mv "${temp_file}" "${destination_dir}/SKILL.md"
  log "Installed ${skill} → ${destination_dir}/SKILL.md"
}

main() {
  local platform
  local skill

  require_tty
  detect_default_platforms
  choose_platforms
  choose_skills

  log ""
  log "Installing selected skills..."

  for platform in "${SELECTED_PLATFORMS[@]}"; do
    log "Platform: $(platform_label "${platform}")"
    for skill in "${SELECTED_SKILLS[@]}"; do
      install_skill "${platform}" "${skill}"
    done
  done

  log ""
  log "Done."
}

main "$@"
