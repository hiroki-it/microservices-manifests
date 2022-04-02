{{- define "prd.account.app.deployment" }}
      hostname: account-app-pod
      containers:
        # Ginコンテナ
        - name: gin
          image: account-gin:latest
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 8080
{{- end }}
