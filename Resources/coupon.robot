*** Settings ***
Library           DateTime
Resource          library.robot

*** Variables ***

*** Keywords ***
Do Not Use The Coupon
    ${status}    Run Keyword And Return Status    Wait Until Element Is Visible    //div[@class="coupon"]
    Run Keyword If    '${status}'=='True'    Choose Coupon Unuse

Choose Coupon Unuse
    Execute Javascript    $("html,body").animate({scrollTop: $(".couponBtn").offset().top},1000)
    Sleep    1s
    Click Element    //div[@class="couponBtn"]    #点击优惠券下拉框
    Wait Until Element Is Visible    jquery=span:contains("不使用优惠券")
    Click Element    jquery=span:contains("不使用优惠券")    #点击“不使用优惠券”按钮
    Wait Until Element Contains    //div[@class="couponBtn"]/span    不使用优惠券
