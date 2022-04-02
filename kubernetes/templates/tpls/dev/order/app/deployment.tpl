{{- define "dev.order.app.deployment" }}
      hostname: order-app-pod
      containers:
        # Lumenコンテナ
        - name: lumen
          image: order-lumen:latest
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 9000
          volumeMounts:
            - name: order-app-persistent-volume
              mountPath: /var/www/order
        - name: nginx
          image: order-nginx:latest
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 8080
          volumeMounts:
            - name: order-app-persistent-volume
              mountPath: /var/www/order
      volumes:
        - name: order-app-persistent-volume
          persistentVolumeClaim:
            claimName: order-app-host-path-persistent-volume-claim
{{- end }}