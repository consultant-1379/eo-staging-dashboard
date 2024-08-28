#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
lib_dir="$(dirname "$DIR")"
root_dir="$(dirname "$lib_dir")"
red=$'\e[1;31m' ; grn=$'\e[1;32m' ; yel=$'\e[1;33m' ; blu=$'\e[1;34m' ; mag=$'\e[1;35m' ; cyn=$'\e[1;36m' ; end=$'\e[0m'


printf "\n\n\n\n${grn}BUILDING DASH BASE IMAGE${end}\n\n"
printf "copying gemfiles..."
rm "$DIR"/Gemfil*
\cp "$root_dir"/Gemfile "$DIR" 
\cp "$root_dir"/Gemfile.lock "$DIR"
docker build -f DockerfileDashBase -t armdocker.rnd.ericsson.se/proj_oss/dashbase:latest "$DIR"
printf "\n\n${grn}PUSHING DASH BASE IMAGE${end}\n\n"
docker push armdocker.rnd.ericsson.se/proj_oss/dashbase:latest
printf "\n\n${grn}FINISHED DASH BASE IMAGE${end}\n\n"
