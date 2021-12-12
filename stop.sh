#!/bin/bash
pids=$(pgrep -f processing)
for pid in "${pids}"; do
	echo "processing ID: ${pid}"
done
