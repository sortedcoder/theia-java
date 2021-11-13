FROM ubuntu:impish

ENV HOME /root
ENV NVM_DIR /root/.nvm
ENV DEBIAN_FRONTEND noninteractive
# Since the default shell is sh (bash --posix), if we set the ENV env variable to a file
# It will execute that file on startup
ENV ENV ~/.bashrc

RUN apt-get update && apt-get install -y zip unzip curl wget python3 pkg-config libsecret-1-0 libsecret-1-dev make g++ git

# Installing Node v 12
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
RUN . "$NVM_DIR/nvm.sh" && nvm install 12

# Installing JDK
SHELL [ "/bin/bash", "-c" ]
RUN curl -s "https://get.sdkman.io"|bash
RUN /bin/bash -c ". $HOME/.sdkman/bin/sdkman-init.sh && sdk install java 17-open"
RUN /bin/bash -c ". $HOME/.sdkman/bin/sdkman-init.sh && sdk install gradle"

RUN ls
RUN mkdir /theia
COPY package.json /theia
# Install theia ide

WORKDIR /theia

RUN . "$NVM_DIR/nvm.sh" && npm install -g yarn
RUN . "$NVM_DIR/nvm.sh" && yarn
RUN . "$NVM_DIR/nvm.sh" && yarn theia build
RUN . "$NVM_DIR/nvm.sh" && yarn theia download:plugins

RUN mv /usr/bin/sh /usr/sh.old && ln -s /usr/bin/bash /usr/bin/sh

ENV JAVA_HOME /root/.sdkman/candidates/java/17-open
ENTRYPOINT ["/bin/bash","-c",". $NVM_DIR/nvm.sh && yarn theia start --plugins=local-dir:plugins --hostname 0.0.0.0"]