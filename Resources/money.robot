*** Settings ***
Resource          library.robot

*** Variables ***

*** Keywords ***
Check Ordercode Of Accounts Detail
    [Arguments]    ${orderLocator}
    ${detailOrdercode}=    Get Text    ${orderLocator}
    @{detailOrdercode}=    Get Regexp Matches    ${detailOrdercode}    (DD.*)    1
    Should Be Equal    @{detailOrdercode}    ${ORDERCODE}

Check Money Of Accounts Detail
    [Arguments]    ${moneyLocator}    ${money}
    ${detailAmount}=    Convert Number    ${moneyLocator}
    Should Be Equal    ${detailAmount}    ${money}

Check Account Balances Of Accounts Detail
    [Arguments]    ${calculation}
    ${detailAccountBalance}=    Convert Money Of Accounts Detail    //div[@class="Form-list"]/table/tbody/tr/td[6]
    ${balance}=    Evaluate    ${calculation}    #账户余额
    Should Be Equal    ${balance}    ${detailAccountBalance}

Go To Accounts Detail Of Buyer
    Go To    ${PURURL}/Finance/TradeCashFlow
    Wait Until Element Is Visible    //div[@class="Form-list"]/table/tbody/tr/td[7]    ${WAIT_TIMEOUT}

Check Outbound Money Of Supplier Order List
    Comment    Search Ordercode
    ${OUTBOUND_MONEY}=    Convert Number    //tbody//td[6]
    ${total}=    Evaluate    ${GOOD_PRICE}*${OUT_NUM}
    Should Be Equal    ${total}    ${OUTBOUND_MONEY}
    Set Global Variable    ${OUTBOUND_MONEY}
    ${UNOUTBOUND_MONEY}=    Evaluate    ${GOOD_PRICE}*(${BUY_NUMBER}-${OUT_NUM})    #退差金额
    Set Global Variable    ${UNOUTBOUND_MONEY}

Check Poor Refund Money Of Accounts Detail
    ${poorRefundMoney}=    Convert Number    //tbody//td[4]/strong
    ${money}=    Evaluate    ${GOODPRICE}*(${BUYNUMBER}-${OUTNUM})
    Should Be Equal    ${poorRefundMoney}    ${money}

Convert Money Of Supplier
    [Arguments]    ${moneyLocator}
    ${priceStr}=    Get Text    ${moneyLocator}
    @{goodprice}=    Get Regexp Matches    ${priceStr}    [+-](.*)    1
    ${money}=    Convert To Number    @{goodprice}
    [Return]    ${money}

Check Accounts Detail Of Supplier
    Go To    ${SALESURL}/finance/TradeCashFlow/Index
    #验证冲红金额
    Check Ordercode Of Accounts Detail    //td[contains(.,'订单号：${ORDERCODE}')]
    ${detailamount}=    Convert Money Of Supplier    //tbody/tr/td[5]/b
    Should Be Equal    ${detailamount}    ${REDMONEY}
    #验证供应商货款收入
    Check Ordercode Of Accounts Detail    //td[contains(.,'自主物流 | 货款 | 订单号：${ORDERCODE}')]
    ${detailamount}=    Convert Money Of Supplier    //tbody/tr[2]/td[4]/b
    Should Be Equal    ${detailamount}    ${OUTBOUND_MONEY}

Check Accounts Detail Of Buyer
    Switch Browser    ${BUYER_BROWSER}
    Go To Accounts Detail Of Buyer
    #验证采购商冲红金额
    Check Ordercode Of Accounts Detail    //td[contains(.,'订单号：${ORDERCODE}')]
    Check Money Of Accounts Detail    //tbody/tr/td[4]/strong    ${REDMONEY}
    #验证采购商账户余额
    Check Account Balances Of Accounts Detail    ${ACCOUNT_BALANCE}-${CART_MONEY}+${UNOUTBOUND_MONEY}+${REDMONEY}

Check Money Of Buyer Confirm Order Page
    [Arguments]    ${goodsAmount}
    ${TOTAL_PRICE}=    Convert Number    //strong[@name='totalAll']
    ${amount}=    Evaluate    ${goodsAmount}    #计算商品价格*购买数量
    Should Be Equal As Numbers    ${TOTAL_PRICE}    ${amount}
    Set Global Variable    ${TOTAL_PRICE}

Check Money Of Pay Page
    ${orderAmount}=    Convert Money Of Float    //div[@class="pay_information"]/table/tbody/tr[2]/td[2]/span
    Should Be Equal As Numbers    ${orderAmount}    ${TOTAL_PRICE}

Check Tejia Messages From Good Detail
    #检查特价文字提示
    #检查原价和特价是否正确
    #验证未超限购的价格总额是否正确
    #验证超限购的价格总额是否正确
    #验证超限购的提示

Check Tejia Messages From Cart
    #检查特价标签
    #检查原价和特价是否正确
    #验证未超限购的价格总额是否正确
    #验证超限购的价格总额是否正确
    #验证超限购的提示

Check Account Balance After Payed
    Go To    ${PUR_URL}
    Wait Until Element Is Visible    //div[@class="right-module"]/p[1]    ${WAIT_TIMEOUT}    获取账户余额失败
    ${text}=    Get Text    //div[@class="right-module"]/p[1]    #获取账户余额
    @{BALANCE_AFTER_PAYED}=    Get Regexp Matches    ${text}    账户余额：(.*)元    1
    ${BALANCE_AFTER_PAYED}    Convert To String    @{BALANCE_AFTER_PAYED}[0]
    Set Global Variable    ${BALANCE_AFTER_PAYED}
    ${difference}    Evaluate    ${ACCOUNT_BALANCE}-${BALANCE_AFTER_PAYED}
    ${totalPrice}    Evaluate    ${GOOD_PRICE}*${BUY_NUMBER}+${POSTAGE}-${DISCOUNT}
    Should Be Equal As Strings    ${totalPrice}    ${difference}    使用优惠券后的订单金额不正确

Get The Discount Money
    Comment    ${DISCOUNT}    Get Element Attribute    //span[@class="red j_discounts"]@data-discounts
    Comment    Set Suite Variable    ${DISCOUNT}
    ${priceStr}=    Get Text    //div[text()="优惠："]/parent::*/child::div[2]/span
    @{goodPrice}=    Get Regexp Matches    ${priceStr}    -￥(.*)    1
    ${DISCOUNT}    Convert To String    @{goodPrice}[0]
    Set Suite Variable    ${DISCOUNT}

Get The Postage
    ${priceStr}=    Get Text    //div[text()="邮费："]/parent::*/child::div[2]/span
    ${goodPrice}=    Get Regexp Matches    ${priceStr}    ￥(.*)    1
    ${POSTAGE}    Convert To String    ${goodPrice[0]}
    Set Suite Variable    ${POSTAGE}

Check Account Balance After Order Completed
    Switch Browser    ${BUYER_BROWSER}
    Go To    ${PUR_URL}
    Wait Until Element Is Visible    //div[@class="right-module"]/p[1]    ${WAIT_TIMEOUT}    显示账户余额
    ${balanceLast}=    Get Text    //div[@class="right-module"]/p[1]    #获取账户余额
    @{balanceLast}=    Get Regexp Matches    ${balanceLast}    账户余额：(.*)元    1
    ${balanceLast}=    Convert To String    @{balanceLast}[0]
    ${difference}    Evaluate    ${balanceLast}-${BALANCE_AFTER_PAYED}
    ${difference}    Evaluate    round(${difference},2)
    ${unoutMoney}    Evaluate    (${BUY_NUMBER}-${OUT_NUMBER})*${GOOD_PRICE}    #退差金额
    ${unreceiptMoney}    Evaluate    (${OUT_NUMBER}-${RECEIPT_NUMBER})*${GOOD_PRICE}    #冲红金额
    ${totalMoney}    Evaluate    ${unoutMoney}+${unreceiptMoney}    #退钱总额
    Should Be Equal As Strings    ${difference}    ${totalMoney}    #交易完成前和支付后的账户余额之差等于退差金额+冲红金额

Check Account Balance After Closed
    Switch Browser    ${BUYER_BROWSER}
    Go To    ${PUR_URL}
    Wait Until Element Is Visible    //div[@class="right-module"]/p[1]    ${WAIT_TIMEOUT}    未显示账户余额
    ${balanceAfterClosed}=    Get Text    //div[@class="right-module"]/p[1]    #获取账户余额
    @{balanceAfterClosed}=    Get Regexp Matches    ${balanceAfterClosed}    账户余额：(.*)元    1
    ${balanceAfterClosed}=    Convert To String    @{balanceAfterClosed}[0]
    ${difference}    Evaluate    ${balanceAfterClosed}-${BALANCE_AFTER_PAYED}
    ${totalPrice}    Evaluate    ${GOOD_PRICE}*${BUY_NUMBER}+${POSTAGE}-${DISCOUNT}
    Should Be Equal As Strings    ${totalPrice}    ${difference}

Convert Number
    [Arguments]    ${moneyLocator}
    ${priceStr}=    Get Text    ${moneyLocator}
    @{goodPrice}=    Get Regexp Matches    ${priceStr}    ¥(.*)    1
    ${money}=    Convert To String    @{goodPrice}[0]
    [Return]    ${money}

Convert Money Of Float
    [Arguments]    ${moneyLocator}
    ${balanceStr}=    Get Text    ${moneyLocator}
    @{balance}=    Get Regexp Matches    ${balanceStr}    ¥(.*)    1
    ${balanceNum}=    Replace String    @{balance}    ,    ${EMPTY}
    ${money}    Convert To Number    ${balanceNum}
    [Return]    ${money}
