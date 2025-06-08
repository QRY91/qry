# Infrastructure Learning: Web Stack Fundamentals and DNS Troubleshooting

**Author**: QRY (Human) with Claude 3.5 Sonnet (AI)  
**Date**: June 7, 2025  
**Context**: Real-time learning session while setting up ai.qry.zone subdomain  
**Learning Gap**: Web infrastructure stack understanding  

---

## 🎯 The Learning Challenge

**Situation**: Needed to set up ai.qry.zone subdomain but discovered significant gaps in web infrastructure knowledge. Despite working on projects like Mileviewer, never had time to understand the foundational stack properly - "features first, infrastructure later."

**Time to learn systematically.**

## 🏗️ Web Infrastructure Stack: The Foundation

### **Layer 1: Domain Registrar (Ownership)**
- **What**: Legal ownership of the domain name
- **Example**: Porkbun owns qry.zone registration
- **Function**: Proves you have rights to the domain
- **Analogy**: Having the deed to your house

### **Layer 2: DNS Management (Directions)**
- **What**: Controls where the domain actually points
- **Options**: Porkbun, Cloudflare, Vercel, Route53, etc.
- **Function**: "When someone types qry.zone, send them to IP X.X.X.X"
- **Analogy**: GPS directions to your house

### **Layer 3: Hosting (The Actual Building)**
- **What**: Server that stores and serves your website files
- **Options**: Vercel, Netlify, GitHub Pages, Cloudflare Pages
- **Function**: Stores index.html, CSS, JS and serves them to visitors
- **Analogy**: The actual house/building at the address

### **Layer 4: CDN/Analytics (Optional Services)**
- **What**: Additional services layered on top
- **Example**: Cloudflare caching, analytics, security
- **Function**: Sits between users and hosting, adds features
- **Analogy**: Security system, smart doorbell, package delivery

## 🎯 Our Specific Challenge: Subdomain Architecture

**Goal**: Set up multiple subdomains with different hosting:
- `qry.zone` → Vercel (main site)
- `ai.qry.zone` → GitHub Pages (AI collaboration content)
- `labs.qry.zone` → Future hosting (developer tools)
- `arcade.qry.zone` → Future hosting (educational games)

**Problem**: DNS management was controlled by Vercel nameservers, limiting flexibility.

## 🔧 The Systematic Solution Process

### **Step 1: Identify the Constraint**
- Vercel nameservers only allowed basic DNS management
- Couldn't easily point subdomains to different hosting providers
- Limited to Vercel's DNS capabilities

### **Step 2: Evaluate Options**
**Option A**: Create separate Vercel projects for each subdomain
- Pro: Simple within Vercel ecosystem
- Con: Vendor lock-in, increased complexity

**Option B**: Move DNS to Cloudflare
- Pro: Full control, can point subdomains anywhere
- Con: Additional configuration complexity

**Option C**: Use Porkbun DNS
- Pro: Single vendor, simple
- Con: Limited advanced features

**Decision**: Option B (Cloudflare) for maximum flexibility and control.

### **Step 3: Implementation**
1. **Add qry.zone to Cloudflare** (automatically scanned existing records)
2. **Configure DNS records** for current setup + new subdomains
3. **Update nameservers** at Porkbun to point to Cloudflare
4. **Set up subdomain routing** to different hosting providers

## 🐛 Troubleshooting: The Real Learning

### **Problem 1: 404 NOT_FOUND from Vercel**
**Symptom**: ai.qry.zone showing Vercel 404 instead of GitHub Pages
**Cause**: Wildcard A records (`*`) catching all subdomains and routing to Vercel
**Solution**: Delete wildcard records to allow specific CNAME to work

### **Problem 2: GitHub Pages "Improperly Configured" Error**
**Symptom**: GitHub couldn't verify custom domain setup
**Error**: "Your site's DNS settings are using a custom subdomain, ai.qry.zone, that is set up as an A record. We recommend you change this to a CNAME record"
**Cause**: Cloudflare "Proxied" setting converts CNAME to A record
**Solution**: Change CNAME from "Proxied" (orange cloud) to "DNS only" (gray cloud)

### **Problem 3: DNS Propagation Delays**
**Symptom**: Changes not reflecting immediately in DNS queries
**Cause**: Normal DNS propagation time (5 minutes to 48 hours)
**Learning**: DNS changes aren't instant, patience required

## 🧠 Key Insights from Systematic Learning

### **Infrastructure Hierarchy Matters**
Understanding the stack layers helps troubleshoot problems:
- Domain ownership (Porkbun) ≠ DNS management (Cloudflare) ≠ Hosting (multiple providers)
- Each layer can be managed independently
- Problems often stem from misalignment between layers

### **Vendor Lock-in vs. Flexibility Trade-offs**
- **Simple**: Single vendor (Vercel) handles everything
- **Flexible**: Multiple specialized vendors for each layer
- **Choice**: Depends on control needs vs. simplicity preference

### **DNS Record Types Have Specific Purposes**
- **A records**: Point to IP addresses
- **CNAME records**: Point to other domain names
- **Wildcard records** (`*`): Catch-all that can override specific records
- **Proxied vs. DNS only**: Changes how records appear to external services

### **Debugging Requires Layer-by-Layer Analysis**
1. **Check domain ownership**: Is it registered and controlled?
2. **Check DNS management**: Are nameservers pointing to correct provider?
3. **Check DNS records**: Are they configured correctly?
4. **Check hosting**: Is the service expecting the custom domain?
5. **Check propagation**: Have changes had time to spread?

## 🎯 Systematic Troubleshooting Framework

### **When Subdomains Don't Work:**
1. **`dig [subdomain]`** - What IP is it resolving to?
2. **`dig CNAME [subdomain]`** - Is the CNAME record visible?
3. **Check DNS provider interface** - Are records configured as expected?
4. **Check hosting provider** - Is custom domain set up on their end?
5. **Wait and test again** - DNS propagation takes time

### **Common Mistakes to Avoid:**
- **Wildcard records overriding specific records**
- **Proxied CNAMEs when hosting providers need direct access**
- **Not setting custom domain on hosting provider side**
- **Impatience with DNS propagation times**

## 🌟 AI Collaboration Learning Insights

### **How AI Helped This Learning Process:**
1. **Systematic explanation** of complex infrastructure concepts
2. **Real-time troubleshooting** support during problem-solving
3. **Pattern recognition** for common DNS/hosting issues
4. **Documentation synthesis** of the learning process

### **Human Learning Patterns:**
- **Gap identification**: "I should learn what I'm doing"
- **Systematic approach**: Understanding layers rather than random fixes
- **Real-world application**: Learning while solving actual problems
- **Documentation**: Capturing insights for future reference and community benefit

### **Effective Learning Collaboration:**
- AI provided technical explanation and troubleshooting guidance
- Human made decisions and executed changes
- Both contributed to systematic documentation of the process
- Learning happened through practical application, not just theory

## 🔄 Future Applications

### **This Infrastructure Knowledge Enables:**
- **Flexible subdomain architecture** for QRY ecosystem expansion
- **Vendor-agnostic hosting** - can choose best service for each subdomain
- **Troubleshooting confidence** when DNS issues arise
- **Systematic approach** to infrastructure decisions

### **Next Infrastructure Learning Goals:**
- **HTTPS/SSL certificate management** across multiple subdomains
- **Performance optimization** with CDN configuration
- **Monitoring and alerting** for infrastructure health
- **Backup and disaster recovery** planning

### **Transferable Methodology:**
This systematic approach to infrastructure learning applies to:
- **Database management** (connection, scaling, backup)
- **CI/CD pipeline** setup and troubleshooting
- **Security configuration** (authentication, authorization, encryption)
- **Performance monitoring** and optimization

## 📋 Practical Checklist for Others

### **Setting Up Custom Subdomains:**
- [ ] Identify current DNS management provider
- [ ] Evaluate if current provider supports your subdomain needs
- [ ] If needed, transfer DNS management to more flexible provider
- [ ] Configure DNS records (CNAME for subdomains)
- [ ] Set custom domain on hosting provider
- [ ] Test and wait for propagation
- [ ] Document configuration for future reference

### **Troubleshooting DNS Issues:**
- [ ] Use `dig` to verify DNS resolution
- [ ] Check for conflicting wildcard records
- [ ] Verify hosting provider custom domain setup
- [ ] Consider proxied vs. DNS-only settings
- [ ] Allow time for propagation
- [ ] Document solutions for future problems

## 🎭 Meta-Learning: The Real Value

**This wasn't just about setting up ai.qry.zone** - it was about developing systematic approaches to unfamiliar technical challenges.

**Key meta-insights:**
- **Infrastructure knowledge gaps are normal** - even experienced developers haven't learned everything
- **Systematic learning during real problems** is more effective than theoretical study
- **Documentation while learning** helps others and reinforces understanding
- **AI collaboration** can accelerate learning without replacing human judgment
- **Taking time to understand fundamentals** pays off in future troubleshooting

**The infrastructure is now more robust, flexible, and understandable because we took time to learn systematically rather than just applying quick fixes.**

---

## 📝 Attribution & Methodology

**Human Contribution**: QRY identified knowledge gaps, made infrastructure decisions, executed changes, and provided real-world context for learning

**AI Contribution**: Claude 3.5 Sonnet provided systematic explanations, troubleshooting guidance, and helped organize learning insights into transferable methodology

**Collaborative Value**: Demonstrates systematic approach to learning complex technical concepts through practical application with AI assistance

**Community Benefit**: Others can use this framework for their own infrastructure learning and troubleshooting

---

*This document was collaboratively created during a real infrastructure learning session, demonstrating the QRY methodology of converting knowledge gaps into systematic understanding through practical application and thorough documentation.*