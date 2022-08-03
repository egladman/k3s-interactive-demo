#!/usr/bin/env bash

FAILFAST=${FAILFAST:-1}

_log() {
    declare -a tmp
    tmp=("$@")
    tmp=("${tmp[@]:1}")
    printf "\n[$1] %s\n" "${tmp[*]}"
}

_wait() {
    while :; do
        read -s -n 1 key
        # Break if the enter key is pressed
        [[ -z "$key" ]] && break
    done
}

_try() {
    _log EXEC "$*"
    while :; do
        eval "$@"
        if [[ $? -eq 0 ]]; then
            break
        fi
        sleep 3
        printf '%s\n' "(╯°□°)╯︵ ┻━┻"
    done
}

_say() {
    _wait && _log ${PREFIX:-INFO} "$*"
}

_run() {
    _log EXEC "$*"
    _wait && eval "$@" |& sed 's/^/    /'
    printf '    %s\n' ✅
}

_bullet() {
    printf '  - %s\n' "$@"
}

main() {
    [[ "${OSTYPE,,}" != *"linux"* ]] && [[ FAILFAST -eq 1 ]] && _log FATAL "Linux required" && exit 128

    printf '%s\n' "Press Enter"

    _say What\'s k3s?

    _say Links to Additional Resources
    _bullet "https://traefik.io/glossary/k3s-explained/" "https://www.cncf.io/projects/k3s/" "https://github.com/cncf/toc/pull/447"

    _say Differences between k3s and k8s

    _say Install k3s
    _run curl -sfL https://get.k3s.io \| sh -s - --write-kubeconfig-mode 644

    _say Learning the CLI. One command to rule them all
    _run k3s --help

    _say About the cluster
    _run k3s kubectl cluster-info

    _say Links to Additional Resources
    _bullet "https://rancher.com/docs/k3s/latest/en/architecture/"

    _say What\'s running on the cluster by default?
    _run k3s kubectl get all --all-namespaces
    _run sudo ls /var/lib/rancher/k3s/server/manifests

    _say Ingress Controller
    _run sudo cat /var/lib/rancher/k3s/server/manifests/traefik.yaml

    _say Links to Additional Resources
    _bullet "https://rancher.com/docs/k3s/latest/en/helm/" "https://github.com/k3s-io/helm-controller" "https://rancher.com/docs/k3s/latest/en/networking/"

    _say Let\'s deploy a sample app

    _run cat manifests/whoami/deployment.yaml
    _run k3s kubectl apply -f manifests/whoami/deployment.yaml

    _run cat manifests/whoami/service.yaml
    _run k3s kubectl apply -f manifests/whoami/service.yaml

    _run cat manifests/whoami/ingress.yaml
    _run k3s kubectl apply -f manifests/whoami/ingress.yaml

    _try curl --fail-with-body http://localhost/whoami
}

main "$@"
