AWS_REGION=us-east-1
AWS_PROFILE=default
AWS_SHARED_CREDENTIALS_FILE=../../.aws/credentials
AWS_CONFIG_FILE=../../.aws/config
AWS_SDK_LOAD_CONFIG=1
REPOSITORY_NAME=micropaywall-service
GIT_BRANCH := $(shell git rev-parse --abbrev-ref HEAD)
ENV := dev

version=

.PHONY: ecr-uri
ecr-uri:
	$(eval ECR_REPOSITORY := $(shell AWS_SHARED_CREDENTIALS_FILE=$(AWS_SHARED_CREDENTIALS_FILE) AWS_CONFIG_FILE=$(AWS_CONFIG_FILE) aws ecr describe-repositories --repository-names $(REPOSITORY_NAME) --region $(AWS_REGION) --profile $(AWS_PROFILE) --query 'repositories[0].repositoryUri' --output text))

.PHONY: build
build: gen-frontend
	docker build --progress=plain --platform linux/amd64 -t $(REPOSITORY_NAME):latest -f ./docker/Dockerfile .

.PHONY: run-local
run-local: build
	docker run -p 8080:3000 --rm --name $(REPOSITORY_NAME)-local $(REPOSITORY_NAME):latest

.PHONY: login-ecr
login-ecr: ecr-uri
	@AWS_SHARED_CREDENTIALS_FILE=$(AWS_SHARED_CREDENTIALS_FILE) AWS_CONFIG_FILE=$(AWS_CONFIG_FILE) aws ecr get-login-password --region $(AWS_REGION) --profile $(AWS_PROFILE) | \
	docker login --username AWS --password-stdin $(ECR_REPOSITORY)

.PHONY: tag-push-image
tag-push-image: ecr-uri
	@if [ -z "$(version)" ]; then \
		echo "\n\nError: version is not set. Please provide a version number.\n"; \
		echo "Example:"; \
		echo "\tmake deploy version=v0.0.1\n\n"; \
		exit 1; \
	fi
	@echo "\nDeploying version $(version) to $(ECR_REPOSITORY)\n"
	docker tag $(REPOSITORY_NAME):latest $(ECR_REPOSITORY):$(version)
	docker push $(ECR_REPOSITORY):$(version)
	@echo "\nCompleted deploy of $(version) to $(ECR_REPOSITORY)\n"

.PHONY: run-remote
run-remote: ecr-uri
	@if [ -z "$(version)" ]; then \
		echo "Error: version is not set. Please provide a version number."; \
		exit 1; \
	fi
	docker pull $(ECR_REPOSITORY):$(version)
	docker run -p 8080:3000 --rm --name $(REPOSITORY_NAME)-local $(ECR_REPOSITORY):$(version)

.PHONY: deploy
deploy: build
	cddc deploy --service-config ./service.yaml -p code$(ENV) -t latest

.PHONY: dev
dev:
	@echo "Starting development environment"
	cd packages/backend && npm run dev

.PHONY: gen-api
gen-api:
	cd packages/api && npm run gen

.PHONY: gen-db
gen-db:
	cd packages/database && npm run db:format
	cd packages/database && npm run db:init

.PHONY: gen-frontend
gen-frontend:
	cd packages/frontend && npm run build

.PHONY: gen
gen: gen-api gen-db gen-frontend

.PHONY: migrate
migrate:
	cd packages/database && npm run db:migrate

.PHONY: install
install:
	@echo "Installing dependencies"
	cd packages/api && npm install
	cd packages/api && npm run gen
	cd packages/database && npm install
	cd packages/database && npm run db:init
	cd packages/frontend && npm install
	cd packages/frontend && npm run build
	cd packages/backend && npm install

	@echo "Initializing database"

	@if [ ! -f packages/backend/.env ]; then \
		echo "\nError: packages/backend/.env file not found. Please create one using the template provided in packages/backend/.env.example"; \
		echo "\nExample:"; \
		echo "\tcp ./packages/backend/example.env ./packages/backend/.env\n\n"; \
		exit 1; \
	fi

	cd packages/database && npm run db:migrate

.PHONY: verifier-key
verifier-key:
	@echo "Generating verifier key"
	cd packages/backend && npm run script:gen-secret

.PHONY: backup-full
backup-full:
	@echo "Creating full backup of the application..."
	@mkdir -p ./backups
	@DATE=$$(date +"%Y%m%d"); \
	TIME=$$(date +"%H%M"); \
	KEYWORD_SUFFIX=""; \
	if [ ! -z "$(keyword)" ]; then \
		KEYWORD_SUFFIX="_$(keyword)"; \
		echo "Adding keyword: $(keyword)"; \
	fi; \
	BACKUP_FILE="./backups/$$DATE"_"$$TIME$$KEYWORD_SUFFIX.tar"; \
	echo "Backing up entire application..."; \
	tar --exclude="node_modules" --exclude="dist" --exclude=".git" -cf $$BACKUP_FILE $$(git ls-files) || true; \
	echo "Backing up database..."; \
	if [ -d "./packages/database" ]; then \
		(cd packages/database && npm run db:dump) || echo "Warning: Database backup failed"; \
		if [ -f "./packages/database/database_dump.sql" ]; then \
			tar -rf $$BACKUP_FILE packages/database/database_dump.sql || true; \
			rm ./packages/database/database_dump.sql; \
		else \
			echo "Warning: Database dump not found. Database was not backed up."; \
		fi; \
	fi; \
	echo "Including untracked files and uploads..."; \
	if [ -d "./packages/backend/uploads" ]; then \
		tar -rf $$BACKUP_FILE packages/backend/uploads || true; \
	fi; \
	echo "Including environment files..."; \
	find . -name ".env*" -not -path "*/node_modules/*" | xargs tar -rf $$BACKUP_FILE 2>/dev/null || true; \
	if [ -f "$$BACKUP_FILE" ]; then \
		echo "Compressing archive..."; \
		gzip -f $$BACKUP_FILE; \
		echo "Full backup created at $$BACKUP_FILE.gz"; \
	else \
		echo "Error: Backup file was not created successfully."; \
	fi

.PHONY: restore-full
restore-full:
	@if [ -z "$(backup)" ]; then \
		echo "\n\nError: backup file is not specified. Please provide a backup file."; \
		echo "Example:"; \
		echo "\tmake restore-full backup=./backups/20250321_1216_initial-test.tar.gz\n\n"; \
		exit 1; \
	fi; \
	echo "Restoring from backup $(backup)..."; \
	BACKUP_DIR="./backup_restore_temp"; \
	mkdir -p $$BACKUP_DIR; \
	echo "Extracting backup..."; \
	tar -xzf $(backup) -C $$BACKUP_DIR; \
	echo "Restoring application files..."; \
	cp -r $$BACKUP_DIR/* ./; \
	if [ -f "$$BACKUP_DIR/database_dump.sql" ]; then \
		echo "Restoring database..."; \
		cp $$BACKUP_DIR/database_dump.sql ./packages/database/; \
		cd packages/database && npm run db:restore; \
		rm database_dump.sql; \
	fi; \
	rm -rf $$BACKUP_DIR; \
	echo "Full restoration completed successfully."; \
	echo "You may need to run 'make install' to rebuild dependencies."

.PHONY: list-full-backups
list-full-backups:
	@echo "Available backups:"
	@ls -lh ./backups/*.tar.gz 2>/dev/null || echo "No backups found."

.PHONY: start
start:
	@echo "Starting application with PM2..."
	cd packages/backend && pm2 start src/server.ts --interpreter bun --name klypse-app || pm2 restart klypse-app

.PHONY: restart
restart:
	@echo "Restarting application with PM2..."
	cd packages/backend && pm2 restart klypse-app 2>/dev/null || pm2 start src/server.ts --interpreter bun --name klypse-app

.PHONY: stop
stop:
	@echo "Stopping application..."
	cd packages/backend && pm2 stop klypse-app || true

.PHONY: status
status:
	@echo "Checking application status..."
	pm2 status

.PHONY: start-dev
start-dev:
	@echo "Starting development application with PM2..."
	cd packages/backend && PORT=3000 pm2 start src/server.ts --interpreter bun --name klypse-dev-app --env development

.PHONY: start-prod
start-prod:
	@echo "Starting production application with PM2..."
	cd packages/backend && PORT=3001 pm2 start src/server.ts --interpreter bun --name klypse-prod-app --env production

.PHONY: restart-dev
restart-dev:
	@echo "Restarting development application with PM2..."
	cd packages/backend && pm2 restart klypse-dev-app 2>/dev/null || PORT=3000 pm2 start src/server.ts --interpreter bun --name klypse-dev-app --env development

.PHONY: restart-prod
restart-prod:
	@echo "Restarting production application with PM2..."
	cd packages/backend && pm2 restart klypse-prod-app 2>/dev/null || PORT=3001 pm2 start src/server.ts --interpreter bun --name klypse-prod-app --env production

.PHONY: stop-dev
stop-dev:
	@echo "Stopping development application..."
	cd packages/backend && pm2 stop klypse-dev-app || true

.PHONY: stop-prod
stop-prod:
	@echo "Stopping production application..."
	cd packages/backend && pm2 stop klypse-prod-app || true

.PHONY: push-dev
push-dev:
	@echo "Creating backup before pushing to dev..."
	@make backup-full keyword=pre-push
	@echo "Adding all changes to git..."
	git add .
	@echo "Committing changes..."
	@read -p "Enter commit message: " message; \
	git commit -m "$$message"
	@echo "Pushing to dev branch..."
	git push origin dev
	@echo "Changes pushed to dev branch successfully."