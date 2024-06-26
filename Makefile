VENV = .venv
BIN = $(VENV)/bin
PYTHON = $(BIN)/python
PIP = $(BIN)/pip
TEST = pytest

# Self documenting commands
.DEFAULT_GOAL := help
.PHONY: help
help: ## show this help
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%s\033[0m|%s\n", $$1, $$2}' \
	| column -t -s '|'

$(VENV)/bin/activate: requirements.txt
	python3 -m venv .venv
	$(PIP) install -U pip
	$(PIP) install -r requirements.txt

clean: ## Remove temporary files
	rm -rf .ipynb_checkpoints
	rm -rf **/.ipynb_checkpoints
	rm -rf __pycache__
	rm -rf **/__pycache__
	rm -rf **/**/__pycache__
	rm -rf .pytest_cache
	rm -rf **/.pytest_cache
	rm -rf .ruff_cache
	rm -rf .coverage
	rm -rf build
	rm -rf dist
	rm -rf *.egg-info

show-bump: ## Show the next version
	@bump-my-version show-bump

bump-patch: $(VENV)/bin/activate ## Bump patch version
	@$(MAKE) show-bump
	@printf "Applying patch bump\n"
	@$(BIN)/bump-my-version bump patch

bump-minor: $(VENV)/bin/activate ## Bump minor version
	@$(MAKE) show-bump
	@printf "Applying minor bump\n"
	@$(BIN)/bump-my-version bump minor

bump-major: $(VENV)/bin/activate ## Bump major version
	@$(MAKE) show-bump
	@printf "Applying major bump\n"
	@$(BIN)/bump-my-version bump major

update: $(VENV)/bin/activate ## Update pip and pre-commit
	$(PIP) install -U pip
	$(PYTHON) -m pre_commit autoupdate

lint: $(VENV)/bin/activate ## Run pre-commit hooks
	$(PYTHON) -m pre_commit install --install-hooks
	$(PYTHON) -m pre_commit run --all-files

build: $(VENV)/bin/activate ## Generate distrubition packages
	$(PYTHON) -m build

publish: $(VENV)/bin/activate ## Publish to PyPI
	$(MAKE) lint
	$(MAKE) build
	$(PYTHON) -m twine upload --repository pypi dist/*
	$(MAKE) clean
