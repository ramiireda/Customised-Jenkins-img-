FROM jenkins/jenkins:lts-jdk11

USER root
# install dependencies
RUN apt-get update && apt-get install -y apt-transport-https \
       ca-certificates curl gnupg2 zip \
       software-properties-common
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
RUN apt-key fingerprint 0EBFCD88
RUN add-apt-repository \
       "deb [arch=amd64] https://download.docker.com/linux/debian \
       $(lsb_release -cs) stable"
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash
RUN apt-get install -y nodejs
RUN apt update && apt install -y docker-ce-cli sudo wget
RUN npm install -g npm@latest
RUN npm install --global yarn

#RUN apt-get install -y gnome-terminal
RUN wget -O /usr/local/bin/relay https://storage.googleapis.com/webhookrelay/downloads/relay-linux-amd64

# Docker/Jenkins configurations
RUN chmod +wx /usr/local/bin/relay
RUN groupadd docker
RUN usermod -aG docker jenkins
RUN newgrp docker 
RUN echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers
RUN relay login -k ca9017dd-fc03-4183-bc11-866cc100c17f -s 7WNfAXBfk46h
ENV RELAY_KEY=ca9017dd-fc03-4183-bc11-866cc100c17f
ENV RELAY_SECRET=7WNfAXBfk46h

RUN apt-get install -y nginx

USER jenkins

COPY --chown=jenkins:jenkins plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt

# so we can use jenkins cli
COPY config/jenkins.properties /usr/share/jenkins/ref/

# Copy my jenkins configurations and saved files
COPY config/ /usr/share/jenkins/ref/
COPY users /usr/share/jenkins/ref/users/
COPY jobs /usr/share/jenkins/ref/jobs/

ENV JENKINS_OPTS --httpPort=8084 --httpsPort=8083
EXPOSE 8083
EXPOSE 8084

#USER root
#CMD /bin/sh "relay forward -b jenkins-url http://localhost:8084/webhook"

