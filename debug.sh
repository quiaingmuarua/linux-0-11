#!/bin/bash

# Linux 0.01 快速调试脚本
# 使用方法: ./debug.sh

echo "=================================="
echo "    Linux 0.01 快速调试脚本"
echo "=================================="

# 检查必要文件是否存在
if [ ! -f "tools/system" ]; then
    echo "错误: 找不到 tools/system，请先编译内核"
    echo "运行: make clean && make"
    exit 1
fi

if [ ! -f ".gdbinit" ]; then
    echo "错误: 找不到 .gdbinit 配置文件"
    exit 1
fi

echo "正在启动 QEMU 调试模式..."
echo "QEMU 将在后台运行，等待 GDB 连接"

# 后台启动 QEMU 调试模式
make debug &
QEMU_PID=$!

# 等待 QEMU 启动
echo "等待 QEMU 启动..."
sleep 2

echo "正在启动 GDB..."
echo "=================================="

# 启动 GDB（会自动使用 .gdbinit 配置）
gdb

# 清理：杀死 QEMU 进程
echo ""
echo "正在关闭 QEMU..."
kill $QEMU_PID 2>/dev/null

echo "调试会话结束"
