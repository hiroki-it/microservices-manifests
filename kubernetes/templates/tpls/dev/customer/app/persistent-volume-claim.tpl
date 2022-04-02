{{- define "dev.customer.app.persistent-volume-claim" }}
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  namespace: microservices
  name: customer-app-host-path-persistent-volume-claim
  labels:
    app: customer
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
      app: customer
      component: app
      env: {{ .Values.labels.env }}
      type: hostPath
{{- end }}
