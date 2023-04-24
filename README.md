# Redis客户端处理工具

每次批量删缓存都要现写一个脚本，让ChatGPT4写了一个（并不是一次就能成功的，让其修修改改好几遍）。

### 批量查找工具
通过SCAN命令遍历Redis集群查找所有符合前缀的key写入文件。

命令：`./redis_key_finder.sh [集群任意节点的地址和端口] [密码] [key前缀] [写入文件名] [SCAN单次数量]` 

```
wget -O redis_key_finder.sh https://raw.githubusercontent.com/qy8502/redis-cli-tools/main/redis_key_finder.sh && chmod +x redis_key_finder.sh
./redis_key_finder.sh "192.168.100.37:6379" "password" "cache:user:" "found_keys.txt" 1000000
```

### 批量删除工具
批量并行删除指定文件的所有key。

命令：`./redis_key_deleter.sh [集群任意节点的地址和端口] [密码] [读取文件名] [单次读取数量]`

```
wget -O redis_key_deleter.sh https://raw.githubusercontent.com/qy8502/redis-cli-tools/main/redis_key_deleter.sh && chmod +x redis_key_deleter.sh
./redis_key_deleter.sh "192.168.100.37:6379" "password" "found_keys.txt" 1000

```
