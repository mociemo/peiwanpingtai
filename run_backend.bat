@echo off
echo Setting up environment for Playmate Backend...

REM 设置Java路径
set JAVA_HOME=C:\Program Files\Java\jdk-25
set PATH=%JAVA_HOME%\bin;%PATH%

REM 设置类路径
set CLASSPATH=target/classes

REM 添加所有依赖的jar文件到类路径
for /r "target" %%f in (*.jar) do (
    set CLASSPATH=!CLASSPATH!;%%f
)

REM 运行应用
echo Starting Playmate Backend...
java -cp "%CLASSPATH%" com.playmate.PlaymateApplication

pause