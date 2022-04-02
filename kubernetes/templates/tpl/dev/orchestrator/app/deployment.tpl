{{- define "orchestrator.app.deployment" }}
      hostname: orchestrator-pod
      containers:
        # FastAPIコンテナ
        - name: fastapi
          image: orchestrator-fastapi:latest
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 8000
          volumeMounts:
            - name: orchestrator-persistent-volume
              mountPath: /var/www/orchestrator
      volumes:
        - name: orchestrator-persistent-volume
          persistentVolumeClaim:
            claimName: orchestrator-host-path-persistent-volume-claim
{{- end }}
