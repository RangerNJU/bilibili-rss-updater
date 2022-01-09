# bilibili-rss-updater

A set of simple scripts to download bilibili updates according to uploaders' uid

一组简单的脚本，用来通过up主的uid定时下载up主更新的视频。

## 使用方法

使用crontab在服务器或长期运行的平台上定期运行，如果你选择一周运行一次，那么不需要对脚本进行修改。否则，应当修改generateLinkAndDownLoad.sh中的执行date命令时-d后传的参数。（目前为14天和7天，如你希望每天更新，可改为2天和1天）。

## 配置方法（aka魔改指南）

在clone该仓库后，将自己所关注的b站up主的uid和对应的下载子文件夹名称写到uids文件中即可。uid为访问up主主页时URL中的数字部分。

### 主要运行原理

1. 通过RSSHUB提供的RSS链接获得up主更新内容的文本描述

2. 用comm和上一次运行程序时的文本描述对比，提取出变化的部分，并用grep提取相应的av号，拼接成下载链接的列表描述文件

3. 用you-get下载列表描述文件，并检查返回值，在失败时无限次重复尝试

### 已知的bug

一旦运行起来，要停止非常麻烦，因为实际上启动了好多个相互依赖的进程，要停止时需要**按顺序**通过`ps -aux | grep`之类的手段来找到并`kill`掉关键字有vidRSS.sh、generateLinkAndDownLoad.sh和you-get三个进程。暂时还没有想到什么好方法（~~又不是不能用~~)
