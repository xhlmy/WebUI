*** Settings ***
Force Tags        not_ready

*** Test Cases ***
Pubilish Medicine Package Activity
    [Documentation]    药品包活动
    ...    流程：运营人员发布药品包活动->采购商进入药品包活动页面验证->提交订单
    ...    规则：1.验证药品包发布成功；
    ...    \ \ \ \ \ 2.验证药品包价格；
    ...    \ \ \ \ 3.验证药品包最小采购量以及限制购买数量；
    ...    \ \ \ 4.验证订单金额；
    [Tags]
    [Timeout]
    Given Byuer And Manage Are Already Logined Certified User
    When Manager Creates The Medicine Package Activity
    Then Buyer Checks The Medicine Package Price And Limit Number

*** Keywords ***
Byuer And Manage Are Already Logined Certified User
    buyer login
    manager login

Manager Creates The Medicine Package Activity
    pubilish activity
    add medicine package
    set page

Buyer Checks The Medicine Package Price And Limit Number
    buyer can see medicine package price
    check minimum buy number and limit buyer number
    submit medicine package order
    check order money
