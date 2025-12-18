# Necessary VSCode Plugins

- Local:
	- Remote SSH
		
	![](vscode-fig/0.png)
	
- Remote SSH:
	- C/C++: GDB visualization, supports C++ visual debugging
		
	- Clangd: Code hints, code completion, and code navigation
		
	- CMake: CMake syntax highlighting
		
	- GitLens: View commit history for each line of code in the repository (including commit time and author)
		
	- C++ TestMate: Display all unit tests in the project, run or debug with one click
		
	- Clang-Format: Automatic code formatting on save
		

![](vscode-fig/1.png)
![](vscode-fig/2.png)

# Remote SSH Connection

- Configure the VSCode Remote SSH environment locally, and you can normally view projects in the devbox through Mac.
	

# Clangd Configuration

- Download the clangd plugin on the remote end.
	
- Create settings.json under .vscode and copy the following content into settings.json. The path need to be replaced with your own build directory's debug directory, typically `/home/{your_home}/bolt/_build/Release/` (use absolute path). Note: This path needs to find the compile_commands.json file in the build directory, as building the index depends on the compile_commands.json file.
	
- *ctrl+shift+p* to open the command window, type *Clangd* and find `clangd: Download language server` in the command list, click to install the language server; after installation, it will prompt to reload.
	
- After restarting, you can try the effect. In actual use, there may be cases where code hints and navigation still have problems even after recompilation. In this case, you can try restarting *clangd*. The specific method is *ctrl+shift+p*, type Clangd and find `clangd: Restart language server`, click to re-execute the index.
	
- The following configuration information needs to be written into the `/home/{your_home}/bolt/.vscode/settings.json` configuration file (note to modify the highlighted path information):
	

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

# Remote Debugging C++ Code

- Download the C/C++ plugin to the remote end:
	

![](vscode-fig/3.png)

- Click the "Debug" option on the left side of VSCode, then click the gear icon in the upper right corner to open the launch.json file to configure debugging information:
	

![](vscode-fig/4.png)

- Then fill in the following configuration information into the launch.json file. The following parameters need to be **customized**:
	- "name": The name of the current debug configuration. Generally, projects involve debugging multiple executable files, so there may be multiple configuration options in the "configurations" list.
		
	- "program": The full path of the executable file you plan to debug. Here, if I need to debug the bolt_exec_test test code, I need to fill in its full path in program.
		
	- "args": Since gtest generally uses --gtest_filter to limit the scope of unit tests to a specific unit when executing executable files, parameter information can be filled in args when debugging with gdb.
		
	- "cwd": Fill in your project's working path.
		

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
                // Break immediately when EXPECT/ASSERT fails in GTEST
                "--gtest_break_on_failure"
            ],
            "stopAtEntry": false,
            "cwd": "/home/{your_home}/bolt",
            "environment": [],
            "externalConsole": false,
            "MIMode": "gdb",
            "setupCommands": [
                {
                    "description": "Enable pretty-printing for gdb",
                    "text": "-enable-pretty-printing",
                    "ignoreFailures": true
                },
                {
                    "description": "Break immediately when throw exception after Attach",
                    "text": "-exec \"catch throw\"",
                    "ignoreFailures": true
                }
            ]
        }
    ]
}
```

- After filling in the above configuration information, you can debug happily:
	

![](vscode-fig/5.png)

# Quickly Run Unit Tests in the Project

- Download the `C++ TestMate` plugin to the remote end:
	

![](vscode-fig/6.png)

- You can see the test icon appears on the left side of VSCode. Click to enter and find that TestMate has not discovered unit tests in the project. Here you need to configure the TestMate discover path:
	

![](vscode-fig/7.png)

- Open the VSCode settings page, find the remote TestMate settings, find the `Executables` option, and change `build` to `_build`. Here you can know why TestMate couldn't discover unit tests in the project before, because the compilation products in bolt are placed in the `_build` folder, not `build`.
	

![](vscode-fig/8.png)

- Go back to the test interface, click the refresh button in the upper right corner, and TestMate can discover all unit tests in the project:
	

![](vscode-fig/9.png)

- Open any unit test, find the green icon, and you can **right-click** to run or debug the unit test:
	

![](vscode-fig/10.png)

# Clang-Format Automatic Code Formatting on Save

- Install clang-format on devbox with the command `sudo apt install clang-format`. It will be installed in `/usr/bin/clang-format` by default. You can check the specific installation path with `which clang-format`.
	
- Download the clang-format plugin in VSCode and configure it as the default code formatter. Add the following configuration in `.vscode/settings.json`:
	

```Bash
"editor.formatOnSave": true, # Configure automatic formatting when saving files
"clang-format.executable": "/usr/bin/clang-format", # Fill in the installation path of the clang-format executable
"files.autoSave": "afterDelay"
```

- Finally, after writing code in VSCode, clang-format is generally triggered automatically. You can also right-click to manually trigger clang-format:
	

![](vscode-fig/11.png)
<br>

note:
If remote doesn't work properly, you can delete the .vscode-server/ on the remote machine and reinstall the extensions.
<br>