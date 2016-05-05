FROM cs241:base
WORKDIR /code
COPY rm_root.c Makefile ./
RUN make
ENTRYPOINT ["./rm_root"]
