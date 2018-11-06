*** Settings ***
Force Tags        notReady
Resource          resource/common.robot

*** Test Cases ***
Publish Tuangou Activity
    [Documentation]    团购活动
    ...    流程：平台发布团购全场活动->不指定供应商->供应商参加活动->提交活动商品审核通过
    ...    规则：1.发布后参与活动商品在PC端价格不变
    [Tags]
    Given Over All Activities
    And Buyer Gets Goods Original Price
    When Manage Publishes Tuangou Activity
    And Saler Joins Tuangou Activity
    And Manager Approved To Verify Activity Goods
    Then Buyer Check The App Goods Price Is The Original Price In PC
    [Teardown]    Close Browsers

*** Keywords ***
Manage Publishes Tuangou Activity
    Manager Creates An Activity    团购    10 minutes    ${BUYER_AREA_CODE}

Saler Joins Tuangou Activity
    Saler Joined In The Activity    ${SALES_URL}/promotion/GroupBuy/Index
    Check Activity Goods Submit Success
