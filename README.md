CS 241 Autograder Docker
========================
Instead of actually integrating Docker into our huge autograder code base, I
isolated the basic usage into a single bash script and supplementary
Dockerfiles that handle the Docker things. The bash script handles generating
the Docker images as necessary.

It may be necessary to run it within UIUC's network since there are some UIUC
repositories required to correctly match the 241 VM environment.

As a side note, due to the way Docker runs the process as PID 1, the programs
will ignore SIGINT and SIGTERM by default so ctrl-c won't work. Instead, you
can run `docker kill $(docker ps -q)` to send a SIGKILL to all running docker
containers.

Below are various ways to execute malicious C programs I've made within Docker.
You can choose to run one of them within Docker with the single argument to the
bash script. Here are the three ways to call the script.

`./run_docker.sh fork_bomb`
`./run_docker.sh root_access`
`./run_docker.sh rm_root`

## Fork Bomb
This program does exactly what it says and starts a fork bomb after 3 or so
seconds. The bash script starts the program in Docker, and then attempts to
stop the Docker container a few seconds after the bomb detonates.

Unfortunately Docker doesn't seem to have any per-container process limits.
This makes it less effective than our other technique for dealing with fork
bombs (intercepting the dynamic call to fork() with dlsym). However, I can use
the kernel memory limit for the same purpose. This combined with cpu and memory
limits is moderately effective since the system is still mostly usable even
during the fork bomb. Although killing the process still takes longer than
ideal, fork bombs are not crippling when isolated within a Docker container.

## Root Access
This program very simply copies the executables cat and sh into the host's
directory and sets the set-uid bit on them. Of course, this requires the host
to mount its directory into the Docker container, but that's a very convenient
option so I suspect plenty of people do it. Anyways, since Docker processes
"run" as root inside Docker, when the executables are copied out, they will
still have root permissions in the host. Of course, the user needs to execute
the file in order for malicious code to run, but it is possible that the
attacker could trick the user into executing something.

After creating the root-access executables, the script will attempt to cat
/etc/shadow as a demonstration of root permissions and then start a root-access
shell.

The Docker developers claim that this is intended behaviour since in their
mind, any one with the ability to run Docker containers essentially has root
access already. However, this basically means I am running these programs as
root and relying on Docker to not have vulnerabilities which doesn't reduce the
attack surface really and instead just moves it.

As a side note, on my machine, the malicious sh doesn't work due to shared
libraries being weird, but hopefully cat is simple enough to not run into those
issues.

## Rm Root
This basically just runs `rm -rf --no-preserve-root /`. Very simple trick and
very easily stopped by Docker since Docker sets up a separate file system layer
by default.
