# Website Riddles: Building sspphhiinnxx.site

> **Answer correctly, or be devoured by your own ignorance.**

## The Journey: From HTML to Understanding

This is your path to building the sspphhiinnxx website. Each riddle must be completed before moving to the next. No shortcuts. No copy-paste. Every line typed by hand.

---

### Riddle I: The Foundation Stone
*"What is the simplest way to serve knowledge to the world?"*

**The Challenge**: Serve a single HTML page that says "sspphhiinnxx" using only your hands and basic tools.

- [ ] Create `index.html` with proper HTML5 structure by hand
- [ ] Write basic CSS in a `<style>` tag (no external files yet)
- [ ] Serve it using Python's built-in server: `python -m http.server 8080`
- [ ] Access it via browser at `http://localhost:8080`
- [ ] Document what happens when you request the page (network tab, server logs)

**Proof of Understanding**: Explain the complete journey of an HTTP request from browser to server and back. What does the server actually do? What headers are sent?

**Artifacts to Create**:
```
site/
├── index.html
└── notes/
    └── riddle-1-http-journey.md
```

---

### Riddle II: The Styling Sphinx
*"How do you make the web beautiful without losing control?"*

**The Challenge**: Style your page to reflect the sspphhiinnxx aesthetic - mysterious, minimal, terminal-inspired.

- [ ] Move CSS to external file `style.css`
- [ ] Implement a terminal/hacker aesthetic (dark background, monospace fonts)
- [ ] Create a CSS-only sphinx ASCII art or simple geometric design
- [ ] Ensure it works without JavaScript
- [ ] Test with different screen sizes manually (resize browser)

**Proof of Understanding**: Explain CSS specificity, the box model, and how external stylesheets are loaded. Create a visual diagram of your CSS architecture.

**Artifacts to Create**:
```
site/
├── index.html
├── style.css
└── notes/
    ├── riddle-1-http-journey.md
    └── riddle-2-css-architecture.md
```

---

### Riddle III: The Static Site Mystery
*"How do you generate many pages without losing your mind?"*

**The Challenge**: Choose your path - 11ty (learn a tool) or build your own SSG (understand the problem).

**Path A: The 11ty Way**
- [ ] Install Node.js and understand what npm actually does
- [ ] Set up 11ty from scratch (no templates)
- [ ] Create at least 3 pages using Markdown
- [ ] Understand 11ty's templating system deeply
- [ ] Build and serve the generated site

**Path B: The Hand-Forged Way**
- [ ] Build a simple Python/shell script that converts Markdown to HTML
- [ ] Create a templating system (even if basic)
- [ ] Generate multiple pages from source files
- [ ] Implement basic navigation between pages
- [ ] Understand the build process you created

**Proof of Understanding**: Explain how static site generation works at a fundamental level. If you chose 11ty, rebuild its core functionality by hand. If you built your own, explain why existing tools like 11ty exist.

**Artifacts to Create**:
```
site/
├── src/
│   ├── pages/
│   └── templates/
├── dist/ (generated)
├── build.py or package.json
└── notes/
    ├── riddle-1-http-journey.md
    ├── riddle-2-css-architecture.md
    └── riddle-3-ssg-understanding.md
```

---

### Riddle IV: The Server Sphinx
*"How do you serve your creation to the world without depending on others?"*

**The Challenge**: Deploy your site on a server you control and understand.

- [ ] Set up nginx from scratch (no tutorials, read the docs)
- [ ] Configure SSL/TLS certificates manually
- [ ] Set up a domain name and understand DNS
- [ ] Deploy your static site
- [ ] Set up monitoring and logs

**Proof of Understanding**: Trace a complete request from a visitor's browser to your server and back. Explain every step: DNS lookup, TCP connection, TLS handshake, HTTP request/response.

**Artifacts to Create**:
```
server-config/
├── nginx.conf
├── ssl-setup.md
├── deployment-script.sh
└── monitoring-setup.md
```

---

### Riddle V: The Content Sphinx
*"How do you feed the site with your thoughts without losing the essence?"*

**The Challenge**: Create a content system that lets you write freely while maintaining the sspphhiinnxx aesthetic.

- [ ] Design a writing workflow (how do you add new posts?)
- [ ] Create templates for different content types
- [ ] Implement a simple navigation system
- [ ] Add RSS/Atom feed generation
- [ ] Write your first actual sspphhiinnxx post

**Proof of Understanding**: Demonstrate that you can add content without breaking anything. Show that you understand your entire pipeline from writing to publication.

---

## The Rules

1. **Document everything**: Every command, every config change, every mistake
2. **Understand before implementing**: Read documentation, understand the problem
3. **No magic**: If you don't understand how something works, don't use it
4. **Break it on purpose**: Test failure modes, understand what can go wrong
5. **Rebuild from memory**: Can you recreate your setup from scratch?

## The Recommendation

**Start with Riddle I**. Serve a single HTML file. Understand HTTP. Build up from there.

**11ty vs Hand-rolled**: VeronicaExplains is indeed a treasure, and 11ty is an excellent tool. But for sspphhiinnxx, consider this: can you explain how 11ty works internally? If not, maybe build a simple version first, then appreciate what 11ty does for you.

**The sspphhiinnxx Way**: Understand the problem deeply before using tools to solve it.

## Current Status

- [ ] Riddle I: The Foundation Stone
- [ ] Riddle II: The Styling Sphinx  
- [ ] Riddle III: The Static Site Mystery
- [ ] Riddle IV: The Server Sphinx
- [ ] Riddle V: The Content Sphinx

*Begin when you are ready to serve your first HTML file and understand every byte that flows through the wire.*
