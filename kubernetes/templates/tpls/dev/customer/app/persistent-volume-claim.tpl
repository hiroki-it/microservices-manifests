{{- define "dev.customer.app.persistent-volume-claim" }}
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  namespace: microservices
  name: customer-app-host-path-persistent-volume-claim
  labels:
    app: customer
    component: app
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
      app: customer
      component: app
      env: {{ .Values.general.env }}
      type: hostPath
{{- end }}
