# Linux 0.01 GDB调试指南

本文档详细介绍如何使用GDB调试Linux 0.01内核。

## 环境要求

- GDB (GNU Debugger)
- QEMU x86模拟器
- Linux开发环境

## 快速开始

### 1. 编译内核
```bash
make clean
make
```

### 2. 启动调试模式
```bash
# 启动QEMU调试模式（暂停等待GDB连接）
make debug

# 或者使用curses界面（无GUI环境）
make debug-curses
```

### 3. 连接GDB

#### 方式一：使用自动配置（推荐）
项目根目录已配置了`.gdbinit`文件，只需：
```bash
gdb
```

GDB会自动：
- 加载符号文件 `tools/system`
- 连接到 `localhost:1234`
- 设置最优的调试参数
- 显示欢迎信息和常用命令

#### 方式二：手动配置
在新的终端窗口中：
```bash
gdb tools/system
```

在GDB中连接到QEMU：
```bash
(gdb) target remote localhost:1234
(gdb) break main
(gdb) continue
```

## 详细调试步骤

### 启动调试会话

1. **编译带调试符号的内核**
   ```bash
   make clean && make
   ```
   内核会使用`-g`标志编译，包含调试信息。

2. **启动QEMU调试模式**
   ```bash
   make debug
   ```
   
   这会启动QEMU并：
   - `-s`: 在TCP端口1234启用GDB服务器
   - `-S`: CPU启动时暂停，等待GDB连接

3. **启动GDB并连接**
   ```bash
   gdb tools/system
   (gdb) target remote localhost:1234
   ```

### 常用GDB命令

#### 断点管理
```bash
# 在函数设置断点
(gdb) break main
(gdb) break start_kernel
(gdb) break sched_init

# 在地址设置断点
(gdb) break *0x00000000
(gdb) break *0x00001000

# 查看断点
(gdb) info breakpoints

# 删除断点
(gdb) delete 1
(gdb) clear main
```

#### 代码执行控制
```bash
# 继续执行
(gdb) continue
(gdb) c

# 单步执行（源码级别）
(gdb) step
(gdb) s

# 单步执行（不进入函数）
(gdb) next
(gdb) n

# 汇编级单步执行
(gdb) stepi
(gdb) si

# 执行到函数返回
(gdb) finish
```

#### 查看代码和状态
```bash
# 显示当前源码
(gdb) list
(gdb) l

# 显示汇编代码
(gdb) disassemble
(gdb) disas main

# 查看当前位置附近的汇编指令
(gdb) x/10i $eip
```

#### 寄存器和内存
```bash
# 查看所有寄存器
(gdb) info registers
(gdb) info reg

# 查看特定寄存器
(gdb) print $eax
(gdb) p $esp
(gdb) p $eip

# 查看内存内容（十六进制）
(gdb) x/10x 0x00000000
(gdb) x/10x $esp

# 查看内存内容（汇编指令）
(gdb) x/10i 0x00000000

# 查看内存内容（字符串）
(gdb) x/s 0x00000000
```

#### 调用栈
```bash
# 显示调用栈
(gdb) backtrace
(gdb) bt

# 切换栈帧
(gdb) frame 0
(gdb) f 1

# 查看栈帧信息
(gdb) info frame
```

#### 变量和符号
```bash
# 打印变量值
(gdb) print variable_name
(gdb) p *pointer_variable

# 查看变量类型
(gdb) whatis variable_name

# 查看符号信息
(gdb) info symbol 0x00001000
(gdb) info address main
```

### 调试场景示例

#### 1. 调试内核启动过程

```bash
# 连接GDB
(gdb) target remote localhost:1234

# 在启动入口设置断点
(gdb) break *0x00000000

# 或在head.s的startup_32设置断点
(gdb) break startup_32

# 继续执行
(gdb) continue

# 单步跟踪启动过程
(gdb) stepi
```

#### 2. 调试main函数

```bash
(gdb) target remote localhost:1234
(gdb) break main
(gdb) continue

# 查看main函数代码
(gdb) list main

# 单步执行
(gdb) step
```

#### 3. 调试系统调用

```bash
# 在系统调用入口设置断点
(gdb) break system_call
(gdb) break sys_fork

# 查看系统调用参数
(gdb) print $eax  # 系统调用号
(gdb) print $ebx  # 第一个参数
```

#### 4. 调试内存管理

```bash
# 调试内存分配
(gdb) break get_free_page
(gdb) break free_page

# 查看页表
(gdb) x/1024x 0x00000000  # 查看页目录
```

#### 5. 调试进程调度

```bash
# 调试调度器
(gdb) break schedule
(gdb) break switch_to

# 查看当前进程
(gdb) print current
```

### 实用技巧

#### 1. 使用符号表
查看System.map文件了解符号地址：
```bash
cat System.map | grep main
cat System.map | head -20
```

#### 2. 设置显示选项
```bash
# 显示汇编代码
(gdb) set disassembly-flavor intel

# 自动显示寄存器
(gdb) display/i $eip
(gdb) display $esp
```

#### 3. 保存和加载断点
```bash
# 保存断点到文件
(gdb) save breakpoints breakpoints.gdb

# 从文件加载断点
(gdb) source breakpoints.gdb
```

#### 4. 调试实模式代码
由于Linux 0.01从实模式启动，早期调试可能需要：
```bash
# 设置架构为16位
(gdb) set architecture i8086

# 切换回32位保护模式
(gdb) set architecture i386
```

### 故障排除

#### 1. 连接失败
如果GDB无法连接到QEMU：
- 确保QEMU使用了`-s -S`参数
- 检查端口1234是否被占用
- 尝试重启QEMU和GDB

#### 2. 符号信息缺失
如果看不到源码：
- 确保使用`-g`标志编译
- 检查tools/system文件是否包含调试信息：
  ```bash
  file tools/system
  objdump -h tools/system | grep debug
  ```

#### 3. 断点无法设置
- 确保符号名称正确
- 使用`info functions`查看可用函数
- 尝试使用地址设置断点

### 自定义调试命令（.gdbinit提供）

项目的`.gdbinit`文件提供了多个便捷的调试命令：

#### 快速断点设置
```bash
(gdb) bp_main        # 在main函数设置断点
(gdb) bp_syscall     # 在系统调用入口设置断点
(gdb) bp_schedule    # 在调度器设置断点  
(gdb) bp_fork        # 在fork系统调用设置断点
```

#### 系统状态查看
```bash
(gdb) show_current   # 显示当前进程信息
(gdb) show_memory    # 显示内存布局
(gdb) show_idt       # 显示中断向量表
(gdb) show_pgdir     # 显示页目录
(gdb) status         # 显示CPU状态和调用栈
```

#### 增强的执行命令
```bash
(gdb) stepr          # 单步执行并显示寄存器
```

### 进阶调试

#### 1. 自定义.gdbinit
如需修改调试配置，编辑项目根目录的`.gdbinit`文件：
- 取消注释自动断点设置
- 添加自定义的display设置
- 定义新的调试命令

#### 2. 远程调试脚本
创建GDB脚本文件`debug.gdb`：
```bash
target remote localhost:1234
break main
continue
```

使用脚本：
```bash
gdb tools/system -x debug.gdb
```

#### 2. 条件断点
```bash
# 只在特定条件下停止
(gdb) break main if argc > 1
(gdb) break schedule if current->pid == 1
```

#### 3. 监视点
```bash
# 监视内存变化
(gdb) watch variable_name
(gdb) watch *0x00001000
```

## 常见调试目标

- **启动过程**: boot/boot.s, boot/head.s
- **内核初始化**: init/main.c
- **内存管理**: mm/memory.c
- **进程管理**: kernel/sched.c, kernel/fork.c
- **文件系统**: fs/
- **系统调用**: kernel/sys.c, kernel/system_call.s

## 参考资料

- [GDB官方文档](https://www.gnu.org/software/gdb/documentation/)
- [QEMU文档](https://www.qemu.org/docs/master/)
- Linux 0.01源码注释
