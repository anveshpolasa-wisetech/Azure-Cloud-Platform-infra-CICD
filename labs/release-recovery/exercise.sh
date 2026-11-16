#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"
output_dir=${1:-"${TMPDIR:-/tmp}/release-recovery-results"}
mkdir -p "$output_dir"
output_dir=$(cd "$output_dir" && pwd)
work_dir=$(mktemp -d)
export KUBECONFIG="$work_dir/kubeconfig"
cluster="release-recovery-$$"
forward_pid=
cluster_started=false

stop_forwarding() {
  if [[ -n "$forward_pid" ]]; then
    kill "$forward_pid" 2>/dev/null || true
    wait "$forward_pid" 2>/dev/null || true
    forward_pid=
  fi
}

cleanup() {
  stop_forwarding
  if [[ "$cluster_started" == true ]]; then
    kind delete cluster --name "$cluster" || true
  fi
  rm -rf -- "$work_dir"
}
trap cleanup EXIT

smoke_test() {
  local phase=$1
  local log="$output_dir/$phase-port-forward.log"
  local address
  kubectl --namespace release-lab port-forward --address 127.0.0.1 service/release-demo :8080 >"$log" 2>&1 &
  forward_pid=$!
  for _ in {1..30}; do
    address=$(awk '/^Forwarding from 127\.0\.0\.1:/ {print $3; exit}' "$log")
    if [[ -n "$address" ]]; then
      break
    fi
    if ! kill -0 "$forward_pid" 2>/dev/null; then
      cat "$log"
      return 1
    fi
    sleep 1
  done
  if [[ -z "$address" ]]; then
    cat "$log"
    return 1
  fi
  python -m robot --variable "BASE_URL:http://$address" \
    --outputdir "$output_dir/$phase" smoke.robot
  stop_forwarding
}

capture_state() {
  local phase=$1
  kubectl --namespace release-lab get deployments,replicasets,pods -o wide >"$output_dir/$phase-state.txt"
  kubectl --namespace release-lab get events --sort-by=.metadata.creationTimestamp >"$output_dir/$phase-events.txt"
}

kind create cluster --name "$cluster" --kubeconfig "$KUBECONFIG" --wait 120s
cluster_started=true
kind load docker-image release-demo:lab --name "$cluster"
kubectl create namespace release-lab
kubectl --namespace release-lab apply -f deployment.yml
kubectl --namespace release-lab rollout status deployment/release-demo --timeout=90s
smoke_test baseline
capture_state baseline

kubectl --namespace release-lab set env deployment/release-demo LAB_READY=false
if kubectl --namespace release-lab rollout status deployment/release-demo --timeout=90s >"$output_dir/bad-rollout.txt" 2>&1; then
  echo "The intentionally unready rollout unexpectedly succeeded." >&2
  exit 1
fi
cat "$output_dir/bad-rollout.txt"
reason=$(kubectl --namespace release-lab get deployment release-demo \
  -o 'jsonpath={.status.conditions[?(@.type=="Progressing")].reason}')
available=$(kubectl --namespace release-lab get deployment release-demo -o 'jsonpath={.status.availableReplicas}')
capture_state bad-rollout
[[ "$reason" == ProgressDeadlineExceeded && "$available" == 2 ]]
smoke_test during-bad-rollout

kubectl --namespace release-lab rollout undo deployment/release-demo
kubectl --namespace release-lab rollout status deployment/release-demo --timeout=90s
ready=$(kubectl --namespace release-lab get deployment release-demo \
  -o 'jsonpath={.spec.template.spec.containers[0].env[?(@.name=="LAB_READY")].value}')
[[ "$ready" == true ]]
smoke_test recovered
capture_state recovered
