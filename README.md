# wormhole
## ios平台的简版群控系统

系统的总体设计框架参见本人[简书文章](https://www.jianshu.com/p/787ff057561b)，这里开源了所有与此框架相关的代码。服务器端的控制代码虽然核心但并非关键，且不受我控制，无法开源。这里只给出用python写的一个测试服务器代码。

- LSWormhole是框架的中的Daemon服务器，使用MonkeyDev作为开发框架，其暂时不支持Daemon的自动化打包，所以要开机自启动的话，Daemon安装包需要手动制作并安装，具体打包方法参见[这里](https://github.com/haxii/ios-daemon)。

- iQiYiPlugin是框架里的业务插件，实现从服务器下发业务指令到爱奇艺视频并得到其计算后的结果，具体业务内容自己研究，这里就不在细说了。

- phoneclient.py、phoneserver.py是简单模拟用户、服务器操作的脚本，用于协调测试
