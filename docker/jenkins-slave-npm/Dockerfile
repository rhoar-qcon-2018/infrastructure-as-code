#invoke npm in jenkinsfile: sh "scl enable rh-nodejs6 'npm run build'"
FROM registry.access.redhat.com/openshift3/jenkins-slave-base-rhel7
USER root

RUN curl --silent --location https://rpm.nodesource.com/setup_10.x | bash; yum -y install nodejs; yum clean all -y; rm -rf /var/cache/yum
RUN curl -L -o sonar-scanner.zip https://github.com/SonarSource/sonar-scanner-cli/releases/download/2.6-rc1/sonar-scanner-2.6-SNAPSHOT.zip; unzip sonar-scanner.zip -d /opt/; rm -f sonar-scanner.zip
RUN printf 'export PATH=${PATH}:/opt/sonar-scanner-2.6/bin\n' >> /etc/profile

USER 1001