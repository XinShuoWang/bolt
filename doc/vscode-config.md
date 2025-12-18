# Vscode必备插件

- 本地：
	- Remote SSH
		
	![](vscode-fig/0.png)
	
- 远程SSH：
	- C/C++：GDB的可视化，支持C++的可视化调试
		
	- Clangd：代码提示、代码补全和代码跳转
		
	- CMake：cmake语法高亮
		
	- GitLens：能够看到代码库中每一行代码的提交历史（包括提交时间和提交人）
		
	- C++ TestMate：能够展示工程中所有的单元测试，一键运行或调试
		
	- Clang-Format：代码保存时自动格式化
		

![](vscode-fig/1.png)
![](vscode-fig/2.png)

# Remote SSH连接

- 本地配置好vscode remote SSH环境，就能够通过mac正常看到devbox中的项目。
	

# Clangd的配置

- Remote端下载clangd插件。
	
- 在.vscode下面创建settings.json，将如下内容复制到settings.json中，需要经路径替换成你自己的build目录下的debug目录，一般为`/``home/{your_home}/``bolt/_build/Release/`(写绝对路径)。注意：通过该路径需要能够找到build目录中的compile\_commands.json文件，因为构建索引需要依赖compile\_commands.json文件。
	
- *ctrl+shift+p* 打开命令窗口，输入 *Clangd* 然后在命令列表里面找到 `clangd: Download language server` , 点击安装语言服务器； 安装完成后会提示重新加载。
	
- 重启后，可以试试效果了。在实际使用的时候，有可能出现即使重新编译了，但是代码提示和跳转依旧存在问题，那么可以尝试重启 *clangd*。具体做法是 *ctrl+shift+p* ，输入 Clangd 然后找到 `clangd: Restart language server`，点击后会重新执行索引。
	
- 下面的配置信息需要写入`/home/{your_home}/bolt/.vscode/settings.json`配置文件中（注意修改黄底的路径信息）：
	

```JSON
{
    "files.associations": {
        "array": "cpp",
        "string_view": "cpp",
        "cctype": "cpp",
        "clocale": "cpp",
        "cmath": "cpp",
        "cstdarg": "cpp",
        "cstddef": "cpp",
        "cstdio": "cpp",
        "cstdlib": "cpp",
        "cstring": "cpp",
        "ctime": "cpp",
        "cwchar": "cpp",
        "cwctype": "cpp",
        "atomic": "cpp",
        "strstream": "cpp",
        "bit": "cpp",
        "*.tcc": "cpp",
        "bitset": "cpp",
        "chrono": "cpp",
        "codecvt": "cpp",
        "compare": "cpp",
        "complex": "cpp",
        "concepts": "cpp",
        "condition_variable": "cpp",
        "cstdint": "cpp",
        "deque": "cpp",
        "list": "cpp",
        "map": "cpp",
        "set": "cpp",
        "unordered_map": "cpp",
        "unordered_set": "cpp",
        "vector": "cpp",
        "exception": "cpp",
        "algorithm": "cpp",
        "functional": "cpp",
        "iterator": "cpp",
        "memory": "cpp",
        "memory_resource": "cpp",
        "numeric": "cpp",
        "optional": "cpp",
        "random": "cpp",
        "ratio": "cpp",
        "regex": "cpp",
        "string": "cpp",
        "system_error": "cpp",
        "tuple": "cpp",
        "type_traits": "cpp",
        "utility": "cpp",
        "fstream": "cpp",
        "future": "cpp",
        "initializer_list": "cpp",
        "iomanip": "cpp",
        "iosfwd": "cpp",
        "iostream": "cpp",
        "istream": "cpp",
        "limits": "cpp",
        "mutex": "cpp",
        "new": "cpp",
        "ostream": "cpp",
        "ranges": "cpp",
        "shared_mutex": "cpp",
        "sstream": "cpp",
        "stdexcept": "cpp",
        "stop_token": "cpp",
        "streambuf": "cpp",
        "thread": "cpp",
        "cfenv": "cpp",
        "cinttypes": "cpp",
        "typeindex": "cpp",
        "typeinfo": "cpp",
        "valarray": "cpp",
        "variant": "cpp"
    },
    "C_Cpp.intelliSenseEngine": "disabled",
    "C_Cpp.autocomplete": "disabled",
    "C_Cpp.errorSquiggles": "disabled",
    "clangd.arguments": [
        "--background-index",
        "--clang-tidy",
        "--clang-tidy-checks=performance-*,bugprone-*",
        "--all-scopes-completion",
        "--completion-style=detailed",
        "--header-insertion=iwyu",
        "--pch-storage=disk",
        "--cross-file-rename",
        "--suggest-missing-includes",
        "-log=verbose", 
        "-pretty",
        "--compile-commands-dir=/home/{your_home}/Gluten/bolt/_build/Release/"
    ]
}
```

# 远程 debug C++代码

- 下载C/C++插件到remote端：
	

![](vscode-fig/3.png)

- 点击vscode左侧“调试”选项，然后点击右上角的“齿轮”，打开launch.json文件配置调试信息：
	

![](vscode-fig/4.png)

- 然后将如下配置信息填入launch.json文件中，如下几个参数需要++自定义++：
	- "name"：当前调试配置的名称。一般项目中会涉及到多个可执行文件的调试，因此“configurations”配置列表中可能会有多个配置选项。
		
	- "program"：你打算调试的可执行文件的完整路径，这里如果我需要调试bolt\_exec\_test这个测试代码，则需要将其完整路径填写在program中。
		
	- "args"：由于gtest执行可执行文件的时候一般利用--gtest\_filter将单元测试的范围限定到某一个单元中，因此利用gdb调试的时候可以将参数信息填写到args中。
		
	- "cwd"：填写的你的项目的工作路径。
		

```Shell
{
    // Use IntelliSense to learn about possible attributes.
    // Hover to view descriptions of existing attributes.
    // For more information, visit: https://go.microsoft.com/fwlink/?linkid=830387
    "version": "0.2.0",
    "configurations": [
        {
            "name": "GDB",
            "type": "cppdbg",
            "request": "launch",
            "program": "/home/{your_home}/bolt/_build/Debug/bolt/exec/tests/bolt_exec_test",
            "args": [
                "--gtest_filter=*SpillTest.spillState*",
                // GTEST 中的 EXPECT/ASSERT 失败时立刻 break
                "--gtest_break_on_failure"
            ],
            "stopAtEntry": false,
            "cwd": "/home/{your_home}/bolt",
            "environment": [],
            "externalConsole": false,
            "MIMode": "gdb",
            "setupCommands": [
                {
                    "description": "为 gdb 启用整齐打印",
                    "text": "-enable-pretty-printing",
                    "ignoreFailures": true
                },
                {
                    "description": "Attach 之后立刻就能在 throw exception 的时候 break",
                    "text": "-exec \"catch throw\"",
                    "ignoreFailures": true
                }
            ]
        }
    ]
}
```

- 填写完如上配置信息之后，就能够将愉快的调试了：
	

![](vscode-fig/5.png)

# 快速运行工程中的单元测试

- 下载`C++ TestMate`插件到remote端：
	

![](vscode-fig/6.png)

- 可以看到vscode左边出现了测试的icon，点进去发现TestMate并没有发现工程中的单元测试，这里需要配置一下TestMate的 discover 路径：
	

![](vscode-fig/7.png)

- 打开vscode的设置页面，找到remote的TestMate设置选项，找到`Executables`选项，将`build`改为`_build`即可，这里可以知道为啥之前TestMate发现不了工程中了ut了，因此bolt中编译产物是放在`_build`文件夹中的，而不是`build`。
	

![](vscode-fig/8.png)

- 再次来到测试界面，点击右上角刷新按钮，TestMate就能够发现工程中所有的单元测试了：
	

![](vscode-fig/9.png)

- 随便打开一个单元测试，找到绿色的icon，就可以++右键++运行或调试单元测试了：
	

![](vscode-fig/10.png)

# Clang-Format代码保存时自动格式化

- devbox上通过`sudo apt install clang-format`命令下载clang-format，默认会安装在`/usr/bin/clang-format`，可以通过`which clang-format`查看具体的安装路径。
	
- vscode上下载clang-format插件，并配置为默认的代码格式化器。在`.vscode/settings.json`中添加如下配置：
	

```Bash
"editor.formatOnSave": true, # 配置在保存文件时自动格式化
"clang-format.executable": "/usr/bin/clang-format", # 填写clang-format执行文件的安装路径
"files.autoSave": "afterDelay"
```

- 最后在vscode上编写完代码之后，一般会自动触发clang-format，同时还可以右键单击手动触发clang-format：
	

![](vscode-fig/11.png)
<br>

note：
如果 remote 工作不正常，可以删除 remote 机器上的 .vscode-server/，重新安装 extensions 即可。
<br>