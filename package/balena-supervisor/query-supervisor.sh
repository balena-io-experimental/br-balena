#!/bin/sh
_version="$1"
_arch="$2"
_version_flt="(supervisor_version+eq+'${_version}')"
_arch_flt="(is_for__device_type/any(ifdt:ifdt/is_of__cpu_architecture/any(ioca:ioca/slug+eq+'${_arch}')))"
curl -G --silent \
	-d "\$top=1" \
	-d "\$select=image_name" \
	-d "\$filter=${_version_flt}+and+${_arch_flt}" \
	https://api.balena-cloud.com/v6/supervisor_release \
	| jq -r '.d[].image_name'
