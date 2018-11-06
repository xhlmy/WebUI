*** Settings ***
Documentation     搜索价格库存同步是指当商品的价格和库存发生变化时，搜索界面的价格库存会随之变化
Force Tags        search
Resource          ../../Resources/goods.robot
Resource          ../../Resources/money.robot
Resource          ../../Resources/inventory.robot
Resource          ${RESOURCE_PATH}${/}combine_service${/}交易域${/}商品${/}goods_web.robot
Resource          ${RESOURCE_PATH}${/}single_service${/}交易域${/}商品${/}price_web.robot

*** Test Cases ***
商家药销宝修改价格库存后搜索价格库存同步
    [Documentation]    writer:yyy
    ...    搜索价格库存同步主要验证：
    ...    前提：商家在药销宝修改价格库存
    ...    1、终端宝搜索界面能查看到最新的价格
    ...    2、终端宝搜索界面能查看到最新的库存
    [Tags]
    [Setup]
    Given 商业登录并修改价格和库存
    When Buyer Search Goods
    Then Buyer Can See The Last Price And Inventory In Search Page
    [Teardown]    Close Browsers

TO DO商家ERP修改价格库存后搜索价格库存同步
    [Tags]    not_ready

*** Keywords ***
商业登录并修改价格和库存
    Saler Logined Successfully
    商业修改价格和库存
