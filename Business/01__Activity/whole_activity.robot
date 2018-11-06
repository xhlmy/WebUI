*** Settings ***
Resource          resource/common.robot

*** Test Cases ***
Publish Whole Activity To Special Saler
    [Documentation]    全场活动
    ...    流程：平台发布特价全场活动(指定供应商)->供应商参与活动->审核通过->商品显示在活动页面验证商品信息
    ...    规则：1.未指定商家无法查看到活动；
    ...    2.商品审核失败可以重新提交一次；
    ...    3.验证参加活动商品价格与特价一致；
    ...    4.验证限购数量与设置一致；
    [Tags]
    Manager Logined Successfully
    Manage Terminates All Activity
    Given Over All Activities
    When Manage Creates The Whole Activity To Special Saler
    And Saler Joins The Whole Activity
    And Manager Approved To Verify Activity Goods
    Then Buyer Checks The Whole Activity Price And Limit Inventory
    [Teardown]    Close Browsers

Publish Whole Activity To All Salers
    [Documentation]    特价全场活动(所有供应商)
    ...    流程：平台发布特价全场活动(所有供应商)->供应商参与活动->提交活动商品审核->审核通过->商品显示在活动页面->验证商品信息
    ...    规则：1.验证供应商可以参加活动
    ...    \ \ \ \ \ 2.商品审核失败可以重新提交一次；
    ...    \ \ \ \ 3.验证参加活动商品价格与特价一致；
    [Tags]
    Manager Logined Successfully
    Manage Terminates All Activity
    Given Over All Activities
    When Manager Creates An Activity To All Salers
    And Saler Joins The Whole Activity
    And Manager Refuses To Verfiy Activity Goods
    And Salers Submits Refused Goods
    And Manager Verfies Goods
    Then Buyer Checks The Whole Activity Price And Limit Inventory
    [Teardown]    Close Browsers

*** Keywords ***
Manage Creates The Whole Activity To Special Saler
    Manager Creates An Activity    特价    10 minutes    ${BUYER_AREA_CODE}

Saler Joins The Whole Activity
    Saler Joined In The Activity    ${SALES_URL}/promotion/MemberDayActivitys/Index
    Check Activity Goods Submit Success

Buyer Checks The Whole Activity Price And Limit Inventory
    Buyer Logined Successfully    ${BUYER_MOBILE}    ${BUYER_PWD}
    Buyer Checks Activity Price
    Buyer Checks Limit Inventory

Create An Activity To All Salers
    [Arguments]    ${activityType}    ${activityTime}
    Switch Browser    ${MANAGE_BROWSER}
    Go To    ${M_URL}/Operate/Activity/Index
    Wait Until Element Is Visible    createLink
    Click Element    createLink    #点击新增
    Wait Until Element Is Visible    Title
    ${num}=    Evaluate    random.randint(0,sys.maxint)    random,sys
    Convert To String    ${num}
    ${ACTIVITY_NAME}=    Catenate    平台活动${num}
    Set Global Variable    ${ACTIVITY_NAME}
    Input Text    Title    ${ACTIVITY_NAME}    #输入活动名称
    Select From List By Label    PromoType    ${activityType}    #选择活动类型
    List Selection Should Be    PromoType    ${activityType}
    ${time}    Get Element Attribute    //input[@id='CollectStartTime']@value    #获取征集开始时间
    ${collectEndTime}    Add Time To Date    ${time}    ${activityTime}    result_format=%Y.%m.%d %H:%M
    ${activityStartTime}    Add Time To Date    ${collectEndTime}    1 minutes    result_format=%Y.%m.%d %H:%M
    ${activityEndTime}    Add Time To Date    ${collectEndTime}    2 minutes    result_format=%Y.%m.%d %H:%M
    Execute Javascript    document.getElementById('ActivityStartTime').setAttribute('value','${activityStartTime}')    #输入活动开始时间
    Execute Javascript    document.getElementById('ActivityEndTime').setAttribute('value','${activityEndTime}')    #输入活动结束时间
    Execute Javascript    document.getElementById('CollectEndTime').setAttribute('value','${collectEndTime}')    #输入活动征集结束时间
    Click Element    //input[@value="${BUYER_AREA_CODE}"]    #选择活动区域
    Click Element    l_submit
    Wait Until Element Is Visible    //div[@id='search_condition']//input    ${WAIT_TIMEOUT}    #验证：提交后返回到活动管理列表
    Input Text    //div[@id='search_condition']//input    ${ACTIVITY_NAME}
    Click Element    //button[@class="btn red search_submit"]    #点击搜索活动按钮
    Wait Until Element Is Visible    //td[contains(.,"${ACTIVITY_NAME}")]
    ${status}    Run Keyword And Return Status    Wait Until Element Is Visible    //td[contains(.,"${ACTIVITY_NAME}")]/parent::*/child::td/a[contains(.,"活动页面")]
    Run Keyword If    '${status}'=='True'    Get Activity Url

Manager Creates An Activity To All Salers
    Create An Activity To All Salers    特价    10min

Manage And Salers Are Already Logined Certified User
    Buyer Logined Successfully    ${BUYER_MOBILE}    ${BUYER_PWD}
    Saler Logined Successfully
    Close The Ongoing Activities
    Manager Logined Successfully
    Terminate All Activity Before Create

Buyer Checks Limit Inventory
    ${inventry}=    Get Text    //span[@class="border0"]/em
    Should Be Equal As Strings    ${inventry}    ${XIANGOU_NUM}    限购库存不匹配

Buyer Checks Activity Price
    Switch Browser    ${BUYER_BROWSER}
    Go To    ${ACTIVITY_URL}
    Wait Until Page Contains Element    //div[@class="top_img1"]
    Execute Javascript    $("html,body").animate({scrollTop: $("div.contain div:eq(0)").offset().top},1000)
    Wait Until Element Is Visible    //div[@class="contain"]/div[1]//span[@class="nowPrice"]    ${WAIT_TIMEOUT}    活动价格未加载
    ${price1}=    Get Text    //div[@class="contain"]/div[1]//span[@class="nowPrice"]
    @{price2}    Get Regexp Matches    ${price1}    ￥(.*)    1
    ${price}    Convert To String    @{price2}[0]
    Should Be Equal As Numbers    ${price}    ${ACTIVITY_PRICE}    价格不匹配

Salers Submits Refused Goods
    Switch Browser    ${SALER_BROWSER}
    Click Element    jquery=a:contains("已提交商品")
    Wait Until Element Is Visible    //a[@command="commit"]    ${WAIT_TIMEOUT}    已提交商品页面加载失败
    Click Element    //a[@command="commit"]    #点击再次提交
    Wait Until Element Is Visible    //a[@command="rcommit"]    ${WAIT_TIMEOUT}
    Click Element    //a[@command="rcommit"]    #点击确认提交按钮
    Wait Until Element Is Visible    //a[@command="edit"]    ${WAIT_TIMEOUT}    提交商品失败

Manager Verfies Goods
    Switch Browser    ${MANAGE_BROWSER}
    Reload Page
    Wait Until Element Is Visible    //a[@command="pass"]    ${WAIT_TIMEOUT}    商品审核页面加载失败
    Click Element    //a[@command="pass"]    #点击通过
    Wait Until Element Is Visible    Confirm    ${WAIT_TIMEOUT}    通过审核失败
    Click Element    Confirm
    Wait Until Element Is Visible    //span[@class="green"]    ${WAIT_TIMEOUT}    审核失败

Manager Refuses To Verfiy Activity Goods
    Switch Browser    ${MANAGE_BROWSER}
    Click Element    //button[@class="btn red search_submit"]    #点击搜索活动按钮
    Wait Until Element Is Visible    //td[contains(.,"${ACTIVITY_NAME}")]/parent::*/child::td/a[contains(.,"商品审核")]    ${WAIT_TIMEOUT}
    Click Element    //td[contains(.,"${ACTIVITY_NAME}")]/parent::*/child::td/a[contains(.,"商品审核")]    #点击商品审核
    Wait Until Element Is Visible    //a[@command="pass"]    ${WAIT_TIMEOUT}    商品提交失败
    Click Element    //a[@command="refuse"]    #点击拒绝
    Wait Until Element Is Visible    css=[value="库存不足"]    ${WAIT_TIMEOUT}    拒绝理由框未加载
    Click Element    css=[value="库存不足"]    #选择拒绝理由
    Click Button    commit    #点击确定
    Wait Until Element Is Visible    jquery=span:contains("已拒绝")    ${WAIT_TIMEOUT}    拒绝审核失败
