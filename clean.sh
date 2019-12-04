#!/bin/bash
echo "cleanup files"
rm -rf payload && rm -rf testpayload* & rm certs/snakeoil* certs/client* certs/kafka* & docker-compose stop && docker-compose rm --force 
#rm -rf minio
