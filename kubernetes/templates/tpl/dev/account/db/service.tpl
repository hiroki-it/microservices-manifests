{{- define "account.db.service" }}
apiVersion: v1
kind: Service
metadata:
  namespace: microservices
  name: account-db-service
  labels:
    app: account
    component: db
spec:
  clusterIP: None
  selector:
    app: account
    component: db
  ports:
    - name: tcp-account
      appProtocol: tcp
      port: 3306
      targetPort: 3306
{{- end }}
