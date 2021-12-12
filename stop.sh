#!/bin/bash
pids=$(pgrep -f processing)
for pid in "${pids}"; do
	if [[ $pid != $$ ]]; then
		echo "$pid"
	fi
done

