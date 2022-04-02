{{- define "orchestrator.app.persistent-volume" }}
apiVersion: v1
kind: PersistentVolume
metadata:
  namespace: microservices
  name: orchestrator-persistent-volume
  labels:
    app: orchestrator
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
    path: /data/src/orchestrator
  nodeAffinity:
    required:
      nodeSelectorTerms:
        - matchExpressions:
            - key: kubernetes.io/hostname
              operator: In
              values:
                - minikube
{{- end }}
