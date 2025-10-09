package main

import (
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"path/filepath"

	"github.com/getlantern/systray"
	"github.com/skratchdot/open-golang/open"
)

const (
	AZURE_RSS = "https://azurestatuscdn.azureedge.net/en-us/status/feed/"
	PORT      = ":8787"
)

var (
	iconAvailable   []byte
	iconUnavailable []byte
	iconChecking    []byte
)

func main() {
	if err := loadIcons(); err != nil {
		log.Printf("Error while loading icons: %v", err)
	}

	systray.Run(onReady, onExit)
}

func onReady() {
	systray.SetIcon(iconAvailable)

	systray.SetTitle("Azure Status Proxy")
	systray.SetTooltip(fmt.Sprintf("Azure Status Proxy (localhost%s)", PORT))

	mURL := systray.AddMenuItem("Open Azure Status", "Opens Azure Status page")
	mStatus := systray.AddMenuItem(fmt.Sprintf("Proxy running on port%s", PORT), "Proxy status")
	mStatus.Disable()

	systray.AddSeparator()
	mQuit := systray.AddMenuItem("Quit", "Quit the app")

	go func() {
		for {
			select {
			case <-mURL.ClickedCh:
				open.Run("https://status.azure.com")
			case <-mQuit.ClickedCh:
				systray.Quit()
				return
			}
		}
	}()

	go startProxyServer()
}

func onExit() {}

func enableCors(w *http.ResponseWriter) {
	(*w).Header().Set("Access-Control-Allow-Origin", "*")
	(*w).Header().Set("Access-Control-Allow-Methods", "GET, OPTIONS")
	(*w).Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, Cache-Control, Pragma")
}

func handleRss(w http.ResponseWriter, r *http.Request) {
	enableCors(&w)

	if r.Method == "OPTIONS" {
		return
	}

	resp, err := http.Get(AZURE_RSS)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer resp.Body.Close()

	w.Header().Set("Content-Type", "application/rss+xml")

	if _, err := io.Copy(w, resp.Body); err != nil {
		log.Printf("Error copying response: %v", err)
	}
}

func startProxyServer() {
	http.HandleFunc("/azure-status", handleRss)

	if err := http.ListenAndServe(PORT, nil); err != nil {
		log.Fatal(err)
	}
}

func loadIcons() error {
	execPath, err := os.Executable()
	if err != nil {
		return fmt.Errorf("error: %v", err)
	}

	appDir := filepath.Dir(execPath)

	var err1, err2, err3 error
	iconAvailable, err1 = os.ReadFile(filepath.Join(appDir, "assets", "icon-available.ico"))
	iconUnavailable, err2 = os.ReadFile(filepath.Join(appDir, "assets", "icon-unavailable.ico"))
	iconChecking, err3 = os.ReadFile(filepath.Join(appDir, "assets/icon-checking.ico"))

	if err1 != nil {
		return fmt.Errorf("error loading available.ico: %v", err1)
	}
	if err2 != nil {
		return fmt.Errorf("error loading unavailable.ico: %v", err2)
	}
	if err3 != nil {
		return fmt.Errorf("error loading checking.ico: %v", err3)
	}

	return nil
}
