{{- define "account.app.deployment" }}
      hostname: account-app-pod
      containers:
        # Ginコンテナ
        - name: gin
          image: account-gin:latest
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 8080
          volumeMounts:
            - name: account-app-persistent-volume
              mountPath: /go/src
      volumes:
        - name: account-app-persistent-volume
          persistentVolumeClaim:
            claimName: account-app-host-path-persistent-volume-claim
{{- end }}
