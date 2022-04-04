{{- define "prd.account.app.deployment" }}
      hostname: account-app-pod
      containers:
        # Ginコンテナ
        - name: gin
          image: account-gin:{{ .Values.kubernetes.image.account.gin }}
          imagePullPolicy: Always
          ports:
            - containerPort: 8080
{{- end }}
