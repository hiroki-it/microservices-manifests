{{- define "customer.db.service" }}
apiVersion: v1
kind: Service
metadata:
  namespace: microservices
  name: customer-db-service
  labels:
    app: customer
    component: db
    env: {{ .Values.labels.env }}
spec:
  clusterIP: None
  selector:
    app: customer
    component: db
  ports:
    - name: tcp-customer
      appProtocol: tcp
      port: 3306
      targetPort: 3306
{{- end }}
