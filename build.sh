#!/bin/bash
base_dir=$(dirname "$(readlink $0)")

if ! command -v sass >/dev/null; then
    echo "Error: Please install sass (or provide it on the path)"
    echo "Example install: pnpm install --global sass"
    exit 1
fi

if ! command -v nim >/dev/null; then
    echo "Error: Please install nim (or provide it on the path)"
    echo "Example install: pacman -S nim"
    exit 1
fi


nim_args=()
uglify=0

while [[ $# -gt 0 ]]; do
    case "$1" in
        --release)
            nim_args+="-d:release"
            uglify=1
            shift
            ;;
        --quiet)
            nim_args+="--hints:off"
            shift
            ;;
        *)
            echo "Unknown argument $1"
            echo "Available arguments are: --release, --quiet"
            exit 1
    esac
done


mkdir -p -- "$base_dir"/dist
rm -rf -- "$base_dir"/dist/*
cp -r -- "$base_dir"/res/* "$base_dir"/dist
sass "$base_dir/src/index.sass" "$base_dir/dist/index.css"
nim js "${nim_args[@]}" -o:"$base_dir"/dist/index.js -p:src "$base_dir"/src/index.nim

if [ $uglify = 1 ]; then
    if ! command -v uglifyjs >/dev/null; then
        echo "Error: Please install uglifyjs (or provide it on the path)"
        echo "Example install: pnpm install --global uglify-js"
        exit 1
    fi
    uglifyjs "$base_dir"/dist/index.js -o "$base_dir"/dist/index.min.js --toplevel -c -m
    mv "$base_dir"/dist/index.min.js "$base_dir"/dist/index.js
fi
