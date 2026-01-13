FROM tomcat:10.1-jdk17
COPY target/hello.war /usr/local/tomcat/webapps/hello.war
EXPOSE 8080
CMD ["catalina.sh", "run"]
