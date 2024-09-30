<div><img align="left" src="ultrasecurity.png" alt="Description" width="36" height="36"> <h1>UltraSecurity</h1></div>

[![build status](https://img.shields.io/github/actions/workflow/status/kataras/ultrasecurity/ci.yml?branch=main&style=for-the-badge)](https://github.com/kataras/ultrasecurity/actions/workflows/ci.yml)

**UltraSecurity** is a Go-based utility designed to enhance system security by monitoring the presence of a specific folder on the user's desktop. If the folder named `letsgo` is not found within 10 seconds of the program's execution, the system will automatically shut down. This tool is particularly useful for ensuring that certain security protocols are followed before allowing the system to remain operational.

### Features

- **Folder Monitoring**: Checks for the existence of a folder named `letsgo` on the desktop.
- **Automatic Shutdown**: Initiates a system shutdown if the folder is not found within the specified time frame.
- **Administrative Privileges**: Requests and utilizes administrative privileges to perform the shutdown operation.
- **Silent Operation**: Runs without opening a console window, ensuring a seamless user experience.
- **Customizable Folder Name**: Allows customization of the folder name through build tags.
- **Customizable Timeout**: Allows customization of the timeout duration through build tags.

### Usage

1. **[Download the executable](https://github.com/kataras/ultrasecurity/releases)** or build the executable from source:
    ```sh
    go build -ldflags="-H=windowsgui -s -w" -o ultrasecurity.exe .
    ```

    <details><summary>Build the Executable with Custom Folder Name and Timeout</summary>

    Use the -tags flag to specify the build tags and the -ldflags flag to pass the custom folder name and timeout when building your executable:
    ```sh
    go build -tags "folder timeout" -ldflags="-X main.folder=letsgo -X main.timeout=15s -H=windowsgui -s -w" -o ultrasecurity.exe .
    ```

</details>

2. **Place in Startup Folder**:
    Copy the `ultrasecurity.exe` to the Windows startup folder:
    ```sh
    C:\Users\<YourUsername>\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup
    # Or press Win + R, type shell:startup, and press Enter
    # and move the executable to the opened folder.
    ```

    > This will ensure that the script runs every time the computer starts up. If the folder "letsgo" is not created on the desktop within 10 seconds, the computer will shut down.

### Requirements

- **Operating System**: Windows 11
- **Go**: Version 1.23 or higher

## License

This project is licensed under the [MIT License](LICENSE).

<!--

To add a logo or icon to the final executable built by the go build command, especially for Windows executables, you can follow these steps:

1. *Prepare the Icon*: Create or obtain an icon file in .ico format.

2. *Generate .syso File*: Use a tool like rsrc to embed the icon into a .syso file. You can install rsrc using:
   
go install github.com/akavel/rsrc@latest
   Then, generate the .syso file:
   
rsrc -arch arm64 -ico youricon.ico -o rsrc.syso

3. *Build the Go Program*: Place the generated rsrc.syso file in the same directory as your Go source code. When you run the go build command, it will automatically include the .syso file in the final executable:
   
go build -o yourprogram.exe

This process will embed the icon into your Windows executable⁴.

-->

<!--

`go build` does not have a `-manifest` flag. Instead, you we use a different approach to embed the manifest file into your executable.

1. **Create the Manifest File**: Save the following XML content into a file named `ultrasecurity.manifest`:

    ```xml
    <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
    <assembly xmlns="urn:schemas-microsoft-com:asm.v1" manifestVersion="1.0">
      <trustInfo xmlns="urn:schemas-microsoft-com:asm.v3">
        <security>
          <requestedPrivileges>
            <requestedExecutionLevel level="requireAdministrator" uiAccess="false"/>
          </requestedPrivileges>
        </security>
      </trustInfo>
    </assembly>
    ```

2. **Embed the Manifest File**: Use a tool like `rsrc` to embed the manifest file into your executable. First, install `rsrc`:

    ```sh
    go install github.com/akavel/rsrc@latest
    ```

    Then, generate a `.syso` file from the manifest:

    ```sh
    rsrc -manifest ultrasecurity.manifest -o ultrasecurity.syso
    ```

3. **Build the Executable**: Now, build your Go executable. The `.syso` file will be automatically included:

    ```sh
    go build -ldflags="-s -w" -o ./binaries/ultrasecurity.exe .
    ```

This process will ensure that your executable requests administrative privileges when run.

-->

<!--

To prevent the Windows Terminal from opening when your executable starts, you can build your Go application as a Windows GUI application. This will prevent the console window from appearing.

```sh
go build -ldflags="-H=windowsgui -s -w" -o ./binaries/ultrasecurity.exe .
```

-->