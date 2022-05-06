# バージョン
KUBERNETES_VERSION := 1.23.5
ISTIO_ADDON_VERSION := 1.12
ARGOCD_VERSION := 2.3.3

# パス
PROJECT_DIR := $(shell dirname $(shell pwd))

# Minikubeを初期化します．
.PHONY: init
init:
	minikube start \
		--driver=hyperkit \
		--mount=true \
		--mount-string="${PROJECT_DIR}/microservices-backend:/data" \
		--kubernetes-version=v${KUBERNETES_VERSION} \
		--cpus=4 \
		--memory=16384 \
		--addons=metrics-server

# ポート8001番で，ローカルPCからワーカーノードにポートフォワードを実行します．
.PHONY: kubectl-proxy
kubectl-proxy:
	minikube kubectl -- proxy --address=0.0.0.0 --accept-hosts='.*' 

# K8sをデプロイします．
.PHONY: apply-k8s
apply-k8s:
	skaffold run --force --no-prune=false --cache-artifacts=false

# K8sをデプロイします．また，ポートフォワードを実行します．
.PHONY: apply-k8s-with-pf
apply-k8s-with-pf:
	skaffold run --force --no-prune=false --cache-artifacts=false --port-forward

# Istioをデプロイします．
.PHONY: apply-istio
apply-istio:
	istioctl operator init
	istioctl install -y -f ./release-plan/dev/istio-operator.yaml
	minikube kubectl -- apply -f ./release-plan/dev/istio.yaml
	istioctl verify-install

# Istioのダッシュボードをデプロイします．
.PHONY: apply-istio-dashboard
apply-istio-dashboard:
	minikube kubectl -- apply -f https://raw.githubusercontent.com/istio/istio/release-${ISTIO_ADDON_VERSION}/samples/addons/jaeger.yaml
	minikube kubectl -- apply -f https://raw.githubusercontent.com/istio/istio/release-${ISTIO_ADDON_VERSION}/samples/addons/kiali.yaml
	minikube kubectl -- apply -f https://raw.githubusercontent.com/istio/istio/release-${ISTIO_ADDON_VERSION}/samples/addons/prometheus.yaml

# Istioを削除します．
.PHONY: destroy-istio
destroy-istio:
	minikube kubectl -- delete -f ./release-plan/dev/istio.yaml
	istioctl x uninstall --purge -y

# マニフェストファイルを生成します．
.PHONY: plan-manifests
plan-manifests:
	helm package ./kubernetes ./istio ./argocd ./eks ./operator/istio -d ./archives
	helm template release ./archives/microservices-manifests-kubernetes-*.tgz -f values/dev.yaml >| ./release-plan/dev/kubernetes.yaml
	helm template release ./archives/microservices-manifests-istio-*.tgz -f values/dev.yaml >| ./release-plan/dev/istio.yaml
	helm template release ./archives/microservices-manifests-argocd-*.tgz -f values/dev.yaml >| ./release-plan/dev/argocd.yaml
	helm template release ./archives/microservices-manifests-eks-*.tgz -f values/dev.yaml >| ./release-plan/dev/eks.yaml

# ArgoCDをデプロイします．
.PHONY: apply-argocd
apply-argocd:
	minikube kubectl -- apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v${ARGOCD_VERSION}/manifests/install.yaml
	minikube kubectl -- patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
	minikube kubectl -- apply -f ./release-plan/prd/argocd.yaml

# ArgoCDにログインできるようにします．同時に，make kubectl-proxy を実行し，ロードバランサーを構築しておく必要があります．
.PHONY: expose-argocd
expose-argocd:
	minikube kubectl -- get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d; echo
	minikube kubectl -- port-forward svc/argocd-server -n argocd 8080:443

# ArgoCDを削除します．
.PHONY: destroy-argocd
destroy-argocd:
	minikube kubectl -- delete -f ./release-plan/dev/argocd.yaml
	minikube kubectl -- delete -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v${ARGOCD_VERSION}/manifests/install.yaml

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
	minikube delete
