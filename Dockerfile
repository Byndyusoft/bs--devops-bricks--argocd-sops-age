FROM registry.access.redhat.com/ubi9/ubi:9.5

USER root

#https://github.com/helm/helm/releases
ENV HELM_VERSION=3.17.3
#https://github.com/kubernetes-sigs/kustomize/releases
ENV KUSTOMIZE_VERSION=5.6.0
#https://github.com/FiloSottile/age/releases
ENV AGE_VERSION=1.2.1
#https://github.com/getsops/sops/releases
ENV SOPS_VERSION=3.10.1
#https://github.com/argoproj-labs/argocd-vault-plugin/releases
ENV AVP_VERSION=1.18.1 

RUN dnf -y install \
    bash tar gzip unzip which findutils git && \
    dnf -y -q clean all && rm -rf /var/cache/yum && \
    echo "install bash tar gzip unzip which findutils git"

# Install the AVP plugin
RUN curl -skL -o /tmp/argocd-vault-plugin https://github.com/argoproj-labs/argocd-vault-plugin/releases/download/v${AVP_VERSION}/argocd-vault-plugin_${AVP_VERSION}_linux_amd64 && \
    chmod +x /tmp/argocd-vault-plugin && \
    mv -v /tmp/argocd-vault-plugin /usr/local/bin && \
    echo "ArgoCD Vault Plugin version ${AVP_VERSION} installed"

# Install helm
RUN curl -skL -o /tmp/helm.tar.gz https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz && \
    tar -C /tmp -xzf /tmp/helm.tar.gz && \
    mv -v /tmp/linux-amd64/helm /usr/local/bin && \
    chmod -R 775 /usr/local/bin/helm && \
    rm -rf /tmp/linux-amd64 && \
    echo "Helm version ${HELM_VERSION} installed"

# Install kustomize
RUN curl -skL -o /tmp/kustomize.tar.gz https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv${KUSTOMIZE_VERSION}/kustomize_v${KUSTOMIZE_VERSION}_linux_amd64.tar.gz && \
    tar -C /tmp -xzf /tmp/kustomize.tar.gz && \
    mv -v /tmp/kustomize /usr/local/bin && \
    chmod -R 775 /usr/local/bin/kustomize && \
    rm -rf /tmp/linux-amd64 && \
    echo "Kustomize version ${KUSTOMIZE_VERSION} installed"

# Install age
RUN curl -skL -o /tmp/age.tar.gz https://github.com/FiloSottile/age/releases/download/v${AGE_VERSION}/age-v${AGE_VERSION}-linux-amd64.tar.gz && \
    tar -C /tmp -xzf /tmp/age.tar.gz && \
    mv -v /tmp/age/age /usr/local/bin && \
    mv -v /tmp/age/age-keygen /usr/local/bin && \
    chmod -R 775 /usr/local/bin/age && \
    chmod -R 775 /usr/local/bin/age-keygen && \
    rm -rf /tmp/age && \
    echo "Age version ${AGE_VERSION} installed"

# Install sops
RUN curl -skL -o /usr/local/bin/sops https://github.com/getsops/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux.amd64 && \
    chmod -R 775 /usr/local/bin/sops && \
    echo "SOPS version ${SOPS_VERSION} installed"

USER 999