{{- define "prd.order.app.deployment" }}
      hostname: order-app-pod
      containers:
        # Lumenコンテナ
        - name: lumen
          image: {{ .Values.general.aws.accountKeyId }}.dkr.ecr.{{ .Values.general.aws.region }}.amazonaws.com/order-lumen-repository:{{ .Values.kubernetes.image.order.lumen }}
          imagePullPolicy: Always
          ports:
            - containerPort: 9000
        - name: nginx
          image: {{ .Values.general.aws.accountKeyId }}.dkr.ecr.{{ .Values.general.aws.region }}.amazonaws.com/order-nginx-repository:{{ .Values.kubernetes.image.order.nginx }}
          imagePullPolicy: Always
          ports:
            - containerPort: 8080
{{- end }}