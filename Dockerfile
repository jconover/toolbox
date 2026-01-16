FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/usr/local/bin:/root/.local/bin:${PATH}"

# 1. Update and install base dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    unzip \
    jq \
    vim \
    nano \
    python3 \
    python3-pip \
    python3-venv \
    pipx \
    apt-transport-https \
    gnupg \
    lsb-release \
    software-properties-common \
    ca-certificates \
    less \
    locales \
    && rm -rf /var/lib/apt/lists/*

# Fix locale
RUN echo "LC_ALL=en_US.UTF-8" >> /etc/environment
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
RUN echo "LANG=en_US.UTF-8" > /etc/locale.conf
RUN locale-gen en_US.UTF-8

# 2. Install Node.js 20 (Required for Claude Code)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

# 3. Install AWS CLI v2 (ARM64)
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf aws awscliv2.zip

# 4. Install Terraform (HashiCorp)
RUN wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list \
    && apt-get update && apt-get install -y terraform

# 5. Install Google Cloud SDK
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
    && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - \
    && apt-get update && apt-get install -y google-cloud-cli

# 6. Install Azure CLI & AKS Tools
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# kubelogin (ARM64)
RUN KUBELOGIN_VERSION=$(curl -s https://api.github.com/repos/Azure/kubelogin/releases/latest | jq -r .tag_name) \
    && curl -L "https://github.com/Azure/kubelogin/releases/download/${KUBELOGIN_VERSION}/kubelogin-linux-arm64.zip" -o kubelogin.zip \
    && unzip kubelogin.zip \
    && mv bin/linux_arm64/kubelogin /usr/local/bin/ \
    && rm -rf kubelogin.zip bin

# 7. Install Kubernetes Tools (kubectl, helm, eksctl)
# kubectl (ARM64)
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl" \
    && chmod +x kubectl \
    && mv kubectl /usr/local/bin/

# Helm
RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# eksctl (ARM64)
RUN curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_arm64.tar.gz" | tar xz -C /tmp \
    && mv /tmp/eksctl /usr/local/bin

# 7. Install GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list \
    && apt-get update \
    && apt-get install -y gh

# 8. Install AI & Python Tools
# Ansible
RUN pipx install ansible

# Gemini CLI
RUN pipx install gemini-cli

# Claude Code (npm)
RUN npm install -g @anthropic-ai/claude-code

# 9. Install kubectl-ai (ARM64)
# Note: Using a fixed version or finding latest can be tricky in Dockerfile logic without extra tools, 
# but we can try to grab the latest release URL for linux_arm64.  
# Fallback: manually construct URL for a known recent valid version if dynamic fails, but let's try dynamic via GitHub API via curl/jq.
RUN KUBECTL_AI_VERSION=$(curl -s https://api.github.com/repos/sozercan/kubectl-ai/releases/latest | jq -r .tag_name) \
    && curl -L "https://github.com/sozercan/kubectl-ai/releases/download/${KUBECTL_AI_VERSION}/kubectl-ai_linux_arm64.tar.gz" -o kubectl-ai.tar.gz \
    && tar -zxvf kubectl-ai.tar.gz \
    && mv kubectl-ai /usr/local/bin/ \
    && rm kubectl-ai.tar.gz

# 10. Install k9s (ARM64)
RUN K9S_VERSION=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | jq -r .tag_name) \
    && curl -L "https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_arm64.tar.gz" -o k9s.tar.gz \
    && tar -zxvf k9s.tar.gz \
    && mv k9s /usr/local/bin/ \
    && rm k9s.tar.gz

WORKDIR /workspace

CMD ["/bin/bash"]
