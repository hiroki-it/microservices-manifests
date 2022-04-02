{{- define "order.db.service" }}
apiVersion: v1
kind: Service
metadata:
  namespace: microservices
  name: order-db-service
  labels:
    app: order
    component: db
    env: {{ .Values.labels.env }}
spec:
  clusterIP: None
  selector:
    app: order
    component: db
  ports:
    - name: tcp-order
      appProtocol: tcp
      port: 3306
      targetPort: 3306
{{- end }}
