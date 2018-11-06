*** Settings ***
Force Tags        recommend
Library           DatabaseLibrary
Resource          Resources/search.robot
Resource          ${RESOURCE_PATH}${/}single_service${/}通行证${/}login_web.robot
Resource          ${RESOURCE_PATH}${/}single_service${/}交易域${/}搜索${/}search_web.robot
Resource          ../../Resources/library.robot
Resource          ../../Resources/goods.robot

*** Test Cases ***
未登录时首页商品推荐及商品详情推荐
    [Documentation]    writer:yyy
    [Tags]
    Given 用户未登录状态下进入首页
    When 用户查看到首页的新品优选推荐
    And 用户进入此商品详情页面也能看到推荐商品
    [Teardown]    Close Browsers

已登录时首页商品推荐及商品详情推荐
    [Documentation]    writer:yyy
    [Tags]    stage
    Given Buyer Logined Successfully
    When 用户查看到首页的新品优选推荐
    And 用户进入此商品详情页面也能看到推荐商品
    When 用户通过热搜词任一搜索商品
    Then 用户能看到搜索结果页的推荐商品
    When 用户搜索一个不存在的商品
    Then 用户能看到搜索结果页的推荐商品
    [Teardown]    Close Browsers

未登录搜索有结果的商品推荐
    [Documentation]    writer:yyy
    [Tags]
    Given 用户未登录状态下进入首页
    When 用户通过热搜词任一搜索商品
    Then 用户能看到搜索结果页的推荐商品
    [Teardown]    Close Browsers

已登录搜索有结果的商品推荐
    [Documentation]    writer:yyy
    [Tags]
    Given Buyer Logined Successfully
    When 用户通过热搜词任一搜索商品
    Then 用户能看到搜索结果页的推荐商品
    [Teardown]    Close Browsers

未登录搜索无结果的商品推荐
    [Documentation]    writer:yyy
    [Tags]
    Given 用户未登录状态下进入首页
    When 用户搜索一个不存在的商品
    Then 用户能看到搜索结果页的推荐商品
    [Teardown]    Close Browsers

已登录搜索无结果的商品推荐
    [Documentation]    writer:yyy
    [Tags]
    Given Buyer Logined Successfully
    When 用户搜索一个不存在的商品
    Then 用户能看到搜索结果页的推荐商品
    [Teardown]    Close Browsers

*** Keywords ***
用户未登录状态下进入首页
    ${BUYER_BROWSER}=    Open Home Page    ${INDEX_URL}    firefox

用户查看到首页的新品优选推荐
    Go To    ${INDEX_URL}
    Wait Until Element Is Visible    //div[@id="J_newGoods"]//li[2]/div[@class="item-img"]/a/img    ${WAIT_TIMEOUT}    首页新品优选未加载出来
    Wait Until Element Is Visible    //div[@id="J_hotGoods"]//li[1]/div[@class="item-img"]/a/img    ${WAIT_TIMEOUT}    首页当前好卖未加载出来
    Comment    Wait Until Element Is Visible    //div[@id="J_gaomao"]//li[1]//img    ${WAIT_TIMEOUT}    首页高毛精选未加载出来
    ${homeRecommendGoodsUrl}    Get Element Attribute    //div[@id="J_hotGoods"]//li[1]/div[@class="item-img"]/a@href
    Set Test Variable    ${homeRecommendGoodsUrl}
    [Teardown]

用户通过热搜词任一搜索商品
    Go To    ${INDEX_URL}
    Wait Until Element Is Visible    hotKeyword    ${WAIT_TIMEOUT}    首页搜索框未加载出来
    Input Text    searchInput    阿莫西林
    Click Button    btnSearch
    Wait Until Page Contains Element    //div[@class="search-total-count"]    ${WAIT_TIMEOUT}    未搜索到对应商品

用户搜索一个不存在的商品
    输入商品进行搜索    国药准字YWIKSDKJK
    采购商无法搜索到此商品

用户能看到搜索结果页的推荐商品
    Wait Until Element Is Visible    //div[@class="aside-list"]/ul/li[2]//img    ${WAIT_TIMEOUT}    搜索结果页无推荐商品显示
    Capture Page Screenshot

用户进入此商品详情页面也能看到推荐商品
    Go To    ${homeRecommendGoodsUrl}
    Wait Until Element Is Visible    //ul/li[1]/a/img    ${WAIT_TIMEOUT}    商品详情页的推荐商品未显示出来
