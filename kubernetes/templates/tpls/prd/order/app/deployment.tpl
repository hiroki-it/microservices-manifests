{{- define "prd.order.app.deployment" }}
      hostname: order-app-pod
      containers:
        # Lumenコンテナ
        - name: lumen
          image: order-lumen:{{ .Values.kubernetes.image.order.lumen }}
          imagePullPolicy: Always
          ports:
            - containerPort: 9000
        - name: nginx
          image: order-nginx:{{ .Values.kubernetes.image.order.nginx }}
          imagePullPolicy: Always
          ports:
            - containerPort: 8080
{{- end }}