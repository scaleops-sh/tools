

#readonly=false
#while [ "$#" -gt 0 ]; do
#    case $1 in
#        --namespace|-n)
#          filter_namespaces+=("$2"); shift ;;
#        --label|-l)
#          label="$2"; shift ;;
#        --readonly|-r)
#          readonly=true ;;
#        -*)
#          echo "error: unknown option $1"
#          exit 1
#          ;;
#      esac
#      shift
#done
#
#if [ "$label" == "" ] ; then
#  echo label is required
#  exit 1
#fi

namespace=device-drivers-active
readonly=true
label="app.kubernetes.io/name"

namespace_tab_length=30
pod_tab_length=50
label_tab_length=50

line1=$(printf "Namespace \t" | tr -s '[:blank:]' '[\t*]' | expand -t $namespace_tab_length)
line2=$(printf "Pod \t" | tr -s '[:blank:]' '[\t*]' | expand -t $pod_tab_length)
line3=$(printf "Label \t" | tr -s '[:blank:]' '[\t*]' | expand -t $label_tab_length)
headline="$line1$line2$line3"
echo "$headline"

for namespace in $namespace
do

  pods=$(kubectl get pods -n "$namespace" -o=custom-columns=NAME:.metadata.name --no-headers=true)
  for pod in $pods
  do
    label_value_in_pod=$(kubectl get pod "$pod" -n "$namespace" -o=jsonpath='{.metadata.labels.'"$label"'}')
    if [ "$label_value_in_pod" != "" ] ; then
      if [ "$readonly" == "false" ] ; then
        kubectl annotate pod "$pod" -n "$namespace" scaleops.sh/pod-owner-identifier="$label_value_in_pod" --overwrite
      fi
    fi

    line1=$(printf "$namespace \t" | tr -s '[:blank:]' '[\t*]' | expand -t $namespace_tab_length)
    line2=$(printf "$pod \t" | tr -s '[:blank:]' '[\t*]' | expand -t $pod_tab_length)
    line3=$(printf "$label_value_in_pod \t" | tr -s '[:blank:]' '[\t*]' | expand -t $label_tab_length)
    pod_line="$line1$line2$line3"
    echo "$pod_line"
  done
done


