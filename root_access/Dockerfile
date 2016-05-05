FROM cs241:base
WORKDIR /code
COPY root_access.c Makefile ./
RUN make
ENTRYPOINT ["./root_access"]
