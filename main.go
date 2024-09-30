package main

import (
	"context"
	"flag"
	"log/slog"
	"os"
	"os/user"
	"path/filepath"
	"time"

	"golang.org/x/sys/windows"
)

const debug = false

func init() {
	if folder == "" {
		flag.StringVar(&folder, "folder", "letsgo", "Name of the folder to check (e.g. letsgo)")
	}

	if timeout == "" {
		flag.StringVar(&timeout, "timeout", "10s", "Timeout duration (e.g. 10s, 1m)")
		flag.Parse()
	}

	if len(os.Args) > 1 {
		flag.Parse()
	}
}

// $ rsrc -arch arm64 -ico ultrasecurity.ico -manifest ultrasecurity.manifest -o ultrasecurity.syso
// $ go build -tags "folder timeout" -ldflags="-X main.folder=letsgo -X main.timeout=15s -H=windowsgui -s -w" -o ./binaries/ultrasecurity.exe .
func main() {
	usr, err := user.Current()
	if err != nil {
		log("Failed to get current user: %v", err)
		return
	}

	desktopPath := filepath.Join(usr.HomeDir, "Desktop", folder)

	log("Waiting for folder creation...")

	timeoutDuration, err := time.ParseDuration(timeout)
	if err != nil {
		log("Invalid timeout duration: %v\n", err)
		os.Exit(1)
	}
	time.Sleep(timeoutDuration)

	if _, err := os.Stat(desktopPath); os.IsNotExist(err) {
		log("Folder not found. Shutting down...")
		enableShutdownPrivilege()
		shutdown()
	} else {
		log("Folder found. No action needed.")
	}
}

const SE_SHUTDOWN_NAME = "SeShutdownPrivilege"

func enableShutdownPrivilege() {
	var token windows.Token
	err := windows.OpenProcessToken(windows.CurrentProcess(), windows.TOKEN_ADJUST_PRIVILEGES|windows.TOKEN_QUERY, &token)
	if err != nil {
		log("Failed to open process token: %v\n", err)
		return
	}
	defer token.Close()

	var luid windows.LUID
	err = windows.LookupPrivilegeValue(nil, windows.StringToUTF16Ptr(SE_SHUTDOWN_NAME), &luid)
	if err != nil {
		log("Failed to lookup privilege value: %v\n", err)
		return
	}

	tp := windows.Tokenprivileges{
		PrivilegeCount: 1,
		Privileges: [1]windows.LUIDAndAttributes{
			{
				Luid:       luid,
				Attributes: windows.SE_PRIVILEGE_ENABLED,
			},
		},
	}

	err = windows.AdjustTokenPrivileges(token, false, &tp, 0, nil, nil)
	if err != nil {
		log("Failed to adjust token privileges: %v\n", err)
		return
	}
}

func shutdown() {
	user32 := windows.NewLazySystemDLL("user32.dll")
	exitWindowsEx := user32.NewProc("ExitWindowsEx")
	const EWX_SHUTDOWN = 0x00000001
	const EWX_FORCE = 0x00000004

	_, _, err := exitWindowsEx.Call(uintptr(EWX_SHUTDOWN|EWX_FORCE), 0)
	if err != nil && err.Error() != "The operation completed successfully." {
		log("Failed to shutdown: %v\n", err)
	}
}

func log(msg string, args ...any) {
	if !debug {
		return
	}

	slog.Log(context.Background(), slog.LevelInfo, msg, args...)
}
