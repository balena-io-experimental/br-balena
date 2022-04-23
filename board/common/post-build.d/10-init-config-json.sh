#!/bin/bash
set_config() {
	# Make sure not to read and write the same file in the same pipeline.
	# https://github-wiki-see.page/m/koalaman/shellcheck/wiki/SC2094
	config=${1}
	path=${2}
	jq -S "${config}" "${path}" > "${path}.tmp" \
		&& mv "${path}.tmp" "${path}"
}

init_config_json() {
	if [ -z "${1}" ]; then
		echo "init_config_json: Needs a path"
		exit 1
	fi

	echo '{}' > "${1}"/config.json

	set_config ".persistentLogging=false" "${1}/config.json"
	set_config ".localMode=true" "${1}/config.json"
	set_config '.deviceType="genericx86-64-ext"' "${1}/config.json"
}

mkdir -p "${TARGET_DIR}/mnt/boot"
init_config_json "${TARGET_DIR}/mnt/boot/"
