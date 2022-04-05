# バージョン
KUBERNETES_VERSION := 1.23.5
ISTIO_ADDON_VERSION := 1.12
ARGOCD_VERSION := 2.3.1

# パス
PROJECT_DIR := $(shell dirname $(shell pwd))

# Minikubeを初期化します．
init:
	minikube start \
		--driver=hyperkit \
		# ホストPCのディレクトリをワーカーノードにマウント \
		--mount=true \
		--mount-string="${PROJECT_DIR}/microservices-backend:/data" \
		# Kubernetesのバージョンを指定する． \
		--kubernetes-version=v${KUBERNETES_VERSION} \
		# Istioを使用するために必要な最低限のスペック \
		--cpus=4 \
		--memory=16384 \
		# 拡張機能の有効化（メトリクスの有効化） \
		--addons=metrics-server
		# dockerクライアントの向き先の変更 \
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
	istioctl install -y -f ./release/dev/istio-operator.yaml
	minikube kubectl -- apply -f ./release/dev/istio.yaml
	istioctl verify-install

# Istioのダッシュボードをデプロイします．
apply-istio-dashboard:
	minikube kubectl -- apply -f https://raw.githubusercontent.com/istio/istio/release-${ISTIO_ADDON_VERSION}/samples/addons/jaeger.yaml
	minikube kubectl -- apply -f https://raw.githubusercontent.com/istio/istio/release-${ISTIO_ADDON_VERSION}/samples/addons/kiali.yaml
	minikube kubectl -- apply -f https://raw.githubusercontent.com/istio/istio/release-${ISTIO_ADDON_VERSION}/samples/addons/prometheus.yaml

# Istioを削除します．
destroy-istio:
	minikube kubectl -- delete -f ./release/dev/istio.yaml
	istioctl x uninstall --purge -y

# ArgoCDをデプロイします．
apply-argocd:
	minikube kubectl -- apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v${ARGOCD_VERSION}/manifests/install.yaml
	minikube kubectl -- patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
	minikube kubectl -- apply -f ./release/dev/argocd.yaml

# ArgoCDにログインできるようにします．同時に，make kubectl-proxy を実行し，ロードバランサーを構築しておく必要があります．
expose-argocd:
	minikube kubectl -- get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d; echo
	minikube kubectl -- port-forward svc/argocd-server -n argocd 8080:443

# ArgoCDを削除します．
destroy-argocd:
	minikube kubectl -- delete -f -f ./release/dev/argocd.yaml
	minikube kubectl -- delete -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v${ARGOCD_VERSION}/manifests/install.yaml

# マニフェストファイルを生成します．
helm-template:
	helm package ./kubernetes ./istio ./argocd ./eks ./operator/istio
	helm template release microservices-manifests-kubernetes-*.tgz -f values/dev.yaml >| ./release/dev/kubernetes.yaml
	helm template release microservices-manifests-istio-*.tgz -f values/dev.yaml >| ./release/dev/istio.yaml
	helm template release microservices-manifests-argocd-*.tgz -f values/dev.yaml >| ./release/dev/argocd.yaml
	helm template release microservices-manifests-eks-*.tgz -f values/dev.yaml >| ./release/dev/eks.yaml
	helm template release microservices-manifests-operator-istio-*.tgz -f values/dev.yaml >| ./release/dev/istio-operator.yaml

# ロードテストを実行します．同時に，make kubectl-proxy を実行し，ロードバランサーを構築しておく必要があります．
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
