# microservices-manifests

## 概要

マイクロサービスアーキテクチャのアプリケーションのインフラ領域を管理するリポジトリ．

GitOpsの **[ベストプラクティス](https://blog.argoproj.io/5-gitops-best-practices-d95cb0cbe9ff)** に則って，バックエンド領域は **[microservices-backendリポジトリ](https://github.com/hiroki-it/microservices-backend)** で管理しています．

フロントエンド領域のリポジトリは用意しておりません．


<br>

## 開発運用シナリオ

SREチームが以下のようなシナリオで開発運用していること，を想定しながら練習しております．

1. SREチームは，各マイクロサービスのイメージがAWS ECRのいずれのリポジトリで管理されているか，またコンテナのインバウンド通信を受け付けるポートは何番か，を知っておく必要がある．
2. SREチームは，本番環境のAWS EKS上でKubernetesを稼働させる前に，Skaffoldを用いてMinikube上でKubernetesの挙動を検証する．DBとして，本番環境ではAWS RDS(Aurora)を用いるが，開発環境ではMySQLコンテナを用いる．
3. SREチームは，マニフェストファイルのソースコードを変更し，プルリクを作成する．またGitFlowを経て変更がreleaseブランチにマージされる．
4. 本リポジトリ上のGitHub Actionsは，releaseブランチのプッシュを検知する．この時，HelmがValuesファイルを基にして実行計画用のマニフェストファイルを自動生成し，これをプルリク上にプッシュする．
5. SREチームのリリース責任者は，生成されたマニフェストファイルをレビューし，プルリクをmainブランチにマージする． 
6. GitHub Actionが，mainブランチのマージを検知する．この時，Valuesファイルの機密性の高い値を環境変数で上書きする．このValuesファイルを各チャート内にコピーし，チャートをAWS ECRにプッシュする．これらにより，Valuesファイルの機密情報のバージョン管理を避けつつ，本番環境では完全なValuesファイルを使用できる． 
7. AWS EKS上で稼働するArgoCDが，mainブランチのマージを検知し，AWS ECRからチャートをプルする．
8. Kubernetesリソースのデプロイが完了する．

<br>

## 設計方針

### ディレクトリ構成

ディレクトリ構成は以下の通りとします。

ユーザ定義のチャートは、```app```ディレクトリと```infra```ディレクトリ配下に配置しています。

一方で、公式チャートはチャートリポジトリを参照しています。

複数のチャートから構成される一部のツール（Istioなど）、各チャートのリポジトリを監視する孫Applicationを用意し、これを子Applicationで管理しています。

```yaml
repository/
├── README.md
├── app
│   ├── account # Accountサービスが占有するKubernetesリソース (例：Deployment)
│   ├── shared # 各マイクロサービスが共有するKubernetesリソース (例：Namespace)
│   ...
│
├── deploy
│   ├── argocd
│   │   ├── app # アプリチームの占有Applicationを配置
│   │   ├── infra # インフラチムの占有Applicationを配置
│   │   └── shared # 全チームの共有Applicationを配置
│   │       ├── parent # 親Applicationを配置
│   │       └── root # ルートApplicationを配置
│   │
│   ...
│
└── infra # インフラチームのツールごとのユーザ定義チャートを配置
    ├── shared  # インフラチームで各ツールが共有するKubernetesリソース (例：Namespace)
    ...
```

<br>

### 使用技術

#### ▼ インフラ

インフラ領域を構成する使用技術の一覧です．


| 役割                | ツール                | 導入の状況          |
|-------------------|--------------------|----------------|
| 仮想化               | Docker             | ⭕              |
| コンテナオーケストレーション    | Kubernetes         | ⭕              |
| マイクロサービス間通信の管理    | Istio | ⭕              |
| プロキシコンテナ          | Envoy，Nginx        | ⭕              |
| テンプレート管理          | Helm               | ⭕              |
| SagaパターンのためのQueue | AWS SQS            | coming soon... |
| API Gateway       | AWS API Gateway    | coming soon... |
| Kubernetesの実行環境   | AWS EKS            | coming soon... |

マイクロサービス間通信の管理方法は，リクエストリプライ方式に基づくサービスメッシュを実現するIstioを採用します．

プロキシコンテナはEnvoyとしますが，インバウンド通信をFastCGIプロトコルでルーティングする場合にNginxも用いる想定です．

この時，HTTPプロトコルによる同期通信を行い，gRPCプロトコルは用いない想定です．

ちなみに，イベント駆動方式を採用している場合は，イベントメッシュになります．

参考：https://www.redhat.com/ja/topics/integration/what-is-an-event-mesh

#### ▼ CI/CD

開発環境ではSkaffoldを用いてCI/CDを実行します．

一方で，本番環境ではCIをGitHub Actionsで，またCDをArgoCDで実行します．

| 役割          | ツール                   | 導入の状況 |
|-------------|-----------------------|-------|
| CI/CD（開発環境） | Skaffold              | ⭕     |
| CI（本番環境）    | GitHub Actions & Helm | ⭕     |
| CD（本番環境）    | ArgoCD                | ⭕     |

<br>

### ArgoCD

#### ▼ App-Of-Appsパターン

<img src="https://raw.githubusercontent.com/hiroki-it/helm-charts-practice/main/root-application.png" alt="root-application" style="zoom:80%;" />


ArgoCDでは、[App-Of-Appsパターン](https://argo-cd.readthedocs.io/en/stable/operator-manual/cluster-bootstrapping/#app-of-apps-pattern)を採用しており、以下のようなApplication構成になっています。

```yaml
argocd-root
├── argocd-app-parent # アプリチームのマイクロサービスごとのチャートをデプロイできる。
└── argocd-infra-parent # インフラチームのツールごとのチャートをデプロイできる
```

ArgoCDのルートApplication（argocd-root）のみ、ArgoCDを使用してデプロイできないため、Helmfileを使用しています。


#### ▼ プロジェクト

ArgoCDでは、プロジェクト名でApplicationをフィルタリングできます。

これは、Applicationの選び間違えるといったヒューマンエラーを防ぐことにつながります。

今現在、以下のプロジェクトを定義しています。

- root
- app
- infra

#### ▼ 認証認可

認証認可方法には、SSOを採用しています。

認証フェーズの委譲先としてGitHubを選び、GitHubへの通信時のハブとして```dex-server```を使用しています。

```bash
$ kubectl get deployment -n argocd

NAME                 READY   UP-TO-DATE   AVAILABLE   AGE
argocd-dex-server    1/1     1            1           41h # これ！
argocd-redis         1/1     1            1           41h
argocd-repo-server   1/1     1            1           41h
argocd-server        1/1     1            1           41h
```

<br>

## セットアップ

### ツールのインストール

asdfを使用して、ツールを一通りインストールします。

```bash
$ asdf install
```

<br>

### チャート仕様書の更新

```helm-docs```コマンドを使用して、チャート仕様書の更新を自動的に更新します。

valuesファイルの実装に基づいて、READMEを更新します。

```bash
$ helm-docs -f values-prd.yaml
```

<br>


### Minikube

#### ▼ 起動

Minikubeを起動します。

コンテナランタイムとして、Containerdを使用します。

CPUとメモリの要求量は任意で変更します。

```bash
# バージョン
$ KUBERNETES_VERSION=1.28.5

# パス
$ PROJECT_DIR=$(dirname $(pwd))

$ minikube start \
    --nodes 5 \
    --container-runtime=containerd \
    --driver=docker \
    --mount=true \
	--mount-string="${PROJECT_DIR}/microservices-backend:/data" \
	--kubernetes-version=v${KUBERNETES_VERSION} \
	--cpus=8 \
	--memory=12288
```

#### ▼ コンテキスト

コンテキストを切り替えます。

```bash
$ kubectx minikube
```

#### ▼ ワーカーNodeの種類分け

node affinityのために、ワーカーNodeの```metadata.labels```キー配下にNodeの種類を表すラベルを付与します。

```bash
# minikube-m01はコントロールプレーンNodeのため、ラベルを付与しない。
$ kubectl label node minikube-m02 node.kubernetes.io/nodegroup=app \
  && kubectl label node minikube-m03 node.kubernetes.io/nodegroup=deploy \
  && kubectl label node minikube-m04 node.kubernetes.io/nodegroup=ingress \
  && kubectl label node minikube-m05 node.kubernetes.io/nodegroup=system
```

#### ▼ ネットワークツールの導入

マイクロサービスアーキテクチャでは、ネットワークのデバッグのために、Linuxのパッケージを使用することがあります。

Minikube仮想サーバーにツールをインストールします。

```bash
$ minikube ssh -- "sudo apt-get update -y && sudo apt-get install -y tcptraceroute"
```

#### ▼ 削除

Minikubeを完全に削除します。

```bash
$ minikube delete --all --purge
```

<br>


### ArgoCD

#### ▼ デプロイ

```bash
$ cd deploy/argocd-root
$ helmfile -e dev -f helmfile.d/argocd.yaml diff
$ helmfile -e dev -f helmfile.d/argocd.yaml apply
```

```bash
$ cd deploy/argocd-root
$ helmfile -e dev -f helmfile.d/argocd-apps.yaml diff
$ helmfile -e dev -f helmfile.d/argocd-apps.yaml apply
```

#### ▼ ダッシュボードへのアクセス

本番環境では、Ingressを介してダッシュボードのPodに接続します。

一方で開発環境のMinikube上では、Ingressを介さずに、ArgoCDのPodに直接的に接続します。

```bash
$ kubectl port-forward svc/argocd-server -n argocd 8080:443
```

<br>


### アプリケーションへの接続

アプリケーションには [Hello Kubernetes!
](https://github.com/paulbouwer/hello-kubernetes) を採用しています。

istio-ingressgatewayのServiceは、NodePort Serviceとして設計しています。

そのため、```minikube service```コマンドから取得できるURLでアプリケーションに接続できます。

```bash
$ minikube service --url istio-ingressgateway -n istio-ingress

http://127.0.0.1:57774
```

アプリケーションに正しく接続できていれば、以下のような画面が表示されます。

![hello-kubernetes](https://raw.githubusercontent.com/paulbouwer/hello-kubernetes/main/hello-kubernetes.png)

また、レスポンスヘッダーの```server```キーから、```istio-proxy```コンテナを経由できていることを確認できます。

```yaml
HTTP/1.1 200 OK
---
x-powered-by: Express
content-type: text/html; charset=utf-8
content-length: 800
etag: W/"320-IKpy7WdeRlEJz8JSkGbdha/Cq88"
date: Mon, 20 Feb 2023 09:49:37 GMT
x-envoy-upstream-service-time: 379
server: istio-envoy # これ！！
```

<br>

### Prometheus、Alertmanager、Grafana

#### ▼ ダッシュボードへのアクセス

本番環境では、Ingressを介してダッシュボードのPodに接続します。

一方で開発環境のMinikube上では、Ingressを介さずに、これらのPodに直接的に接続します。

```bash
$ kubectl port-forward svc/kube-prometheus-stack-prometheus -n prometheus 9090:9090

$ kubectl port-forward svc/kube-prometheus-stack-alertmanager -n prometheus 9093:9093

# ユーザ名: admin
# パスワード: prom-operator
$ kubectl port-forward svc/kube-prometheus-stack-grafana -n prometheus 8000:80
```

<br> 

### Kiali

本番環境では、Ingressを介してダッシュボードのPodに接続します。

一方で開発環境のMinikube上では、Ingressを介さずに、KialiのPodに直接的に接続します。

```bash
$ kubectl port-forward svc/kiali 20001:20001 -n istio-system
```

<br>

### Jaeger


本番環境では、Ingressを介してダッシュボードのPodに接続します。

一方で開発環境のMinikube上では、Ingressを介さずに、JaegerのPodに直接的に接続します。

```bash
$ kubectl port-forward svc/jaeger-query 8081:80 -n jaeger
```

<br>
