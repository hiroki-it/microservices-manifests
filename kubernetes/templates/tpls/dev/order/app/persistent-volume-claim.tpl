{{- define "dev.order.app.persistent-volume-claim" }}
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  namespace: microservices
  name: order-app-host-path-persistent-volume-claim
  labels:
    app: order
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
      app: order
      component: app
      env: {{ .Values.labels.env }}
      type: hostPath
{{- end }}
