#!/bin/bash

# 参数处理
if [ "$#" -lt 3 ]; then
  echo "Usage: $0 cluster_address password prefix [output_file] [count]"
  exit 1
fi

cluster_address=$1
password=$2
prefix=$3
output_file=${4:-found_keys.txt}
count=${5:-10}

# 获取集群地址
host=${cluster_address%:*}
port=${cluster_address#*:}

# 获取集群节点列表
node_addresses=$(redis-cli -c -h "$host" -p "$port" -a "$password"  --no-auth-warning CLUSTER NODES | awk '{if ($3 ~ /master/) print $2}')

# 清空文件
echo -n "" > "$output_file"

found_keys=0

echo "Nodes:"
echo "$node_addresses"

# 遍历集群并记录要删除的键
for addr in $node_addresses; do
  host=${addr%:*}
  port=${addr#*:}
  cursor=0

  while true; do
    # 执行 SCAN 命令
    result=$(redis-cli -c -h "$host" -p "$port" -a "$password" --no-auth-warning SCAN "$cursor" MATCH "${prefix}*" COUNT "$count" )
    keys=$(echo "$result" | tail -n +2) # 提取键列表
    cursor=$(echo "$result" | head -n 1) # 提取新的游标

    # 记录键到文件
    for key in $keys; do
      echo "$key" >> "$output_file"
      found_keys=$((found_keys + 1))
    done

    # 显示已获取的键数量
    printf "\rKeys found: %d" "$found_keys"

    # 判断是否完成
    if [[ "$cursor" == "0" ]]; then
      break
    fi
  done
done

echo -e "\nFound keys with prefix '$prefix' have been saved to '$output_file'."