.PHONY: help
help:
	@echo
	@echo "Commands:"
	@grep -E -h '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
	@echo

.PHONY: start
start: ## Start cluster [ex. make start]
	docker-compose up -d
	@echo "\033[92mCluster is ready\033[0m"
	@echo "\033[92mCheck the application status from:\033[0m"
	@echo "\033[92m- Spark Master UI: http://localhost:8080\033[0m"
	@echo "\033[92m- Spark Worker UI: http://localhost:8081\033[0m"
	@echo "\033[92m- Spark App UI: http://localhost:4040 (When app is running) \033[0m"
	@echo "\033[92mCheck ES status from:\033[0m"
	@echo "\033[92m- ES UI: http://localhost:9100\033[0m"
	@echo "\033[92m- Kibana UI: http://localhost:5601\033[0m"

.PHONY: run
run: start ## Run the application in the cluster [ex. make run]
	@echo "\033[92mBuilding the application artifacts...\033[0m"
	./mvnw clean package
	cp ./target/spark-es-loader-jar-with-dependencies.jar ./bin/spark-es-loader.jar
	@echo "\033[92mSubmitting application to cluster...\033[0m"
	docker-compose exec master bin/spark-submit --class net.cavdar.data.SparkEsLoader /app/spark-es-loader.jar

.PHONY: stop
stop: ## Stop all the nodes in the cluster. [ex. make stop]
	docker-compose down

.PHONY: ps
list: ## List all the nodes in the cluster. [ex. make list]
	docker-compose ps

.PHONY: logs
logs: ## Show logs for a host. [ex. make logs HOSTNAME=master|worker|elasticsearch|elasticsearch2|elasticsearch3]
	docker-compose logs -f $(HOSTNAME)
