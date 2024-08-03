#!/bin/bash

debug_on() {
  # Set debug mode on
  set -x

  # Set colorful prompt for debug output
  local COLOR_RESET='\e[0m'
  local COLOR_GRAY='\e[90m'  # Gray, normal
  local COLOR_INFO='\e[34m\e[1m'  # Blue, bold
  local COLOR_WARN='\e[33m\e[1m'  # Yellow, bold
  local COLOR_ERROR='\e[31m\e[1m'  # Red, bold
  local COLOR_SUCCESS='\e[32m\e[1m'  # Green, bold
  local COLOR_DEBUG='\e[35m\e[1m'  # Magenta, bold

  # Randomly select a prompt style
  local DEBUG_PROMPT_STYLES=(INFO WARN ERROR SUCCESS DEBUG)
  local RANDOM_INDEX=$(( RANDOM % ${#DEBUG_PROMPT_STYLES[@]} ))
  local DEBUG_PROMPT_STYLE=${DEBUG_PROMPT_STYLES[$RANDOM_INDEX]}

  # Set different prompts for different types of output
  local PS4_INFO="${COLOR_INFO} ${LINENO}: ${FUNCNAME[0]}() + ${COLOR_RESET}"
  local PS4_WARN="${COLOR_WARN} ${LINENO}: ${FUNCNAME[0]}() + ${COLOR_RESET}"
  local PS4_ERROR="${COLOR_ERROR} ${LINENO}: ${FUNCNAME[0]}() + ${COLOR_RESET}"
  local PS4_SUCCESS="${COLOR_SUCCESS} ${LINENO}: ${FUNCNAME[0]}() + ${COLOR_RESET}"
  local PS4_DEBUG="${COLOR_DEBUG} ${LINENO}: ${FUNCNAME[0]}() + ${COLOR_RESET}"

  # Set the prompt based on the random style
  case $DEBUG_PROMPT_STYLE in
    INFO) PS4=$PS4_INFO ;;
    WARN) PS4=$PS4_WARN ;;
    ERROR) PS4=$PS4_ERROR ;;
    SUCCESS) PS4=$PS4_SUCCESS ;;
    DEBUG) PS4=$PS4_DEBUG ;;
  esac

  # Add a subtle gray color to the prompt
  PS4="${COLOR_GRAY}❯ $PS4${COLOR_RESET}"
}