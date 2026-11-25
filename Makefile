.PHONY: setup up down lint test ingest ask eval report run

setup: ## Install dependencies and the git hooks
	uv sync
	uv run pre-commit install

up: ## Start Postgres with pgvector
	docker compose up -d --wait

down: ## Stop Postgres (data is kept in the volume)
	docker compose down

lint: ## Run every pre-commit check on all files
	uv run pre-commit run --all-files

test: ## Run the tests with coverage
	uv run pytest

ingest:
	@echo "make ingest: not implemented yet (see #10 and #11)" && exit 1

ask:
	@echo "make ask: not implemented yet (see #11)" && exit 1

eval report:
	@echo "make $@: not implemented yet (see #13)" && exit 1

run:
	@echo "make run: not implemented yet (see #25)" && exit 1
