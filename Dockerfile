
FROM tomcat:9.0-jdk15

WORKDIR /tmp/build


COPY *.html ./
COPY *.css ./
COPY *.JPG ./
COPY *.pdf ./

RUN jar -cvf swe645_a2.war *

WORKDIR /usr/local/tomcat/webapps/

RUN rm -rf ./*

RUN mv /tmp/build/swe645_a2.war ./ROOT.war

RUN jar -tf ROOT.war

EXPOSE 8080