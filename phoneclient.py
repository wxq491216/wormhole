# -*- coding: utf-8 -*-
import socket
import struct
import json
import time


def handle_data(data):
    global buf
    buf.extend(data)
    info = []
    error = None
    length = len(buf)
    start = 0
    if length > 12:
        while True:
            print("开始解析数据")
            head = buf[start : start + 12]
            version, ptype, pLen = struct.unpack("!2iI", head)
            print("解析数据成功", version, ptype, pLen)
            left = length - start
            if pLen == 0:
                start = start + 12
            elif pLen <= left:
                s = start + 12
                e = s + pLen
                item = bytes(buf[s : e])
                print("数据为", item)
                if ptype == 3 :
                    print(item)
                    error = item
                else:
                    info.append(item)
                start = start + 12 + pLen
            else:
                print("末接收完全部数据")
                break

            if length - start <= 12:
                break
        newbuffer = buf[start:]
        buf = newbuffer

    return info, error


def sendTask():
    info = {"name" : "videoUrl", "app" : "com.qiyi.iphone", "params" : [{"albumId" : "231017401", "videoId" : "1404912500"}, {"albumId" : "1374859900", "videoId" : "1374859900"}] }
    msg = json.dumps(info)
    length = len(msg)
    d = struct.pack("!2iI", 1, 1, length)
    data = bytearray(d)
    data.extend(msg.encode('utf-8'))

    s.sendall(data)
    print("发送业务请求包", data)


s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
#s.connect(('10.1.6.105', 12345))
# s.connect(('192.168.1.8', 12345))
# s.connect(('10.1.2.192', 12345))
s.connect(('120.78.227.106', 22345))

already_send_identy = False
index = 0
buf = bytearray()

# while True:
info = {}

if already_send_identy == False:
    info["userName"] = "customer-demo"
    info["password"] = "e10adc3949ba59abbe56e057f20f883e"
    msg = json.dumps(info)
    length = len(msg)
    d = struct.pack("!2iI", 1, 4, length)
    data = bytearray(d)
    data.extend(msg.encode('utf-8'))
    print("发送身份包", data)

    s.sendall(data)


while True:
    data = s.recv(2048)
    info, error = handle_data(data)
    if error is not None:
        item = json.loads(error.decode("utf-8"))
        t = item['name']
        if t == 'identyVerify':
            code = item['params']['code']
            already_send_identy = True
            sendTask()
    if len(info) != 0:
        for index in range(0, len(info)):
            message = json.loads(info[index].decode("utf-8"))
            print(message)


s.close()




