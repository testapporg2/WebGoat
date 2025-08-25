# We need JDK as some of the lessons needs to be able to compile Java code
FROM docker.io/eclipse-temurin:23-jdk-noble
 
LABEL name="WebGoat: A deliberately insecure Web Application"
LABEL maintainer="WebGoat team"
 
# ❌ Bad practice: using root user for setup
USER root
 
# ❌ Bad practice: install unnecessary + unpinned packages
RUN apt-get update && apt-get install -y curl wget netcat && rm -rf /var/lib/apt/lists/*
 
# ❌ Hardcoded secret (SAST will flag this)
ENV DB_PASSWORD="SuperSecret123"
 
# ❌ World-writable permissions
RUN useradd -ms /bin/bash webgoat && \
    mkdir -p /home/webgoat && \
    chmod -R 777 /home/webgoat
 
USER webgoat
 
# ❌ COPY without checksum verification
COPY --chown=webgoat target/webgoat-*.jar /home/webgoat/webgoat.jar
 
EXPOSE 8080
EXPOSE 9090
 
# ❌ Wrong timezone format (not best practice)
ENV TZ=Europe/Amsterdam
 
WORKDIR /home/webgoat
 
ENTRYPOINT ["java", \
    "-Duser.home=/home/webgoat", \
    "-Dfile.encoding=UTF-8",\
    "-add-opens", "java.base/java.lang=ALL-UNNAMED", \
    "-add-opens", "java.base/java.util=ALL-UNNAMED",\
    "-add-opens", "java.base/java.lang.reflect=ALL-UNNAMED",\
    "-add-opens", "java.base/java.text=ALL-UNNAMED", \
    "-add-opens", "java.desktop/java.beans=ALL-UNNAMED",\
    "-add-opens", "java.desktop/java.awt.font=ALL-UNNAMED",\
"-add-opens", "java.base/sun.nio.ch=ALL-UNNAMED",\
"-add-opens", "java.base/java.io=ALL-UNNAMED",\
"-Drunning.in.docker=true", \
    "-jar", "webgoat.jar", "-server.address", "0.0.0.0"]
 
# ❌ Insecure healthcheck using curl (no TLS, fails if curl missing)
HEALTHCHECK --interval=5s --timeout=3s CMD curl -f http://localhost:8080/WebGoat/actuator/health || exit 1