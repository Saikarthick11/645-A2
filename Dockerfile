FROM tomcat:9.0-jdk15

# Set the maintainer label

# 1. Create a temporary build directory inside the container
WORKDIR /tmp/build

# 2. Copy web assets. 
# We use a more flexible approach here. 
# If you don't have .css files, we copy the current directory 
# and filter later, or copy only what is guaranteed to exist.
COPY . .

# 3. Package the files into a WAR directly inside the container.
# We exclude the Dockerfile and Jenkinsfile from the WAR to keep it clean.
RUN jar -cvf swe645_a2.war *.html *.JPG *.pdf 2>/dev/null || jar -cvf swe645_a2.war *.html

# 4. Move to the live Tomcat deployment directory
WORKDIR /usr/local/tomcat/webapps/

# 5. Remove Tomcat's default apps
RUN rm -rf ./*

# 6. Deploy the newly created WAR as the ROOT application.
RUN mv /tmp/build/swe645_a2.war ./ROOT.war

# Expose the default Tomcat port
EXPOSE 8080