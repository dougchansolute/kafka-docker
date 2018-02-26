FROM anapsix/alpine-java

ARG kafka_version=1.0.0
ARG scala_version=2.12

MAINTAINER wurstmeister

ENV KAFKA_VERSION=$kafka_version \
    SCALA_VERSION=$scala_version \
    KAFKA_HOME=/opt/kafka \
    PATH=${PATH}:${KAFKA_HOME}/bin \
    KAFKA_ADVERTISED_PORT=9094 \
    KAFKA_PORT=9092 \
    KAFKA_ADVERTISED_HOST_NAME=wmkafka-dataanalytics.apps.osetrial.aws-gov.solute.us \
    KAFKA_HOST_NAME=localhost \
    KAFKA_ADVERTISED_PROTOCOL_NAME=OUTSIDE \
    KAFKA_PROTOCOL_NAME=INSIDE \
    KAFKA_LISTENER_SECURITY_PROTOCOL_MAP=INSIDE:PLAINTEXT,OUTSIDE:PLAINTEXT \
    KAFKA_ZOOKEEPER_CONNECT=10.129.1.227:2181



COPY download-kafka.sh start-kafka.sh broker-list.sh create-topics.sh /tmp/

RUN apk add --update unzip wget curl docker jq coreutils \
 && chmod a+x /tmp/*.sh \
 && mv /tmp/start-kafka.sh /tmp/broker-list.sh /tmp/create-topics.sh /usr/bin \
 && /tmp/download-kafka.sh \
 && tar xfz /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz -C /opt \
 && rm /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz \
 && ln -s /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION} /opt/kafka \
 && rm /tmp/*

VOLUME ["/kafka"]

EXPOSE 9092 9094

# Use "exec" form so that it runs as PID 1 (useful for graceful shutdown)
CMD ["start-kafka.sh"]
