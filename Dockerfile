FROM ubuntu:14.04

RUN apt-get update -y
RUN apt-get install -y wget libedit-dev libpython2.7-dev libxml2-dev libcurl4-openssl-dev git

ENV WORK_DIR=/root/Prorsum

RUN mkdir -p ${WORK_DIR}
WORKDIR ${WORK_DIR}

COPY . $WORK_DIR
RUN rm -rf ./Packages .build
WORKDIR ${WORK_DIR}

RUN ./Scripts/install-swift.sh
RUN ls -la
RUN swift build --configuration=release

CMD ["./build/release/Performance"]
