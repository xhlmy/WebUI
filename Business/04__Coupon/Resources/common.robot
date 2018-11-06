*** Settings ***
Resource          ../../../Resources/order.robot
Resource          ../../../Resources/coupon.robot
Resource          ${RESOURCE_PATH}${/}single_service${/}通行证${/}login_web.robot
Resource          ${RESOURCE_PATH}${/}single_service${/}交易域${/}采购${/}下单${/}create_order_web.robot
Resource          ${RESOURCE_PATH}${/}single_service${/}交易域${/}搜索${/}search_web.robot

*** Keywords ***
Saler Publishes A Coupon
    Saler Logined Successfully
    Go To    ${SALES_URL}/promotion/coupon/Create?status=0
    ${couponMoney}    Evaluate    random.randint(1,10)    random,sys
    Input Text    Title    ${couponMoney}元优惠券    #活动名称
    Input Text    Price    ${couponMoney}    #单张面值
    Input Text    CardNum    1
    Comment    Unselect Checkbox    //input[@name='allArea']    #取消发放区域全选
    Input Text    LimitPrice    ${couponMoney}    #使用条件
    ${currentdate}=    Get Current Date    result_format=%Y-%m-%d
    Execute Javascript    document.getElementById('beginTime').setAttribute('value','${currentdate}')    #开始时间
    Execute Javascript    document.getElementById('endTime').setAttribute('value','${currentdate}')    #结束时间
    ${currentTime}    Get Current Date    result_format=%Y.%m.%d %H:%M
    ${startDemandTime}    Subtract Time From Date    ${currentTime}    00:05:00:000    result_format=%Y.%m.%d %H:%M
    ${endDemandTime}    Add Time To Date    ${currentTime}    01:00:00:000    result_format=%Y.%m.%d %H:%M
    Execute Javascript    document.getElementById('beginDemandTime').setAttribute('value','${startDemandTime}')    #开始时间
    Execute Javascript    document.getElementById('endDemandTime').setAttribute('value','${endDemandTime}')    #结束时间
    Comment    Select Radio Button    limitMerch    1    #使用商品范围：2是部分商品，1是全部商品
    Click Element    //dd//input[@value="${BUYER_AREA_CODE}"]
    Comment    Click Button    //button[@name='submit']
    Wait Until Keyword Succeeds    2 times    5s    Wait Coupon Was Submited Successfully
    ${url}    Get Text    //div[@class="center_body Yahei"]/p[2]/a[1]
    @{text}    Get Regexp Matches    ${url}    =(.....)    1
    ${COUPONID}    Convert To String    @{text}[0]
    Set Suite Variable    ${COUPONID}

提交订单并冻结库存
    Buyer Submits Order
    Check Coupon Number After Used    #使用优惠券后验证券数量变化

Get Coupon From Cart
    Go To    ${CART_URL}/cart/index
    Wait Until Element Is Visible    //tr[@id='J_goodsTr_${searchGoodId}']    ${WAIT_TIMEOUT}    购物车商品未加载出来
    Get My Coupon Number    #领券前获取优惠券总数
    Wait Until Element Is Visible    //a[@class="btn-coupon"]    ${WAIT_TIMEOUT}    等待优惠券按钮加载出来
    Mouse Over    //a[@class="btn-coupon"]
    Comment    Mouse Over    //a[@class="btn-coupon"]
    Comment    Mouse Down    //button[@value="${COUPONID}"]
    Wait Until Element Is Visible    //button[@value="${COUPONID}"]    ${WAIT_TIMEOUT}    等待优惠券列表中的点击领取按钮显示出来
    Comment    Mouse Up    //button[@value="${COUPONID}"]
    Click Element    //button[@value="${COUPONID}"]    #点击“点击领取”按钮
    Wait Until Element Is Visible    //li[@class="has-get"]/button[@value="${COUPONID}"]    ${WAIT_TIMEOUT}    购物车领取优惠券失败
    Check Coupon Number After Geted    #领券后验证券数量变化

Check Coupon Number After Geted
    Go To    ${PUR_URL}/Main/Home
    Wait Until Element Is Visible    //div[@class="right-module"]/p[2]
    ${text}    Get Text    //div[@class="right-module"]/p[2]
    @{number}    Get Regexp Matches    ${text}    优惠券：(.*) 查看我的优惠券 >>    1
    ${COUPON_NUMBER_GETED}    Convert To String    @{number}[0]
    Set Suite Variable    ${COUPON_NUMBER_GETED}
    ${differce}    Evaluate    ${COUPON_NUMBER_GETED}-${COUPON_NUMBER}
    Should Be Equal As Strings    ${differce}    1    领取优惠券失败
    Go Back

Check Coupon Number After Used
    Go To    ${PUR_URL}
    Wait Until Element Is Visible    //div[@class="right-module"]/p[2]    ${WAIT_TIMEOUT}    pur首页优惠券栏目未加载出来
    ${text}    Get Text    //div[@class="right-module"]/p[2]
    @{number}    Get Regexp Matches    ${text}    优惠券：(.*) 查看我的优惠券 >>    1
    ${COUPON_NUMBER_USED}    Convert To String    @{number}[0]
    Set Suite Variable    ${COUPON_NUMBER_USED}
    ${differce}    Evaluate    ${COUPON_NUMBER_GETED}-${COUPON_NUMBER_USED}
    Should Be Equal As Strings    ${differce}    1
    Go Back

Buyer Used A Coupon
    Execute Javascript    $("html,body").animate({scrollTop: $(".couponBtn").offset().top},1000)
    Wait Until Element Is Visible    //div[@class="couponBtn"]    ${WAIT_TIMEOUT}    未显示能使用的优惠券按钮

Get My Coupon Number
    Go To    ${PUR_URL}
    Wait Until Element Is Visible    //div[@class="right-module"]/p[2]    ${WAIT_TIMEOUT}
    ${text}    Get Text    //div[@class="right-module"]/p[2]
    @{couponNumber}    Get Regexp Matches    ${text}    优惠券：(.*) 查看我的优惠券 >>    1
    ${COUPON_NUMBER}    Convert To String    @{couponNumber}[0]
    Set Suite Variable    ${COUPON_NUMBER}
    Go Back

Wait The Goods Was Been Searched
    Click Element    searchBtn
    Wait Until Element Is Visible    merchSelList
    Wait Until Element Contains    //tbody[@id='merchSelList']//td[2]    ${SEARCH_GOOD}
    Click Element    //tbody[@id='merchSelList']//td[2]
    Checkbox Should Be Selected    name=merchSel

Wait Coupon Was Submited Successfully
    Click Button    //button[@name='submit']
    Wait Until Element Is Visible    //div[@class="center_body Yahei"]/p[2]/a[1]

等待购物车的优惠券展示出来
    Reload Page
    Wait Until Element Is Visible    //a[@class="btn-coupon"]    ${WAIT_TIMEOUT}    #等待优惠券按钮加载出来
    Click Element    //a[@class="btn-coupon"]    #点击优惠券下拉框
    Wait Until Element Is Visible    //button[@value="${COUPONID}"]    ${WAIT_TIMEOUT}    #等待优惠券列表中的点击领取按钮显示出来
