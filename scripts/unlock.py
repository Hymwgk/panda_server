# DaVinci Kitchen GmbH Python 3.6.8 Script by Ibrahim Elfaramawy
#!/usr/bin/python3
import platform
import os
import sys
import ssl
import json
import hashlib
import base64
import time
from time import gmtime, strftime, sleep
from http.client import HTTPSConnection
splash = (r"""
  ______  ______  __    __       _______     _____    __
 /___  / /___  / |  |  |  |     |   __  \   /  _  \  |  |
    / /     / /  |  |  |  |     |  |__)  | /  /_\  \ |  |
   / /     / /   |  |  |  |     |   _   / |   ___   ||  |
  / /___  / /___ |  |__|  |     |  | \  \ |  |   |  ||  |
 /______|/______| \______/      |__|  \__\|__|   |__||__|
----------------------------------------------------------""")



def encode_password(user, password):  #
    bs = ','.join([str(b) for b in hashlib.sha256((password + '#' + user + '@franka').encode('utf-8')).digest()])
    return base64.encodebytes(bs.encode('utf-8')).decode('utf-8')

class FrankaAPI:  #
    def __init__(self, hostname, user, password):     #构造函数，进行类变量初始化，输入主机名，账户名，密码
        self._hostname = hostname    #主机名
        self._user = user       #web网页账户
        self._password = password      #密码

    def __enter__(self):          
        self._client = HTTPSConnection(self._hostname, context=ssl._create_unverified_context())
        self._client.connect()     #链接
        self._client.request('POST', '/admin/api/login',
                             body=json.dumps(
                                 {'login': self._user, 'password': encode_password(self._user, self._password)}),
                             headers={'content-type': 'application/json'})
        self._token = self._client.getresponse().read().decode('utf8')
        #print(self._token)
        return self

    def __exit__(self, type, value, traceback):
        self._client.close()

    def start_task(self, task):
        self._client.request('POST', '/desk/api/execution',
                             body='id=%s' % task,
                             headers={'content-type': 'application/x-www-form-urlencoded',
                                      'Cookie': 'authorization=%s' % self._token})
        return self._client.getresponse().read()

    def open_brakes(self):  #打开机械臂锁
        self._client.request('POST', '/desk/api/robot/open-brakes',
                             headers={'content-type': 'application/x-www-form-urlencoded',
                                      'Cookie': 'authorization=%s' % self._token})
        return self._client.getresponse().read()

    def close_brakes(self):  #关闭机械臂锁
        self._client.request('POST', '/desk/api/robot/close-brakes',
                             headers={'content-type': 'application/x-www-form-urlencoded',
                                      'Cookie': 'authorization=%s' % self._token})
        return self._client.getresponse().read()       

def log(message):
    return print(strftime("%H:%M:%S")+"  "+message)

#启动的时候，不断ping FCI控制器
def ping_host(ip):
    #iplist = list()
    #ip = '192.168.1.11'
    count = 0;
    while 1:
        backinfo = os.system('ping -c 1 -w 1 %s'%ip) # 实现pingIP地址的功能，-c1指发送报文一次，-w1指等待1秒
        if backinfo:
            print('Waiting Panda to Start')
            count=1
        elif count==1:
            print('System initializing')
            sleep(50)  #ping通之后，并不是马上才能通讯，大约需要一分钟左右
            break
        else:
            break

ping_host('192.168.10.1')

with FrankaAPI('192.168.10.1', 'admin', '123456789') as api:
    print(splash)
    log("Opening Brakes")
    try:
        api.open_brakes()
    except:
        log("ERROR Opening Brakes")
    log("Brakes Opened")

 

