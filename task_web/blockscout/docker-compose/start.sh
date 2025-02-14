rm -rf ./services/blockscout-db-data
rm -rf ./services/logs
rm -rf ./services/redis-data
docker-compose up --build -d
