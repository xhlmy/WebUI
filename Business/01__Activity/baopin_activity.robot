*** Settings ***
Resource          resource/common.robot

*** Test Cases ***
Publish Baopin Activity
    [Documentation]    曝品活动
    ...    流程：平台发布爆品全场活动->不指定供应商->供应商参加活动->提交活动商品审核通过
    ...    规则：1.发布后参与活动商品在PC端价格不变
    [Tags]
    Given Over All Activities
    And Buyer Gets Goods Original Price
    When Manager Creates Baopin Activity
    And Saler Joins Baopin Activity
    And Manager Approved To Verify Activity Goods
    Then Buyer Check The App Goods Price Is The Original Price In PC
    [Teardown]    Close Browsers

*** Keywords ***
Saler Joins Baopin Activity
    Saler Joined In The Activity    ${SALES_URL}/promotion/Explosive/Index
    Check Activity Goods Submit Success

Manager Creates Baopin Activity
    Manager Creates An Activity    爆品    10 minutes    ${BUYER_AREA_CODE}

Baopin Goods Price Is Original Price In PC
    Buyer Check The App Goods Price Is The Original Price In PC
