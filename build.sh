#!/bin/bash
set -euo pipefail

IMAGE=${IMAGE:-menduz/jsc:latest}

mkdir -p out && chmod 777 out
docker run --rm -t -v "$(pwd):/src" -w "/src" -v "$(pwd)/out:/out" \
    $IMAGE /bin/bash -c "
    set -euo pipefail
    shopt -s nullglob
    export OUT='/out'
    gn gen out --args=\"target_os=\\\"wasm\\\" is_debug=true\"
    ninja -C out
"

