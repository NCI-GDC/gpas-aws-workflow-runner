INPUT_JSON=/home/ubuntu/input.json
PACKED_WORKFLOW=/home/ubuntu/packed.json
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

