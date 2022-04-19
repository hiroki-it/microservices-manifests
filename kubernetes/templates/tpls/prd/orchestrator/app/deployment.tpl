{{- define "prd.orchestrator.app.deployment" }}
      hostname: orchestrator-pod
      containers:
        # FastAPIコンテナ
        - name: fastapi
          image: {{ .Values.general.aws.accountId }}.dkr.ecr.{{ .Values.general.aws.region }}.amazonaws.com/orchestrator-fastapi-repository:{{ .Values.kubernetes.image.orchestrator.fastapi }}
          imagePullPolicy: Always
          ports:
            - containerPort: 8000
{{- end }}
