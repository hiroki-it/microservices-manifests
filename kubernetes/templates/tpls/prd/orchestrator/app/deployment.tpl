{{- define "prd.orchestrator.app.deployment" }}
      hostname: orchestrator-pod
      containers:
        # FastAPIコンテナ
        - name: fastapi
          image: orchestrator-fastapi:{{ .Values.kubernetes.image.orchestrator.fastapi }}
          imagePullPolicy: Always
          ports:
            - containerPort: 8000
{{- end }}
