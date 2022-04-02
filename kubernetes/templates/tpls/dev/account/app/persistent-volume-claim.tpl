{{- define "account.app.persistent-volume-claim" }}
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  namespace: microservices
  name: account-app-host-path-persistent-volume-claim
  labels:
    app: account
    component: app
    env: {{ .Values.labels.env }}
spec:
  storageClassName: standard
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
  selector:
    matchLabels:
      app: account
      component: app
      env: {{ .Values.labels.env }}
      type: hostPath
{{- end }}
