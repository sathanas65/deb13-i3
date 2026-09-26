#!/bin/bash
# =====================================================================
#  APP PICKER
#  The menu that lets you tick which optional apps to install.
#  You should not need to edit this file - the list of apps lives in
#  optional-apps.sh.
# =====================================================================

APP_IDS=()              # every app, in install order
CATEGORIES=()           # menu pages, in the order they first appear
FAILED_APPS=()          # apps whose install failed
declare -A APP_DEFAULT APP_CATEGORY APP_DESC SELECTED CATEGORY_NOTE

# Called by a "category_note" line in optional-apps.sh:
# shows extra text at the top of that category's page
category_note() {
    if [ "$#" -ne 2 ]; then
        echo "optional-apps.sh: a 'category_note' line needs 2 parts, got $#: category_note $*" >&2
        exit 1
    fi
    CATEGORY_NOTE[$1]="$2"
}

# Called by each "app" line in optional-apps.sh
app() {
    if [ "$#" -ne 4 ]; then
        echo "optional-apps.sh: an 'app' line needs 4 parts, got $#: app $*" >&2
        exit 1
    fi
    local id="$1" def="$2" cat="$3" desc="$4"
    if [[ ! "$id" =~ ^[A-Za-z0-9_]+$ ]]; then
        echo "optional-apps.sh: app name '$id' may only use letters, numbers and _" >&2
        exit 1
    fi
    if [[ -n "${APP_DESC[$id]+x}" ]]; then
        echo "optional-apps.sh: app name '$id' is used twice" >&2
        exit 1
    fi
    case "$def" in
        on|off|vm) ;;
        *) echo "optional-apps.sh: app '$id' default must be on, off or vm (got '$def')" >&2; exit 1 ;;
    esac

    APP_IDS+=("$id")
    APP_DEFAULT[$id]="$def"
    APP_CATEGORY[$id]="$cat"
    APP_DESC[$id]="$desc"

    local c
    for c in "${CATEGORIES[@]}"; do
        [ "$c" = "$cat" ] && return 0
    done
    CATEGORIES+=("$cat")
}

# Load optional-apps.sh and make sure every app has its install_ function
load_apps() {
    # shellcheck source=optional-apps.sh
    source "$1"
    local id missing=0
    for id in "${APP_IDS[@]}"; do
        if ! declare -F "install_$id" >/dev/null; then
            echo "optional-apps.sh: app '$id' has no install_$id() function" >&2
            missing=1
        fi
    done
    [ "$missing" -eq 0 ] || exit 1
}

running_in_kvm() {
    case "$(systemd-detect-virt --vm 2>/dev/null || true)" in
        kvm|qemu) return 0 ;;
        *)        return 1 ;;
    esac
}

select_defaults() {
    local id in_vm=0
    running_in_kvm && in_vm=1
    for id in "${APP_IDS[@]}"; do
        case "${APP_DEFAULT[$id]}" in
            on) SELECTED[$id]=1 ;;
            vm) SELECTED[$id]=$in_vm ;;
            *)  SELECTED[$id]=0 ;;
        esac
    done
}

select_none() {
    local id
    for id in "${APP_IDS[@]}"; do SELECTED[$id]=0; done
}

count_selected() {   # count_selected [category]
    local id n=0
    for id in "${APP_IDS[@]}"; do
        [ -n "${1:-}" ] && [ "${APP_CATEGORY[$id]}" != "$1" ] && continue
        [ "${SELECTED[$id]:-0}" = 1 ] && n=$((n + 1))
    done
    echo "$n"
}

count_in_category() {
    local id n=0
    for id in "${APP_IDS[@]}"; do
        [ "${APP_CATEGORY[$id]}" = "$1" ] && n=$((n + 1))
    done
    echo "$n"
}

have_tty() { ( : </dev/tty >/dev/tty ) 2>/dev/null; }

# whiptail draws on the terminal directly, so the menu still works when
# the installer's output is piped to a log file (| tee install.log)
wt() {
    whiptail --backtitle "deb13-i3 installer" "$@" 3>&1 1>/dev/tty 2>&3 </dev/tty
}

# pick a box size that fits the screen
screen_size() {
    local rows=24 cols=80 size
    size="$(stty size </dev/tty 2>/dev/null || true)"
    if [ -n "$size" ]; then
        rows="${size% *}"
        cols="${size#* }"
    fi
    BOX_H=$(( rows - 2 )); [ "$BOX_H" -gt 40 ] && BOX_H=40; [ "$BOX_H" -lt 15 ] && BOX_H=15
    BOX_W=$(( cols - 6 )); [ "$BOX_W" -gt 90 ] && BOX_W=90; [ "$BOX_W" -lt 60 ] && BOX_W=60
    LIST_H=$(( BOX_H - 8 ))
}

pick_in_category() {
    local cat="$1" id out rc items=()
    for id in "${APP_IDS[@]}"; do
        [ "${APP_CATEGORY[$id]}" = "$cat" ] || continue
        if [ "${SELECTED[$id]:-0}" = 1 ]; then
            items+=("$id" "${APP_DESC[$id]}" ON)
        else
            items+=("$id" "${APP_DESC[$id]}" OFF)
        fi
    done

    screen_size
    local text="\nSPACE ticks / unticks an app.   ENTER when done.\n"
    local list_h="$LIST_H"
    if [ -n "${CATEGORY_NOTE[$cat]:-}" ]; then
        text="\n${CATEGORY_NOTE[$cat]}\n$text"
        list_h=$(( LIST_H - 3 ))
    fi
    rc=0
    out="$(wt --title " $cat " --notags --separate-output \
              --ok-button "Done" --cancel-button "Back" \
              --checklist "$text" \
              "$BOX_H" "$BOX_W" "$list_h" "${items[@]}")" || rc=$?
    [ "$rc" -eq 0 ] || return 0      # Back / Esc: keep previous choices

    for id in "${APP_IDS[@]}"; do
        if [ "${APP_CATEGORY[$id]}" = "$cat" ]; then
            SELECTED[$id]=0
        fi
    done
    while IFS= read -r id; do
        if [ -n "$id" ]; then
            SELECTED[$id]=1
        fi
    done <<< "$out"
    return 0
}

selection_summary() {
    local cat id text=""
    for cat in "${CATEGORIES[@]}"; do
        local lines=""
        for id in "${APP_IDS[@]}"; do
            if [ "${APP_CATEGORY[$id]}" = "$cat" ] && [ "${SELECTED[$id]:-0}" = 1 ]; then
                lines+="    ${APP_DESC[$id]}\n"
            fi
        done
        [ -n "$lines" ] && text+="$cat\n$lines\n"
    done
    [ -n "$text" ] || text="(no optional apps - only the base system)\n"
    printf '%b' "$text"
}

# The main menu.   choose_apps defaults   -> start with recommended picks
#                  choose_apps none       -> start with nothing ticked
# $PICKER_INTRO and $PICKER_GO_LABEL can change the wording.
choose_apps() {
    if [ "${1:-defaults}" = none ]; then select_none; else select_defaults; fi

    if ! command -v whiptail >/dev/null 2>&1; then
        echo "Installing whiptail for the app menu..."
        sudo apt-get install -y whiptail
    fi

    local choice rc last="GO" cat i total
    local intro="${PICKER_INTRO:-The base i3 desktop always gets installed.\nPick the extra apps you want, then choose Install.}"
    local go_label="${PICKER_GO_LABEL:->>  Install now}"

    while true; do
        screen_size
        total="$(count_selected)"
        local items=("GO" "$go_label  ($total apps ticked)")
        i=0
        for cat in "${CATEGORIES[@]}"; do
            i=$((i + 1))
            items+=("$i" "$(printf '%-22s %3s of %-3s ticked' "$cat" "$(count_selected "$cat")" "$(count_in_category "$cat")")")
        done
        items+=("DEFAULTS" "Reset to the recommended picks" "NONE" "Untick everything" "QUIT" "Quit without installing")

        rc=0
        choice="$(wt --title " Choose your apps " --notags --default-item "$last" \
                     --ok-button "Select" --cancel-button "Quit" \
                     --menu "\n$intro\n" "$BOX_H" "$BOX_W" "$LIST_H" "${items[@]}")" || rc=$?
        [ "$rc" -ne 0 ] && choice="QUIT"
        last="$choice"

        case "$choice" in
            GO)
                if wt --title " Ready to install " --scrolltext --yes-button "Install" --no-button "Back" \
                      --yesno "These apps will be installed:\n\n$(selection_summary)" "$BOX_H" "$BOX_W"; then
                    return 0
                fi ;;
            DEFAULTS)  select_defaults ;;
            NONE)      select_none ;;
            QUIT)
                if wt --title " Quit? " --yesno "Quit without installing anything?" 8 50; then
                    clear >/dev/tty 2>/dev/null || true
                    echo "Nothing was installed."
                    exit 0
                fi ;;
            *)         pick_in_category "${CATEGORIES[$((choice - 1))]}" || true ;;
        esac
    done
}

print_selection() {
    echo "=================================================="
    echo " Optional apps selected: $(count_selected)"
    echo "=================================================="
    selection_summary
}

# Install every ticked app, in the order they appear in optional-apps.sh.
# If one app fails, note it and carry on with the rest.
install_selected_apps() {
    local id rc n=0 total
    total="$(count_selected)"
    for id in "${APP_IDS[@]}"; do
        [ "${SELECTED[$id]:-0}" = 1 ] || continue
        n=$((n + 1))
        echo
        echo "=================================================="
        echo " [$n/$total] ${APP_DESC[$id]}"
        echo "=================================================="
        set +e
        ( set -e; "install_$id" )
        rc=$?
        set -e
        if [ "$rc" -ne 0 ]; then
            echo "!!! ${APP_DESC[$id]} failed (exit code $rc) - continuing with the rest"
            FAILED_APPS+=("$id")
        fi
    done
}

# Tell the user which apps failed (if any). Returns 1 if something failed.
report_failures() {
    local logfile="$1" id list=""
    [ "${#FAILED_APPS[@]}" -eq 0 ] && { rm -f "$logfile"; return 0; }

    for id in "${FAILED_APPS[@]}"; do
        list+="    ${APP_DESC[$id]}   ($id)\n"
    done
    printf 'These optional apps failed to install:\n%b' "$list" | tee "$logfile"
    echo "You can retry them later with:  bash install-apps.sh"

    if have_tty && command -v whiptail >/dev/null 2>&1; then
        screen_size
        wt --title " Some apps failed " --msgbox \
           "These apps did not install:\n\n${list}\nEverything else finished. The list is saved in\n$logfile\n\nTo try them again later, run:\n    bash install-apps.sh" \
           "$BOX_H" "$BOX_W" || true
    fi
    return 1
}
