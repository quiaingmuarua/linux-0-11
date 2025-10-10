# CLion远程调试配置指南

本文档详细说明如何在CLion中调试Linux 0.01内核。

## 前提条件

1. 确保内核已编译：
   ```bash
   make clean && make
   ```

2. 启动QEMU调试模式：
   ```bash
   make debug
   ```

## CLion调试配置步骤

### 1. 创建Remote Debug配置

1. 打开 **Run/Debug Configurations**
2. 点击 **+** 添加新配置
3. 选择 **Remote Debug**

### 2. 配置参数

#### 基本设置
- **Name**: `LINUX001` （或任意你喜欢的名称）
- **Debugger**: `WSL GDB from 'WSL' toolchain`

#### 连接设置
- **'target remote' args**: `:1234`

#### 符号和路径设置
- **Symbol file**: `tools/system`
- **Sysroot**: `/Ubuntu/root/linux-0.01` （或留空）

#### 路径映射（重要）
点击Path mappings下的 **+** 添加：
- **Remote**: `/root/linux-0.01`
- **Local**: `/Ubuntu/root/linux-0.01`

### 3. 调试流程

#### 启动调试
1. 在终端运行：`make debug`
2. 在CLion中点击Debug按钮（绿色虫子图标）
3. CLion会连接到QEMU

#### 设置断点
```c
// 在这些关键函数设置断点：
main()           // 主函数入口
start_kernel()   // 内核启动（如果存在）
system_call()    // 系统调用入口  
schedule()       // 进程调度器
sys_fork()       // fork系统调用
```

#### 调试命令
- **Continue**: F9 或点击绿色箭头
- **Step Over**: F8
- **Step Into**: F7  
- **Step Out**: Shift+F8

### 4. 常见问题和解决方案

#### 问题1：连接失败
**症状**: "Connection refused" 或类似错误

**解决**:
1. 确保QEMU正在运行：`make debug`
2. 检查端口1234是否被占用：`netstat -an | grep 1234`
3. 重启QEMU和CLion调试器

#### 问题2：找不到符号
**症状**: 看不到源码，只显示汇编

**解决**:
1. 确认Symbol file设置为：`tools/system`
2. 确认文件路径正确
3. 检查tools/system是否包含调试符号：
   ```bash
   file tools/system
   objdump -h tools/system | grep debug
   ```

#### 问题3：路径不匹配
**症状**: 调试器无法找到源文件

**解决**:
1. 正确设置Path mappings
2. 使用绝对路径
3. 确保Remote和Local路径对应正确

#### 问题4：调试会话快速结束
**症状**: 连接后很快断开

**解决**:
1. 在main函数设置断点后再启动
2. 检查QEMU是否正常运行
3. 确保没有其他GDB实例连接到相同端口

### 5. 调试技巧

#### 设置初始断点
在开始调试前，建议先在main函数设置断点：
1. 打开 `init/main.c`
2. 在main函数第一行设置断点
3. 启动调试

#### 查看变量和内存
- **Variables窗口**: 查看局部变量和参数
- **Memory窗口**: 查看内存内容
- **Registers窗口**: 查看CPU寄存器状态

#### 调试多线程/进程
Linux 0.01是单线程的，但可以：
- 查看进程切换过程
- 观察系统调用执行
- 跟踪中断处理

#### 汇编级调试
- 在Disassembly窗口查看汇编代码
- 使用Step Into Instruction进行汇编级单步
- 查看寄存器状态变化

### 6. 高级配置

#### 自动设置断点
可以在配置的"Before launch"部分添加自动执行的GDB命令。

#### 自定义GDB命令
在CLion的GDB控制台中，可以使用项目提供的自定义命令：
```bash
# 我们之前在.gdbinit中定义的命令在CLion中也可用
show_current
show_memory  
status
```

#### 条件断点
右键断点可以设置条件，例如：
- `current->pid == 1`
- `argc > 0`

### 7. 调试会话示例

#### 调试内核启动过程
```bash
# 1. 启动QEMU
make debug

# 2. 在CLion中启动调试
# 3. 在main函数设置断点
# 4. Continue执行
# 5. 单步跟踪初始化过程
```

#### 调试系统调用
```bash
# 1. 在system_call设置断点
# 2. Continue让系统启动
# 3. 当系统调用触发时会停在断点
# 4. 查看EAX寄存器（系统调用号）
# 5. 查看参数寄存器
```

### 8. 性能优化

#### 减少符号加载时间
如果符号加载很慢，可以：
1. 只加载必要的符号
2. 使用较小的二进制文件进行测试

#### 网络延迟优化
如果使用远程WSL：
1. 确保网络连接稳定
2. 考虑在本地运行QEMU

## 故障排除检查清单

- [ ] 内核已成功编译（存在Image和tools/system）
- [ ] QEMU在后台运行（make debug）
- [ ] Symbol file路径正确（tools/system）
- [ ] Path mappings配置正确
- [ ] 没有其他GDB实例占用端口1234
- [ ] 在合适的位置设置了断点
- [ ] WSL GDB工具链配置正确

## 替代方案

如果CLion调试有问题，可以使用：
1. 命令行GDB（使用项目的.gdbinit）
2. 一键调试脚本：`./debug.sh`
3. GDB + TUI界面：`gdb -tui`

---

现在你应该可以在CLion中顺利调试Linux 0.01了！🚀
