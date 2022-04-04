{{- define "dev.orchestrator.app.persistent-volume-claim" }}
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  namespace: microservices
  name: orchestrator-host-path-persistent-volume-claim
  labels:
    app: orchestrator
    env: {{ .Values.general.env }}
spec:
  storageClassName: standard
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
  selector:
    matchLabels:
      app: orchestrator
      env: {{ .Values.general.env }}
      type: hostPath
{{- end }}
