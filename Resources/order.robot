*** Settings ***
Resource          library.robot
Resource          inventory.robot
Resource          money.robot
Resource          ${RESOURCE_PATH}${/}single_service${/}交易域${/}商品${/}price_web.robot

*** Variables ***

*** Keywords ***
Verify The Jump To Alipay
    Click Button    btnSubmit
    Reload Page
    Sleep    3s
    Select Window    title=支付宝 - 网上支付 安全快速！
    Wait Until Element Is Visible    //img[@src="https://t.alipayobjects.com/tfscom/T1Z5XfXdxmXXXXXXXX.png"]    2min    未成功跳转至支付宝页面
    Close Window

Join Cart From Store
    [Arguments]    ${buyNumber}
    Wait Until Element Is Visible    //div[@class="imgh"]    ${WAIT_TIMEOUT}
    Click Element    //p[@class="buy_new"]/a[1]
    Sleep    1
    Wait Until Element Is Visible    jquery=div.addcart_up    ${WAIT_TIMEOUT}
    Click Element    jquery=a:contains("去购物车结算")    #去购物车
    Select Window    title=购物车 - 药品终端网
    Wait Until Element Is Visible    jquery=strong.koan    ${WAIT_TIMEOUT}    加入购物车失败，购物车为空
    Execute Javascript    ${buyNumber}    #修改商品数量
    Press Key    jquery=input.item-input    q    #敲回车键
    Execute Javascript    $('input.item-input').blur()    #失去输入框的焦点
    Sleep    500ms

Saler Can Not Sale Off
    Switch Browser    ${SALER_BROWSER}
    Go To    ${SALES_URL}/Order/Order/Detail?id=${ORDERCODE}
    ${status}    Run Keyword And Return Status    Wait Until Element Is Visible    //span[@class="realPostPrice"]
    Run Keyword If    '${status}'=='True'    Judge Free Postage
    ...    ELSE    Wait Until Element Is Not Visible    jquery=a:contains("订单优惠")    ${WAIT_TIMEOUT}    使用券没有邮费的订单显示了订单改价按钮

Buyer Close Order To Check Coupon Back
    Switch Browser    ${BUYER_BROWSER}
    Click Element    jquery=a:contains("我的订单")
    Search Text    ${ORDERCODE}
    Wait Until Element Is Visible    //a[@href="/Order/Home/Close?id=${ORDERCODE}"]    ${WAIT_TIMEOUT}    该订单的关闭订单按钮未出现
    Click Element    //a[@href="/Order/Home/Close?id=${ORDERCODE}"]
    Wait Until Element Is Visible    //div[@class="choose-btn"]    ${WAIT_TIMEOUT}    未弹出关闭订单的提示
    Click Element    confirmModalYes
    Wait Until Element Contains    //div[@class="Form-list"]/table/tbody/tr/td[6]/span    已关闭    ${WAIT_TIMEOUT}    #验证订单状态是否是等待出库

Saler Confirms Order Red
    Switch Browser    ${SALER_BROWSER}
    Go To    ${SALES_URL}/Order/Red/Index    #进入冲红查询界面
    Search Text    ${ORDERCODE}
    Wait Until Element Is Visible    jquery=a.oper    ${WAIT_TIMEOUT}
    Click Element    jquery=a.oper    #点击查看按钮
    Wait Until Element Is Visible    jquery=a.btn-xxs    ${WAIT_TIMEOUT}
    Click Element    jquery=a.btn-xxs    #确认冲红按钮
    Wait Until Element Is Visible    confirmModalYes    ${WAIT_TIMEOUT}
    Click Element    confirmModalYes    #确认冲红
    Search Text    ${ORDERCODE}
    Wait Until Element Contains    //span[@class="c-green"]    已完成    ${WAIT_TIMEOUT}    确认冲红失败

Check Order Status
    [Arguments]    ${orderStatus}
    #验证卖家的订单状态
    Switch Browser    ${SALER_BROWSER}
    Go To    ${SALES_URL}/Order/Order/Detail?id=${ORDER_CODE}
    Wait Until Element Is Visible    //p[@class="had"]/strong[text()="${orderStatus}"]
    #验证买家的订单状态
    Switch Browser    ${BUYER_BROWSER}
    Go To    ${PUR_URL}/Order/Home/Detail?id=${ORDER_CODE}
    Wait Until Element Is Visible    //p[@class="had"]/strong[text()="${orderStatus}"]

Judge Free Postage
    ${realPostPrice}    Get Text    //span[@class="realPostPrice"]
    Run Keyword If    '${realPostPrice}'=='¥0.00'    Wait Until Element Is Not Visible    jquery=a:contains("订单优惠")    ${WAIT_TIMEOUT}    使用券没有邮费的订单显示了订单改价按钮
    ...    ELSE    Wait Until Element Is Visible    jquery=a:contains("订单优惠")    ${WAIT_TIMEOUT}    使用券不包邮的订单未显示订单优惠按钮

Buyer Receipts Partial Goods
    Switch Browser    ${BUYER_BROWSER}
    Go To    ${PUR_URL}/Order/Home/Receive?id=${ORDERCODE}
    Comment    Search Text    ${ORDERCODE}
    Comment    Click Element    //a[@href="/Order/Home/Receive?id=${ORDERCODE}"]    #点击确认收货
    Wait Until Element Is Visible    jquery=input.checkGoodsNum
    Input Text    jquery=input.checkGoodsNum    ${RECEIPT_NUMBER}    #输入收货的数量
    Click Element    jquery=button.btn-md    #点击收货界面的确认收货
    Wait Until Element Is Visible    //input[@value="未收到货"]    ${WAIT_TIMEOUT}    等待冲红理由界面弹出
    Click Element    //input[@value="未收到货"]    #勾选未收到货选项
    Sleep    500ms
    Click Element    //input[@value="确认提交"]    #点击确认提交按钮
    Wait Until Element Is Visible    //div[@class="Form-list"]/table/tbody/tr/td[7]/span    ${WAIT_TIMEOUT}    确认收货产生冲红后页面未跳转到订单列表
    Comment    Wait Until Element Contains    //div[@class="Form-list"]/table/tbody/tr/td[7]/span    冲红待完成    ${WAIT_TIMEOUT}    收货失败

The Order Was Completed
    Check Account Balance After Order Completed    #验证交易完成后的金额变化

Check Cart Exceed Limit Buy Number Reminder

全部收货
    Switch Browser    ${BUYER_BROWSER}
    Go To    ${PUR_URL}/Order/Home
    Search Text    ${ORDERCODE}
    Click Element    //a[@href="/Order/Home/Receive?id=${ORDERCODE}"]    #点击确认收货
    Click Element    //button[@class="btn btn-blue btn-md"]

从商品详情页将商品加入购物车
    Go To    ${GOOD_DETAIL_URL}
    Wait Until Keyword Succeeds    2 times    5 s    等待商品详情页价格显示
    Execute Javascript    $(".number_list input").attr('value',${BUY_NUMBER})
    Execute Javascript    $(".number_list input").blur
    ${number}    Get Element Attribute    //div[@class="number_list"]/input@value
    Should Be Equal As Numbers    ${number}    ${BUY_NUMBER}    购买数量未设置成功
    Click Element    //a[@name="addCart"]
    Sleep    1s
