#!/bin/bash

# 参数处理
if [ "$#" -lt 3 ]; then
  echo "Usage: $0 cluster_addresses password key_file [count]"
  exit 1
fi

cluster_addresses=$1
password=$2
key_file=$3
count=${4:-1000}

# 将集群地址分割成数组
IFS=',' read -ra ADDR_ARRAY <<< "$cluster_addresses"

# 初始化总键数和删除键数
total_keys=$(wc -l < "$key_file")
deleted_keys=0

# 获取键的Redis实例地址
addr=${ADDR_ARRAY[RANDOM % ${#ADDR_ARRAY[@]}]}
host=${addr%:*}
port=${addr#*:}

# 批量删除键
while read -ra key_batch; do

    printf "%s\n" "${key_batch[@]}" | xargs -P "$(nproc)" -I {} redis-cli -c -h "$host" -p "$port" -a "$password" --no-auth-warning DEL "{}"  > /dev/null
    deleted_keys=$((deleted_keys + ${#key_batch[@]}))


  # 更新进度条
  percentage=$(echo "$deleted_keys $total_keys" | awk '$2 > 0 {printf "%.2f", $1 / $2 * 100}')
  tput cuu 1; tput el # 将光标向上移动一行并清除该行
  printf "Progress: [%-50s] %s%% %s / %s" "$(seq -s= -1 $(echo "$percentage / 2" | awk '{printf "%.0f", $1 / 2}') | tr -d '[:digit:]')" "$percentage" "$deleted_keys" "$total_keys"



done < <(xargs -a "$key_file" -n "$count")

# 输出结果
printf "\nDeleted %d keys from the cluster.\n" "$deleted_keys"