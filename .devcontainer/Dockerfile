#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

FROM golang:1.13.1-stretch

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# Configure apt, install packages and tools
RUN apt-get update \
    && apt-get -y install --no-install-recommends apt-utils 2>&1 \
    && apt-get -y install sudo \
    && apt-get -y install git procps lsb-release \
    && apt-get -y install wget nano zsh inotify-tools jq \
    && apt-get install -y graphviz \
    && go get -x -d github.com/stamblerre/gocode 2>&1 \
    && go build -o gocode-gomod github.com/stamblerre/gocode \
    && mv gocode-gomod $GOPATH/bin/ \
    && GO111MODULE=on go get -v golang.org/x/tools/gopls@latest \
    && go get -u -v \
        github.com/google/wire/cmd/wire \
        github.com/rakyll/gotest \
        github.com/mdempsky/gocode \
        github.com/uudashr/gopkgs/cmd/gopkgs \
        github.com/ramya-rao-a/go-outline \
        github.com/acroca/go-symbols \
        github.com/godoctor/godoctor \
        golang.org/x/tools/cmd/guru \
        golang.org/x/tools/cmd/gorename \
        github.com/rogpeppe/godef \
        github.com/zmb3/gogetdoc \
        github.com/haya14busa/goplay/cmd/goplay \
        github.com/sqs/goreturns \
        github.com/josharian/impl \
        github.com/davidrjenni/reftools/cmd/fillstruct \
        github.com/fatih/gomodifytags \
        github.com/cweill/gotests/... \
        golang.org/x/tools/cmd/goimports \
        golang.org/x/lint/golint \
        github.com/alecthomas/gometalinter \
        honnef.co/go/tools/... \
        github.com/mgechev/revive \
        github.com/derekparker/delve/cmd/dlv 2>&1 \
    && GO111MODULE=on go get golang.org/x/tools/gopls@latest \
    && curl -sfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin v1.23.1 \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get -y install git procps wget nano zsh inotify-tools jq zip

# Verify git, process tools installed
RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true

RUN git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
    && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting \
    && sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/g' ~/.zshrc

# Save command line history 
RUN echo "export HISTFILE=/root/commandhistory/.zsh_history" >> "/root/.zshrc" \
    && echo "export PROMPT_COMMAND='history -a'" >> "/root/.zshrc" \
    && mkdir -p /root/commandhistory \
    && touch /root/commandhistory/.zsh_history

# Installing node
RUN curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash - \
    && sudo apt-get install -y nodejs

ENV GO111MODULE=on

ENV SHELL /bin/zsh
