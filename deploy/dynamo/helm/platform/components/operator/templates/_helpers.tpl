# SPDX-FileCopyrightText: Copyright (c) 2025 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
{{/*
Expand the name of the chart.
*/}}
{{- define "dynamo-operator.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "dynamo-operator.fullname" -}}
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
{{- define "dynamo-operator.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "dynamo-operator.dynamo.envname" -}}
{{ include "dynamo-operator.fullname" . }}-dynamo-env
{{- end }}

{{/*
Generate k8s robot token
*/}}
{{- define "dynamo-operator.yataiApiToken" -}}
    {{- $secretObj := (lookup "v1" "Secret" .Release.Namespace (include "dynamo-operator.dynamo.envname" .)) | default dict }}
    {{- $secretData := (get $secretObj "data") | default dict }}
    {{- (get $secretData "YATAI_API_TOKEN") | default (randAlphaNum 16 | nospace | b64enc) | b64dec }}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "dynamo-operator.labels" -}}
helm.sh/chart: {{ include "dynamo-operator.chart" . }}
{{ include "dynamo-operator.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "dynamo-operator.selectorLabels" -}}
app.kubernetes.io/name: {{ include "dynamo-operator.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "dynamo-operator.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "dynamo-operator.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Generate docker config json for registry credentials
*/}}
{{- define "dynamo-operator.dockerconfig" -}}
{{- $server := .Values.dynamo.dockerRegistry.server -}}
{{- $username := .Values.dynamo.dockerRegistry.username -}}
{{- $password := default .Values.global.NGC_API_KEY .Values.dynamo.dockerRegistry.password -}}
{{- if .Values.dynamo.dockerRegistry.passwordExistingSecretName -}}
{{- $password = .Values.dynamo.dockerRegistry.passwordExistingSecretKey -}}
{{- end -}}
{
  "auths": {
    "{{ $server }}": {
      "username": "{{ $username }}",
      "password": "{{ $password }}",
      "auth": "{{ printf "%s:%s" $username $password | b64enc }}"
    }
  }
}
{{- end -}}
