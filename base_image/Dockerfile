FROM ringo/scientific:7.1
# Load in yum repos
COPY yum_repos/cobbler-config.repo yum_repos/sl-extras.repo /etc/yum.repos.d/
# Install 241 packages
RUN yum install -y clang gcc gdb make valgrind
