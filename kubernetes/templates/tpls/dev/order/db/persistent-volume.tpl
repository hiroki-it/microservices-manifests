{{- define "dev.order.db.persistent-volume" }}
apiVersion: v1
kind: PersistentVolume
metadata:
  namespace: microservices
  name: order-db-persistent-volume
  labels:
    app: order
    component: db
    env: {{ .Values.general.env }}
    type: hostPath
spec:
  storageClassName: standard
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  hostPath:
    path: /data/src/order
    type: DirectoryOrCreate
{{- end }}
