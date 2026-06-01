{{/*
Chart name, truncated to 63 chars (K8s label limit).
*/}}
{{- define "bsc-devops.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Fully qualified release name used as resource name prefix.
*/}}
{{- define "bsc-devops.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Chart label value: name-version with "+" replaced by "_".
*/}}
{{- define "bsc-devops.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Standard Helm recommended labels applied to every resource.
*/}}
{{- define "bsc-devops.labels" -}}
helm.sh/chart: {{ include "bsc-devops.chart" . }}
{{ include "bsc-devops.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: bsc-devops
{{- end }}

{{/*
Selector labels — must be stable across upgrades (immutable on Deployments).
*/}}
{{- define "bsc-devops.selectorLabels" -}}
app.kubernetes.io/name: {{ include "bsc-devops.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Target namespace: prefers .Values.global.namespace, falls back to release namespace.
*/}}
{{- define "bsc-devops.namespace" -}}
{{- .Values.global.namespace | default .Release.Namespace }}
{{- end }}

{{/*
Resolve full image reference (repository:tag).
Precedence: service-specific tag -> global imageTag -> "latest"

Usage:
  {{ include "bsc-devops.imageRef" (dict "repo" .Values.users.image.repository "tag" .Values.users.image.tag "ctx" .) }}
*/}}
{{- define "bsc-devops.imageRef" -}}
{{- $tag := .tag | default .ctx.Values.imageTag | default "latest" -}}
{{- printf "%s:%s" .repo $tag -}}
{{- end }}
