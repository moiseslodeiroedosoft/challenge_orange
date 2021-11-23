#
# Edosoft challenge
#
FROM jenkins/jenkins:lts-jdk11
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false

# Task made by root user
USER root
RUN apt update && apt install maven wget git curl -yq

# K8s install
RUN apt-get install -y apt-transport-https ca-certificates curl
RUN curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list
RUN apt-get update && apt-get install -y kubectl


# Tasks made by jenkins (unprivileged) user
USER jenkins
COPY config/plugins.txt /plugins.txt
RUN for plugin in `cat /plugins.txt`; \
       do echo "Installing ${plugin}" && jenkins-plugin-cli --plugins ${plugin}; \
    done;

# Export port just in 8080 tcp
EXPOSE 8080/tcp
