{{- define "prd.order.app.deployment" }}
      hostname: order-app-pod
      containers:
        # Lumenコンテナ
        - name: lumen
          image: order-lumen:{{ .Values.image.tag.order.lumen }}
          imagePullPolicy: Always
          ports:
            - containerPort: 9000
        - name: nginx
          image: order-nginx:{{ .Values.image.tag.order.nginx }}
          imagePullPolicy: Always
          ports:
            - containerPort: 8080
{{- end }}