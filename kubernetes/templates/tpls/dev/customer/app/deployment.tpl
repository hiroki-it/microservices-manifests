{{- define "dev.customer.app.deployment" }}
      hostname: customer-app-pod
      containers:
        # FastAPIコンテナ
        - name: fastapi
          image: customer-fastapi:e35fcc6
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 8000
          volumeMounts:
            - name: customer-app-persistent-volume
              mountPath: /var/www/customer
      volumes:
        - name: customer-app-persistent-volume
          persistentVolumeClaim:
            claimName: customer-app-host-path-persistent-volume-claim
{{- end }}
