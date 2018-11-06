*** Settings ***
Library           DatabaseLibrary

*** Variables ***

*** Keywords ***
Connect Stage Database
    [Arguments]    ${dbName}
    Connect To Database    pymysql    dbName=${dbName}    dbUsername=user    dbPassword=yjy20111008    dbHost=stage.cmqndxdodheb.rds.cn-north-1.amazonaws.com.cn    dbPort=8306
    ...    dbConfigFile=None
