#!/usr/bin/env bash

set -euo pipefail

REPO_OWNER="Fuzzwah"
REPO_NAME="code-agent-skills-and-commands"
REPO_REF="${AGENTIC_SKILLS_REF:-main}"
BASE_URL="${AGENTIC_SKILLS_BASE_URL:-https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${REPO_REF}}"
SKILLS_SOURCE_DIR="${AGENTIC_SKILLS_SOURCE_DIR:-skills}"
PROMPT_INPUT="${AGENTIC_SKILLS_PROMPT_INPUT:-/dev/tty}"
PROMPT_OUTPUT="${AGENTIC_SKILLS_PROMPT_OUTPUT:-/dev/tty}"
TEMP_FILES=()
SELECTED_ARTIFACT_TYPES=()
SELECTED_PLATFORMS=()
SELECTED_SKILLS=()
SELECTED_CLAUDE_COMMANDS=()
SELECTED_PI_PROMPTS=()

ARTIFACT_TYPES=(skills claude-commands pi-prompts)
PLATFORMS=(claude copilot codex opencode)
SKILLS=(
  adversarial-review
  code-review
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
CLAUDE_COMMANDS=(
  shipit
)
PI_PROMPTS=()

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

array_contains() {
  local needle="$1"
  shift
  local value

  for value in "$@"; do
    [[ "${value}" == "${needle}" ]] && return 0
  done

  return 1
}

track_temp_file() {
  TEMP_FILES+=("$1")
}

untrack_temp_file() {
  local file_to_remove="$1"
  local remaining_files=()
  local current_file

  for current_file in "${TEMP_FILES[@]:-}"; do
    [[ "${current_file}" == "${file_to_remove}" ]] || remaining_files+=("${current_file}")
  done

  TEMP_FILES=("${remaining_files[@]}")
}

cleanup_temp_files() {
  local temp_file

  for temp_file in "${TEMP_FILES[@]:-}"; do
    [[ -n "${temp_file}" && -e "${temp_file}" ]] && rm -f -- "${temp_file}"
  done

  return 0
}

detect_default_platforms() {
  DETECTED_PLATFORMS=()

  [[ -d ".claude" ]] && add_unique "claude" DETECTED_PLATFORMS
  [[ -d ".github" ]] && add_unique "copilot" DETECTED_PLATFORMS
  [[ -d ".codex" ]] && add_unique "codex" DETECTED_PLATFORMS
  [[ -d ".opencode" ]] && add_unique "opencode" DETECTED_PLATFORMS

  return 0
}

artifact_type_label() {
  case "$1" in
    skills) printf 'Skills' ;;
    claude-commands) printf 'Claude commands' ;;
    pi-prompts) printf 'Pi prompts' ;;
    *) return 1 ;;
  esac
}

platform_label() {
  case "$1" in
    claude) printf 'Claude Code (.claude → .claude/skills)' ;;
    copilot) printf 'GitHub Copilot (.github → installs to .github/skills)' ;;
    codex) printf 'OpenAI Codex (.codex → .codex/skills)' ;;
    opencode) printf 'OpenCode (.opencode → .agents/skills)' ;;
    *) return 1 ;;
  esac
}

platform_destination() {
  case "$1" in
    claude) printf '.claude/skills' ;;
    copilot) printf '.github/skills' ;;
    codex) printf '.codex/skills' ;;
    opencode) printf '.agents/skills' ;;
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
      4|opencode) add_unique "opencode" PARSED_PLATFORMS ;;
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

parse_named_selection() {
  local input="$1"
  local source_array_name="$2"
  local output_array_name="$3"
  local normalized token value found
  local -n source_array="${source_array_name}"
  local -n output_array="${output_array_name}"

  output_array=()
  normalized="$(printf '%s' "${input}" | tr '[:upper:]' '[:lower:]' | tr ',' ' ')"

  for token in ${normalized}; do
    if [[ "${token}" == "all" ]]; then
      output_array=("${source_array[@]}")
      return 0
    fi

    found=0

    if [[ "${token}" =~ ^[0-9]+$ ]] && (( token >= 1 && token <= ${#source_array[@]} )); then
      add_unique "${source_array[$((token - 1))]}" output_array
      found=1
    else
      for value in "${source_array[@]}"; do
        if [[ "${token}" == "${value}" ]]; then
          add_unique "${value}" output_array
          found=1
          break
        fi
      done
    fi

    (( found )) || return 1
  done

  [[ ${#output_array[@]} -gt 0 ]]
}

choose_artifact_types() {
  local response
  local index
  local artifact_type

  while true; do
    log_tty ""
    log_tty "Install agentic artifacts into: ${PWD}"
    log_tty ""
    log_tty "Choose artifact types to install:"

    index=1
    for artifact_type in "${ARTIFACT_TYPES[@]}"; do
      log_tty "  ${index}) $(artifact_type_label "${artifact_type}")"
      index=$((index + 1))
    done

    response="$(prompt "Artifact selection (comma-separated, 'all', or Enter for all): ")"

    if [[ -z "${response}" ]]; then
      SELECTED_ARTIFACT_TYPES=("${ARTIFACT_TYPES[@]}")
      return 0
    fi

    if parse_named_selection "${response}" "ARTIFACT_TYPES" "SELECTED_ARTIFACT_TYPES"; then
      return 0
    fi

    log_tty "Invalid selection. Please choose artifact numbers, names, or 'all'."
  done
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
  local opencode_status="no"

  [[ -d ".claude" ]] && claude_status="yes (.claude)"
  [[ -d ".github" ]] && copilot_status="yes (.github)"
  [[ -d ".codex" ]] && codex_status="yes (.codex)"
  [[ -d ".opencode" ]] && opencode_status="yes (.opencode)"

  while true; do
    log_tty ""
    log_tty "Detected project markers for skill installation:"
    log_tty "  - Claude: ${claude_status}"
    log_tty "  - Copilot: ${copilot_status}"
    log_tty "  - Codex: ${codex_status}"
    log_tty "  - OpenCode: ${opencode_status}"
    log_tty ""
    log_tty "Choose platforms to install skills for:"

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

    log_tty "Invalid selection. Please choose 1-4, platform names, or 'all'."
  done
}

choose_named_items() {
  local heading="$1"
  local prompt_message="$2"
  local source_array_name="$3"
  local selected_array_name="$4"
  local empty_message="${5:-}"
  local response
  local index
  local item
  local -n source_array="${source_array_name}"
  local -n selected_array="${selected_array_name}"

  if [[ ${#source_array[@]} -eq 0 ]]; then
    selected_array=()
    [[ -n "${empty_message}" ]] && log_tty "${empty_message}"
    return 0
  fi

  while true; do
    log_tty ""
    log_tty "${heading}"

    index=1
    for item in "${source_array[@]}"; do
      log_tty "  ${index}) ${item}"
      index=$((index + 1))
    done

    response="$(prompt "${prompt_message}")"

    if [[ -z "${response}" ]]; then
      selected_array=("${source_array[@]}")
      return 0
    fi

    if parse_named_selection "${response}" "${source_array_name}" "${selected_array_name}"; then
      return 0
    fi

    log_tty "Invalid selection. Please choose item numbers, names, or 'all'."
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
    fail "curl or wget is required to download artifacts"
  fi
}

install_remote_file() {
  local url="$1"
  local destination_path="$2"
  local artifact_name="$3"
  local temp_file

  mkdir -p "$(dirname "${destination_path}")"

  temp_file="$(mktemp "${TMPDIR:-/tmp}/agentic-artifact.XXXXXX")"
  track_temp_file "${temp_file}"

  if ! download_file "${url}" "${temp_file}"; then
    rm -f "${temp_file}"
    untrack_temp_file "${temp_file}"
    fail "failed to download ${artifact_name} from ${url}"
  fi

  [[ -s "${temp_file}" ]] || fail "downloaded ${artifact_name} from ${url} was empty"

  mv "${temp_file}" "${destination_path}"
  untrack_temp_file "${temp_file}"
  log "Installed ${artifact_name} → ${destination_path}"
}

install_skill() {
  local platform="$1"
  local skill="$2"
  local destination_root
  local destination_path
  local url

  destination_root="$(platform_destination "${platform}")"
  destination_path="${destination_root}/${skill}/SKILL.md"
  url="${BASE_URL}/${SKILLS_SOURCE_DIR}/${skill}/SKILL.md"

  install_remote_file "${url}" "${destination_path}" "skill ${skill}"
}

install_claude_command() {
  local command_name="$1"
  local destination_path=".claude/commands/${command_name}.md"
  local url="${BASE_URL}/claude-commands/${command_name}.md"

  install_remote_file "${url}" "${destination_path}" "Claude command ${command_name}"
}

install_pi_prompt() {
  local prompt_file="$1"
  local destination_path="pi-prompts/${prompt_file}"
  local url="${BASE_URL}/pi-prompts/${prompt_file}"

  install_remote_file "${url}" "${destination_path}" "Pi prompt ${prompt_file}"
}

main() {
  local platform
  local skill
  local command_name
  local prompt_file

  require_tty
  choose_artifact_types

  if array_contains "skills" "${SELECTED_ARTIFACT_TYPES[@]}"; then
    detect_default_platforms
    choose_platforms
    choose_named_items "Available skills:" "Skill selection (comma-separated, 'all', or Enter for all): " "SKILLS" "SELECTED_SKILLS"
  fi

  if array_contains "claude-commands" "${SELECTED_ARTIFACT_TYPES[@]}"; then
    choose_named_items "Available Claude commands:" "Claude command selection (comma-separated, 'all', or Enter for all): " "CLAUDE_COMMANDS" "SELECTED_CLAUDE_COMMANDS" "No Claude commands are available to install from this repository yet."
  fi

  if array_contains "pi-prompts" "${SELECTED_ARTIFACT_TYPES[@]}"; then
    choose_named_items "Available Pi prompts:" "Pi prompt selection (comma-separated, 'all', or Enter for all): " "PI_PROMPTS" "SELECTED_PI_PROMPTS" "No Pi prompts are available to install from this repository yet."
  fi

  log ""
  log "Installing selected artifacts..."

  if array_contains "skills" "${SELECTED_ARTIFACT_TYPES[@]}"; then
    for platform in "${SELECTED_PLATFORMS[@]}"; do
      log "Skills for: $(platform_label "${platform}")"
      for skill in "${SELECTED_SKILLS[@]}"; do
        install_skill "${platform}" "${skill}"
      done
    done
  fi

  if array_contains "claude-commands" "${SELECTED_ARTIFACT_TYPES[@]}" && [[ ${#SELECTED_CLAUDE_COMMANDS[@]} -gt 0 ]]; then
    log "Claude commands: .claude/commands"
    for command_name in "${SELECTED_CLAUDE_COMMANDS[@]}"; do
      install_claude_command "${command_name}"
    done
  fi

  if array_contains "pi-prompts" "${SELECTED_ARTIFACT_TYPES[@]}" && [[ ${#SELECTED_PI_PROMPTS[@]} -gt 0 ]]; then
    log "Pi prompts: pi-prompts"
    for prompt_file in "${SELECTED_PI_PROMPTS[@]}"; do
      install_pi_prompt "${prompt_file}"
    done
  fi

  log ""
  log "Done."
}

trap cleanup_temp_files EXIT

main "$@"
