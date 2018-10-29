# -*- coding: utf-8 -*-
import socket
import threading
import socketserver
import struct
import json
import time

lock = threading.Lock()
clients = []
customs = []

#客户信息类，保存有客户的socket连接、客户惟一标识，
#用于将处理终端返回的数据发送给正确的用户
class ClientInfo(object):
    #构造函数，request为该客户的socket信息
    def __init__(self, request, ip, port):
        super(ClientInfo, self).__init__()
        self.request = request
        self.ip = ip
        self.port = port
        self.client_info = {}
        self.user_name = None
        self.password = None
        self.app = None
        self.is_phone = False
        #用户将使用的设备列表
        self.pair_client = None
        #手机当前状态
        self.is_ready = False

    #验证身份信息
    def verify_identify(self, info):
        self.client_info = info
        self.user_name = info["userName"]
        if "password" in info.keys():
            self.password = info["password"]
        if "type" in info.keys():
            self.is_phone = info["type"]
        if "app" in info.keys():
            self.app = info["app"]
        if (self.user_name is not None) and (self.password is not None):
            return True
        elif self.is_phone:
            return True
        else:
            return False

    #分配配对客户
    def assign_pair_client(self, client):
        if self.pair_client is None:
            self.pair_client = client


    def is_same_client(self, identy):
        if self.user_name == identy:
            return True
        else:
            return False

    def is_custom(self):
        if self.is_phone:
            return False
        else:
            return True

    def get_socket(self):
        return self.request






class PhoneSocketServer(socketserver.ThreadingMixIn, socketserver.TCPServer):
    pass


class PhoneSocketRequestHandler(socketserver.BaseRequestHandler):

    def setup(self):
        self.hasVerify = False
        #缓冲区
        self.buffer = bytearray()
        ip = self.client_address[0]
        port = self.client_address[1]
        self.client = ClientInfo(self.request, ip, port)
        print("IP:{0} Port:{1}的客户端请求加入".format(ip, port))

    def handle(self):
        while  True:
            try:
                data = self.request.recv(1024)
                if not data:
                    print("客户端失去连接")
                    break
                print("服务器接收数据", data)
                info, cinfo = self.handle_data(data)
                print("服务器接收到的数据是", info, cinfo)
                if self.hasVerify == False:
                    if cinfo is not None:
                        verify = self.client.verify_identify(cinfo)
                        with lock:
                            if self.client.is_custom():
                                customs.append(self.client)
                            else:
                                clients.append(self.client)

                        self.hasVerify = verify
                        if verify:
                            self.sendOpenAppCommand()
                    else:
                        self.responseMessage("请先验证身份！")
                        break
                
                    print("7")
                for item in info:
                    print("8")
                    self.handout(item)
            except Exception as e:
                print("接收数据超时", e)

            time.sleep(1)


    def finish(self):
        print("客户端失去连接", self.client, clients, customs)
        with lock:
            if self.client in clients:
                clients.remove(self.client)
            else:
                customs.remove(self.client)
        
    def sendOpenAppCommand(self):
        print("sendOpenAppCommand")
        app = self.client.app
        if len(app) == 0:
            return
        message = {}
        message["name"] = "OpenApp"
        l = [{"bundleId" : self.client.app}]
        message["params"] = l
        msg = json.dumps(message)
        print("msg = ", msg)
        length = len(msg)
        d = struct.pack("!2iI", 1, 2, length)
        data = bytearray(d)
        data.extend(msg.encode('utf-8'))
        self.request.sendall(data)
        print("发送打开app命令成功")


    def handle_data(self, data):
        self.buffer.extend(data)
        identy = None
        info = []
        length = len(self.buffer)
        start = 0
        if length > 12:
            while True:
                print("开始解析数据")
                head = self.buffer[start : start + 12]
                print(head)
                version, ptype, pLen = struct.unpack("!2iI", head)
                print("解析数据成功", version, ptype, pLen)
                left = length - start
                if pLen == 0:
                    start = start + 12
                elif pLen <= left:
                    s = start + 12
                    e = s + pLen
                    item = bytes(self.buffer[s : e])
                    print("数据为", item)
                    if ptype == 4 :
                        identy = json.loads(item.decode("utf-8"))
                    elif ptype == 3:
                        responseInfo = json.loads(item.decode("utf-8"))
                        self.handleCommandResponse(responseInfo)
                    else:
                        info.append(item)
                    start = start + 12 + pLen
                else:
                    break

                if length - start <= 12:
                    break
            newbuffer = self.buffer[start:]
            self.buffer = newbuffer

        return info, identy

    def is_custom_socket(self):
        result = False
        for item in customs:
            if item.request == self.request:
                result = True
                break
        return result

    def responseMessage(self, message):
        msg = json.dumps(message)
        length = len(msg)
        d = struct.pack("!2iI", 1, 3, length)
        data = bytearray(d)
        data.extend(msg.encode('utf-8'))
        self.request.sendall(data)
        print("返回信息：", message)

    def handleCommandResponse(self, info):
        commandName = info["name"]
        result = info["params"]["result"]
        print(commandName, "命令返回值为", result)
        if commandName == "OpenApp":
            self.client.is_ready = result

    def handout(self, info):
        if self.client.is_custom():
            print("转发手机计算")
            identy = self.client.user_name
            self.send_task_phone(info, identy)
        else:
            print("转发客户", info)
            self.send_result_custom(info, identy)

    #给处理终端下发数据处理任务
    def send_task_phone(self, info, identy):
        value = json.loads(info)
        value["identy"] = identy
        message = json.dumps(value)
        length = len(message)
        d = struct.pack("!2iI", 1, 1, length)
        data = bytearray(d)
        data.extend(message.encode('utf-8'))
        
        print("向手机发送数据", data)

        if len(clients) > 0:
            client = clients[0]
            client.sendall(data)
        else:
            print("没有可用于计算的设备，请稍等")

    #返回计算结果给客户
    def send_result_custom(self, info):
        value = json.loads(info)
        identy = value.pop("identy")
        message = json.dumps(value)
        print("拼装返回包", message, identy)
        length = len(message)
        d = struct.pack("!2iI", 1, 1, length)
        data = bytearray(d)
        data.extend(message.encode('utf-8'))
        print("发送返回包")
        for custom in customs:
            if custom.is_same_client(identy):
                print("成功查询到目标客户", data)
                custom.get_socket().sendall(data)
                print("成功发送返回包")
                break

    


if __name__ == "__main__":

    # host = "172.18.18.244"
    host = ''
    server = PhoneSocketServer((host, 12345), PhoneSocketRequestHandler)
    server_thread = threading.Thread(target=server.serve_forever)
    server_thread.daemon = True
    server_thread.start()
    server_thread.join()

    pass












        