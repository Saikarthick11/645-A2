
FROM tomcat:9.0-jdk15

WORKDIR /tmp/build


COPY *.html ./645-A2
COPY *.css ./645-A2
COPY *.JPG ./645-A2
COPY *.pdf ./645-A2

RUN jar -cvf swe645_a2.war *

WORKDIR /usr/local/tomcat/webapps/

RUN rm -rf ./*

RUN mv /tmp/build/swe645_a2.war ./ROOT.war

RUN jar -tf ROOT.war

EXPOSE 8080