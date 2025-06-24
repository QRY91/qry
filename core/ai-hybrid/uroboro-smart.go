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
	ContentType string  `json:"content_type"` // "devlog", "blog", "social", "general"
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

// UroboroEntry represents a work capture entry
type UroboroEntry struct {
	Timestamp   time.Time `json:"timestamp"`
	Type        string    `json:"type"`         // "capture", "devlog", "blog", "social"
	Content     string    `json:"content"`      // original capture content
	AIGenerated string    `json:"ai_generated"` // AI-enhanced content
	Model       string    `json:"model"`        // model used for generation
	Backend     string    `json:"backend"`      // backend used
}

// SmartUroboro handles intelligent AI routing for uroboro content generation
type SmartUroboro struct {
	localAIEndpoint string
	speedKeywords   []string
	qualityKeywords []string
	devlogKeywords  []string
	blogKeywords    []string
	socialKeywords  []string
}

// NewSmartUroboro creates a new smart uroboro instance
func NewSmartUroboro() *SmartUroboro {
	localAIEndpoint := os.Getenv("LOCALAI_ENDPOINT")
	if localAIEndpoint == "" {
		localAIEndpoint = "http://localhost:8080"
	}

	return &SmartUroboro{
		localAIEndpoint: localAIEndpoint,
		speedKeywords: []string{
			"quick", "fast", "brief", "summary", "urgent", "immediate",
			"rapid", "short", "simple", "asap", "now", "standup",
		},
		qualityKeywords: []string{
			"comprehensive", "detailed", "professional", "thorough",
			"complete", "polished", "publish", "blog", "article",
			"documentation", "presentation",
		},
		devlogKeywords: []string{
			"working", "debugging", "implementing", "building", "coding",
			"fixing", "developing", "progress", "technical", "dev",
			"feature", "bug", "issue", "commit", "merge",
		},
		blogKeywords: []string{
			"blog", "article", "post", "write", "publish", "share",
			"explain", "tutorial", "guide", "story", "experience",
			"lessons", "insights", "thoughts",
		},
		socialKeywords: []string{
			"twitter", "social", "tweet", "share", "announcement",
			"update", "milestone", "achievement", "launch", "release",
			"linkedin", "post",
		},
	}
}

// AnalyzeUroboroPrompt examines uroboro content and determines optimal AI routing
func (u *SmartUroboro) AnalyzeUroboroPrompt(content, contentType string) PromptAnalysis {
	fullText := strings.ToLower(content + " " + contentType)
	words := strings.Fields(fullText)

	analysis := PromptAnalysis{
		Complexity:  u.analyzeComplexity(fullText, words),
		Urgency:     u.analyzeUrgency(fullText, words),
		ContentType: u.analyzeUroboroContentType(fullText, words, contentType),
	}

	analysis.Confidence = u.calculateConfidence(analysis, fullText)
	return analysis
}

// analyzeComplexity determines task complexity for uroboro content
func (u *SmartUroboro) analyzeComplexity(text string, words []string) string {
	complexityScore := 0

	// Length-based complexity
	if len(words) > 50 {
		complexityScore += 2
	} else if len(words) > 20 {
		complexityScore += 1
	}

	// Technical complexity indicators
	if regexp.MustCompile(`(architect|design|system|analysis|complex|comprehensive|detailed)`).MatchString(text) {
		complexityScore += 2
	}

	// Multiple concepts
	if strings.Count(text, " and ") > 2 || strings.Count(text, ",") > 3 {
		complexityScore += 1
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

// analyzeUrgency determines urgency for uroboro content
func (u *SmartUroboro) analyzeUrgency(text string, words []string) string {
	speedScore := 0
	qualityScore := 0

	for _, word := range words {
		if u.containsWord(u.speedKeywords, word) {
			speedScore++
		}
		if u.containsWord(u.qualityKeywords, word) {
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

// analyzeUroboroContentType determines the type of uroboro content
func (u *SmartUroboro) analyzeUroboroContentType(text string, words []string, explicitType string) string {
	// If explicitly specified, use that with some validation
	if explicitType != "" {
		switch explicitType {
		case "devlog", "blog", "social":
			return explicitType
		}
	}

	devlogScore := 0
	blogScore := 0
	socialScore := 0

	for _, word := range words {
		if u.containsWord(u.devlogKeywords, word) {
			devlogScore++
		}
		if u.containsWord(u.blogKeywords, word) {
			blogScore++
		}
		if u.containsWord(u.socialKeywords, word) {
			socialScore++
		}
	}

	switch {
	case devlogScore > blogScore && devlogScore > socialScore:
		return "devlog"
	case blogScore > devlogScore && blogScore > socialScore:
		return "blog"
	case socialScore > 0:
		return "social"
	default:
		return "general"
	}
}

// calculateConfidence estimates confidence in the analysis
func (u *SmartUroboro) calculateConfidence(analysis PromptAnalysis, text string) float64 {
	confidence := 0.6 // higher base for uroboro context

	if analysis.ContentType != "general" {
		confidence += 0.2
	}
	if analysis.Urgency != "normal" {
		confidence += 0.1
	}
	if len(text) > 20 {
		confidence += 0.1
	}

	if confidence > 1.0 {
		confidence = 1.0
	}
	return confidence
}

// SelectUroboroAI chooses the best AI for uroboro content generation
func (u *SmartUroboro) SelectUroboroAI(analysis PromptAnalysis) AITarget {
	// Speed priority for quick captures and standups
	if analysis.Urgency == "immediate" {
		if u.isOllamaModelAvailable("orca-mini:3b") {
			return AITarget{
				Backend:       "ollama",
				Model:         "orca-mini:3b",
				Reason:        "Speed priority for immediate uroboro captures",
				EstimatedCost: 0.001,
				EstimatedTime: 3 * time.Second,
			}
		}
	}

	// Quality routing for blog posts and detailed documentation
	if analysis.ContentType == "blog" && analysis.Urgency == "quality" {
		if u.isOllamaModelAvailable("llama2:13b") {
			return AITarget{
				Backend:       "ollama",
				Model:         "llama2:13b",
				Reason:        "High quality for professional blog content",
				EstimatedCost: 0.008,
				EstimatedTime: 25 * time.Second,
			}
		}
	}

	// Technical development content
	if analysis.ContentType == "devlog" {
		if u.isOllamaModelAvailable("codellama:7b") {
			return AITarget{
				Backend:       "ollama",
				Model:         "codellama:7b",
				Reason:        "Technical specialist for development logs",
				EstimatedCost: 0.005,
				EstimatedTime: 15 * time.Second,
			}
		}
		// Fallback to mistral for devlogs if codellama not available
		if u.isOllamaModelAvailable("mistral:7b") {
			return AITarget{
				Backend:       "ollama",
				Model:         "mistral:7b",
				Reason:        "Balanced model for development content",
				EstimatedCost: 0.004,
				EstimatedTime: 12 * time.Second,
			}
		}
	}

	// Social media content - needs engaging tone
	if analysis.ContentType == "social" {
		if u.isOllamaModelAvailable("mistral:7b") {
			return AITarget{
				Backend:       "ollama",
				Model:         "mistral:7b",
				Reason:        "Engaging tone for social media content",
				EstimatedCost: 0.003,
				EstimatedTime: 10 * time.Second,
			}
		}
	}

	// Default balanced choice
	if u.isOllamaModelAvailable("mistral:7b") {
		return AITarget{
			Backend:       "ollama",
			Model:         "mistral:7b",
			Reason:        "Balanced performance for general uroboro content",
			EstimatedCost: 0.004,
			EstimatedTime: 12 * time.Second,
		}
	}

	// Final fallback to LocalAI
	return AITarget{
		Backend:       "localai",
		Model:         "llama-3.2-1b-instruct:q4_k_m",
		Reason:        "LocalAI fallback for uroboro content",
		EstimatedCost: 0.003,
		EstimatedTime: 8 * time.Second,
	}
}

// GenerateContent creates AI-enhanced content for uroboro entries
func (u *SmartUroboro) GenerateContent(entry UroboroEntry, explain bool) (*UroboroEntry, error) {
	analysis := u.AnalyzeUroboroPrompt(entry.Content, entry.Type)
	target := u.SelectUroboroAI(analysis)

	if explain {
		u.printUroboroExplanation(analysis, target, entry)
	}

	prompt := u.buildUroboroPrompt(entry, analysis)

	var content string
	var err error

	switch target.Backend {
	case "ollama":
		content, err = u.queryOllama(target.Model, prompt)
	case "localai":
		content, err = u.queryLocalAI(target.Model, prompt)
	default:
		return nil, fmt.Errorf("unknown backend: %s", target.Backend)
	}

	if err != nil && target.Backend == "ollama" {
		// Try LocalAI fallback
		if explain {
			fmt.Printf("⚠️  Primary failed, trying LocalAI fallback...\n")
		}
		content, err = u.queryLocalAI("llama-3.2-1b-instruct:q4_k_m", prompt)
		if err == nil {
			target.Backend = "localai"
			target.Model = "llama-3.2-1b-instruct:q4_k_m"
		}
	}

	if err != nil {
		return nil, fmt.Errorf("AI generation failed: %v", err)
	}

	enhancedEntry := entry
	enhancedEntry.AIGenerated = strings.TrimSpace(content)
	enhancedEntry.Model = target.Model
	enhancedEntry.Backend = target.Backend

	return &enhancedEntry, nil
}

// buildUroboroPrompt creates specialized prompts for different uroboro content types
func (u *SmartUroboro) buildUroboroPrompt(entry UroboroEntry, analysis PromptAnalysis) string {
	switch analysis.ContentType {
	case "devlog":
		return u.buildDevlogPrompt(entry)
	case "blog":
		return u.buildBlogPrompt(entry)
	case "social":
		return u.buildSocialPrompt(entry)
	default:
		return u.buildGeneralPrompt(entry)
	}
}

// buildDevlogPrompt creates prompts for development log entries
func (u *SmartUroboro) buildDevlogPrompt(entry UroboroEntry) string {
	return fmt.Sprintf(`Create a professional development log entry based on this work capture:

WORK CAPTURE:
%s

Generate a detailed devlog entry that includes:
- What was accomplished
- Technical details and decisions made
- Challenges encountered and solutions
- Next steps or follow-up items
- Any learning or insights gained

Format as markdown with clear sections. Be technical but readable.
Focus on the engineering aspects and development process.`, entry.Content)
}

// buildBlogPrompt creates prompts for blog post content
func (u *SmartUroboro) buildBlogPrompt(entry UroboroEntry) string {
	return fmt.Sprintf(`Transform this work capture into engaging blog post content:

WORK CAPTURE:
%s

Create a well-structured blog post that:
- Has an engaging introduction
- Explains the context and motivation
- Describes the technical approach or solution
- Includes practical insights and lessons learned
- Concludes with takeaways for readers

Write in a conversational but professional tone.
Make it accessible to both technical and non-technical readers.
Use markdown formatting with headers, code blocks if relevant, and bullet points.`, entry.Content)
}

// buildSocialPrompt creates prompts for social media content
func (u *SmartUroboro) buildSocialPrompt(entry UroboroEntry) string {
	return fmt.Sprintf(`Create engaging social media content based on this work:

WORK CAPTURE:
%s

Generate social media posts (provide 2-3 variations):
- Keep each post concise and engaging
- Highlight the most interesting or valuable aspect
- Use appropriate hashtags
- Make it shareable and relatable
- Include a call to action or question when appropriate

Format as separate posts, clearly labeled as "Option 1:", "Option 2:", etc.
Optimize for platforms like Twitter, LinkedIn, or general social sharing.`, entry.Content)
}

// buildGeneralPrompt creates general enhancement prompts
func (u *SmartUroboro) buildGeneralPrompt(entry UroboroEntry) string {
	return fmt.Sprintf(`Enhance and structure this work capture into clear, professional documentation:

WORK CAPTURE:
%s

Improve the content by:
- Organizing information clearly
- Adding context where needed
- Correcting any grammar or clarity issues
- Structuring with appropriate headings
- Making it more readable and professional

Maintain the original meaning and tone while making it more polished.
Use markdown formatting for better readability.`, entry.Content)
}

// queryOllama executes a query using Ollama
func (u *SmartUroboro) queryOllama(model, prompt string) (string, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 90*time.Second)
	defer cancel()

	cmd := exec.CommandContext(ctx, "ollama", "run", model)
	cmd.Stdin = strings.NewReader(prompt)

	output, err := cmd.Output()
	if err != nil {
		return "", fmt.Errorf("ollama error: %v", err)
	}

	return strings.TrimSpace(string(output)), nil
}

// queryLocalAI executes a query using LocalAI
func (u *SmartUroboro) queryLocalAI(model, prompt string) (string, error) {
	requestBody := map[string]interface{}{
		"model": model,
		"messages": []map[string]string{
			{"role": "user", "content": prompt},
		},
		"stream": false,
	}

	jsonBody, err := json.Marshal(requestBody)
	if err != nil {
		return "", fmt.Errorf("failed to marshal request: %v", err)
	}

	ctx, cancel := context.WithTimeout(context.Background(), 90*time.Second)
	defer cancel()

	req, err := http.NewRequestWithContext(ctx, "POST", u.localAIEndpoint+"/v1/chat/completions", bytes.NewBuffer(jsonBody))
	if err != nil {
		return "", fmt.Errorf("failed to create request: %v", err)
	}

	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return "", fmt.Errorf("localai request error: %v", err)
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", fmt.Errorf("failed to read response: %v", err)
	}

	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("HTTP %d: %s", resp.StatusCode, string(body))
	}

	var response struct {
		Choices []struct {
			Message struct {
				Content string `json:"content"`
			} `json:"message"`
		} `json:"choices"`
	}

	if err := json.Unmarshal(body, &response); err != nil {
		return "", fmt.Errorf("failed to parse response: %v", err)
	}

	if len(response.Choices) == 0 {
		return "", fmt.Errorf("no response choices returned")
	}

	return strings.TrimSpace(response.Choices[0].Message.Content), nil
}

// isOllamaModelAvailable checks if a model is available in Ollama
func (u *SmartUroboro) isOllamaModelAvailable(model string) bool {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	cmd := exec.CommandContext(ctx, "ollama", "list")
	output, err := cmd.Output()
	if err != nil {
		return false
	}

	return strings.Contains(string(output), strings.Split(model, ":")[0])
}

// containsWord checks if a word exists in a slice
func (u *SmartUroboro) containsWord(slice []string, word string) bool {
	for _, s := range slice {
		if s == word {
			return true
		}
	}
	return false
}

// printUroboroExplanation shows the routing decision for uroboro content
func (u *SmartUroboro) printUroboroExplanation(analysis PromptAnalysis, target AITarget, entry UroboroEntry) {
	fmt.Println("🧠 Uroboro Smart Routing Analysis:")
	fmt.Printf("   Content Type: %s\n", analysis.ContentType)
	fmt.Printf("   Complexity: %s\n", analysis.Complexity)
	fmt.Printf("   Urgency: %s\n", analysis.Urgency)
	fmt.Printf("   Confidence: %.1f%%\n", analysis.Confidence*100)

	fmt.Println("\n🎯 AI Selection:")
	fmt.Printf("   Backend: %s\n", target.Backend)
	fmt.Printf("   Model: %s\n", target.Model)
	fmt.Printf("   Reason: %s\n", target.Reason)
	fmt.Printf("   Estimated Cost: $%.4f\n", target.EstimatedCost)
	fmt.Printf("   Estimated Time: %v\n", target.EstimatedTime)

	fmt.Println("\n📝 Content Preview:")
	contentPreview := entry.Content
	if len(contentPreview) > 100 {
		contentPreview = contentPreview[:100] + "..."
	}
	fmt.Printf("   \"%s\"\n", contentPreview)
	fmt.Println()
}

// CLI interface functions
func showHelp() {
	fmt.Println(`🚀 Uroboro Smart AI - Intelligent work documentation with AI enhancement

USAGE:
    uroboro-smart [COMMAND] [OPTIONS]

COMMANDS:
    capture <content>     Capture work and generate enhanced documentation
    devlog <content>      Generate development log entry
    blog <content>        Generate blog post content
    social <content>      Generate social media content
    enhance <content>     General content enhancement

OPTIONS:
    --explain            Show AI routing decisions
    --type <type>        Force content type (devlog, blog, social)
    --interactive        Interactive mode
    --help, -h           Show this help

EXAMPLES:
    uroboro-smart capture "Fixed authentication bug in user service"
    uroboro-smart devlog "Implemented new caching layer" --explain
    uroboro-smart blog "Lessons learned from microservice migration"
    uroboro-smart social "Just launched our new API!" --explain

INTERACTIVE MODE:
    uroboro-smart --interactive
    # Then enter content interactively with guided prompts`)
}

func runInteractiveMode() {
	u := NewSmartUroboro()
	scanner := bufio.NewScanner(os.Stdin)

	fmt.Println("🚀 Uroboro Smart AI - Interactive Mode")
	fmt.Println("Enter your work content, and I'll help you create enhanced documentation.")
	fmt.Println("Commands: 'explain on/off', 'type <devlog|blog|social>', 'quit'")
	fmt.Println()

	explain := false
	contentType := ""

	for {
		fmt.Print("uroboro> ")
		if !scanner.Scan() {
			break
		}

		input := strings.TrimSpace(scanner.Text())
		if input == "" {
			continue
		}

		switch {
		case input == "quit" || input == "exit":
			fmt.Println("👋 Goodbye!")
			return
		case input == "explain on":
			explain = true
			fmt.Println("🔍 Explanation mode enabled")
			continue
		case input == "explain off":
			explain = false
			fmt.Println("🔇 Explanation mode disabled")
			continue
		case strings.HasPrefix(input, "type "):
			contentType = strings.TrimSpace(strings.TrimPrefix(input, "type "))
			fmt.Printf("📝 Content type set to: %s\n", contentType)
			continue
		case input == "help":
			fmt.Println("Commands: 'explain on/off', 'type <devlog|blog|social>', 'quit'")
			fmt.Println("Or enter your work content to enhance")
			continue
		}

		entry := UroboroEntry{
			Timestamp: time.Now(),
			Type:      contentType,
			Content:   input,
		}

		enhanced, err := u.GenerateContent(entry, explain)
		if err != nil {
			fmt.Printf("❌ Error: %v\n", err)
			continue
		}

		fmt.Printf("✅ Enhanced Content (%s/%s):\n", enhanced.Backend, enhanced.Model)
		fmt.Println(strings.Repeat("-", 60))
		fmt.Println(enhanced.AIGenerated)
		fmt.Println(strings.Repeat("-", 60))
		fmt.Println()
	}
}

func main() {
	if len(os.Args) < 2 {
		showHelp()
		return
	}

	// Parse flags
	args := os.Args[1:]
	explain := false
	contentType := ""
	interactive := false

	// Process flags
	var filteredArgs []string
	for i, arg := range args {
		switch arg {
		case "--explain":
			explain = true
		case "--type":
			if i+1 < len(args) {
				contentType = args[i+1]
			}
		case "--interactive":
			interactive = true
		case "--help", "-h":
			showHelp()
			return
		default:
			if i == 0 || args[i-1] != "--type" {
				filteredArgs = append(filteredArgs, arg)
			}
		}
	}

	if interactive {
		runInteractiveMode()
		return
	}

	if len(filteredArgs) < 2 {
		fmt.Println("Error: Please provide command and content")
		showHelp()
		return
	}

	command := filteredArgs[0]
	content := strings.Join(filteredArgs[1:], " ")

	// Map commands to content types
	switch command {
	case "devlog":
		contentType = "devlog"
	case "blog":
		contentType = "blog"
	case "social":
		contentType = "social"
	case "capture", "enhance":
		// Use analyzed content type
	default:
		fmt.Printf("Unknown command: %s\n", command)
		showHelp()
		return
	}

	u := NewSmartUroboro()
	entry := UroboroEntry{
		Timestamp: time.Now(),
		Type:      contentType,
		Content:   content,
	}

	enhanced, err := u.GenerateContent(entry, explain)
	if err != nil {
		fmt.Printf("Error: %v\n", err)
		os.Exit(1)
	}

	fmt.Println(enhanced.AIGenerated)
}
