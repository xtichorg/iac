{{- define "applicationset.appname" -}}
{{- print "'{{ .repository }}-{{ .branch | lower | replace \"/\" \"-\" }}'" }}
{{- end }}

{{- define "applicationset.trackid" -}}
{{- printf "%s:/Namespace:%s/%s" (include "applicationset.appname" .) (include "applicationset.appname" .) (include "applicationset.appname" .) | replace "'" "" }}
{{- end }}