*** Settings ***
Library  String
Library  DateTime
Library  ubiz_service.py


*** Variables ***

${locator.auctionID}                                           css=.auction-auctionID
${locator.title}                                               css=.auction-title
${locator.status}                                              css=.auction-status
${locator.dgfID}                                               css=.auction-dgfId
${locator.procurementMethodType}                               css=.auction-procurementMethodType
${locator.description}                                         css=.auction-description
${locator.minimalStep.amount}                                  css=.auction-minimalStep-amount
${locator.procuringEntity.name}                                css=.auction-procuringEntity-name
${locator.value.amount}                                        css=.auction-value-amount
${locator.guarantee.amount}                                    css=.auction-guarantee-amount
${locator.value.currency}                                      css=.auction-value-currency
${locator.value.valueAddedTaxIncluded}                         css=.auction-value-tax
${locator.tenderPeriod.startDate}                              css=.tender-period-start
${locator.tenderPeriod.endDate}                                css=.tender-period-end
${locator.auctionPeriod.startDate}                             css=.auction-period-start
${locator.auctionPeriod.endDate}                               css=.auction-period-end
${locator.tenderAttempts}                                      css=.auction-tenderAttempts

${locator.qualificationPeriod.startDate}                        css=.award-period-start
${locator.qualificationPeriod.endDate}                          css=.award-period-end

${locator.enquiryPeriod.startDate}                             css=.enquiry-period-start
${locator.enquiryPeriod.endDate}                               css=.enquiry-period-end
${locator.cancellations[0].status}                             css=.cancellation-status
${locator.cancellations[0].reason}                             css=.cancellation-reason
${locator.awards[0].status}                                    css=.award-status-0
${locator.awards[1].status}                                    css=.award-status-1
${locator.minNumberOfQualifiedBids}                            css=.auction-minNumberOfQualifiedBids

*** Keywords ***

ϳ��������� ��� ��� ���������� �������
  [Arguments]  ${user_name}   ${auction_data}   ${role_name}
  ${auction_data}=   before_create_auction   ${auction_data}   ${role_name}
  [return]   ${auction_data}

ϳ��������� �볺�� ��� �����������
  [Arguments]   ${username}
  Set Global Variable    ${MODIFICATION_DATE}   ${EMPTY}
  ${alias}=              Catenate   SEPARATOR=   role_  ${username}
  Set Global Variable    ${BROWSER_ALIAS}   ${alias}
  Open Browser           ${BROKERS['${broker}'].homepage}  ${USERS.users['${username}'].browser}  alias=${BROWSER_ALIAS}
  Set Window Size        @{USERS.users['${username}'].size}
  Set Window Position    @{USERS.users['${username}'].position}
  Run Keyword If        '${username}' != 'ubiz_Viewer'  Login  ${username}

Login
  [Arguments]  ${username}
  Wait Until Page Contains Element    id=login-button
  Click Element                       id=login-button
  Wait Until Element Is Visible       id=login-form-login   30
  Input text                          xpath=//input[contains(@id, 'login-form-login')]   ${USERS.users['${username}'].login}
  Input text                          xpath=//input[contains(@id, 'login-form-password')]   ${USERS.users['${username}'].password}
  Click Element                       id=login-form-button
  Wait Until Page Contains Element    css=.logout   45

�������� ������
  [Arguments]   ${user_name}   ${auction_data}
  ${procurementMethodType}=        Get From Dictionary   ${auction_data.data}   procurementMethodType
  ${tenderAttempts}=               Get From Dictionary   ${auction_data.data}   tenderAttempts
  ${title}=                        Get From Dictionary   ${auction_data.data}   title
  ${description}=                  Get From Dictionary   ${auction_data.data}   description
  ${dgfID}=                        Get From Dictionary   ${auction_data.data}   dgfID
  ${valueAmount}=                  Get From Dictionary   ${auction_data.data.value}   amount
  ${valueAddedTaxIncluded}=        Get From Dictionary   ${auction_data.data.value}   valueAddedTaxIncluded
  ${minimalStepAmount}=            Get From Dictionary   ${auction_data.data.minimalStep}   amount
  ${guaranteeAmount}=              Get From Dictionary   ${auction_data.data.guarantee}   amount
  ${auctionPeriodStartDate}=       Get From Dictionary   ${auction_data.data.auctionPeriod}   startDate

  ${nameContactPoint}=             Get From Dictionary    ${auction_data.data.procuringEntity.contactPoint}   name
  ${emailContactPoint}=            Get From Dictionary    ${auction_data.data.procuringEntity.contactPoint}   email
  ${faxNumberContactPoint}=        Get From Dictionary    ${auction_data.data.procuringEntity.contactPoint}   faxNumber
  ${telephoneContactPoint}=        Get From Dictionary    ${auction_data.data.procuringEntity.contactPoint}   telephone
  ${urlContactPoint}=              Get From Dictionary    ${auction_data.data.procuringEntity.contactPoint}   url


  #Prepare
  ${procurementMethodType}=        cdb_format_to_view_format   ${procurementMethodType}
  ${tenderAttempts}=               Convert To String    ${tenderAttempts}
  ${tenderAttempts}=               cdb_format_to_view_format   ${tenderAttempts}
  ${valueAmount} =                 Convert To String   ${valueAmount}
  ${valueAddedTaxIncluded}         Convert To String   ${valueAddedTaxIncluded}
  ${valueAddedTaxIncluded}         Convert To Lowercase   ${valueAddedTaxIncluded}
  ${minimalStepAmount}=            Convert To String   ${minimalStepAmount}
  ${guaranteeAmount}=              Convert To String   ${guaranteeAmount}
  ${auctionPeriodStartDate}=       auction_period_to_broker_format   ${auctionPeriodStartDate}


  ${items}=                                Get From Dictionary   ${auction_data.data}   items
  ${number_of_items}=                      Get Length   ${items}
  ${isContainMinNumberOfQualifiedBids}=    Run Keyword And Return Status   Dictionary Should Contain Key  ${auction_data.data}  minNumberOfQualifiedBids
	${minNumberOfQualifiedBids}=                 Run Keyword If          ${isContainMinNumberOfQualifiedBids}
	...   Get From Dictionary                    ${auction_data.data}    minNumberOfQualifiedBids
	...   ELSE                                   Set Variable            2

	##====================== ������ / ������ ========================
	${is_lease}=          Set Variable    ${FALSE}
	:FOR  ${index}        IN RANGE        ${number_of_items}
	\  ${is_lease}=       Run Keyword And Return Status    Should Be Equal   ${items[${index}].additionalClassifications[0].id}   PA01-7
	\  Exit For Loop If   ${is_lease}
	\  ${is_lease}=       Run Keyword And Return Status    Should Be Equal   ${items[${index}].additionalClassifications[0].id}   PA02-0
	\  Exit For Loop If   ${is_lease}
	##====================== ������ / ������ ========================


  Wait Until Element Is Visible    id=add_auction
  Click Link                       id=add_auction
  Wait Until Page Contains         ��������� ��������
  ${subProcurementtype}=           cdb_format_to_view_format   sub_${is_lease}
  Run Keyword If   ${is_lease}     SelectBox   auction-subprocurementtype    ${subProcurementtype}
  Log To Console    ${subProcurementtype}
  Sleep    1
  ${minNumberOfQualifiedBids}=     cdb_format_to_view_format   bidder${minNumberOfQualifiedBids}
  Run Keyword If   ${is_lease}     SelectBox   auction-minnumberbids    ${minNumberOfQualifiedBids}

  SelectBox                        auction-tenderattempts   ${tenderAttempts}
  Input Text                       id=auction-title    ${title}
  Input Text                       id=auction-description    ${description}
  Input Text                       id=auction-dgfid    ${dgfID}
  Input Text                       id=Auction-value-amount   ${valueAmount}
  SwitchBox                        Auction-value-valueAddedTaxIncluded   ${valueAddedTaxIncluded}
  Input Text                       id=Auction-minimalStep-amount   ${minimalStepAmount}
  Input Text                       id=Auction-guarantee-amount   ${guaranteeAmount}
  Execute JavaScript               $('#auction-auctionperiod-startdate-disp').removeAttr('readonly');
  Input Text                       id=auction-auctionperiod-startdate-disp   ${auctionPeriodStartDate}
  Input Text                       id=contactPerson-name   ${nameContactPoint}
  Input Text                       id=contactPerson-telephone   ${telephoneContactPoint}
  Input Text                       id=contactPerson-faxNumber   ${faxNumberContactPoint}
  Input Text                       id=contactPerson-email   ${emailContactPoint}
  Input Text                       id=contactPerson-url   ${urlContactPoint}
  Scroll To Element                .box-footer
  Click Element                    xpath=//button[contains(text(), '���')]

   #Items part
  ������ ������                    ${items}
  Click Link                       id=endEdit
  Wait Until Page Contains         ��������
  ĳ� � ���������-���������        draft-publication
  Wait Until Keyword Succeeds   4 x   20 s   Run Keywords
  ...   Reload Page
  ...   AND   ���������� ���������
  Click Link                        css=.auction-draft-status
  Wait Until Element Is Visible     css=.auction-auctionID
  ${auctionID}=                     Get Text   css=.auction-auctionID
  [return]                          ${auctionID}

���������� ���������
  ${publicationStatus}=   Get Text   css=.auction-draft-status
  Should Be Equal   '${publicationStatus}'   '�����������'

������������
  [Arguments]   ${classificationId}    ${scheme}
  Click Link                          css=.classifications
  Wait Until Element Is Visible       id=classificationsearch-code
  ${scheme}=                          cdb_format_to_view_format   ${scheme}
  Select From List By Value           id=classificationsearch-scheme    ${scheme}
  Sleep    1
  Input Text                          id=classificationsearch-code   ${classificationId}
  Click Element                       id=classification-search-find
  Wait Until Page Contains Element    xpath=//tr[contains(@data-classification, '${classificationId}')]
  Sleep    1
  Click Element                       xpath=//tr[contains(@data-classification, '${classificationId}')]
  Wait Until Element Is Visible       id=save-and-hide-modal-btn
  Click Element                       id=save-and-hide-modal-btn
  Sleep    2

������ �����
  [Arguments]   ${item}
  ${description}=                 Get From Dictionary   ${item}   description
  ${quantity}=                    Get From Dictionary   ${item}   quantity
  ${unitName}=                    Get From Dictionary   ${item.unit}   name
  ${classificationId}=            Get From Dictionary   ${item.classification}   id
  ${classificationScheme}=        Get From Dictionary   ${item.classification}   scheme

  ${quantity}=                    Convert To String   ${quantity}

  ����� 䳿 �������� ������      ${item}

  Input Text                      id=item-description   ${description}
  Input Text                      id=item-quantity   ${quantity}
  SelectBox                       item-unitid   ${unitName}
  ������������                    ${classificationId}   ${classificationScheme}
  Scroll To Element               .box-footer
  Click Element                   xpath=//button[contains(text(), '��������')]
  Wait Until Element Is Visible   id=endEdit   30

��������� ����� ������
  [Arguments]   ${locator}   ${value}
  Execute JavaScript   $('#${locator}').removeAttr('readonly');
  ${value}=            contract_period   ${value}
  Input Text           id=${locator}   ${value}
  Sleep                1

����� 䳿 �������� ������
  [Arguments]   ${item}
  ${isExistStartDate}=   Run Keyword And Return Status   Dictionary Should Contain Key  ${item.contractPeriod}  startDate
  ${isExistEndDate}=     Run Keyword And Return Status   Dictionary Should Contain Key  ${item.contractPeriod}  endDate
  Run Keyword If    ${isExistStartDate}   ��������� ����� ������   item-contractperiod-startdate-disp    ${item.contractPeriod.startDate}
  Run Keyword If    ${isExistEndDate}     ��������� ����� ������   item-contractperiod-enddate-disp      ${item.contractPeriod.endDate}

�� ����� ��������� ������
  ${addItem}=   Run Keyword And Return Status   Page Should Contain Element   xpath=//a[contains(text(), '������ �����')]
  Run Keyword If   ${addItem}   Click Element   xpath=//a[contains(text(), '������ �����')]
  Wait Until Element Is Visible   id=item-description   15

������ ������
  [Arguments]   ${items}
  ${count}=   Get Length   ${items}
  : FOR    ${index}    IN RANGE   ${count}
  \   �� ����� ��������� ������
  \   ������ �����   ${items[${index}]}

������ � ������
  [Arguments]   ${auction_id}
  Input Text                           id=main-auctionsearch-title   ${auction_id}
  Click Element                        id=search-main
  Wait Until Page Contains Element     xpath=//span[contains(text() ,'ID �������� ${auction_id}')]   10
  Sleep                                 5

����� ������� �� ��������������
  [Arguments]   ${user_name}   ${auction_id}
  Switch Browser   ${BROWSER_ALIAS}
  Wait Until Page Contains Element    id=main-auctionsearch-title   45
  ${timeout_on_wait}=                 Get Broker Property By Username  ${user_name}  timeout_on_wait
  ${passed}=                          Run Keyword And Return Status   Wait Until Keyword Succeeds   6 x  ${timeout_on_wait} s  ������ � ������   ${auction_id}
  Run Keyword Unless   ${passed}      Fail   ������ �� �������� �� ${timeout_on_wait} ������
  ${url}=                             Get Element Attribute   xpath=//div[contains(@class, 'one_card')]//a[contains(@class, 'auction-view')]@href
  Execute JavaScript                  window.location.href = '${url}';
  Wait Until Page Contains Element    xpath=//a[@href='#parameters']   45

�� ������� �������
  Execute JavaScript     $(window).scrollTop(0);
  Sleep    1

����� ������� � ��� �������� ���
  [Arguments]   ${last_mod_date}   ${user_name}   ${auction_id}
  ${status}=   Run Keyword And Return Status   Should Not Be Equal   ${MODIFICATION_DATE}   ${last_mod_date}
  Run Keyword If   ${status}   ubiz.����� ������� �� ��������������   ${user_name}   ${auction_id}
  Set Global Variable   ${MODIFICATION_DATE}   ${last_mod_date}
  Run Keyword And Ignore Error   �� ������� �������
  Run Keyword And Ignore Error   Click Link   css=.auction-reload

����������� �������� � ������ � �����
  [Arguments]   ${user_name}   ${auction_id}   ${file_path}   ${document_type}=${EMPTY}
  ubiz.����� ������� �� ��������������   ${user_name}   ${auction_id}
  ������� � ����� ������
  ĳ� � ���������                    auction-documents
  Wait Until Page Contains Element   id=documents-box-auctionDocuments   30
  ���������� �����
  Sleep                              2
  Click Element                      xpath=//div[@id='documents-box-auctionDocuments']//button[contains(@class, 'add-item')]
  Sleep                              2
  ${addedBlock}=                     Execute JavaScript   return $('#documents-list-w0-auctionDocuments').find('.form-documents-item').last().attr('id');
  Choose File                        xpath=//div[@id='${addedBlock}']//input[@class='document-img']   ${file_path}
  Wait Until Page Contains           Done    30
  Run Keyword If                     '${document_type}' != '${EMPTY}'   Select From List By Value   xpath=//div[@id='${addedBlock}']//select  ${document_type}
  Click Element                      xpath=//button[contains(text(), '����������')]

�������� ������� �������� � ������
  [Arguments]  ${username}  ${tender_uaid}
  ubiz.����� ������� �� ��������������   ${username}   ${tender_uaid}
  ${number_of_items}=  Get Matching Xpath Count  //div[contains(@class,'item_description')]
  [return]  ${number_of_items}

����������� ��������
  [Arguments]  ${user_name}   ${file_path}   ${auction_id}
  ubiz.����������� �������� � ������ � �����   ${user_name}   ${auction_id}   ${file_path}


������ �������� � ������
  [Arguments]   ${username}   ${tender_uaid}    ${path}   ${docid}
  Fail    ϳ��� �������� ������ ��������� ����������  - ������ ���� ���������

������ ������ ����������
   [Arguments]   ${valueAmount}
   ${valueAmountToString}=   Convert To String   ${valueAmount}
   Input text                id=Bid-value-amount   ${valueAmountToString}

�� �������� ���������
  ${procurementMethodType}=       Get Text    css=.auction-procurementMethodType
  ${isOther}=                     Run Keyword And Return Status   Should Be Equal   '${procurementMethodType}'     '����� �����'
  Return From Keyword If          ${isOther}   ${FALSE}
  ${isFinancial}=                 Run Keyword And Return Status   Should Be Equal   '${procurementMethodType}'     '����� ������'
  Return From Keyword If          ${isFinancial}    ${isFinancial}
  ${subProcurementMethodType}=    Get Text    css=.auction-dutchProcurementMethodType
  ${dutchIsFinancial}=            Run Keyword And Return Status   Should Be Equal   '${subProcurementMethodType}'  '����� ������'
  [return]                        ${dutchIsFinancial}

��������� �������� ��� �� ����������
  ${file_path}  ${file_name}  ${file_content}=  create_fake_doc
  ����������� ���� ��������   ${file_path}

������ ������ ����������
  [Arguments]   ${user_name}   ${auction_id}   ${bid_data}
  ${qualified}=                   Get From Dictionary   ${bid_data.data}   qualified
  Run Keyword And Return If       ${qualified} == ${FALSE}   Fail   ������� �� �������������
  ubiz.����� ������� �� ��������������            ${user_name}   ${auction_id}
  ${isFinancialProcedure}         Run Keyword   �� �������� ���������
  Click Link                      css=.auction-bid-create
  Wait Until Page Contains        ������ ֲ���ί �������ֲ�
  Scroll To Element               .container
  ${isExistValueAmount}=          Run Keyword And Return Status   Dictionary Should Contain Key  ${bid_data.data}   value
  Run Keyword If                  ${isExistValueAmount}   ������ ������ ����������   ${bid_data.data.value.amount}
  Run Keyword If                  ${isFinancialProcedure}   ��������� �������� ��� �� ����������
  Execute JavaScript              $('input[id*=bid-condition]').trigger('click');
  Click Element                   xpath=//button[contains(text(), '��������')]
  Wait Until Element Is Visible   xpath=//p[contains(text(), '�����')]
  Run Keyword If                  ${isFinancialProcedure} == ${FALSE}   ĳ� � �����������   bid-publication

ĳ� � �����������
  [Arguments]   ${class}
  Execute JavaScript              $('.one_card').first().find('.fa-angle-down').click();
  Wait Until Element Is Visible   css=.${class}
  Click Link                      css=.${class}

����������� ��������� ������
  [Arguments]   ${user_name}   ${auction_id}   ${file_path}
  ubiz.����� ������� �� ��������������   ${user_name}   ${auction_id}
  ������� � ����� �����
  ĳ� � �����������                  bid-edit
  Wait Until Page Contains Element   css=.document-img
  Scroll To Element                  .tab-content
  Choose File                        css=.document-img   ${file_path}
  Wait Until Page Contains           Done
  Click Element                      xpath=//button[contains(text(), '��������')]
  Wait Until Element Is Visible      xpath=//p[contains(text(), '�����')]
  ĳ� � �����������                  bid-publication

����������� �������� � ������
  [Arguments]  ${user_name}  ${file_path}  ${auction_id}
  ubiz.����� ������� �� ��������������   ${user_name}   ${auction_id}
  ������� � ����� �����
  ĳ� � �����������   bid-edit
  Wait Until Page contains        ������ ֲ���ί �������ֲ�   45
  Click Element                   xpath=//button[contains(text(), '��������')]
  Wait Until Element Is Visible   xpath=//p[contains(text(), '�����')]


������� � ����� �����
  Click Element                   id=category-select
  Wait Until Element Is Visible   xpath=//a[contains(text(), '�����')]
  Click Link                      xpath=//a[contains(text(), '�����')]
  Wait Until Element Is Visible   xpath=//p[contains(text(), '�����')]

������� � ����� ������
  Click Element                   id=category-select
  Wait Until Element Is Visible   xpath=//a[contains(text(), '������')]
  Click Link                      xpath=//a[contains(text(), '������')]
  Wait Until Element Is Visible   xpath=//p[contains(text(), '������')]

ĳ� � ���������-���������
  [Arguments]   ${class}
  Execute JavaScript              $('.one_card').first().find('.fa-angle-down').click();
  Wait Until Element Is Visible   css=.${class}
  Click Link                      css=.${class}

ĳ� � ���������
  [Arguments]   ${class}
  Execute JavaScript              $('.one_card').first().find('.fa-angle-down').click();
  Wait Until Element Is Visible   css=.${class}
  Click Link                      css=.${class}

��������� ������ ����������
  [Arguments]   ${user_name}   ${auction_id}
  ubiz.����� ������� �� ��������������   ${user_name}   ${auction_id}
  ������� � ����� �����
  ĳ� � �����������        bid-cancellation

�������� ���������� �� ����������
  [Arguments]   ${user_name}   ${auction_id}   ${field}
  ubiz.����� ������� �� ��������������       ${user_name}   ${auction_id}
  ������� � ����� �����
  ${bidValueAmount}=         Get Text   css=.bid-value-amount
  ${bidValueAmount}=         Convert To Number   ${bidValueAmount}
  [return]                   ${bidValueAmount}

������� �������� ����
  Execute JavaScript   $('.close').trigger('click');
  Sleep    1

������ ������ ����������
  [Arguments]   ${user_name}   ${auction_id}   ${field}   ${value}
  ubiz.����� ������� �� ��������������            ${user_name}   ${auction_id}
  Click Element                   css=.bid-change-value-amount
  Wait Until Element Is Visible   id=BidChangeValueAmount-value-amount
  ${valueAmountToString}=         Convert To String   ${value}
  Input Text                      id=BidChangeValueAmount-value-amount   ${valueAmountToString}
  Sleep                           1
  Click Element                   xpath=//button[contains(text(), '������ ������ ����������')]
  Wait Until Page Contains        ���������� ������ ��������   30
  ������� �������� ����

������� ������� � ��������
  [Arguments]   ${user_name}   ${auction_id}
  Return From Keyword If   "�������� �������� � �����" in "${TEST_NAME}"   ${TRUE}
  Return From Keyword If   "����������� ����� �� ����" in "${TEST_NAME}"   ${TRUE}
  ubiz.����� ������� �� ��������������   ${user_name}   ${auction_id}


������ ��������� �� ������
  [Arguments]   ${user_name}   ${auction_id}   ${question_data}
  ${title}=                       Get From Dictionary  ${question_data.data}  title
  ${description}=                 Get From Dictionary  ${question_data.data}  description
  ubiz.����� ������� �� ��������������            ${user_name}   ${auction_id}
  Wait Until Element Is Visible   css=.auction-question-create
  Click Link                      css=.auction-question-create
  Wait Until Element Is Visible   id=question-title   30
  ${auctionTitle}=                Get Text    xpath=//a[contains(@class, 'text-justify')]
  SelectBox                       question-element   ${auctionTitle}
  Input text                      id=question-title   ${title}
  Input text                      id=question-description   ${description}
  Click Element                   xpath=//button[contains(text(), '��������')]
  Wait Until Page Contains        ��������� ��������   45

������ ��������� �� �������
  [Arguments]   ${user_name}   ${auction_id}   ${item_id}   ${question_data}
  ${title}=                       Get From Dictionary  ${question_data.data}  title
  ${description}=                 Get From Dictionary  ${question_data.data}  description
  ubiz.����� ������� �� ��������������            ${user_name}   ${auction_id}
  Wait Until Element Is Visible   css=.auction-question-create
  Click Link                      css=.auction-question-create
  Wait Until Element Is Visible   id=question-title   30
  Execute JavaScript              $("#question-element").val($("#question-element :contains('${item_id}')").last().attr("value")).change();
  Input text                      id=question-title   ${title}
  Input text                      id=question-description   ${description}
  Click Element                   xpath=//button[contains(text(), '��������')]
  Wait Until Page Contains        ��������� ��������   45

³������� �� ���������
  [Arguments]   ${user_name}   ${auction_id}  ${answer_data}   ${question_id}
  ubiz.����� ������� �� ��������������            ${user_name}   ${auction_id}
  ��� ���������
  ${answer}=                      Get From Dictionary  ${answer_data.data}   answer
  Wait Until Page Contains        ${question_id}
  Click Element                   xpath=//div[contains(@data-question-title, '${question_id}')]//a[contains(@class, 'question-answer')]
  Wait Until Element Is Visible   id=question-answer
  Input Text                      id=question-answer   ${answer}
  Click Element                   xpath=//button[contains(text(), '������ �������')]
  Wait Until Page Contains        ��������� ��������   45

�������� ���������� �� �������
  [Arguments]   ${user_name}   ${auction_id}   ${field}
  ubiz.����� ������� � ��� �������� ���   ${TENDER['LAST_MODIFICATION_DATE']}   ${user_name}   ${auction_id}
  Run Keyword And Return   �������� ���������� ��� ${field}

�������� ����� �� ���� � �������� �� �������
  [Arguments]   ${field}
  Wait Until Page Contains Element   ${locator.${field}}    30
  ${value}=                          Get Text   ${locator.${field}}
  [return]                           ${value}

�������� ���������� ��� status
  Reload Page
  ${status}=   �������� ����� �� ���� � �������� �� �������   status
  ${status}=   view_to_cdb_fromat   ${status}
  [return]     ${status}

�������� ���������� ��� dgfDecisionID
  ${dgfDecisionID}=   �������� ����� �� ���� � �������� �� �������   dgfDecisionID
  [return]            ${dgfDecisionID}

�������� ���������� ��� dgfDecisionDate
  ${dgfDecisionDate}=   �������� ����� �� ���� � �������� �� �������   dgfDecisionDate
  ${dgfDecisionDate}=   convert_date_to_dash_format   ${dgfDecisionDate}
  [return]              ${dgfDecisionDate}

�������� ���������� ��� eligibilityCriteria
  ${return_value}=   �������� ����� �� ���� � �������� �� �������   eligibilityCriteria
  [return]           ${return_value}

�������� ���������� ��� procurementMethodType
  ${procurementMethodType}=   �������� ����� �� ���� � �������� �� �������   procurementMethodType
  ${procurementMethodType}=   view_to_cdb_fromat   ${procurementMethodType}
  [return]                    ${procurementMethodType}

�������� ���������� ��� dgfID
  ${dgfID}=   �������� ����� �� ���� � �������� �� �������   dgfID
  [return]    ${dgfID}

�������� ���������� ��� title
  ${title}=   �������� ����� �� ���� � �������� �� �������   title
  [return]    ${title}

�������� ���������� ��� description
  ${description}=   �������� ����� �� ���� � �������� �� �������   description
  [return]          ${description}

�������� ���������� ��� minimalStep.amount
  ��� ��������� ��������
  ${return_value}=   �������� ����� �� ���� � �������� �� �������   minimalStep.amount
  ${return_value}=   Evaluate   "".join("${return_value}".replace(",",".").split(' '))
  ${return_value}=   Convert To Number   ${return_value}
  [return]           ${return_value}

�������� ���������� ��� ����� ������
  ${return_value}=   �������� ����� �� ���� � �������� �� �������   mybid
  ${return_value}=   Evaluate   "".join("${return_value}".replace(",",".").split(' '))
  ${return_value}=   Convert To Number   ${return_value}
  [return]           ${return_value}

�������� ���������� ��� value.amount
  ��� ��������� ��������
  ${return_value}=   �������� ����� �� ���� � �������� �� �������  value.amount
  ${return_value}=   Evaluate   "".join("${return_value}".replace(",",".").split(' '))
  ${return_value}=   Convert To Number   ${return_value}
  [return]           ${return_value}

�������� ���������� ��� guarantee.amount
  ��� ��������� ��������
  ${return_value}=   �������� ����� �� ���� � �������� �� �������  guarantee.amount
  ${return_value}=   Evaluate   "".join("${return_value}".replace(",",".").split(' '))
  ${return_value}=   Convert To Number   ${return_value}
  [return]           ${return_value}

�������� ���������� ��� auctionID
  ${auctionID}=   �������� ����� �� ���� � �������� �� �������   auctionID
  [return]        ${auctionID}

�������� ���������� ��� value.currency
  ��� ��������� ��������
  ${currency}=   �������� ����� �� ���� � �������� �� �������   value.currency
  ${currency}=   view_to_cdb_fromat   ${currency}
  [return]       ${currency}

�������� ���������� ��� value.valueAddedTaxIncluded
  ��� ��������� ��������
  ${tax}=    �������� ����� �� ���� � �������� �� �������   value.valueAddedTaxIncluded
  ${tax}=    view_to_cdb_fromat   ${tax}
  ${tax}=    Convert To Boolean   ${tax}
  [return]   ${tax}

�������� ���������� ��� procuringEntity.name
  ${procuringEntityName}=   �������� ����� �� ���� � �������� �� �������   procuringEntity.name
  [return]                  ${procuringEntityName}

�������� ���������� ��� tenderAttempts
  ��� ��������� ��������
  ${tenderAttempts}=   �������� ����� �� ���� � �������� �� �������   tenderAttempts
  ${tenderAttempts}=   view_to_cdb_fromat   ${tenderAttempts}
  [return]             ${tenderAttempts}

�������� ���������� ��� minNumberOfQualifiedBids
  ��� ��������� ��������
  ${minNumberOfQualifiedBids}=   �������� ����� �� ���� � �������� �� �������   minNumberOfQualifiedBids
  ${minNumberOfQualifiedBids}=   Convert To Integer    ${minNumberOfQualifiedBids}
  [return]                       ${minNumberOfQualifiedBids}

�������� ���������� ��� auctionPeriod.startDate
  ��� ��������� ��������
  ${startDate}=   �������� ����� �� ���� � �������� �� �������    auctionPeriod.startDate
  ${startDate}=   subtract_from_time   ${startDate}  0   0
  [return]        ${startDate}

�������� ���������� ��� auctionPeriod.endDate
  ��� ��������� ��������
  Wait Until Keyword Succeeds   15 x   40 s   Run Keywords
  ...   Reload Page
  ...   AND   ��� ��������� ��������
  ...   AND   Element Should Be Visible   css=.auction-period-end
  ${endDate}=   �������� ����� �� ���� � �������� �� �������   auctionPeriod.endDate
  ${endDate}=   subtract_from_time   ${endDate}   0   0
  [return]      ${endDate}

�������� ���������� ��� tenderPeriod.startDate
  ��� ��������� ��������
  ${startDate}=   �������� ����� �� ���� � �������� �� �������  tenderPeriod.startDate
  ${startDate}=   subtract_from_time    ${startDate}   0   0
  [return]        ${startDate}

�������� ���������� ��� tenderPeriod.endDate
  ��� ��������� ��������
  ${endDate}=   �������� ����� �� ���� � �������� �� �������  tenderPeriod.endDate
  ${endDate}=   subtract_from_time   ${endDate}  0  0
  [return]      ${endDate}

�������� ���������� ��� qualificationPeriod.startDate
  ��� ��������� ��������
  ${return_value}=   �������� ����� �� ���� � �������� �� �������  qualificationPeriod.startDate
  ${return_value}=   subtract_from_time   ${return_value}  0  0
  [return]           ${return_value}

�������� ���������� ��� qualificationPeriod.endDate
  ��� ��������� ��������
  ${return_value}=   �������� ����� �� ���� � �������� �� �������  qualificationPeriod.endDate
  ${return_value}=   subtract_from_time   ${return_value}  0  0
  [return]           ${return_value}

�������� ���������� ��� enquiryPeriod.startDate
  Fail  enquiryPeriod �������

�������� ���������� ��� enquiryPeriod.endDate
  Fail  enquiryPeriod �������

�������� ���������� �� ��������
  [Arguments]   ${user_name}   ${auction_id}   ${item_id}   ${field}
  ��� ������ ��������
  Wait Until Element Is Visible   xpath=//a[contains(text(), '${item_id}')]
  Click Link                      xpath=//a[contains(text(), '${item_id}')]
  Wait Until Element Is Visible   xpath=//div[contains(@data-item-description, '${item_id}')]
  ${fieldValue}=                  Get Text   xpath=//div[contains(@data-item-description, '${item_id}')]//*[contains(@class, 'item-${field.replace('.','-').replace('code','name')}')]
  ${fieldValue}=                  adapt_items_data   ${field}   ${fieldValue}
  [return]                        ${fieldValue}

�������� ��������� �� ������� ��� �������
  [Arguments]   ${user_name}   ${auction_id}   ${lot_id}=${Empty}
  Run Keyword And Return   �������� ��������� �� �������   ${user_name}   ${auction_id}   auction-url

�������� ��������� �� ������� ��� ��������
  [Arguments]   ${user_name}   ${auction_id}   ${lot_id}=${Empty}
  Run Keyword And Return   �������� ��������� �� �������   ${user_name}   ${auction_id}   bidder-url

�������� ��������� �� �������
  [Arguments]   ${user_name}   ${auction_id}   ${auctionOrBidderUrl}
  ubiz.����� ������� �� ��������������   ${user_name}   ${auction_id}
  Wait Until Keyword Succeeds   10 x   15 s   Run Keywords
  ...   Reload Page
  ...   AND   Element Should Be Visible   css=.${auctionOrBidderUrl}
  Run Keyword And Return    Get Element Attribute   css=.${auctionOrBidderUrl}@href

������ �� ����
  Scroll To Element    .nav-tabs-ubiz

����������� �������� ��������
  [Arguments]   ${user_name}   ${auction_id}   ${file_path}   ${award_index}
  ubiz.����� ������� �� ��������������   ${user_name}   ${auction_id}
  ������� � ����� �����
  Wait Until Keyword Succeeds   10 x   15 s   Run Keywords
  ...   Reload Page
  ...   AND   ĳ� � �����������    bid-award-protocol
  Wait Until Page Contains         ������������ ��������� ��������
  ����������� ���� ��������        ${file_path}
  Click Element                    xpath=//button[contains(text(), '�����������')]

����������� ����������
  [Arguments]   ${user_name}   ${auction_id}   ${file_path}
  ubiz.����������� �������� � ������ � �����   ${user_name}   ${auction_id}   ${file_path}   illustration

������ �������� ������� ������
  [Arguments]   ${user_name}   ${auction_id}  ${certificate_url}
  ubiz.����� ������� �� ��������������   ${user_name}   ${auction_id}
  ������� � ����� ������
  ĳ� � ���������                       auction-documents
  Wait Until Page Contains Element      id=documents-box-auctionDocuments   30
  ���������� �����
  Sleep                                 2
  Click Element                         xpath=//div[@id='documents-box-auctionDocuments']//button[contains(@class, 'add-item')]
  Sleep                                 2
  ${addedBlock}=                        Execute JavaScript   return $('#documents-list-w0-auctionDocuments').find('.form-documents-item').last().attr('id');
  Select From List By Value             xpath=//div[@id='${addedBlock}']//select   x_dgfPublicAssetCertificate
  Wait Until Page Contains Element      xpath=//div[@id='${addedBlock}']//textarea[contains(@name, 'textDocument')]    10
  Input text                            xpath=//div[@id='${addedBlock}']//textarea[contains(@name, 'textDocument')]   ${certificate_url}
  Click Element                         xpath=//button[contains(text(), '����������')]

������ ������ ��������
  [Arguments]  ${user_name}  ${auction_id}  ${accessDetails}
  ubiz.����� ������� �� ��������������   ${user_name}   ${auction_id}
  ������� � ����� ������
  ĳ� � ���������                       auction-documents
  Wait Until Page Contains Element      id=documents-box-auctionDocuments   30
  ���������� �����
  Sleep                                 2
  Click Element                         xpath=//div[@id='documents-box-auctionDocuments']//button[contains(@class, 'add-item')]
  Sleep                                 2
  ${addedBlock}=                        Execute JavaScript   return $('#documents-list-w0-auctionDocuments').find('.form-documents-item').last().attr('id');
  Select From List By Value             xpath=//div[@id='${addedBlock}']//select    x_dgfAssetFamiliarization
  Wait Until Page Contains Element      xpath=//div[@id='${addedBlock}']//textarea[contains(@name, 'textDocument')]    10
  Input text                            xpath=//div[@id='${addedBlock}']//textarea[contains(@name, 'textDocument')]   ${accessDetails}
  Click Element                         xpath=//button[contains(text(), '����������')]

�������� ���������� �� ���������
  [Arguments]   ${user_name}   ${auction_id}   ${question_id}   ${field}
  ubiz.����� ������� � ��� �������� ���   ${TENDER['LAST_MODIFICATION_DATE']}   ${user_name}   ${auction_id}
  Wait Until Keyword Succeeds   10 x   30 s   Run Keywords
  ...   Reload Page
  ...   AND   ��� ���������
  ...   AND   Page Should Contain   ${question_id}
  ${fieldValue}=    Get Text   xpath=//div[contains(@data-question-title, '${question_id}')]//*[contains(@class, 'question-${field}')]
  [return]          ${fieldValue}

�������� ���������� �� ��������� �� �������
  [Arguments]   ${user_name}   ${auction_id}   ${document_index}   ${field}
  ubiz.����� ������� � ��� �������� ���   ${TENDER['LAST_MODIFICATION_DATE']}   ${user_name}   ${auction_id}
  ��� ���������
  Wait Until Element Is Visible         id=auction-docs
  ${text}=                              Get Text   css=.document-documentType
  ${text}=                              view_to_cdb_fromat   ${text}
  [return]                              ${text}

�������� ���������� �� ���������
  [Arguments]   ${user_name}   ${auction_id}   ${document_id}   ${field}
  ubiz.����� ������� � ��� �������� ���   ${TENDER['LAST_MODIFICATION_DATE']}   ${user_name}   ${auction_id}
  ${currentStatus}=               Get Text   css=.auction-status
  ${wasCancelled}=                Run Keyword And Return Status   Should Be Equal   ${currentStatus}   ����������
  Run Keyword If   ${wasCancelled}   ��� ����������
  ...   ELSE    ��� ���������
  ${fieldValue}=                  Get Text   xpath=//div[contains(@data-document-title, '${document_id}')]//*[contains(@class, 'document-${field}')]
  [return]                        ${fieldValue}

�������� ��������
  [Arguments]   ${user_name}   ${auction_id}   ${document_id}
  ubiz.����� ������� � ��� �������� ���   ${TENDER['LAST_MODIFICATION_DATE']}   ${user_name}   ${auction_id}
  ��� ���������
  Wait Until Element Is Visible   id=auction-docs
  ${fileName}=                    Get Text   xpath=//div[contains(@data-document-title, '${document_id}')]//a
  ${fileUrl}=                     Get Element Attribute   xpath=//div[contains(@data-document-title, '${document_id}')]//a@href
  ${fileName}=                    download_file_from_url  ${fileUrl}  ${OUTPUT_DIR}${/}${fileName}
  [return]                        ${fileName}

���������� �����
  Execute JavaScript   $('.fa-plus').trigger('click');
  Sleep    2

����������� ���� ��������
  [Arguments]   ${file_path}
  ���������� �����
  Wait Until Page Contains Element   css=.add-item
  Click Element                      css=.add-item
  Wait Until Page Contains Element   css=.document-img
  Choose File                        css=.document-img   ${file_path}
  Wait Until Page Contains           Done

��������� ��������
  [Arguments]   ${user_name}   ${auction_id}   ${reason}   ${file_path}   ${description}
  ubiz.����� ������� �� ��������������               ${user_name}   ${auction_id}
  Click Link                         css=.auction-cancellation
  Wait Until Page Contains           ���������� ��������   45
  Scroll To Element                  .container
  SelectBox                          cancellation-reason   ${reason}
  ����������� ���� ��������          ${file_path}
  Click Element                      xpath=//button[contains(text(), '���������')]
  Wait Until Page Contains Element   xpath=//a[@href='#cancellations']   45

�������� ���������� ��� awards[0].status
  ��� �����������
  ${return_value}=   �������� ����� �� ���� � �������� �� �������   awards[0].status
  ${return_value}=   view_to_cdb_fromat  ${return_value}
  [return]           ${return_value}

�������� ���������� ��� awards[1].status
  ��� �����������
  ${return_value}=   �������� ����� �� ���� � �������� �� �������   awards[1].status
  ${return_value}=   view_to_cdb_fromat  ${return_value}
  [return]           ${return_value}

�������� ���������� ��� cancellations[0].status
  ��� ����������
  ${return_value}=   �������� ����� �� ���� � �������� �� �������   cancellations[0].status
  ${return_value}=   view_to_cdb_fromat  ${return_value}
  [return]           ${return_value}

�������� ���������� ��� cancellations[0].reason
  ��� ����������
  ${return_value}=   �������� ����� �� ���� � �������� �� �������   cancellations[0].reason
  [return]           ${return_value}

�������� ������� ��������� � ������
  [Arguments]   ${user_name}   ${auction_id}
  ubiz.����� ������� �� ��������������   ${user_name}   ${auction_id}
  ��� ���������
  ${countDocuments}=     Get Matching Xpath Count   xpath=//p[contains(@class,'document-datePublished')]
  [return]               ${countDocuments}

�������� ������� ��������� � ������
  [Arguments]  ${username}  ${tender_uaid}  ${bid_index}
  ubiz.����� ������� �� ��������������   ${username}   ${tender_uaid}
  ����� � ����� �����������
  ${drop_id}=  Catenate   SEPARATOR=   ${UBIZ_LOT_ID}   _pending
  ${action_id}=   Catenate   SEPARATOR=   ${UBIZ_LOT_ID}   _confirm_protocol
  Wait Until Keyword Succeeds   10 x   20 s   Run Keywords
  ...   Reload Page
  ...   AND   �������� �� ����������� ������  ${drop_id}
  ...   AND   Element Should Be Visible   id=${action_id}
  �������� ��   ${action_id}
  Wait Until Page Contains   ������� �� ����   10
  Wait Until Keyword Succeeds   10 x   15 s   Run Keywords
  ...   Reload Page
  ...   AND   Wait Until Page Contains   ϳ�������� ��������
  ${bid_doc_number}=   Get Matching Xpath Count   xpath=//a[contains(@class, 'document_title')]
  Log To Console    ${bid_doc_number}
  [return]  ${bid_doc_number}

�������� ��� �� ��������� ����������
  [Arguments]  ${username}   ${tender_uaid}   ${bid_index}   ${document_index}   ${field}
  ${fileid_index}=   Catenate   SEPARATOR=   ${field}   ${document_index}
  ${doc_value}=      Get Text   xpath=//span[contains(@class, '${fileid_index}')]
  ${doc_value}=      view_to_cdb_fromat   ${doc_value}
  [return]           ${doc_value}

��������������
  [Arguments]   ${user_name}   ${auction_id}
  ubiz.����� ������� �� ��������������   ${user_name}   ${auction_id}
  Wait Until Keyword Succeeds   10 x   30 s   Run Keywords
  ...   Reload Page
  ...   AND   ��� �����������
  Wait Until Page Contains Element     css=.award-disqualification
  Click Link                           css=.award-disqualification
  Wait Until Page Contains Element     id=disqualification-title   15

����������� �������� ������ ������������� ����
  [ARGUMENTS]   ${user_name}   ${file_path}  ${auction_id}  ${award_index}
  ��������������   ${user_name}   ${auction_id}
  ${withDocuments}=                    Run Keyword And Return Status    Page Should Contain Element   id=documents-box
  Run Keyword If   ${withDocuments}    ����������� ���� ��������   ${file_path}

��������������� �������������
  [Arguments]   ${user_name}   ${auction_id}  ${award_index}  ${description}
  ${isForm}=   Run Keyword And Return Status   Page Should Contain Element   id=disqualification-title
  Run Keyword If   ${isForm} == ${FALSE}   ��������������   ${user_name}   ${auction_id}
  Input Text                               id=disqualification-title   �������������� ��������
  Input Text                               id=disqualification-description   ${description}
  Click Element                            xpath=//button[contains(text(), '���������������')]
  Wait Until Page Contains Element         xpath=//a[@href='#parameters']   45

����������� ����� �� �������
  [Arguments]   ${user_name}   ${auction_id}   ${contract_index}   ${file_path}
  ubiz.����� ������� �� ��������������   ${user_name}   ${auction_id}
  Wait Until Keyword Succeeds   10 x   30 s   Run Keywords
  ...   Reload Page
  ...   AND   ��� ��������
  Wait Until Page Contains Element     css=.contract-publication
  Click Link                           css=.contract-publication
  Wait Until Page Contains             ��������� ��������   45
  ����������� ���� ��������            ${file_path}
  Scroll To Element                    .action_period

ϳ��������� ��������� ���������
  [Arguments]   ${user_name}   ${auction_id}   ${contract_index}
  Wait Until Page Contains Element   xpath=//button[contains(text(), '�����������')]
  Click Element                      xpath=//button[contains(text(), '�����������')]
  Wait Until Page Contains Element   xpath=//a[@href='#parameters']   45

����������� �������� �������� � �����
  [Arguments]   ${user_name}   ${auction_id}   ${file_path}   ${award_index}
  ubiz.����� ������� �� ��������������   ${user_name}   ${auction_id}
  Wait Until Keyword Succeeds   10 x   30 s   Run Keywords
  ...   Reload Page
  ...   AND   ��� �����������
  Wait Until Page Contains Element    css=.award-upload-protocol
  Click Link                          css=.award-upload-protocol
  Wait Until Page Contains            ������������ ��������� ��������   30
  ����������� ���� ��������           ${file_path}
  Scroll To Element                   .action_period

ϳ��������� �������� ��������� ��������
  [Arguments]   ${user_name}   ${auction_id}   ${award_index}
  Wait Until Page Contains Element   xpath=//button[contains(text(), '�����������')]
  Click Element                      xpath=//button[contains(text(), '�����������')]
  Wait Until Page Contains Element   xpath=//a[@href='#parameters']   45

ϳ��������� �������������
  [Arguments]   ${user_name}   ${auction_id}   ${award_index}
  ubiz.����� ������� �� ��������������   ${user_name}   ${auction_id}
  ��� �����������
  Wait Until Page Contains Element    css=.award-activation
  Click Link                          css=.award-activation
  Wait Until Page Contains Element    xpath=//a[@href='#parameters']   45

���������� ������ ������������� ����
  [Arguments]   ${user_name}   ${auction_id}   ${award_num}
  ubiz.����� ������� �� ��������������   ${user_name}   ${auction_id}
  ������� � ����� �����
  Wait Until Keyword Succeeds   10 x   15 s   Run Keywords
  ...   Reload Page
  ...   AND   ĳ� � �����������    bid-award-cancellation

��� ��������� ��������
  ������ �� ����
  Click Link            xpath=//a[@href='#parameters']

��� ������ ��������
  ������ �� ����
  Click Link            xpath=//a[@href='#items']

��� ���������
  ������ �� ����
  Click Link            xpath=//a[@href='#documents']

��� ���������
  ������ �� ����
  Click Link            xpath=//a[@href='#questions']

��� ����������
  ������ �� ����
  Click Link            xpath=//a[@href='#bids']

��� �����������
  ������ �� ����
  ���������� �����
  Click Link            xpath=//a[@href='#awards']

��� ��������
  ������ �� ����
  Click Link            xpath=//a[@href='#contracts']

��� ����������
  ������ �� ����
  ���������� �����
  Click Link            xpath=//a[@href='#cancellations']

SelectBox
  [Arguments]   ${select_id}   ${text}
  Execute JavaScript   $("#${select_id}").val($("#${select_id} :contains('${text}')").first().attr("value")).change();

SwitchBox
  [Arguments]   ${checkbox_id}   ${bool}
  Execute JavaScript   $("#${checkbox_id}").bootstrapSwitch('state', ${bool}, true).trigger('switchChange.bootstrapSwitch');

Scroll To Element
  [Arguments]   ${selector}
  Execute JavaScript   var targetOffset = $('${selector}').offset().top; $('html, body').animate({scrollTop: targetOffset}, 1000);
  Sleep    2

������ ������� ��������
  [Arguments]   ${locator}   ${value}
  ${value}=     Convert To String   ${value}
  Input Text    id=Edit-${locator}   ${value}

������ ���� � ������
  [Arguments]  ${user_name}  ${auction_id}  ${field}  ${value}
  ubiz.����� ������� �� ��������������    ${user_name}  ${auction_id}
  ������� � ����� ������
  ĳ� � ���������                    auction-edit
  Wait Until Page Contains Element   id=Edit-value-amount   15
  ������ ������� ��������    ${field.replace('.', '-')}    ${value}
  Click Element               xpath=//button[contains(text(), '�������')]
  Wait Until Page Contains    ������