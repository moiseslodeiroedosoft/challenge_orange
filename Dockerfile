#
# Edosoft challenge
#
FROM jenkins/jenkins:lts-jdk11
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false

# Task made by root user
USER root
RUN apt update && apt install maven -yq

# Tasks made by jenkins (unprivileged) user
USER jenkins
COPY plugins.txt /plugins.txt
RUN for plugin in `cat /plugins.txt`; \
       do jenkins-plugin-cli --plugins ${plugin}; \
    done;

# Export port just in 8080 tcp
EXPOSE 8080/tcp
