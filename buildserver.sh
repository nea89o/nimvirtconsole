#!/bin/bash

current_dir=$(dirname "$(readlink $0)")
cd "$current_dir"


echo "Executing initial build."
./build.sh --quiet

while IFS= read -r change; do
    case "$change" in
        ./buildserver.sh)
            echo "Detected change in buildserver script. Restarting."
            # Using bash ./buildserver.sh over regular ./buildserver.sh to avoid race conditions.
            bash ./buildserver.sh
            exit 0
            ;;
        ./build.sh|./src/*|.res/*)
            echo "Detected source change at $change. Rebuilding."
            ./build.sh --quiet
            ;;
        ./.git/*|./dist/*)
            ## Known ignorable changes.
            ;;
        *)
            echo "Unknown change $change. Ignoring."
            ;;
    esac
done < <(inotifywait . -r -m --format %w%f -e modify,create,move,close_write,moved_to 2>/dev/null)
