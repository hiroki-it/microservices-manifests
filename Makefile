# バージョン
KUBERNETES_VERSION := 1.28.5

# パス
PROJECT_DIR := $(shell dirname $(shell pwd))

# Minikubeを初期化します．
.PHONY: init
init:
	minikube start \
		--container-runtime=containerd \
		--driver=docker \
		--mount=true \
		--mount-string="${PROJECT_DIR}/microservices-backend:/data" \
		--kubernetes-version=v${KUBERNETES_VERSION} \
		--cpus=2 \
		--memory=4096 \
		--addons=metrics-server

# ロードテストを実行します．同時に，make kubectl-proxy を実行し，ロードバランサーを構築しておく必要があります．
# @see https://github.com/fortio/fortio#command-line-arguments
ISTIO_LB_IP = $(shell minikube kubectl -- get service/istio-ingressgateway --namespace=istio-system -o jsonpath="{.status.loadBalancer.ingress[0].ip}")
.PHONY: load-test-account
load-test-account:
	docker run fortio/fortio load -c 1 -n 100 http://${ISTIO_LB_IP}/account/
.PHONY: load-test-customer
load-test-customer:
	docker run fortio/fortio load -c 1 -n 100 http://${ISTIO_LB_IP}/customers/
.PHONY: load-test-order
load-test-order:
	docker run fortio/fortio load -c 1 -n 100 http://${ISTIO_LB_IP}/orders/

# Minikubeを削除します．
.PHONY: clean
clean:
	minikube delete --all --purge
