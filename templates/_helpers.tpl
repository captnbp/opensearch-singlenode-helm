{{/* vim: set filetype=mustache: */}}

{{/*
Return the proper ES image name
*/}}
{{- define "opensearch.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global) }}
{{- end -}}


{{/*
Returns true if at least one opensearch-elegible node replica has been configured.
*/}}
{{- define "opensearch.opensearch.enabled" -}}
{{- if or .Values.opensearch.autoscaling.enabled (gt (int .Values.opensearch.replicaCount) 0) -}}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
 Create the name of the opensearch service account to use
 */}}
{{- define "opensearch.opensearch.serviceAccountName" -}}
{{- if .Values.opensearch.serviceAccount.create -}}
    {{ default (include "common.names.fullname" .) .Values.opensearch.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.opensearch.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified metrics name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "opensearch.metrics.fullname" -}}
{{- $name := default "metrics" .Values.metrics.nameOverride -}}
{{- if .Values.metrics.fullnameOverride -}}
{{- .Values.metrics.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" (include "common.names.fullname" .) $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper sysctl image name
*/}}
{{- define "opensearch.sysctl.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.sysctlImage "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "opensearch.imagePullSecrets" -}}
{{ include "common.images.pullSecrets" (dict "images" (list .Values.image .Values.sysctlImage .Values.volumePermissions.image) "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper image name (for the init container volume-permissions image)
*/}}
{{- define "opensearch.volumePermissions.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.volumePermissions.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper Storage Class
Usage:
{{ include "opensearch.storageClass" (dict "global" .Values.global "local" .Values.opensearch) }}
*/}}
{{- define "opensearch.storageClass" -}}
{{/*
Helm 2.11 supports the assignment of a value to a variable defined in a different scope,
but Helm 2.9 and 2.10 does not support it, so we need to implement this if-else logic.
*/}}
{{- if .global -}}
    {{- if .global.storageClass -}}
        {{- if (eq "-" .global.storageClass) -}}
            {{- printf "storageClassName: \"\"" -}}
        {{- else }}
            {{- printf "storageClassName: %s" .global.storageClass -}}
        {{- end -}}
    {{- else -}}
        {{- if .local.persistence.storageClass -}}
              {{- if (eq "-" .local.persistence.storageClass) -}}
                  {{- printf "storageClassName: \"\"" -}}
              {{- else }}
                  {{- printf "storageClassName: %s" .local.persistence.storageClass -}}
              {{- end -}}
        {{- end -}}
    {{- end -}}
{{- else -}}
    {{- if .local.persistence.storageClass -}}
        {{- if (eq "-" .local.persistence.storageClass) -}}
            {{- printf "storageClassName: \"\"" -}}
        {{- else }}
            {{- printf "storageClassName: %s" .local.persistence.storageClass -}}
        {{- end -}}
    {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for cronjob APIs.
*/}}
{{- define "cronjob.apiVersion" -}}
{{- if semverCompare "< 1.8-0" .Capabilities.KubeVersion.GitVersion -}}
{{- print "batch/v2alpha1" }}
{{- else if and (semverCompare ">=1.8-0" .Capabilities.KubeVersion.GitVersion) (semverCompare "< 1.21-0" .Capabilities.KubeVersion.GitVersion) -}}
{{- print "batch/v1beta1" }}
{{- else if semverCompare ">=1.21-0" .Capabilities.KubeVersion.GitVersion -}}
{{- print "batch/v1" }}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "opensearch.securityadmin.fullname" -}}
{{- printf "%s-%s" (include "common.names.fullname" .) .Values.securityadmin.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "opensearch.securityadmin.serviceAccountName" -}}
{{- if .Values.securityadmin.serviceAccount.create -}}
    {{ default (include "opensearch.securityadmin.fullname" .) .Values.securityadmin.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.securityadmin.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Return the proper Opensearch securityadmin image name
*/}}
{{- define "opensearch.securityadmin.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.securityadmin.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the opensearch TLS credentials secret for opensearch nodes.
*/}}
{{- define "opensearch.opensearch.http.tlsSecretName" -}}
{{- $secretName := .Values.security.tls.http.opensearch.existingSecret -}}
{{- if $secretName -}}
    {{- printf "%s" (tpl $secretName $) -}}
{{- else -}}
    {{- printf "%s-http-crt" (include "common.names.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Return true if a TLS credentials secret object should be created
*/}}
{{- define "opensearch.http.createTlsSecret" -}}
{{- if and .Values.security.tls.http.autoGenerated (not (include "opensearch.security.http.tlsSecretsProvided" .)) }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return the opensearch TLS credentials secret for opensearch nodes.
*/}}
{{- define "opensearch.opensearch.transport.tlsSecretName" -}}
{{- $secretName := .Values.security.tls.transport.opensearch.existingSecret -}}
{{- if $secretName -}}
    {{- printf "%s" (tpl $secretName $) -}}
{{- else -}}
    {{- printf "%s-transport-crt" (include "common.names.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Return true if a TLS credentials secret object should be created
*/}}
{{- define "opensearch.transport.createTlsSecret" -}}
{{- if and .Values.security.tls.transport.autoGenerated (not (include "opensearch.security.transport.tlsSecretsProvided" .)) }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return true if an authentication credentials secret object should be created
*/}}
{{- define "opensearch.createSecret" -}}
{{- if not .Values.security.existingSecret }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return the Opensearch authentication credentials secret name
*/}}
{{- define "opensearch.secretName" -}}
{{- coalesce .Values.security.existingSecret (include "common.names.fullname" .) -}}
{{- end -}}

{{/*
Return the Opensearch S3 credentials secret name
*/}}
{{- define "opensearch.s3Snapshots.secretName" -}}
{{- if .Values.s3Snapshots.config.s3.client.default.existingSecret -}}
{{- $secretName := .Values.s3Snapshots.config.s3.client.default.existingSecret -}}
    {{- printf "%s" (tpl $secretName $) -}}
{{- else -}}
    {{- printf "%s-s3" (include "common.names.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Return true if a S3 credentials secret object should be created
*/}}
{{- define "opensearch.s3Snapshots.createSecret" -}}
{{- if not .Values.s3Snapshots.config.s3.client.default.existingSecret }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return the Opensearch keystore secret name
*/}}
{{- define "opensearch.extraSecretsKeystore.secretName" -}}
{{- if .Values.extraSecretsKeystore.existingSecret -}}
{{- $secretName := .Values.extraSecretsKeystore.existingSecret -}}
    {{- printf "%s" (tpl $secretName $) -}}
{{- else -}}
    {{- printf "%s-keystore" (include "common.names.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Return true if a keystore secret object should be created
*/}}
{{- define "opensearch.extraSecretsKeystore.createSecret" -}}
{{- if not .Values.extraSecretsKeystore.existingSecret }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return the Opensearch authentication credentials secret name
*/}}
{{- define "opensearch.security.http.issuerName" -}}
{{- $issuerName := .Values.security.tls.http.issuerRef.existingIssuerName -}}
{{- if $issuerName -}}
    {{- printf "%s" (tpl $issuerName $) -}}
{{- else -}}
    {{- printf "%s-http" (include "common.names.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Return the Opensearch authentication credentials secret name
*/}}
{{- define "opensearch.security.transport.issuerName" -}}
{{- $issuerName := .Values.security.tls.transport.issuerRef.existingIssuerName -}}
{{- if $issuerName -}}
    {{- printf "%s" (tpl $issuerName $) -}}
{{- else -}}
    {{- printf "%s-transport" (include "common.names.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Returns true if at least 1 existing secret was provided
*/}}
{{- define "opensearch.security.http.tlsSecretsProvided" -}}
{{- $clusterManagerSecret :=.Values.security.tls.http.opensearch.existingSecret -}}
{{- if $clusterManagerSecret }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/* Validate values of Opensearch - Existing secret not provided for opensearch nodes */}}
{{- define "opensearch.validateValues.security.http.missingTlsSecrets.opensearch" -}}
{{- if and (include "opensearch.security.http.tlsSecretsProvided" .) (not .Values.security.tls.http.opensearch.existingSecret) -}}
opensearch: security.tls.http.opensearch.existingSecret
    Missing secret containing the TLS certificates for the Opensearch opensearch nodes.
    Provide the certificates using --set .Values.security.tls.http.opensearch.existingSecret="my-secret".
{{- end -}}
{{- end -}}

{{/* Validate values of Opensearch - TLS enabled but no certificates provided */}}
{{- define "opensearch.validateValues.security.tls.http" -}}
{{- if and (not .Values.security.tls.http.autoGenerated) (not (include "opensearch.security.http.tlsSecretsProvided" .)) -}}
opensearch: security.tls.transport
    In order to enable Security, it is necessary to configure TLS.
    Two different mechanisms can be used:
        - Provide an existing secret containing the TLS certificates for each role
        - Enable using auto-generated cert-manager certificates with `security.tls.http.autoGenerated=true`
    Existing secrets containing PKCS8 PEM certificates can be provided using --set Values.security.tls.http.opensearch.existingSecret=opensearch-certs
{{- end -}}
{{- end -}}

{{/*
Returns true if at least 1 existing secret was provided
*/}}
{{- define "opensearch.security.transport.tlsSecretsProvided" -}}
{{- $clusterManagerSecret :=.Values.security.tls.transport.opensearch.existingSecret -}}
{{- if $clusterManagerSecret }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/* Validate values of Opensearch - Existing secret not provided for opensearch nodes */}}
{{- define "opensearch.validateValues.security.transport.missingTlsSecrets.opensearch" -}}
{{- if and (include "opensearch.security.transport.tlsSecretsProvided" .) (not .Values.security.tls.transport.opensearch.existingSecret) -}}
opensearch: security.tls.transport.opensearch.existingSecret
    Missing secret containing the TLS certificates for the Opensearch opensearch nodes.
    Provide the certificates using --set .Values.security.tls.transport.opensearch.existingSecret="my-secret".
{{- end -}}
{{- end -}}

{{/* Validate values of Opensearch - TLS enabled but no certificates provided */}}
{{- define "opensearch.validateValues.security.tls.transport" -}}
{{- if and (not .Values.security.tls.transport.autoGenerated) (not (include "opensearch.security.transport.tlsSecretsProvided" .)) -}}
opensearch: security.tls.transport
    In order to enable Security, it is necessary to configure TLS.
    Two different mechanisms can be used:
        - Provide an existing secret containing the TLS certificates for each role
        - Enable using auto-generated cert-manager certificates with `security.tls.transport.autoGenerated=true`
    Existing secrets containing PKCS8 PEM certificates can be provided using --set Values.security.tls.transport.opensearch.existingSecret=opensearch-certs
{{- end -}}
{{- end -}}

{{/*
Compile all warnings into a single message, and call fail.
*/}}
{{- define "opensearch.validateValues" -}}
{{- $messages := list -}}
{{- $messages := append $messages (include "opensearch.validateValues.security.tls.http" .) -}}
{{- $messages := append $messages (include "opensearch.validateValues.security.http.missingTlsSecrets.opensearch" .) -}}
{{- $messages := append $messages (include "opensearch.validateValues.security.tls.transport" .) -}}
{{- $messages := append $messages (include "opensearch.validateValues.security.transport.missingTlsSecrets.opensearch" .) -}}
{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}

{{- if $message -}}
{{-   printf "\nVALUES VALIDATION:\n%s" $message | fail -}}
{{- end -}}
{{- end -}}

{{/*
Sysctl set if less then
*/}}
{{- define "opensearch.sysctlIfLess" -}}
CURRENT=`sysctl -n {{ .key }}`;
DESIRED="{{ .value }}";
if [ "$DESIRED" -gt "$CURRENT" ]; then
    sysctl -w {{ .key }}={{ .value }};
fi;
{{- end -}}
