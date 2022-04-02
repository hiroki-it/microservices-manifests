{{- define "account.db.persistent-volume" }}
apiVersion: v1
kind: PersistentVolume
metadata:
  namespace: microservices
  name: account-db-persistent-volume
  labels:
    app: account
    component: db
    env: {{ .Values.labels.env }}
    type: hostPath
spec:
  storageClassName: standard
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  hostPath:
    path: /data/src/account
    type: DirectoryOrCreate
{{- end }}
