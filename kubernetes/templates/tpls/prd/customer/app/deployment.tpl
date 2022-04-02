{{- define "prd.customer.app.deployment" }}
      hostname: customer-app-pod
      containers:
        # FastAPIコンテナ
        - name: fastapi
          image: customer-fastapi:{{ .Values.image.tag.customer.fastapi }}
          imagePullPolicy: Always
          ports:
            - containerPort: 8000
{{- end }}
