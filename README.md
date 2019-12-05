# minio-kafka-notification-test
docker compose that bringing up a kafka cluster with ss\tls auth and a minio instance for testing purposes

# depends on
 - bash
 - keytool from Oracle\Open JDK
 - [kafkacat](https://github.com/edenhill/kafkacat/releases) 
 - docker and [docker-compose](https://github.com/docker/compose/releases)
 - git

# usage
 - to start cd to `minio-kafka-notification-test` repo directory and run `./start.sh` script
 - to stop cd to `minio-kafka-notification-test` repo directory and run `./clean.sh` script

# what it does
 - pulls git repo minio with this PR https://github.com/minio/minio/pull/8609
 - builds minio binary
 - builds docker image with `Dockerfile.dev`
 - generates server and client certificates and also keystores for kafka cluster
 - starts a docker-compose with kafka broker, minio, mc anf few other containers
 - adds host to mc config file
 - adds kafka configuration to minio cluster
 - generationg random files for test puposes with size 1,2 and 5Mb
 - creating a test bucket
 - adds event listener to that bucket
 - puting test files to minio
 - checking kafka topic with notification events
