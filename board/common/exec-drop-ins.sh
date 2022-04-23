#!/bin/sh
script_path="$0"
script_name="$(basename ${script_path})"
target_dir="$(echo ${script_name} | cut -d. -f1)"
target_path="$(dirname ${script_path})/${target_dir}.d"
for script in "${target_path}"/*.sh; do
	"${script}"
done
