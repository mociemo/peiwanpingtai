@echo off
echo Starting Playmate Backend...

REM 设置Java路径
set JAVA_HOME=C:\Program Files\Java\jdk-25
set PATH=%JAVA_HOME%\bin;%PATH%

REM 设置类路径
set CLASSPATH=target/classes
set CLASSPATH=%CLASSPATH%;C:\Users\%USERNAME%\.m2\repository\org\springframework\boot\spring-boot\3.2.0\spring-boot-3.2.0.jar
set CLASSPATH=%CLASSPATH%;C:\Users\%USERNAME%\.m2\repository\org\springframework\boot\spring-boot-autoconfigure\3.2.0\spring-boot-autoconfigure-3.2.0.jar
set CLASSPATH=%CLASSPATH%;C:\Users\%USERNAME%\.m2\repository\org\springframework\boot\spring-boot-starter\3.2.0\spring-boot-starter-3.2.0.jar
set CLASSPATH=%CLASSPATH%;C:\Users\%USERNAME%\.m2\repository\org\springframework\boot\spring-boot-starter-web\3.2.0\spring-boot-starter-web-3.2.0.jar
set CLASSPATH=%CLASSPATH%;C:\Users\%USERNAME%\.m2\repository\org\springframework\spring-context\6.1.1\spring-context-6.1.1.jar
set CLASSPATH=%CLASSPATH%;C:\Users\%USERNAME%\.m2\repository\org\springframework\spring-core\6.1.1\spring-core-6.1.1.jar
set CLASSPATH=%CLASSPATH%;C:\Users\%USERNAME%\.m2\repository\org\springframework\spring-beans\6.1.1\spring-beans-6.1.1.jar
set CLASSPATH=%CLASSPATH%;C:\Users\%USERNAME%\.m2\repository\org\springframework\spring-jcl\6.1.1\spring-jcl-6.1.1.jar
set CLASSPATH=%CLASSPATH%;C:\Users\%USERNAME%\.m2\repository\org\springframework\spring-aop\6.1.1\spring-aop-6.1.1.jar
set CLASSPATH=%CLASSPATH%;C:\Users\%USERNAME%\.m2\repository\org\springframework\spring-expression\6.1.1\spring-expression-6.1.1.jar
set CLASSPATH=%CLASSPATH%;C:\Users\%USERNAME%\.m2\repository\org\yaml\snakeyaml\2.2\snakeyaml-2.2.jar

REM 运行应用
echo Starting Playmate Backend...
java -cp "%CLASSPATH%" com.playmate.PlaymateApplication

pause