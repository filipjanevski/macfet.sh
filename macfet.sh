#!/bin/sh
#
# macfet.sh
# A fork of fet.sh, modified for macOS
# Original fet.sh @ https://github.com/eepykate/fet.sh
#

# Suppress errors
exec 2>/dev/null

# macOS Version
if v=/System/Library/CoreServices/SystemVersion.plist; [ -f "$v" ]; then
	temp=
	while read -r line; do
		case $line in
			*ProductVersion*) temp=.;;
			*)
				[ "$temp" ] || continue
				ID=${line#*>}
				ID="macOS ${ID%<*}"
				break
		esac
	done < "$v"
fi

# Hostname
host=$(hostname -s)

# Shell
shell="${SHELL##*/}"

# Terminal
term="${TERM_PROGRAM:-$TERM}"
[ "$term" = "Apple_Terminal" ] && term="Terminal"

# Uptime
uptime_seconds=$(sysctl -n kern.boottime | awk '{print $4}' | sed 's/,//')
current_time=$(date +%s)
uptime=$((current_time - uptime_seconds))
d=$((uptime / 60 / 60 / 24))
up=$(printf %02d:%02d $((uptime / 60 / 60 % 24)) $((uptime / 60 % 60)))
[ "$d" -gt 0 ] && up="${d}d $up"

# CPU
cpu=$(sysctl -n machdep.cpu.brand_string)
cpu=${cpu##*) }
cpu=${cpu%% @*}
cpu=${cpu%% CPU}
cpu=${cpu##CPU }

# Memory
mem_bytes=$(sysctl -n hw.memsize)
mem="$((mem_bytes / 1024 / 1024 / 1024))GB"

# Kernel
kernel=$(uname -r)

# Packages (Homebrew)
pkgs=0
if command -v brew >/dev/null 2>&1; then
	pkgs=$(brew list --formula 2>/dev/null | wc -l | tr -d ' ')
fi

# Color blocks
col() {
	printf '\t'
	for i in 1 2 3 4 5 6; do
		printf '\033[9%sm%s' "$i" "${colourblocks:-██}"
	done
	printf '\033[0m\n'
}

# Print function for 2-column layout
print_pair() {
	printf '\033[9%sm%6s\033[0m%b%-15s' \
		"${accent:-4}" "$1" "${separator:- ~ }" "$2"

	if [ "$3" ]; then
		printf '\033[9%sm%6s\033[0m%b%s' \
			"${accent:-4}" "$3" "${separator:- ~ }" "$4"
	fi
	printf '\n'
}

# Header
echo
printf '\t\033[92m%s \033[93m@ \033[92m%s\033[0m' "$USER" "$host"
echo

# Two column layout
print_pair "os" "$ID" "kern" "$kernel"
print_pair "cpu" "$cpu" "mem" "$mem"
print_pair "term" "$term" "sh" "$shell"
print_pair "pkgs" "$pkgs" "up" "$up"

# Color blocks
echo
col
echo
