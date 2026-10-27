{{/*
Common labels applied to every resource.
*/}}
{{- define "gatana.labels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
{{- end -}}

{{/*
Stable labels for pod templates — excludes helm.sh/chart and
app.kubernetes.io/version so that version bumps don't trigger unnecessary
pod rollouts.
*/}}
{{- define "gatana.podLabels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Returns full image reference for a component. Fails the render if the
component's tag is unset — every image tag must be baked in by `release-helm`
or pinned explicitly at install time.
Usage: include "gatana.image" (dict "Values" .Values "Chart" .Chart "component" "backend")
*/}}
{{- define "gatana.image" -}}
{{- $img := index .Values.images .component -}}
{{- $tag := required (printf "images.%s.tag is required (run `just release-helm` or set it explicitly)" .component) $img.tag -}}
{{- printf "%s/%s:%s" .Values.images.registry $img.repository $tag -}}
{{- end -}}

{{/*
Renders the pod-spec `imagePullSecrets:` block when .Values.imagePullSecret
is set. Use inside a pod template's `spec:`. Outputs nothing if empty.
Usage:
  spec:
    {{- include "gatana.imagePullSecrets" . | nindent 6 }}
*/}}
{{- define "gatana.imagePullSecrets" -}}
{{- with .Values.imagePullSecret }}
imagePullSecrets:
  - name: {{ . }}
{{- end }}
{{- end -}}

{{/*
preStop for an nginx container behind a Service. Kubernetes starts preStop at
the same time as it removes the pod from the Service endpoints, and that change
needs some seconds to reach every node and proxy. nginx continues to serve
during the sleep. When preStop returns, the runtime sends the image's stop
signal. Every nginx image in this chart sets SIGQUIT, which tells nginx to
complete its open requests before it stops.
Do not add 'nginx -s quit' and a wait loop here. The loop cannot end before
the container does, so every stop then records a FailedPreStopHook warning.
Usage (the argument is the drain time in seconds):
  {{- include "gatana.nginxPreStop" 5 | nindent 10 }}
*/}}
{{- define "gatana.nginxPreStop" -}}
lifecycle:
  preStop:
    exec:
      command: ["sleep", "{{ . }}"]
{{- end -}}

{{/*
Postgres password env var. Either inline value or secretKeyRef.
*/}}
{{- define "gatana.postgresPasswordEnv" -}}
- name: POSTGRES_PASSWORD
{{- if .Values.postgres.existingSecret }}
  valueFrom:
    secretKeyRef:
      name: {{ .Values.postgres.existingSecret }}
      key: password
{{- else }}
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}-secrets
      key: postgresPassword
{{- end }}
{{- end -}}
