{{- define "prd.orchestrator.app.deployment" }}
      hostname: orchestrator-pod
      containers:
        # FastAPIコンテナ
        - name: fastapi
          image: orchestrator-fastapi:latest
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 8000
{{- end }}
