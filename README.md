# microservices-infrastructure

## 概要

マイクロサービスアーキテクチャのアプリケーションのインフラ領域を管理するリポジトリ．

GitOpsの [ベストプラクティス](https://blog.argoproj.io/5-gitops-best-practices-d95cb0cbe9ff) に則って，バックエンド領域は **[microservices-backendリポジトリ](https://github.com/hiroki-it/microservices-backend)** で管理しています．

## 使用技術

### 一覧

インフラ領域を構成する使用技術の一覧です．

| 役割              | ツール                 | 導入の状況          |
|-----------------|---------------------|----------------|
| 仮想化             | Docker              | ◯              |
| コンテナオーケストレーション  | Kubernetes          | ◯              |
| マイクロサービス間通信の管理  | Istio，IstioOperator | ◯              |
| プロキシコンテナ        | Envoy，Nginx         | ◯              |
| テンプレート管理        | Helm                | coming soon... |
| API Gateway     | AWS API Gateway     | coming soon... |
| Kubernetesの実行環境 | AWS EKS             | coming soon... |

### マイクロサービス間通信の管理

マイクロサービス間通信の管理方法は，リクエストリプライ方式に基づくサービスメッシュを実現するIstioを採用します．

プロキシコンテナはEnvoyとしますが，インバウンド通信をFastCGIプロトコルでルーティングする場合にNginxも用いる想定です．

この時，HTTPプロトコルによる同期通信を行い，gRPCプロトコルは用いない想定です．

ちなみに，イベント駆動方式を採用している場合は，イベントメッシュになります．

参考：https://www.redhat.com/ja/topics/integration/what-is-an-event-mesh

### CI/CD

CI/CDを構成するツールの一覧です．

| 役割          | ツール      | 導入の状況          |
|-------------|----------|----------------|
| CI/CD（開発環境） | Skaffold | ◯              |
| CD（本番環境）    | ArgoCD   | coming soon... |

## 環境構築

### Minikube

```bash
$ make minikube-start

$ eval $(minikube -p minikube docker-env)
```

### Kubernetes

```bash
$ make apply-k8s
```

### Istio

```bash
$ make apply-istio
```

## 参考

Kubernetesマニフェスト：
<br>https://hiroki-it.github.io/tech-notebook-mkdocs/infrastructure_as_code/infrastructure_as_code_container_kubernetes_manifest_yml.html

Istioマニフェスト：
<br>https://hiroki-it.github.io/tech-notebook-mkdocs/infrastructure_as_code/infrastructure_as_code_container_istio_manifest_yml.html
