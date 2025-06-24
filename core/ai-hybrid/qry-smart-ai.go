package main

import (
	"bufio"
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"os/exec"
	"regexp"
	"strings"
	"time"
)

// PromptAnalysis represents analyzed characteristics of a prompt
type PromptAnalysis struct {
	Complexity  string  `json:"complexity"`   // "simple", "medium", "complex"
	Urgency     string  `json:"urgency"`      // "immediate", "normal", "quality"
	ContentType string  `json:"content_type"` // "code", "docs", "general"
	Confidence  float64 `json:"confidence"`   // 0.0 to 1.0
}

// AITarget represents the selected AI backend and model
type AITarget struct {
	Backend       string        `json:"backend"`        // "localai" or "ollama"
	Model         string        `json:"model"`          // specific model name
	Reason        string        `json:"reason"`         // selection reasoning
	EstimatedCost float64       `json:"estimated_cost"` // in dollars
	EstimatedTime time.Duration `json:"estimated_time"` // expected response time
}

// Response represents the AI response with metadata
type Response struct {
	Content      string        `json:"content"`
	Model        string        `json:"model"`
	Backend      string        `json:"backend"`
	ResponseTime time.Duration `json:"response_time"`
	Success      bool          `json:"success"`
	Error        string        `json:"error,omitempty"`
}

// SmartRouter handles intelligent AI routing between LocalAI and Ollama
type SmartRouter struct {
	localAIEndpoint string
	speedKeywords   []string
	qualityKeywords []string
	codeKeywords    []string
	docsKeywords    []string
	complexKeywords []string
}

// NewSmartRouter creates a new smart router with default configuration
func NewSmartRouter() *SmartRouter {
	localAIEndpoint := os.Getenv("LOCALAI_ENDPOINT")
	if localAIEndpoint == "" {
		localAIEndpoint = "http://localhost:8080"
	}

	return &SmartRouter{
		localAIEndpoint: localAIEndpoint,
		speedKeywords: []string{
			"quick", "fast", "brief", "summary", "urgent", "immediate",
			"rapid", "short", "simple", "asap", "now",
		},
		qualityKeywords: []string{
			"comprehensive", "detailed", "professional", "thorough",
			"complete", "polished", "client", "presentation", "publish",
			"perfect", "best", "excellent",
		},
		codeKeywords: []string{
			"code", "function", "bug", "refactor", "implement", "debug",
			"test", "class", "method", "algorithm", "fix", "error",
			"programming", "development", "software",
		},
		docsKeywords: []string{
			"document", "api", "guide", "readme", "manual", "specification",
			"tutorial", "explanation", "instructions", "documentation",
			"help", "reference",
		},
		complexKeywords: []string{
			"architecture", "system", "design", "analyze", "research",
			"strategy", "planning", "migration", "optimization", "complex",
			"analysis", "comprehensive", "detailed",
		},
	}
}

// AnalyzePrompt examines a prompt and returns analysis results
func (r *SmartRouter) AnalyzePrompt(prompt string) PromptAnalysis {
	prompt = strings.ToLower(prompt)
	words := strings.Fields(prompt)

	analysis := PromptAnalysis{
		Complexity:  r.analyzeComplexity(prompt, words),
		Urgency:     r.analyzeUrgency(prompt, words),
		ContentType: r.analyzeContentType(prompt, words),
	}

	analysis.Confidence = r.calculateConfidence(analysis, prompt)
	return analysis
}

// analyzeComplexity determines if the prompt suggests a simple, medium, or complex task
func (r *SmartRouter) analyzeComplexity(prompt string, words []string) string {
	complexityScore := 0

	// Check for complexity keywords
	for _, word := range words {
		if r.containsWord(r.complexKeywords, word) {
			complexityScore += 2
		}
	}

	// Length-based complexity
	if len(words) > 30 {
		complexityScore += 2
	} else if len(words) > 15 {
		complexityScore += 1
	}

	// Multiple concepts indicator
	if strings.Count(prompt, " and ") > 2 {
		complexityScore += 1
	}

	// Look for analysis/architecture terms
	if regexp.MustCompile(`(analyz|architect|design|system|complex|comprehensive)`).MatchString(prompt) {
		complexityScore += 2
	}

	switch {
	case complexityScore >= 4:
		return "complex"
	case complexityScore >= 2:
		return "medium"
	default:
		return "simple"
	}
}

// analyzeUrgency determines if the prompt suggests immediate, normal, or quality-focused needs
func (r *SmartRouter) analyzeUrgency(prompt string, words []string) string {
	speedScore := 0
	qualityScore := 0

	for _, word := range words {
		if r.containsWord(r.speedKeywords, word) {
			speedScore++
		}
		if r.containsWord(r.qualityKeywords, word) {
			qualityScore++
		}
	}

	switch {
	case speedScore > qualityScore && speedScore > 0:
		return "immediate"
	case qualityScore > speedScore && qualityScore > 0:
		return "quality"
	default:
		return "normal"
	}
}

// analyzeContentType determines the type of content being requested
func (r *SmartRouter) analyzeContentType(prompt string, words []string) string {
	codeScore := 0
	docsScore := 0

	for _, word := range words {
		if r.containsWord(r.codeKeywords, word) {
			codeScore++
		}
		if r.containsWord(r.docsKeywords, word) {
			docsScore++
		}
	}

	switch {
	case codeScore > docsScore && codeScore > 0:
		return "code"
	case docsScore > codeScore && docsScore > 0:
		return "docs"
	default:
		return "general"
	}
}

// calculateConfidence estimates how confident we are in the analysis
func (r *SmartRouter) calculateConfidence(analysis PromptAnalysis, prompt string) float64 {
	confidence := 0.5 // base confidence

	// Boost confidence if we found clear indicators
	if analysis.ContentType != "general" {
		confidence += 0.2
	}
	if analysis.Urgency != "normal" {
		confidence += 0.2
	}
	if len(prompt) > 10 { // longer prompts give more signal
		confidence += 0.1
	}

	if confidence > 1.0 {
		confidence = 1.0
	}
	return confidence
}

// SelectAI chooses the best AI target based on analysis
func (r *SmartRouter) SelectAI(analysis PromptAnalysis) AITarget {
	// Speed priority routing - use fastest available
	if analysis.Urgency == "immediate" {
		if r.isOllamaModelAvailable("orca-mini:3b") {
			return AITarget{
				Backend:       "ollama",
				Model:         "orca-mini:3b",
				Reason:        "Speed priority for immediate tasks",
				EstimatedCost: 0.001,
				EstimatedTime: 3 * time.Second,
			}
		}
		// Fallback to LocalAI for speed
		return AITarget{
			Backend:       "localai",
			Model:         "llama-3.2-1b-instruct:q4_k_m",
			Reason:        "Speed fallback - LocalAI with small model",
			EstimatedCost: 0.002,
			EstimatedTime: 5 * time.Second,
		}
	}

	// Code-specific routing
	if analysis.ContentType == "code" {
		if r.isOllamaModelAvailable("codellama:7b") {
			return AITarget{
				Backend:       "ollama",
				Model:         "codellama:7b",
				Reason:        "Code specialist for technical accuracy",
				EstimatedCost: 0.005,
				EstimatedTime: 15 * time.Second,
			}
		}
	}

	// Quality-focused routing for complex tasks
	if analysis.Complexity == "complex" && analysis.Urgency == "quality" {
		if r.isOllamaModelAvailable("llama2:13b") {
			return AITarget{
				Backend:       "ollama",
				Model:         "llama2:13b",
				Reason:        "High quality for complex professional content",
				EstimatedCost: 0.008,
				EstimatedTime: 25 * time.Second,
			}
		}
	}

	// Balanced choice for general tasks
	if r.isOllamaModelAvailable("mistral:7b") {
		return AITarget{
			Backend:       "ollama",
			Model:         "mistral:7b",
			Reason:        "Balanced performance for general tasks",
			EstimatedCost: 0.004,
			EstimatedTime: 12 * time.Second,
		}
	}

	// Default fallback to LocalAI
	return AITarget{
		Backend:       "localai",
		Model:         "llama-3.2-1b-instruct:q4_k_m",
		Reason:        "LocalAI fallback - reliable default",
		EstimatedCost: 0.003,
		EstimatedTime: 8 * time.Second,
	}
}

// Query executes a smart query with automatic routing
func (r *SmartRouter) Query(prompt string, explain bool) (*Response, error) {
	start := time.Now()

	// Analyze the prompt
	analysis := r.AnalyzePrompt(prompt)
	target := r.SelectAI(analysis)

	if explain {
		r.printExplanation(analysis, target)
	}

	// Execute with the selected backend
	var response *Response
	var err error

	switch target.Backend {
	case "ollama":
		response, err = r.queryOllama(target.Model, prompt)
	case "localai":
		response, err = r.queryLocalAI(target.Model, prompt)
	default:
		return nil, fmt.Errorf("unknown backend: %s", target.Backend)
	}

	if response != nil {
		response.ResponseTime = time.Since(start)
		response.Backend = target.Backend
		response.Model = target.Model
	}

	// If primary fails, try fallback
	if err != nil && target.Backend == "ollama" {
		if explain {
			fmt.Printf("⚠️  Primary failed, trying LocalAI fallback...\n")
		}
		fallback, fallbackErr := r.queryLocalAI("llama-3.2-1b-instruct:q4_k_m", prompt)
		if fallbackErr == nil {
			fallback.ResponseTime = time.Since(start)
			fallback.Backend = "localai"
			fallback.Model = "llama-3.2-1b-instruct:q4_k_m"
			return fallback, nil
		}
	}

	return response, err
}

// queryOllama executes a query using Ollama CLI
func (r *SmartRouter) queryOllama(model, prompt string) (*Response, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 60*time.Second)
	defer cancel()

	cmd := exec.CommandContext(ctx, "ollama", "run", model)
	cmd.Stdin = strings.NewReader(prompt)

	output, err := cmd.Output()
	if err != nil {
		return &Response{
			Success: false,
			Error:   fmt.Sprintf("ollama error: %v", err),
		}, err
	}

	return &Response{
		Content: strings.TrimSpace(string(output)),
		Success: true,
	}, nil
}

// queryLocalAI executes a query using LocalAI HTTP API
func (r *SmartRouter) queryLocalAI(model, prompt string) (*Response, error) {
	requestBody := map[string]interface{}{
		"model": model,
		"messages": []map[string]string{
			{"role": "user", "content": prompt},
		},
		"stream": false,
	}

	jsonBody, err := json.Marshal(requestBody)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal request: %v", err)
	}

	ctx, cancel := context.WithTimeout(context.Background(), 60*time.Second)
	defer cancel()

	req, err := http.NewRequestWithContext(ctx, "POST", r.localAIEndpoint+"/v1/chat/completions", bytes.NewBuffer(jsonBody))
	if err != nil {
		return nil, fmt.Errorf("failed to create request: %v", err)
	}

	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return &Response{
			Success: false,
			Error:   fmt.Sprintf("localai request error: %v", err),
		}, err
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("failed to read response: %v", err)
	}

	if resp.StatusCode != http.StatusOK {
		return &Response{
			Success: false,
			Error:   fmt.Sprintf("localai error %d: %s", resp.StatusCode, string(body)),
		}, fmt.Errorf("HTTP %d: %s", resp.StatusCode, string(body))
	}

	var response struct {
		Choices []struct {
			Message struct {
				Content string `json:"content"`
			} `json:"message"`
		} `json:"choices"`
	}

	if err := json.Unmarshal(body, &response); err != nil {
		return nil, fmt.Errorf("failed to parse response: %v", err)
	}

	if len(response.Choices) == 0 {
		return nil, fmt.Errorf("no response choices returned")
	}

	return &Response{
		Content: strings.TrimSpace(response.Choices[0].Message.Content),
		Success: true,
	}, nil
}

// isOllamaModelAvailable checks if a model is available in Ollama
func (r *SmartRouter) isOllamaModelAvailable(model string) bool {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	cmd := exec.CommandContext(ctx, "ollama", "list")
	output, err := cmd.Output()
	if err != nil {
		return false
	}

	return strings.Contains(string(output), strings.Split(model, ":")[0])
}

// containsWord checks if a word exists in a slice of words
func (r *SmartRouter) containsWord(slice []string, word string) bool {
	for _, s := range slice {
		if s == word {
			return true
		}
	}
	return false
}

// printExplanation shows the routing decision process
func (r *SmartRouter) printExplanation(analysis PromptAnalysis, target AITarget) {
	fmt.Println("🧠 Smart Routing Analysis:")
	fmt.Printf("   Complexity: %s\n", analysis.Complexity)
	fmt.Printf("   Urgency: %s\n", analysis.Urgency)
	fmt.Printf("   Content Type: %s\n", analysis.ContentType)
	fmt.Printf("   Confidence: %.1f%%\n", analysis.Confidence*100)

	fmt.Println("\n🎯 AI Selection:")
	fmt.Printf("   Backend: %s\n", target.Backend)
	fmt.Printf("   Model: %s\n", target.Model)
	fmt.Printf("   Reason: %s\n", target.Reason)
	fmt.Printf("   Estimated Cost: $%.4f\n", target.EstimatedCost)
	fmt.Printf("   Estimated Time: %v\n", target.EstimatedTime)
	fmt.Println()
}

// Interactive CLI interface
func runInteractive() {
	router := NewSmartRouter()
	scanner := bufio.NewScanner(os.Stdin)

	fmt.Println("🚀 QRY Smart AI Router")
	fmt.Println("Enter prompts to see intelligent routing in action.")
	fmt.Println("Commands: 'explain on/off', 'quit', or enter your prompt")
	fmt.Println()

	explain := false

	for {
		fmt.Print("qry-ai> ")
		if !scanner.Scan() {
			break
		}

		input := strings.TrimSpace(scanner.Text())
		if input == "" {
			continue
		}

		switch input {
		case "quit", "exit", "q":
			fmt.Println("👋 Goodbye!")
			return
		case "explain on":
			explain = true
			fmt.Println("🔍 Explanation mode enabled")
			continue
		case "explain off":
			explain = false
			fmt.Println("🔇 Explanation mode disabled")
			continue
		case "help":
			fmt.Println("Commands:")
			fmt.Println("  'explain on/off' - Toggle routing explanations")
			fmt.Println("  'quit' - Exit the program")
			fmt.Println("  Or just enter your AI prompt")
			continue
		}

		response, err := router.Query(input, explain)
		if err != nil {
			fmt.Printf("❌ Error: %v\n", err)
			continue
		}

		if response.Success {
			fmt.Printf("✅ Response (%s/%s, %v):\n", response.Backend, response.Model, response.ResponseTime.Round(time.Millisecond))
			fmt.Println(strings.Repeat("-", 60))
			fmt.Println(response.Content)
			fmt.Println(strings.Repeat("-", 60))
		} else {
			fmt.Printf("❌ Failed: %s\n", response.Error)
		}
		fmt.Println()
	}
}

func main() {
	if len(os.Args) > 1 {
		// Command line mode
		prompt := strings.Join(os.Args[1:], " ")

		// Check for explain flag
		explain := false
		if strings.Contains(prompt, "--explain") {
			explain = true
			prompt = strings.ReplaceAll(prompt, "--explain", "")
			prompt = strings.TrimSpace(prompt)
		}

		router := NewSmartRouter()
		response, err := router.Query(prompt, explain)

		if err != nil {
			fmt.Printf("Error: %v\n", err)
			os.Exit(1)
		}

		if response.Success {
			fmt.Println(response.Content)
		} else {
			fmt.Printf("Failed: %s\n", response.Error)
			os.Exit(1)
		}
	} else {
		// Interactive mode
		runInteractive()
	}
}
