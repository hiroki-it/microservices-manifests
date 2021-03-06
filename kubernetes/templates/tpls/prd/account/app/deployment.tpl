{{- define "prd.account.app.deployment" }}
      hostname: account-app-pod
      containers:
        # Ginコンテナ
        - name: gin
          image: {{ .Values.general.aws.accountId }}.dkr.ecr.{{ .Values.general.aws.region }}.amazonaws.com/account-gin-repository:{{ .Values.kubernetes.image.account.gin }}
          imagePullPolicy: Always
          ports:
            - containerPort: 8080
{{- end }}
