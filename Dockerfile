FROM tomcat:9.0-jdk15

WORKDIR /tmp/build

COPY . .

RUN jar -cvf swe645_a2.war *.html *.JPG *.pdf 2>/dev/null || jar -cvf swe645_a2.war *.html


WORKDIR /usr/local/tomcat/webapps/


RUN rm -rf ./*

RUN mv /tmp/build/swe645_a2.war ./ROOT.war

EXPOSE 8080