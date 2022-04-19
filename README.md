# microservices-manifests

## 概要

マイクロサービスアーキテクチャのアプリケーションのインフラ領域を管理するリポジトリ．

GitOpsの **[ベストプラクティス](https://blog.argoproj.io/5-gitops-best-practices-d95cb0cbe9ff)** に則って，バックエンド領域は **[microservices-backendリポジトリ](https://github.com/hiroki-it/microservices-backend)** で管理しています．

現状，フロントエンド領域のリポジトリは用意しておりません．

<br>

## 開発運用シナリオ

SREチームが以下のようなシナリオで開発運用していること，を想定しながら練習しております．

1. SREチームは，各マイクロサービスのイメージがAWS ECRのいずれのリポジトリで管理されているか，またコンテナのインバウンド通信を受け付けるポートは何番か，を知っておく必要がある．
2. SREチームは，本番環境のAWS EKS上でKubernetesを稼働させる前に，Skaffoldを用いてMinikube上でKubernetesの挙動を検証する．DBとして，本番環境ではAWS RDS(Aurora)を用いるが，開発環境ではMySQLコンテナを用いる．
3. SREチームは，マニフェストファイルのソースコードを変更し，プルリクを作成する．またGitFlowを経て変更がreleaseブランチにマージされる．
4. 本リポジトリ上のGitHub Actionsは，releaseブランチのプッシュを検知する．releaseブランチのプッシュを検知する．この時，HelmがValuesファイルを基にしてマニフェストファイルを自動生成し，これをプルリク上にプッシュする．ただし，ArgoCDはあくまでAWS ECRを監視しており，生成されたマニフェストファイルは実行計画のみのために用いられる．
5. SREチームのリリース責任者は，生成されたマニフェストファイルをレビューし，プルリクをmainブランチにマージする． 
6. GitHub Actionが，mainブランチのマージを検知する．この時，Valuesファイルの機密性の高い値を環境変数で上書きする．このファイルを各チャート内にコピーし，チャートをAWS ECRにプッシュする．
7. AWS EKS上で稼働するArgoCDは，AWS ECRのチャートの変更を検知し，AWS ECRからチャートをプルする．

参考：

- Kubernetesマニフェスト: https://hiroki-it.github.io/tech-notebook-mkdocs/infrastructure_as_code/infrastructure_as_code_container_kubernetes_manifest_yaml.html
- Istioマニフェスト: https://hiroki-it.github.io/tech-notebook-mkdocs/infrastructure_as_code/infrastructure_as_code_container_istio_manifest_yaml.html
- Helmチャート: https://hiroki-it.github.io/tech-notebook-mkdocs/infrastructure_as_code/infrastructure_as_code_container_helm_chart.html
- ArgoCD: https://hiroki-it.github.io/tech-notebook-mkdocs/devops/devops_argocd.html
- Skaffold: https://hiroki-it.github.io/tech-notebook-mkdocs/infrastructure_as_code/infrastructure_as_code_container_skaffold_yaml.html

<br>

## ディレクトリ構成

```bash
project/
├── Makefile
├── README.md
├── argocd/ # ArgoCDのチャート
├── eks/ # EKSのチャート
├── istio/ # Istioのチャート
├── kubernetes/ # Kubernetesのチャート
├── operator/ # 各リソースのOperator
├── release-plan/ # 実行計画としてのマニフェストファイル．Helmによって自動生成される．
│   ├── dev/ # 開発環境のマニフェストファイル．バージョン管理されないことに注意
│   └── prd/ # 本番環境のマニフェストファイル
├── skaffold.yaml
└── values/ # HelmのValuesファイル
```

<br>


## 使用技術

### インフラ

インフラ領域を構成する使用技術の一覧です．

| 役割                | ツール                 | 導入の状況          |
|-------------------|---------------------|----------------|
| 仮想化               | Docker              | ⭕              |
| コンテナオーケストレーション    | Kubernetes          | ⭕              |
| マイクロサービス間通信の管理    | Istio，IstioOperator | ⭕              |
| プロキシコンテナ          | Envoy，Nginx         | ⭕              |
| テンプレート管理          | Helm                | ⭕              |
| SagaパターンのためのQueue | AWS SQS             | coming soon... |
| API Gateway       | AWS API Gateway     | coming soon... |
| Kubernetesの実行環境   | AWS EKS             | coming soon... |

### CI/CD

| 役割          | ツール                   | 導入の状況 |
|-------------|-----------------------|-------|
| CI/CD（開発環境） | Skaffold              | ⭕     |
| CI（本番環境）    | GitHub Actions & Helm | ⭕     |
| CD（本番環境）    | ArgoCD                | ⭕     |


### 補足

#### ▼ マイクロサービス間通信の管理

マイクロサービス間通信の管理方法は，リクエストリプライ方式に基づくサービスメッシュを実現するIstioを採用します．

プロキシコンテナはEnvoyとしますが，インバウンド通信をFastCGIプロトコルでルーティングする場合にNginxも用いる想定です．

この時，HTTPプロトコルによる同期通信を行い，gRPCプロトコルは用いない想定です．

ちなみに，イベント駆動方式を採用している場合は，イベントメッシュになります．

参考：https://www.redhat.com/ja/topics/integration/what-is-an-event-mesh

<br>

## 環境構築

### Minikube

```bash
$ make minikube-start

$ eval $(minikube -p minikube docker-env)
```

### Helm

```bash
make plan-manifests
````

### Kubernetes

```bash
$ make apply-k8s
```

### Istio

```bash
$ make apply-istio
```
