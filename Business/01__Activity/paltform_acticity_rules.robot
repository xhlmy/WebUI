*** Settings ***
Resource          resource/common.robot

*** Test Cases ***
Goods Fail To Join Two Activity The Same Time In The Same Area
    [Documentation]    验证活动规则：同一商品同一时间同一区域只能参加一种活动
    ...    流程：运营平台发布全场活动-->供应商参加全场活动-->供应商提交同一商品-->运营平台发布爆品活动-->供应商参加爆品活动-->供应商提交同一商品
    ...    规则：1.验证供应商可以参加活动
    ...    \ \ \ \ \ 2.提交同一商品参加爆品活动失败
    [Tags]
    Given Publish The Whole Activity
    And Saler Join The Whole Activity Successful
    When Publish The Tuangou Activity At Same Time In Same Area
    Then Saler Fail To Commit Baopin Activity Goods
    [Teardown]    Close Browsers

Goods Can Join Diffrent Area's Activity Same Time
    [Documentation]    验证活动规则：同一商品同一时间可以参加不同区域的同一种活动
    ...    流程：运营平台发布湖北全场活动-->供应商参加湖北全场活动-->供应商提交商品-->运营平台发布重庆全场活动-->同一供应商参加重庆全场活动-->供应商提交同一商品
    ...    规则：1.验证供应商可以参加不同区域的活动
    ...    \ \ \ \ \ 2.同一商品参加同一时间不同区域的活动
    [Tags]
    Given Pbulish The Whole Activity In Hubei
    And Saler Join The Whole Activity Successful
    When Pbulish The Whole Activity In Chongqing
    Then Saler Commit Goods Of Chongqing Activity Successful
    [Teardown]    Close Browsers

Same Goods Can Jion Different Time's Activity In The Same Area
    [Documentation]    验证活动规则：同一商品可以参加同一区域不同时间段的活动
    ...    流程：运营平台发布湖北全场活动-->供应商参加全场活动-->供应商提交商品-->运营平台发布湖北不同时间的全场活动-->同一供应商参加全场活动-->供应商提交同一商品
    ...    规则：1.验证供应商可以参加不同区域的活动
    ...    \ \ \ \ \ 2.同一商品参加同一区域不同时间的活动
    [Tags]
    Given Pbulish The Whole Activity In Hubei
    And Saler Join The Whole Activity Successful
    When Publish The Activity Again In Different Time
    Then Saler Joined The Activity Successful
    [Teardown]    Close Browsers

*** Keywords ***
Publish The Whole Activity
    Over All Activities
    Manager Creates An Activity    特价    10minutes    ${BUYER_AREA_CODE}

Pbulish The Whole Activity In Hubei
    Over All Activities
    Manager Creates An Activity    特价    10 minutes    ${BUYER_AREA_CODE}

Pbulish The Whole Activity In Chongqing
    Manager Creates An Chongqing Activity    特价    10 minutes

Publish The Activity Again In Different Time
    Manager Creates An Activity    特价    20 minutes    ${BUYER_AREA_CODE}

Publish The Tuangou Activity At Same Time In Same Area
    Manager Creates An Activity    团购    10 minutes    ${BUYER_AREA_CODE}

Check Commit Baopin Good Fail

Saler Join The Whole Activity Successful
    Saler Joined In The Activity    ${SALES_URL}/promotion/MemberDayActivitys/Index
    Check Activity Goods Submit Success

Saler Fail To Commit Baopin Activity Goods
    Saler Joined In The Activity    ${SALES_URL}/promotion/GroupBuy/Index
    Check Activity Goods Submit Fail

Saler Commit Goods Of Chongqing Activity Successful
    Saler Joined In The Activity    ${SALES_URL}/promotion/MemberDayActivitys/Index
    Check Activity Goods Submit Success

Saler Joined The Activity Successful
    Saler Joined In The Activity    ${SALES_URL}/promotion/MemberDayActivitys/Index
    Check Activity Goods Submit Success

Manager Creates An Chongqing Activity
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
    Click Element    //input[@value="500000"]    #选择活动区域
    Click Element    uniform-hideRadio    #指定供应商
    Wait Until Element Is Visible    salersName    ${WAIT_TIMEOUT}
    Input Text    salersName    ${COMPANY_NAME}
    Click Button    //button[@onclick="QuerySalers()"]    #点击搜索商家按钮
    Wait Until Element Is Visible    jquery=a:contains("增加"):eq(0)    ${WAIT_TIMEOUT}    未搜索到商家
    Click Element    jquery=a:contains("增加"):eq(0)    #点击新增
    Wait Until Element Is Visible    jquery=a:contains("移除"):eq(0)    ${WAIT_TIMEOUT}    新增供应商失败
    Click Element    l_submit
    Wait Until Element Is Visible    //div[@id='search_condition']//input    ${WAIT_TIMEOUT}    #验证：提交后返回到活动管理列表
    Input Text    //div[@id='search_condition']//input    ${ACTIVITY_NAME}
    Click Element    //button[@class="btn red search_submit"]    #点击搜索活动按钮
    Wait Until Element Is Visible    //td[contains(.,"${ACTIVITY_NAME}")]
    ${status}    Run Keyword And Return Status    Wait Until Element Is Visible    //td[contains(.,"${ACTIVITY_NAME}")]/parent::*/child::td/a[contains(.,"活动页面")]
    Run Keyword If    '${status}'=='True'    Get Activity Url

Manage Terminate All Activity
    Switch Browser    ${MANAGE_BROWSER}
    Click Element    //a[@href="/Operate/Activity/Index"]
    Manage Terminates All Activity

Check Activity Goods Submit Fail
    Reload Page
    Wait Until Element Is Visible    jquery=input.serach    ${WAIT_TIMEOUT}    页面加载失败
    Wait Until Page Contains Element    //p/a[@href="${ACTIVITY_GOOD_URL}"]    ${WAIT_TIMEOUT}    同一商品不能参加多个活动    #//td[contains(.,"平台活动")]/parent::*/child::td/a[contains(.,"活动终止")]
