#!/usr/bin/env bash

# Collects k8s-snap diagnostics into a directory. Used by the debug hooks of
# the spread k8s suite and by the debug-k8s workflow. Every collector is best
# effort: a missing tool or a dead cluster must not stop the rest.

set -u

OUT_DIR="${1:-/tmp/k8s-debug}"
NAMESPACE="kube-system"

function _save() {
    local name="$1"
    shift
    printf '+ %s\n' "$*" >&2
    "$@" > "${OUT_DIR}/${name}" 2>&1 || true
}

function _pod_logs() {
    local pod
    local pods
    pods=$(k8s kubectl get pods --namespace "${NAMESPACE}" -o name 2>/dev/null) || return 0
    for pod in ${pods}; do
        pod="${pod#pod/}"
        _save "logs-${pod}.txt" \
            k8s kubectl logs --namespace "${NAMESPACE}" "${pod}" --all-containers --prefix
        _save "logs-${pod}.previous.txt" \
            k8s kubectl logs --namespace "${NAMESPACE}" "${pod}" --all-containers --prefix --previous
    done
}

function _inspect() {
    printf '+ k8s inspect\n' >&2
    (cd "${OUT_DIR}" && k8s inspect > inspect.txt 2>&1) || true
}

function main() {
    mkdir -p "${OUT_DIR}"

    _save uname.txt uname -a
    _save snap-list.txt snap list
    _save snap-warnings.txt snap warnings
    _save df.txt df -h
    _save free.txt free -m
    _save mounts.txt cat /proc/mounts
    _save lsmod.txt lsmod
    _save dmesg.txt dmesg

    _save ip-addr.txt ip addr
    _save ip-route.txt ip route
    _save ip-link.txt ip -details link
    _save iptables-save.txt iptables-save
    _save ip6tables-save.txt ip6tables-save
    _save nft-ruleset.txt nft list ruleset

    _save k8s-status.txt k8s status
    _save nodes.txt k8s kubectl get nodes -o wide
    _save pods.txt k8s kubectl get pods --all-namespaces -o wide
    _save events.txt k8s kubectl get events --all-namespaces --sort-by=.metadata.creationTimestamp
    _save describe-nodes.txt k8s kubectl describe nodes
    _save describe-pods.txt k8s kubectl describe pods --namespace "${NAMESPACE}"
    _pod_logs

    _save journal-k8s.txt journalctl --no-pager --unit 'snap.k8s.*'
    _save journal-containerd.txt journalctl --no-pager --unit containerd --unit docker
    _inspect

    printf '\n== %s ==\n' "${OUT_DIR}"
    ls -l "${OUT_DIR}"
    printf '\n== pods ==\n'
    cat "${OUT_DIR}/pods.txt"
}

main "$@"
