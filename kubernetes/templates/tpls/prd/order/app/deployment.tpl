{{- define "prd.order.app.deployment" }}
      hostname: order-app-pod
      containers:
        # Lumenコンテナ
        - name: lumen
          image: order-lumen:latest
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 9000
        - name: nginx
          image: order-nginx:latest
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 8080
{{- end }}