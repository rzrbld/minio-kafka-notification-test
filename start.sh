#!/bin/bash
echo "Prepare env"
mkdir ./payload && \
echo "Checkout target minio" && \
git clone https://github.com/rzrbld/minio.git && \
echo "Build up a target minio image" && \
cd minio && make && docker build -t mytest/minio:test -f Dockerfile.dev . && \
echo "Generating SSL server and client certs for Kafka" && \
cd ../certs/ && ./certs-demo.sh && \
echo "Run Kafka stack and tested minio server" && \
cd .. && docker-compose up -d --build && \
echo "Wait for 1 minute" && \
sleep 80 && \
echo "minio add host" && \
bash -c "docker-compose run mc config host add local http://minio:9000/ test testtest123" && \
echo "minio set test config" && \
bash -c "docker-compose run mc admin config set local notify_kafka:1 tls_skip_verify=\"on\"  queue_dir=\"\" queue_limit=\"0\" sasl=\"off\" sasl_password=\"\" sasl_username=\"\" tls_client_auth=\"0\" tls=\"on\" client_tls_cert=\"/opt/minio/kafka/client-ca1-signed.crt\" client_tls_key=\"/opt/minio/kafka/client.key\" brokers=\"broker:9093\" topic=\"minio_event_notification\"" && \
bash -c "docker-compose run mc admin service restart local" && \
echo "Generating testfiles" && \
head -c 1MB /dev/urandom > ./payload/testpayload1.txt && \
head -c 2MB /dev/urandom > ./payload/testpayload2.txt && \
head -c 5MB /dev/urandom > ./payload/testpayload3.txt && \
echo "minio make test bucket" && \
docker-compose run mc mb local/testbucket && \
echo "minio add event listener on testbucket" && \
bash -c "docker-compose run mc event add local/testbucket arn:minio:sqs::1:kafka" && \
echo "copy test files to minio" && \
docker-compose run mc cp /root/payload/testpayload1.txt local/testbucket/testpayload1.txt && \
docker-compose run mc cp /root/payload/testpayload2.txt local/testbucket/testpayload2.txt && \
docker-compose run mc cp /root/payload/testpayload3.txt local/testbucket/testpayload3.txt && \
echo "check topic with kafkacat" && \
kafkacat -C -b localhost:9094 -t minio_event_notification -p 0 -o -1 -e && \
kafkacat -b localhost:9095 -X security.protocol=SSL -X ssl.key.location=./certs/client.key -X ssl.certificate.location=./certs/client-ca1-signed.crt -X ssl.ca.location=./certs/snakeoil-ca-1.crt -t minio_event_notification -e | if [ $(wc -l) -eq 3 ]; then echo "SUCCESS"; else echo "FAIL"; fi
