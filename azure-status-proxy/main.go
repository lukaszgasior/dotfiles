package main

import (
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"sort"
	"strings"

	"github.com/getlantern/systray"
	"github.com/shirou/gopsutil/v4/process"
	"github.com/skratchdot/open-golang/open"
)

const (
	AZURE_RSS        = "https://azurestatuscdn.azureedge.net/en-us/status/feed/"
	AZURE_DEVOPS_RSS = "https://status.dev.azure.com/_rss"
	PORT             = ":8787"
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

func handleRss(rssURL string) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		enableCors(&w)

		if r.Method == "OPTIONS" {
			return
		}

		resp, err := http.Get(rssURL)
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
}

type procInfo struct {
	Name string
	CPU  float64
	Mem  uint64
}

func getTopProcesses(sortBy string) (string, error) {
	procs, err := process.Processes()
	if err != nil {
		return "", err
	}

	grouped := make(map[string]*procInfo)
	for _, p := range procs {
		name, err := p.Name()
		if err != nil || name == "" {
			continue
		}
		cpu, _ := p.CPUPercent()
		mem, err := p.MemoryInfo()
		if err != nil || mem == nil {
			continue
		}
		if g, ok := grouped[name]; ok {
			g.CPU += cpu
			g.Mem += mem.RSS
		} else {
			grouped[name] = &procInfo{Name: name, CPU: cpu, Mem: mem.RSS}
		}
	}

	infos := make([]procInfo, 0, len(grouped))
	for _, g := range grouped {
		infos = append(infos, *g)
	}

	switch sortBy {
	case "mem":
		sort.Slice(infos, func(i, j int) bool { return infos[i].Mem > infos[j].Mem })
	default:
		sort.Slice(infos, func(i, j int) bool { return infos[i].CPU > infos[j].CPU })
	}

	limit := 5
	if len(infos) < limit {
		limit = len(infos)
	}

	var lines []string
	for _, p := range infos[:limit] {
		memMB := float64(p.Mem) / 1024 / 1024
		if sortBy == "mem" {
			lines = append(lines, fmt.Sprintf("%-20s %6.0f MB  %5.1f%% CPU", p.Name, memMB, p.CPU))
		} else {
			lines = append(lines, fmt.Sprintf("%-20s %5.1f%% CPU  %6.0f MB", p.Name, p.CPU, memMB))
		}
	}

	return strings.Join(lines, "\n"), nil
}

func handleTopProcesses(w http.ResponseWriter, r *http.Request) {
	enableCors(&w)
	if r.Method == "OPTIONS" {
		return
	}

	sortBy := r.URL.Query().Get("sort")
	result, err := getTopProcesses(sortBy)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "text/plain; charset=utf-8")
	fmt.Fprint(w, result)
}

func startProxyServer() {
	http.HandleFunc("/azure-status", handleRss(AZURE_RSS))
	http.HandleFunc("/devops-status", handleRss(AZURE_DEVOPS_RSS))
	http.HandleFunc("/top-processes", handleTopProcesses)

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
