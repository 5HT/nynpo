Counter Telegram Bot
====================

Simply count number of users in particular channel or group and record it to files in CSV format.

Options
-------

```erlang
  {nynpo, [{bot,"548231922:AAHmXMMr38XGtH0tJMDUdiByheT2mZ7qkVI"},
           {timer,{0,0,5}},
           {rooms,["CanYaCommunity","HaskellRu","RuHaskell"]}]},
```

Bot is your API key, timer is granularity of tracking, rooms is a list of room you want to track.

Run
---

```sh
$ brew install erlang
$ ./nynpo repl
```

```sh
$ cat HaskellRu
2018/2/27, 10:52:40, "HaskellRu", -1001043143583, 670
2018/2/27, 10:52:47, "HaskellRu", -1001043143583, 670
2018/2/27, 10:52:52, "HaskellRu", -1001043143583, 670
2018/2/27, 10:52:57, "HaskellRu", -1001043143583, 670
```

Credits
-------
* Maxim Sokhatsky


