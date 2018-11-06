*** Settings ***
Resource          ${RESOURCE_PATH}${/}single_service${/}营销域${/}活动${/}activity_web.robot
Resource          ${RESOURCE_PATH}${/}single_service${/}通行证${/}login_web.robot
Resource          ${RESOURCE_PATH}${/}single_service${/}交易域${/}商品${/}price_web.robot
Resource          ../../../Resources/library.robot

*** Keywords ***
Get Activity Url
    ${ACTIVITY_URL}    Get Element Attribute    //td[contains(.,"${ACTIVITY_NAME}")]/parent::*/child::td/a[contains(.,"活动页面")]@href    #获取活动页面的链接
    Set Suite Variable    ${ACTIVITY_URL}

Get Goods Original Price
    Go To    ${ACTIVITY_GOOD_URL}
    Wait Until Keyword Succeeds    5s    1s    Wait Original Price In Goods Detail Page

Buyer Check The App Goods Price Is The Original Price In PC
    Switch Browser    ${BUYER_BROWSER}
    Reload Page
    Wait Until Keyword Succeeds    5s    1s    等待商品详情页价格显示
    Should Be Equal As Numbers    ${PRICE}    ${ORIGINAL_PRICE}

Input Activity Name And Area
    Saler Logined Successfully
    Go To    ${SALES_URL}/promotion/tejia/create?status=0
    Comment    Click Element    //a[@class="btn btn-blue cond-submit search_submit"]    #点击发布特价商品
    Wait Until Element Is Visible    //input[@class="combo-text validatebox-text"]    ${WAIT_TIMEOUT}    输入商品名称框未显示
    Sleep    1s
    Input Text    //input[@class="combo-text validatebox-text"]    ${ACTIVITY_GOOD}    #输入特价商品名称
    Wait Until Element Is Visible    //tr[@id='datagrid-row-r1-2-0']/td[3]/div    ${WAIT_TIMEOUT}    未搜索到商品
    Wait Until Keyword Succeeds    10s    1s    Wait Text Is Visible
    Click Element    //tr[@id='datagrid-row-r1-2-0']/td[3]/div    #选择特价商品
    Wait Until Element Is Not Visible    //tr[@id='datagrid-row-r1-2-0']/td[3]/div    ${WAIT_TIMEOUT}
    Unselect Checkbox    //input[@name='chkAll']    #取消区域全选
    Select Checkbox    //input[@value="${BUYER_AREA_CODE}"]
    Checkbox Should Be Selected    //input[@value="${BUYER_AREA_CODE}"]

Wait Text Is Visible
    ${text}    get text    //tr[@id='datagrid-row-r1-2-0']/td[3]/div
    Should Be Equal    ${text}    ${ACTIVITY_GOOD}

Wait Original Price In Goods Detail Page
    Wait Until Element Is Visible    //b[@name="goodsPrice"]    ${WAIT_TIMEOUT}    价格未加载出来
    ${priceStr}    get text    //b[@name="goodsPrice"]
    Should Not Be Equal    ${priceStr}    ¥0.00
    @{price}    Get Regexp Matches    ${priceStr}    ¥(.*)    1
    ${ORIGINAL_PRICE}    Convert To String    @{price}[0]
    Set Suite Variable    ${ORIGINAL_PRICE}

Over All Activities
    Comment    Manager Logined Successfully
    Comment    Manage Terminates All Activity
    Saler Logined Successfully
    Close The Ongoing Activities

Buyer Gets Goods Original Price
    Buyer Logined Successfully    ${BUYER_MOBILE}    ${BUYER_PWD}
    Get Goods Original Price
