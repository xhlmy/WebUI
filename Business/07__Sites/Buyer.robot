*** Settings ***
Resource          ../../Resources/library.robot
Resource          ${RESOURCE_PATH}${/}single_service${/}通行证${/}login_web.robot

*** Test Cases ***
Page Check
    [Tags]    pur    stage    prod
    Buyer Logined Successfully
    购买报表
    药划算
    店铺内搜索
    [Teardown]    Close Browsers

*** Keywords ***
购买报表
    Go To    ${PUR_URL}/report/GoodsBuyReport/index
    Wait Until Element Is Visible    //thead/tr[1]/th[1]    ${WAIT_TIMEOUT}    历史购买报表页面未打开

药划算
    Go To    ${INDEX_URL}/jshop/ca/yaohuasuan
    Wait Until Element Is Visible    //div[@class="always-buy"]    ${WAIT_TIMEOUT}    药划算页面最近常买未显示

店铺内搜索
    Go To    ${STORE_URL}
    Wait Until Element Is Visible    keyWord
    Input Text    keyWord    ${SEARCH_GOOD_GYZZ}
    Click Button    search
    Wait Until Element Is Visible    //li[@data-shopdomain="${SALES_NAME}"]    ${WAIT_TIMEOUT}    店铺内搜本店未搜索出商品，请查看该商品的状态是否正常
    Click Button    searchShop
    Wait Until Element Is Visible    //div[@class="goods-list"]    ${WAIT_TIMEOUT}    在店铺内搜本店能够搜到的商品，在搜全城却搜索不到
    ${result}    Get Element Attribute    //div[@class="goods-list"]@data-totalcount
    ${result}    Convert To Integer    ${result}
    Should Be True    ${result}>0    店铺内搜索全城商品未搜索到数据
