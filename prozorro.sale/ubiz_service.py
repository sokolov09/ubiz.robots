# -*- coding: utf-8 -
from iso8601 import parse_date
from robot.libraries.BuiltIn import BuiltIn
from datetime import datetime, timedelta
from pytz import timezone
import os
import urllib
import pytz


def get_library():
    return BuiltIn().get_library_instance('Selenium2Library')

def convert_date_to_dash_format(date):
    return datetime.strptime(date,'%d.%m.%Y').strftime('%Y-%m-%d')

def contract_period(date):
    parseDateTime = parse_date(date)
    toFormat = parseDateTime.strftime("%d-%m-%Y")
    return toFormat

def get_webdriver_instance():
    return get_library()._current_browser()

def auction_period_to_broker_format(isodate):
    parseDateTime = parse_date(isodate)
    toFormat = parseDateTime.strftime("%d-%m-%Y %H:%M")
    return toFormat

def adapt_items_data(field_name, value):
    if field_name == 'quantity':
        value = float(value)
    elif field_name == "unit.code":
        value = view_to_cdb_fromat(value)
    elif field_name == "contractPeriod.startDate":
        value = toISO(value)
    elif field_name == "contractPeriod.endDate":
        value = toISO(value)
    return value

def toISO(v_date):
    time_zone = pytz.timezone('Europe/Kiev')
    d_date = datetime.strptime(v_date, '%d.%m.%Y')
    localized_date = time_zone.localize(d_date)
    return localized_date.isoformat()

def cdb_format_to_view_format(string):
    return {
        u"dgfFinancialAssets": u"����� ������",
        u"dgfOtherAssets": u"����� �����",
        u"0": u"�������",
        u"1": u'������',
        u"2": u'������',
        u"3": u'�����',
        u"4": u'���������',
        u"CPV": u"��021",
        u"bidder1": u"����",
        u"bidder2": u"���",
        u"sub_False": u"�������",
        u"sub_True":  u"������"
    }.get(string, string)

def view_to_cdb_fromat(string):
    return {
            u"���": u"PR" ,
            u"���" : u"LTR",
            u"����" : u"SET",
            u"�����" : u"RM",
            u"��������" :u"PK",
            u"�����" : u"NMP",
            u"�����" : u"MTR",
            u"����" : u"BX",
            u"����� �����" : u"MTQ",
            u"����" : u"E54",
            u"����" : u"TNE",
            u"����� ��������" : u"MTK",
            u"��������" : u"KMT",
            u"�����" : u"H87",
            u"�����" : u"MON",
            u"���" : u"LO",
            u"����" : u"D64",
            u"������" : u"HAR",
            u"��������" : u"KGM",
            u"��������": u"�������",
            u"��.": u"��������",
            u"��": u"��������",
            u"MTK":u"����� ��������",
            u"����� ������": u"dgfFinancialAssets",
            u"����� �����": u"dgfOtherAssets",
            u"������������ �������": u"dgfInsider",
            u"���.": u"UAH",
            u"���": u"UAH",
            u" � ���": True,
            u"�������":"E48",
            u"��������": u"������� �������",
            u"��в�� �������ֲ�": u"active.tendering",
            u"��в�� ���ֲ���": u"active.auction",
            u"�������ֲ� ����������": u"active.awarded",
            u"��в�� ���˲Բ��ֲ�": u"active.qualification",
            u"����������": u"complete",
            u"����������": u"cancelled",
            u"������� ���������" : u"active",
            u"�� ²������" : u"unsuccessful",
            u"˳�����" : u"financialLicense",
            u"ϳ�������� ��������" : u"auctionProtocol",
            u" - " : u"",
            u"�������": u"",
            u'������':1,
            u'������':2,
            u'�����':3,
            u'���������':4,
            u"����������� ��� �������" : "notice",
            u"��������� ��������" : u"biddingDocuments",
            u"�������� ������� ������" : u"technicalSpecifications",
            u"������ ������" : u"evaluationCriteria",
            u"������ �����������" : u"eligibilityCriteria",
            u"�������� ������� �����" : u"virtualDataRoom",
            u"����������" : u"illustration",
            u"��������� �� �������� ������� ������" : u"x_dgfPublicAssetCertificate",
            u"�����������" : u"x_presentation",
            u"������ ��� ��������������(NDA)" : u"x_nda",
            u"������� �����" : u"tenderNotice",
            u"�������� ���������� ����������" : u"x_dgfPlatformLegalDetails",
            u'������� ������������ � ������� � ����� �����' : u'x_dgfAssetFamiliarization',
            u"������� ������������ � ������" : u'x_dgfAssetFamiliarization',
            u"��������� ����� �����������" : u"pending.waiting",
            u"��������� ��������" : u"pending.verification",
            u"��������� ������" : u"pending.payment",
            u"�������� ������ ���������� ������" : u"cancelled",
            u"������� ���������" : u"unsuccessful",
            u"��������, ��������� ��������� ��������" : u"active",
            u"���������� ����������": u'active'
    }.get(string, string)

def subtract_from_time(date_time, subtr_min, subtr_sec):
    sub = datetime.strptime(date_time, "%d.%m.%Y %H:%M")
    sub = (sub - timedelta(minutes=int(subtr_min),
                           seconds=int(subtr_sec)))
    return timezone('Europe/Kiev').localize(sub).strftime('%Y-%m-%dT%H:%M:%S.%f%z')
def adapt_procuringEntity(auction_data):
    auction_data.data.procuringEntity['name'] = u"��� \"����� ����\""
    auction_data.data.procuringEntity['contactPoint']['telephone'] = u"0993698510"
    auction_data.data.procuringEntity['contactPoint']['faxNumber'] = u"0993698511"
    return auction_data

def before_create_auction(auction_data, role_name):
    if role_name == 'tender_owner':
        auction_data = adapt_procuringEntity(auction_data)
    return auction_data

def join(l, separator):
    return separator.join(l)