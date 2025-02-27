SHELL := /bin/bash

include $(PWD)/tools/terraform.Makefile

.PHONY: oauth-token hmac-token github-oauth-config cookie plugins update-config

### Prow Components

update-jobs:
	@$(MAKE) -C prow/update-jobs build
	prow/update-jobs/bin/update-jobs --kubeconfig $$HOME/.kube/config --jobs-config-path config/jobs/

oauth-token:
	kubectl create secret generic oauth-token --from-literal=oauth="$${PROW_OAUTH_TOKEN}" --dry-run -o yaml | kubectl replace secret oauth-token -f -

hmac-token:
	kubectl create secret generic hmac-token --from-literal=hmac="$${PROW_HMAC_TOKEN}" --dry-run -o yaml | kubectl replace secret hmac-token -f -

github-oauth-config:
	kubectl create secret generic github-oauth-config --from-file=secret=./config/prow/github_oauth" --dry-run -o yaml | kubectl replace secret github-oauth-config -f -

cookie:
	kubectl create secret generic cookie --from-file=secret=./config/prow/cookie.txt" --dry-run -o yaml | kubectl replace secret cookie -f -

plugins:
	kubectl create configmap plugins --from-file=plugins.yaml=config/plugins.yaml --dry-run -o yaml | kubectl replace configmap plugins -f -

update-config:
	kubectl create configmap config --from-file=config.yaml=config/config.yaml --dry-run -o yaml | kubectl replace configmap config -f -

prow-s3-credentials:
	kubectl create secret generic s3-credentials --from-literal=service-account.json="$${PROW_SERVICE_ACCOUNT_JSON}" --dry-run -o yaml | kubectl replace secret s3-credentials -f -

prow:
	kubectl apply -f config/prow/

kubeconfig:
	aws eks --region eu-west-1 update-kubeconfig --name falco-prow-test-infra --profile default
