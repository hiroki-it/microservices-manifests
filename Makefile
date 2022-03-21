# バージョン
KUBERNETES_VERSION := 1.23.0
ISTIO_ADDON_VERSION := 1.12
ARGOCD_VERSION := 2.3.1

# Minikubeを初期化します．
init: clean
	# ノードの構築
	minikube start \
		--driver=hyperkit \
		--mount=true \
		--mount-string="${HOME}/projects/hiroki-it/microservices-backend:/data" \
		--kubernetes-version=v${KUBERNETES_VERSION} \
		# Istioを使用するために必要な最低限のスペック
		--cpus=4 \
		--memory=16384
	# イングレスの有効化
	# minikube addons enable ingress
	# メトリクスの有効化
	minikube addons enable metrics-server
	# dockerクライアントの向き先の変更
	minikube docker-env
	# 手動で実行 
	# eval $(minikube -p minikube docker-env)

# ポート8001番で，ローカルPCからワーカーノードにポートフォワードを実行します．
kubectl-proxy:
	minikube kubectl -- proxy --address=0.0.0.0 --accept-hosts='.*' 

# K8sをデプロイします．
apply-k8s:
	skaffold run --force --no-prune=false --cache-artifacts=false

# K8sをデプロイします．また，ポートフォワードを実行します．
apply-k8s-with-pf:
	skaffold run --force --no-prune=false --cache-artifacts=false --port-forward

# Istioをデプロイします．
apply-istio:
	istioctl operator init
	istioctl install -y -f ./istio/install/operator.yml
	minikube kubectl -- apply -f ./istio/apply -R
	istioctl verify-install

# Istioのダッシュボードをデプロイします．
apply-istio-dashboard:
	minikube kubectl -- apply -f https://raw.githubusercontent.com/istio/istio/release-${ISTIO_ADDON_VERSION}/samples/addons/jaeger.yaml
	minikube kubectl -- apply -f https://raw.githubusercontent.com/istio/istio/release-${ISTIO_ADDON_VERSION}/samples/addons/kiali.yaml
	minikube kubectl -- apply -f https://raw.githubusercontent.com/istio/istio/release-${ISTIO_ADDON_VERSION}/samples/addons/prometheus.yaml

# ArgoCDをデプロイします．
apply-argocd:
	minikube kubectl -- apply -f ./argocd/install -R
	minikube kubectl -- apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v${ARGOCD_VERSION}/manifests/install.yaml
	minikube kubectl -- patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
	minikube kubectl -- apply -f ./argocd/apply -R

# Istioを削除します．
destroy-istio:
	istioctl x uninstall --purge -y

# ロードテストを実行します．同時に，make kubectl-proxy を実行しておく必要があります．
# @see https://github.com/fortio/fortio#command-line-arguments
ISTIO_LB_IP = $(shell minikube kubectl -- get service/istio-ingressgateway --namespace=istio-system -o jsonpath="{.status.loadBalancer.ingress[0].ip}")
load-test-account:
	docker run fortio/fortio load -c 1 -n 100 http://${ISTIO_LB_IP}/account/
load-test-customer:
	docker run fortio/fortio load -c 1 -n 100 http://${ISTIO_LB_IP}/customers/
load-test-order:
	docker run fortio/fortio load -c 1 -n 100 http://${ISTIO_LB_IP}/orders/

# Minikubeを削除します．
clean:
	minikube delete
