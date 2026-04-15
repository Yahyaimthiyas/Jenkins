FROM jenkins/jenkins:lts-jdk17

# Skip initial setup wizard
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false

# Install the essential plugins for our project
RUN jenkins-plugin-cli --plugins \
    workflow-aggregator \
    git \
    prometheus \
    configuration-as-code \
    job-dsl \
    pipeline-stage-view
