*** Settings ***
Suite Setup
Suite Teardown    Close Browsers
Test Setup
Test Teardown
Force Tags
Resource          resource/common.robot
Resource          ../../Resources/order.robot
Resource          ../../Resources/coupon.robot
Resource          ${RESOURCE_PATH}${/}single_service${/}交易域${/}采购${/}下单${/}create_order_web.robot
Resource          ${RESOURCE_PATH}${/}single_service${/}交易域${/}采购${/}购物车${/}cart_web.robot
Resource          ${RESOURCE_PATH}${/}combine_service${/}交易域${/}订单${/}order_web.robot
Resource          ${RESOURCE_PATH}${/}single_service${/}交易域${/}商品${/}price_web.robot

*** Variables ***

*** Test Cases ***
Check Tejia Activity Rules
    [Documentation]    供应商特价活动
    ...    流程：供应商发布特价活动->采购商进商品详情验证->购物车->提交订单
    ...    规则：1.验证特价活动标签；
    ...    \ \ \ \ \ 2.验证特价价格；
    ...    \ \ \ \ 3.验证限购（详情、购物车）
    ...    \ \ \ 4.验证订单金额
    [Tags]    stage
    [Setup]
    When Saler Publishes Tejia Activity
    Then Buyer Can Not Buy More Than Limit Number Of Goods For Tejia In Goods Detail Page
    And Buyer Can Not Buy More Than Limit Number Of Goods For Tejia In Cart Page
    [Teardown]    Close The Ongoing Activities

*** Keywords ***
Join Cart From Goods Detail
    [Arguments]    ${buyNumber}
    Execute Javascript    ${buyNumber}    #修改购买数量
    Click Element    //a[@name="addCart"]    #点击加入购物车
    Sleep    1
    Wait Until Element Is Visible    jquery=div.addcart_up    ${WAIT_TIMEOUT}    加入购物车未成功
    Click Element    jquery=a:contains("去购物车结算")    #去购物车
    Select Window    title=药品终端网
    Wait Until Element Is Visible    //tr[@id="J_goodsTr_${searchGoodId}"]    ${WAIT_TIMEOUT}    加入购物车失败，购物车为空

Saler Publishes Tejia Activity
    Creat A New Tejia Activity
    Buyer Can See The Tejia Activity

Buyer Can Not Buy More Than Limit Number Of Goods For Tejia In Goods Detail Page
    Buyer Can't Buy Goods More Than Limit Number With Tejia    #买家购买超出限购数量后无法以特价购买
    Buyer Cannot Buy Goods With Tejia After Add Limited Buy Counts To Cart    #买家加入限购数量进入购物车后不能以特价继续购买
    Check The Order Amount Is Tejia    #检查订单金额为特价
    Buyer Cannot Buy Goods With Tejia After Add Submit Orders    #买家提交订单后不能以特价继续购买
    Buyer Can Continue To Buy After Closing Orders    #买家关闭订单后能够继续购买

Creat A New Tejia Activity
    Get Goods Price
    Input Activity Name And Area
    Input Activity Price
    Immediately Start Activity

Buyer Cannot Buy Goods With Tejia After Add Limited Buy Counts To Cart
    Join Cart From Goods Detail    $('input[name="buyNum"]').attr("value", ${XIANGOU_NUM})    #加入限购数量进入购物车
    Check Continue To Buy After Join Limit Buy Number    #加入限购数量后继续购买

Buyer Cannot Buy Goods With Tejia After Add Submit Orders
    Buyer Submits Order
    Check Continue To Buy After Join Limit Buy Number

Check The Order Amount Is Tejia
    Select Window    title=药品终端网
    Buyer Confirm Order
    Do Not Use The Coupon
    Get The Postage
    Check The Payment Amount

Buyer Can Continue To Buy After Closing Orders
    Select Window    title=支付订单 - 支付平台 - 药品终端网
    Buyer Closes Order
    Check Can Buy After Closed The Order

Buyer Can Not Buy More Than Limit Number Of Goods For Tejia In Cart Page
    Click Element    //tr[@id="J_goodsTr_${searchGoodId}"]/td[5]//button[2]
    Sleep    1s
    从购物车获取商品价格
    Should Not Be Equal    ${GOOD_PRICE}    ${TEJIA_PRICE}    超出限购未按原价显示

Input Activity Price
    Input Text    //input[@name="PromoPrice"]    ${TEJIA_PRICE}    #输入商品特价
    Select Checkbox    //input[@name="IsLimit"]
    Wait Until Element Is Visible    //input[@name="LimitNum"]    ${WAIT_TIMEOUT}    限购输入框未显示
    Input Text    //input[@name="LimitNum"]    ${XIANGOU_NUM}

Buyer Can See The Tejia Activity
    Switch Browser    ${BUYER_BROWSER}
    Go To    ${STORE_URL}/0/${ACTIVITY_GOOD_ID}
    Wait Until Element Is Visible    jquery=em:contains("特价活动")    ${WAIT_TIMEOUT}    特价限购未显示    #检查特价限购标签
    Wait Until Keyword Succeeds    5s    1s    等待商品详情页价格显示
    Should Be Equal As Numbers    ${PRICE}    ${TEJIA_PRICE}

Get Goods Price
    Buyer Logined Successfully    ${BUYER_MOBILE}    ${BUYER_PWD}
    Ensure The Cart Is Empty
    Go To    ${STORE_URL}/0/${ACTIVITY_GOOD_ID}
    Wait Until Keyword Succeeds    5s    1s    等待商品详情页价格显示
    ${teJiaPrice}    Evaluate    round(${PRICE}*0.5,2)
    ${TEJIA_PRICE}    Convert To String    ${teJiaPrice}
    Set suite Variable    ${TEJIA_PRICE}

Check The Payment Amount
    Comment    ${totalPrice}    Convert Number    //strong[@class="txt_16 yellow"]    #获取订单总价
    ${totalPrice}    Get Element Attribute    //span[@class="red j_subPrice"]@data-nowprice    #获取订单总价
    ${payment}=    Evaluate    ${TEJIA_PRICE}*${XIANGOU_NUM}+${POSTAGE}    #计算应支付金额
    Should Be Equal As Numbers    ${totalPrice}    ${payment}    特价商品订单未按照特价计算

Check Continue To Buy After Join Limit Buy Number
    Select Window    url=${STORE_URL}/0/${ACTIVITY_GOOD_ID}
    Reload Page
    Wait Until Element Is Visible    //input[@name="buyNum"]    ${WAIT_TIMEOUT}    输入采购数量框未显示
    Wait Until Keyword Succeeds    5s    1s    等待商品详情页价格显示
    Execute Javascript    $('input[name="buyNum"]').attr("value", 1)    #购物车达到限购数量在购买1个商品
    Click Element    //a[@name="addCart"]    #点击加入购物车
    Wait Until Element Is Visible    //div[@class="l_center"]    ${WAIT_TIMEOUT}    超过限购提示未显示
    Wait Until Element Contains    //div[@class="l_center"]/p[1]    采购数量已超出特价限购数量，本次采购数量将全部按照原价购买。    ${WAIT_TIMEOUT}    超过限购提示未显示
    Click Element    //a[@class="l_btna gray"]    #关闭限购提示

Check Can Buy After Closed The Order
    Select Window    url=${STORE_URL}/0/${ACTIVITY_GOOD_ID}
    Reload Page
    Wait Until Element Is Visible    //input[@name="buyNum"]    ${WAIT_TIMEOUT}    输入采购数量框未显示
    Wait Until Keyword Succeeds    5s    1s    等待商品详情页价格显示
    Join Cart From Goods Detail    $('input[name="buyNum"]').attr("value", ${XIANGOU_NUM})

Buyer Can't Buy Goods More Than Limit Number With Tejia
    Execute Javascript    $('input[name="buyNum"]').attr("value", ${XIANGOU_NUM}+1)    #修改购买数量（限购数量加1）
    Execute Javascript    $("html,body").animate({scrollTop: $("a.add_shopcard").offset().top},1000)
    Sleep    1s
    Click Element    //a[@class="add_shopcard mright"]    #点击加入购物车
    Wait Until Element Is Visible    //div[@class="l_center"]    ${WAIT_TIMEOUT}    超过限购提示未显示
    Wait Until Element Contains    //div[@class="l_center"]/p[1]    采购数量已超出特价限购数量，本次采购数量将全部按照原价购买。    ${WAIT_TIMEOUT}    限购弹窗错误
    Click Element    //a[@class="l_btna gray"]    #取消加入购物车操作
    Wait Until Element Is Visible    //a[@name="addCart"]    ${WAIT_TIMEOUT}    超过限购提示弹窗未消失

Immediately Start Activity
    Click Element    jquery=button[name='submit']    #点击提交
    Wait Until Element Is Visible    //button[@data-bb-handler="cancel"]    ${WAIT_TIMEOUT}
    Click Element    //button[@data-bb-handler="cancel"]    #点击取消
    Wait Until Element Is Visible    //tbody/tr[1]/td[8]/span    ${WAIT_TIMEOUT}    商家特价活动发布失败
    Comment    ${status}    Run Keyword And Return Status    Wait Until Element Is Visible    //a[@name="startPromo"]    ${WAIT_TIMEOUT}    没有待开始的活动
    Comment    Run Keyword If    '${status}'=='True'    Start Activity    #存在待开始状态的活动立即开始活动
    Wait Until Keyword Succeeds    60s    3s    Wait Activity start

Start Activity
    Click Element    //a[@name="startPromo"]    #点击开始活动
    Wait Until Element Is Visible    //button[@class="btn btn-primary"]    ${WAIT_TIMEOUT}
    Click Element    //button[@class="btn btn-primary"]    #点击确认开始
    Wait Until Keyword Succeeds    20s    1s    Wait Activity start

Wait Activity start
    Reload Page
    Wait Until Element Contains    //tbody/tr[1]/td[8]/span    进行中

Buyer Clear Cart
    Buyer Logined Successfully    ${BUYER_MOBILE}    ${BUYER_PWD}
    Ensure The Cart Is Empty
