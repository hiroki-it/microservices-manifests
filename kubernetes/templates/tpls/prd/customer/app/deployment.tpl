{{- define "prd.customer.app.deployment" }}
      hostname: customer-app-pod
      containers:
        # FastAPIコンテナ
        - name: fastapi
          image: customer-fastapi:e35fcc6
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 8000
{{- end }}
