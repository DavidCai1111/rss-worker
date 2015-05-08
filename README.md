# rss-worker
[![Build Status](https://travis-ci.org/DavidCai1993/rss-worker.svg?branch=master)](https://travis-ci.org/DavidCai1993/rss-worker)
[![Coverage Status](https://coveralls.io/repos/DavidCai1993/rss-worker/badge.svg)](https://coveralls.io/r/DavidCai1993/rss-worker)

## 简介
rss-worker是一个持久的可配的rss爬虫。支持多URL的并行爬取，并且会将所有条目按时间顺序进行保存，保存格式为`"时间\n标题\n内容\n\n"`，支持的保存方式有fs与mongodb。

## 使用

### 安装
直接通过npm：
```SHELL
npm install rss-worker --save
```
源码：
```SHELL
git clone git@github.com:DavidCai1993/rss-worker.git
cd rss-worker && npm i && gulp #编译coffee的输出目录为./build
```

### 例子
```js
var RssWorker = require('rss-worker');

var opt = {
  urls: ['https://cnodejs.org/rss', 'https://github.com/DavidCai1993.atom', 'http://segmentfault.com/feeds'],
  store: {
    type: 'fs',
    dist: './store/rss.txt'
  },
  timeout: 10
};

var rssWorker = new RssWorker(opt);
rssWorker.start();
```

一个抓取`https://github.com/alsotang.atom`，`https://cnodejs.org/rss`，`http://segmentfault.com/feeds/blogs`内容24小时的输出（2015/5/6 19:30至2015/5/7 19:30 ，地址是随手挑的...←_←）：[这里][1]

### API

#### new RssWorker(options)
生成一个RssWorker的实例

__options:__

* `urls(Array)` - 必选，需要抓取的rss地址的数组 
* `store(Object)` - 存储方式，需要配置`type`与`dist`两属性
  * `type` - 存储方式，可选`fs`（默认）或`mongodb`
  * `dist` - 存储结果的文件地址（将会自动创建），如：`./store/rss.txt`（fs），`mongodb://localhost:27017/rss_worker`（mongodb）
* `timeout(Number)` - 每次抓取的间隔（秒），默认为60秒

#### start()
开始抓取

#### forceToEnd()
发出停止抓取信号，将不会继续抓取，但不会影响到正在进行的本次抓取。

  [1]: https://raw.githubusercontent.com/DavidCai1993/rss-worker/master/example/output.txt
