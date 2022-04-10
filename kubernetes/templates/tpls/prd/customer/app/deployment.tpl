{{- define "prd.customer.app.deployment" }}
      hostname: customer-app-pod
      containers:
        # FastAPIコンテナ
        - name: fastapi
          image: {{ .Values.general.aws.accountKeyId }}.dkr.ecr.{{ .Values.general.aws.region }}.amazonaws.com/customer-fastapi-repository:{{ .Values.kubernetes.image.customer.fastapi }}
          imagePullPolicy: Always
          ports:
            - containerPort: 8000
{{- end }}
