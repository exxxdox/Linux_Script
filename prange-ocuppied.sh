#!/bin/bash
# 用法: ./prange-ocuppied.sh <起始端口> <结束端口> [ipv4|ipv6|all]
# 功能: 显示 [a,b] 区间内的端口占用情况，按端口号升序排序
# 默认 all = IPv4 + IPv6
#
# @参数说明
#   起始端口           必填   端口区间起点（数字，通常 1-65535）
#   结束端口           必填   端口区间终点（数字，应 >= 起始端口）
#   ipv4|ipv6|all     可选   地址族过滤，省略时为 all（IPv4 + IPv6）
#

if [ $# -lt 2 ] || [ $# -gt 3 ]; then
    echo "用法: $0 <起始端口> <结束端口> [ipv4|ipv6|all]"
    exit 1
fi

start=$1
end=$2
mode=${3:-all}  # 默认为 all

# 构造 ss 参数
case "$mode" in
    ipv4) proto="-4" ;;
    ipv6) proto="-6" ;;
    all) proto="" ;;
    *) echo "参数错误: 请选择 ipv4、ipv6 或 all"; exit 1 ;;
esac

# 打印表头
# ss $proto -ltnp "sport >= $start and sport <= $end" \
#     | column -t \
#     | head -n1

# 处理数据行：提取端口 -> 排序 -> 恢复原格式
    # | tail -n +2 \
ss $proto -ltnp "sport >= $start and sport <= $end" \
    | awk 'NR==1{$0="0 " $0; print; next} {split($4,a,":"); port=a[length(a)]; print port, $0}' \
    | sort -n \
    | cut -d' ' -f2- \
    | column -t
