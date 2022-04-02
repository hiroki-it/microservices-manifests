{{- define "prd.account.app.deployment" }}
      hostname: account-app-pod
      containers:
        # Ginコンテナ
        - name: gin
          image: account-gin:{{ .Values.image.tag.account.gin }}
          imagePullPolicy: Always
          ports:
            - containerPort: 8080
{{- end }}
