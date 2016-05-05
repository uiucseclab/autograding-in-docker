FROM cs241:base
WORKDIR /code
COPY fork_bomb.c Makefile ./
RUN make
ENTRYPOINT ["./fork_bomb"]
