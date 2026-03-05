#!/usr/bin/env bash
set -euo pipefail

OUT_LEFT="DisplayPort-1"
OUT_RIGHT="DVI-D-0"
URI="qemu:///system"

N="${1:-}"; [[ "$N" =~ ^[0-5]$ ]] || { echo "usage: $0 <0-5>"; exit 2; }
VM_NAME=$([[ "$N" == 0 ]] && echo "Whonix-Workstation" || echo "Whonix-Workstation$N")
WS_LEFT="WhonixWS${N}-L"
WS_RIGHT="WhonixWS${N}-R"

# --- kill any existing virt-viewer sessions for this VM ---
pkill -f "virt-viewer.*$VM_NAME" 2>/dev/null || true


command -v i3-msg >/dev/null
command -v jq >/dev/null
command -v virt-viewer >/dev/null
command -v virsh >/dev/null

# --- ensure a libvirt domain is running, start if needed ---
ensure_running() {
  local name="$1"
  local label="${2:-$1}"  # for notification
  if ! virsh -c "$URI" dominfo "$name" >/dev/null 2>&1; then
    echo "VM not found: $name" >&2
    exit 1
  fi
  local state
  state="$(virsh -c "$URI" domstate "$name" 2>/dev/null | tr '[:upper:]' '[:lower:]')"
  if [[ "$state" != "running" ]]; then
    command -v dunstify >/dev/null 2>&1 && dunstify "Starting $label"
    virsh -c "$URI" start "$name"
    # wait up to ~60s for running
    for _ in {1..60}; do
      state="$(virsh -c "$URI" domstate "$name" 2>/dev/null | tr '[:upper:]' '[:lower:]')"
      [[ "$state" == "running" ]] && break
      sleep 1
    done
    [[ "$state" == "running" ]] || { echo "VM failed to reach running: $name" >&2; exit 1; }
  fi
}

# --- prereqs: Gateway first, then selected Workstation ---
ensure_running "Whonix-Gateway" "Whonix-Gateway"
ensure_running "$VM_NAME" "$VM_NAME"

# --- helpers ---
list_vm_windows() {
  # outputs: X11ID<TAB>title
  i3-msg -t get_tree | jq -r --arg vm "$VM_NAME" '
    def walk: .nodes[]?, .floating_nodes[]?;
    recurse(walk)
    | select(.window and (.name|tostring|contains($vm)))
    | "\(.window)\t\(.name)"'
}
win_ws() {  # workspace name for X11 id
  i3-msg -t get_tree | jq -r --argjson wid "$1" '
    def walk: .nodes[]?, .floating_nodes[]?;
    recurse(walk)
    | select(.window==$wid)
    | .. | objects | select(.type=="workspace") | .name' | head -n1
}
place_fullscreen() { # wid, ws, out
  i3-msg "focus output $3; [id=\"$1\"] move to workspace \"$2\"; workspace \"$2\"; [id=\"$1\"] focus; border pixel 0"
}

# --- fast-path: if viewer already open for this VM, just jump to workspaces and exit ---
i3-msg "focus output $OUT_LEFT;  workspace \"$WS_LEFT\""
i3-msg "focus output $OUT_RIGHT; workspace \"$WS_RIGHT\""
i3-msg "focus output $OUT_LEFT;  workspace \"$WS_LEFT\""

mapfile -t OPEN < <(list_vm_windows || true)
if (( ${#OPEN[@]} >= 1 )); then
  exit 0
fi

# Put workspaces on outputs and focus LEFT before launch
i3-msg "focus output $OUT_LEFT;  workspace \"$WS_LEFT\""
i3-msg "focus output $OUT_RIGHT; workspace \"$WS_RIGHT\""
i3-msg "focus output $OUT_LEFT;  workspace \"$WS_LEFT\""

# Launch or attach: let virt-viewer handle fullscreen
virt-viewer --full-screen --connect "$URI" --attach "$VM_NAME" >/dev/null 2>&1 &

# Wait for >=1 window, then up to ~20s for a second (if present)
for _ in {1..100}; do
  mapfile -t L < <(list_vm_windows || true)
  (( ${#L[@]} >= 1 )) && break
  sleep 0.2
done
(( ${#L[@]} >= 1 )) || { echo "No windows for $VM_NAME"; exit 1; }

for _ in {1..60}; do
  mapfile -t L < <(list_vm_windows || true)
  (( ${#L[@]} >= 2 )) && break
  sleep 0.2
done

get_id()   { cut -f1 <<<"$1"; }
get_title(){ cut -f2- <<<"$1"; }

shopt -s nocasematch
if (( ${#L[@]} >= 2 )); then
  LEFT_WID=""; RIGHT_WID=""
  for row in "${L[@]}"; do
    wid=$(get_id "$row"); tt=$(get_title "$row"); tt_lc="${tt,,}"
    if   [[ -z $LEFT_WID  && $tt =~ \([[:space:]]*1[[:space:]]*\) ]]; then
      LEFT_WID="$wid"
    elif [[ -z $RIGHT_WID && $tt =~ \([[:space:]]*2[[:space:]]*\) ]]; then
      RIGHT_WID="$wid"
    elif [[ -z $LEFT_WID  && "$tt_lc" == *"display 1"* ]]; then
      LEFT_WID="$wid"
    elif [[ -z $RIGHT_WID && "$tt_lc" == *"display 2"* ]]; then
      RIGHT_WID="$wid"
    fi
  done
  if [[ -z $LEFT_WID || -z $RIGHT_WID ]]; then
    mapfile -t _ids < <(printf '%s\n' "${L[@]}" | cut -f1)
    for id in "${_ids[@]}"; do
      if [[ -z $LEFT_WID && "$id" != "$RIGHT_WID" ]]; then
        LEFT_WID="$id"
      elif [[ -z $RIGHT_WID && "$id" != "$LEFT_WID" ]]; then
        RIGHT_WID="$id"
      fi
    done
  fi
  if [[ "$LEFT_WID" == "$RIGHT_WID" ]]; then
    declare -A seen; UNIQUE=()
    for row in "${L[@]}"; do wid=$(get_id "$row")
      [[ ${seen[$wid]+x} ]] || { UNIQUE+=("$wid"); seen[$wid]=1; }
    done
    (( ${#UNIQUE[@]} >= 2 )) || { echo "Only one distinct window for $VM_NAME"; exit 1; }
    LEFT_WID="${UNIQUE[0]}"; RIGHT_WID="${UNIQUE[1]}"
  fi

  place_fullscreen "$LEFT_WID"  "$WS_LEFT"  "$OUT_LEFT"
  place_fullscreen "$RIGHT_WID" "$WS_RIGHT" "$OUT_RIGHT"

  LWS="$(win_ws "$LEFT_WID"  || true)"
  RWS="$(win_ws "$RIGHT_WID" || true)"
  if [[ -n "$LWS" && "$LWS" == "$RWS" ]]; then
    place_fullscreen "$RIGHT_WID" "$WS_RIGHT" "$OUT_RIGHT"
  fi
else
  ONLY_WID="$(get_id "${L[0]}")"
  ONLY_TT="$(get_title "${L[0]}")"; ONLY_TT_LC="${ONLY_TT,,}"
  if [[ "$ONLY_TT" =~ \([[:space:]]*2[[:space:]]*\) || "$ONLY_TT_LC" == *"display 2"* ]]; then
    place_fullscreen "$ONLY_WID" "$WS_RIGHT" "$OUT_RIGHT"
  else
    place_fullscreen "$ONLY_WID" "$WS_LEFT"  "$OUT_LEFT"
  fi
fi
shopt -u nocasematch

i3-msg "focus output $OUT_LEFT; workspace \"$WS_LEFT\""
