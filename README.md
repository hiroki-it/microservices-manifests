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
4. 本リポジトリ上のGitHub Actionsは，releaseブランチのプッシュを検知する．この時，HelmがValuesファイルを基にして実行計画用のマニフェストファイルを自動生成し，これをプルリク上にプッシュする．
5. SREチームのリリース責任者は，生成されたマニフェストファイルをレビューし，プルリクをmainブランチにマージする． 
6. GitHub Actionが，mainブランチのマージを検知する．この時，Valuesファイルの機密性の高い値を環境変数で上書きする．このValuesファイルを各チャート内にコピーし，チャートをAWS ECRにプッシュする．これらにより，Valuesファイルの機密情報のバージョン管理を避けつつ，本番環境では完全なValuesファイルを使用できる． 
7. AWS EKS上で稼働するArgoCDが，mainブランチのマージを検知し，AWS ECRからチャートをプルする．
8. Kubernetesリソースのデプロイが完了する．

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
├── release/ # 実行計画としてのマニフェストファイル．Helmによって自動生成される．
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

マイクロサービス間通信の管理方法は，リクエストリプライ方式に基づくサービスメッシュを実現するIstioを採用します．

プロキシコンテナはEnvoyとしますが，インバウンド通信をFastCGIプロトコルでルーティングする場合にNginxも用いる想定です．

この時，HTTPプロトコルによる同期通信を行い，gRPCプロトコルは用いない想定です．

ちなみに，イベント駆動方式を採用している場合は，イベントメッシュになります．

参考：https://www.redhat.com/ja/topics/integration/what-is-an-event-mesh

### CI/CD

開発環境ではSkaffoldを用いてCI/CDを実行します．

一方で，本番環境ではCIをGitHub Actionsで，またCDをArgoCDで実行します．

| 役割          | ツール                   | 導入の状況 |
|-------------|-----------------------|-------|
| CI/CD（開発環境） | Skaffold              | ⭕     |
| CI（本番環境）    | GitHub Actions & Helm | ⭕     |
| CD（本番環境）    | ArgoCD                | ⭕     |

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
