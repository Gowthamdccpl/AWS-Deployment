{{/* Copyright Siemens 2022 */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "opcenter-core.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "opcenter-core.fullname" -}}
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
Create chart name and version as used by the chart label.
*/}}
{{- define "opcenter-core.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "opcenter-core.labels" -}}
helm.sh/chart: {{ include "opcenter-core.chart" . }}
{{ include "opcenter-core.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "opcenter-core.selectorLabels" -}}
app.kubernetes.io/name: {{ include "opcenter-core.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
App Server Selector labels
*/}}
{{- define "opcenter-core.appServer.selectorLabels" -}}
app.kubernetes.io/name: {{ include "opcenter-core.name" . }}-app-server
app.kubernetes.io/instance: {{ .Release.Name }}-app-server
{{- end }}

{{/*
App Server SF Selector labels
*/}}
{{- define "opcenter-core.appServerSf.selectorLabels" -}}
app.kubernetes.io/name: {{ include "opcenter-core.name" . }}-app-server-sf
app.kubernetes.io/instance: {{ .Release.Name }}-app-server-sf
{{- end }}

{{/*
Notification Service Selector labels
*/}}
{{- define "opcenter-core.notificationService.selectorLabels" -}}
app.kubernetes.io/name: {{ include "opcenter-core.name" . }}-notification-service
app.kubernetes.io/instance: {{ .Release.Name }}-notification-service
{{- end }}

{{/*
Security Services Selector labels
*/}}
{{- define "opcenter-core.securityServices.selectorLabels" -}}
app.kubernetes.io/name: {{ include "opcenter-core.name" . }}-security-services
app.kubernetes.io/instance: {{ .Release.Name }}-security-services
{{- end }}

{{/*
Portal Selector labels
*/}}
{{- define "opcenter-core.portal.selectorLabels" -}}
app.kubernetes.io/name: {{ include "opcenter-core.name" . }}-portal
app.kubernetes.io/instance: {{ .Release.Name }}-portal
{{- end }}

{{/*
Inline SPC Selector labels
*/}}
{{- define "opcenter-core.inlinespc.selectorLabels" -}}
app.kubernetes.io/name: {{ include "opcenter-core.name" . }}-inlinespc
app.kubernetes.io/instance: {{ .Release.Name }}-inlinespc
{{- end }}