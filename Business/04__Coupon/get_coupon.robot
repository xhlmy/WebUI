*** Settings ***
Suite Teardown
Test Teardown
Resource          Resources/common.robot

*** Test Cases ***
Delete Coupon From Store
    [Documentation]    商家优惠券(商铺领取)：
    ...    流程：供应商登录->发优惠券->采购商登录->采购商进入商铺领取优惠券
    ...    规则：1.领券后验证券的数量
    [Tags]
    Given Buyer And Saler Are Already Logined Certified User
    When Saler Publishes A Coupon
    Then Buyer Geted Coupon From Store
    [Teardown]    Close Browsers

Coupon From Goods Detail
    [Documentation]    商家优惠券(商品详情领取)：
    ...    流程：供应商登录->发优惠券->采购商登录->采购商进入商品详情领取优惠券
    ...    规则：1.领券后验证券的数量
    [Tags]    stage
    When Saler Publishes A Coupon
    Then Buyer Geted Coupon From Good Detail
    [Teardown]    Close Browsers

*** Keywords ***
Buyer Geted Coupon From Store
    Switch Browser    ${BUYER_BROWSER}
    Get My Coupon Number    #领券前获取优惠券总数
    Go To    ${STORE_URL}
    Wait Until Keyword Succeeds    60s    3s    等待优惠券展示出来
    Click Element    //a[@data-couponid="${COUPONID}"]
    ${status}    Run Keyword And Return Status    Wait Until Element Is Visible    useHref
    Run Keyword If    '${status}'=='False'    Wait Until Element Contains    //div[@class="couponBar"]/ul[1]//h3/span    已领取    ${WAIT_TIMEOUT}
    Check Coupon Number After Geted    #领券后验证券数量变化

Buyer And Saler Are Already Logined Certified User
    Buyer Logined Successfully    ${BUYER_MOBILE}    ${BUYER_PWD}

Buyer Geted Coupon From Good Detail
    Buyer Logined Successfully    ${BUYER_MOBILE}    ${BUYER_PWD}
    Go To    ${GOOD_DETAIL_URL}
    Wait Until Element Is Visible    //a[@href="/main/ShopStore/MoreCoupon"]
    Get My Coupon Number    #领券前获取优惠券总数
    Go To    ${STORE_URL}/main/ShopStore/MoreCoupon
    Wait Until Element Is Visible    //a[@data-couponid="${COUPONID}"]    ${WAIT_TIMEOUT}    无优惠券可领取
    Click Element    //a[@data-couponid="${COUPONID}"]
    Wait Until Element Is Not Visible    //a[@data-couponid="${COUPONID}"]    ${WAIT_TIMEOUT}    店铺领取优惠券失败
    Check Coupon Number After Geted    #领券后验证券数量变化

等待优惠券展示出来
    Reload Page
    Wait Until Element Is Visible    //a[@data-couponid="${COUPONID}"]    ${WAIT_TIMEOUT}    无优惠券可领取
