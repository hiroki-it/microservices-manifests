{{- define "dev.order.app.persistent-volume" }}
apiVersion: v1
kind: PersistentVolume
metadata:
  namespace: microservices
  name: order-app-persistent-volume
  labels:
    app: order
    component: app
    env: {{ .Values.labels.env }}
    type: hostPath
spec:
  storageClassName: standard
  capacity:
    storage: 2Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  local:
    path: /data/src/order
  nodeAffinity:
    required:
      nodeSelectorTerms:
        - matchExpressions:
            - key: kubernetes.io/hostname
              operator: In
              values:
                - minikube
{{- end }}
