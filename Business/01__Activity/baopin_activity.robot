*** Settings ***
Resource          resource/common.robot

*** Test Cases ***
Publish Baopin Activity
    [Documentation]    ��Ʒ�
    ...    ���̣�ƽ̨������Ʒȫ���->��ָ����Ӧ��->��Ӧ�̲μӻ->�ύ���Ʒ���ͨ��
    ...    ����1.�����������Ʒ��PC�˼۸񲻱�
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
    Manager Creates An Activity    ��Ʒ    10 minutes    ${BUYER_AREA_CODE}

Baopin Goods Price Is Original Price In PC
    Buyer Check The App Goods Price Is The Original Price In PC
