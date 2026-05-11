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
