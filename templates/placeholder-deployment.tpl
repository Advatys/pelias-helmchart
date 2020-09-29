apiVersion: apps/v1
kind: Deployment
metadata:
  name: pelias-placeholder
spec:
  replicas: {{ .Values.placeholder.replicas }}
  minReadySeconds: {{ .Values.placeholder.minReadySeconds }}
  selector:
    matchLabels:
      app: pelias-placeholder
  strategy:
    rollingUpdate:
      maxSurge: {{ .Values.placeholder.maxSurge }}
      maxUnavailable: {{ .Values.placeholder.maxUnavailable }}
  template:
    metadata:
      labels:
        app: pelias-placeholder
      annotations:
{{- if .Values.placeholder.annotations }}
{{ toYaml .Values.placeholder.annotations | indent 8 }}
{{- end }}
    spec:
      initContainers:
        - name: download
          image: pelias/placeholder:{{ .Values.placeholder.dockerTag }}
          env:
            - name: DOWNLOAD_URL
              value: {{ .Values.placeholder.storeURL | quote }}
          command: ["sh", "-c", {{ .Values.placeholder.downloadCommand | quote }} ]
          volumeMounts:
            - name: data-volume
              mountPath: /data

      containers:
        - name: pelias-placeholder
          image: pelias/placeholder:{{ .Values.placeholder.dockerTag }}
          volumeMounts:
            - name: data-volume
              mountPath: /data
          env:
            - name: PLACEHOLDER_DATA
              value: "/data/placeholder/"
            - name: CPUS
              value: "{{ .Values.placeholder.cpus }}"
          {{- if .Values.placeholder.resources }}
          resources:
{{ toYaml .Values.placeholder.resources | indent 12 }}
          {{- end }}
      volumes:
        - name: data-volume
        {{- if .Values.placeholder.pvc.create }}
          persistentVolumeClaim:
            claimName: {{ .Values.placeholder.pvc.name }}
        {{- else }}
          emptyDir: {}
	{{- end }}
      nodeSelector:
{{ toYaml .Values.placeholder.nodeSelector | indent 8 }}
