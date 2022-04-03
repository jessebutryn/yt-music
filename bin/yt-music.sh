#!/usr/bin/env bash
#
[[ $DEBUG == true ]] && set -x
#######################################
if [[ -f "${0%/*}/../lib/config" ]]; then
	. "${0%/*}/../lib/config"
else
	printf '%s\n' 'ERROR! Could not find lib/config' >&2
	exit 1
fi
#######################################
max_bg_procs () {
	local max_number=$((0 + ${1:-0}))
	while :; do
		local current_number=$(jobs -pr | wc -l)
		if [[ $current_number -lt $max_number ]]; then
			break
		fi
		sleep 2
	done
}
main () {
    file=$(youtube-dl -o "${output_dir}/%(title)s" --get-filename "$url")
    file="${file}.mp3"
    youtube-dl "${dl_opts[@]}" -o "${output_dir}/%(title)s.%(ext)s" "$url" >/dev/null
    if [[ ! -f "$file" ]]; then
        printf '%s\n' "$fail_file"
    fi
}
#######################################
dos2unix "$url_file" &>/dev/null
mapfile -t urls < "$url_file"
for url in "${urls[@]}"; do
    max_bg_procs 5
    main &
done
wait
echo > "$url_file"