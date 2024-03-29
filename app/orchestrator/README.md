# orchestrator

![Version: 1.0.0](https://img.shields.io/badge/Version-1.0.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.0.0](https://img.shields.io/badge/AppVersion-1.0.0-informational?style=flat-square)

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| hiroki hasegawa |  |  |

## Source Code

* <https://github.com/hiroki-it/microservices-manifests>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| aws.accountId | string | `nil` |  |
| aws.region | string | `nil` |  |
| aws.user.accessKeyId | string | `nil` |  |
| aws.user.secretAccessKey | string | `nil` |  |
| global.env | string | `"prd"` |  |
| global.serviceName | string | `"orchestrator"` |  |
| image.orchestrator.fastapi | float | `690000000000` |  |
| ingressGateway.pod.listenPort | int | `50004` |  |
| service.listenPort | int | `50004` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.12.0](https://github.com/norwoodj/helm-docs/releases/v1.12.0)
