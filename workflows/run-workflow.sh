DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
INPUT_JSON=${1:-${DIR}/example_input_json/WGS-hello-world/wgs.hello-world.input.json}
PACKED_WORKFLOW=${DIR}/packed.json
CACHE=/mnt/cache
TMP=/mnt/tmp
CID=/mnt/cid
JOB_UUID=16b6472c-a4fa-4bd2-9b94-789f30c192aa

/home/ubuntu/.virtualenvs/p2/bin/cwltool \
	--debug \
	--rm-tmpdir \
	--rm-container \
	--custom-net bridge \
	--tmp-outdir-prefix ${CACHE} \
	--tmpdir-prefix ${TMP} \
	--timestamps \
	--cidfile-dir ${CID} \
	--cidfile-prefix ${JOB_UUID} \
	${PACKED_WORKFLOW} ${INPUT_JSON}

