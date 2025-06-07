# Current Context: QRY Labs Guerrilla Marketing Campaign

## Where We Left Off

**Working on:** Sticker design for campus guerrilla marketing campaign during finals week

**Core Concept:** 
- QRY Labs logo that looks like QR code from distance
- "(wanna play?)" text in center
- Actual QR code in bottom-right corner redirecting to `labs.qry.zone`
- Chaotic engineer in grey jumpsuit placing flyers/stickers on bulletin boards

## What's Been Planned

### ✅ **Completed:**
- **Vision document** (`qry_computing_vision.md` → now QRY Labs)
- **Campaign strategy** documented in `guerrilla_marketing_design.md`
- **Design specifications** (3"x3" or 4"x4" stickers, matte finish, removable adhesive)
- **Risk management** (bulletin boards only, respectful placement, admin considerations)
- **Success metrics** (50+ QR scans, 25+ Quantum Dice players, zero complaints)

### 🔄 **In Progress:**
- **Domain setup** for `labs.qry.zone` (user owns qry.zone, setting up subdomain)
- **Landing page** creation (simple, mobile-optimized, clear call-to-action)

### ⏳ **Next Steps:**
1. **Generate QR code** for labs.qry.zone (high error correction, SVG + PNG)
2. **Create sticker design mockup** (Figma/Illustrator/Inkscape)
3. **Test design** at various distances (QR code illusion effect)
4. **Print test batch** (10-20 stickers)
5. **Deploy during finals week** with systematic measurement

## Key Files:
- **`guerrilla_marketing_design.md`** - Complete campaign plan
- **`qry_computing_vision.md`** - QRY Labs foundational vision

## Campaign Goals:
- **Validate QRY Labs concept** through real user engagement
- **Get feedback** on Quantum Dice prototype  
- **Build campus recognition** for QRY Labs brand
- **Generate content** for qryzone documentation
- **Demonstrate** systematic approach to creative marketing

## Technical Requirements:
- **`labs.qry.zone`** subdomain pointing to landing page
- **QR code** with 30% error correction
- **Analytics tracking** (UTM parameters for campaign measurement)
- **Mobile-responsive** landing page
- **Quantum Dice** ready for increased traffic

---

**Status:** Moving to `../qryzone` to set up subdomain and landing page infrastructure.

**Return Point:** Come back here to continue with QR code generation and sticker design once technical infrastructure is ready.

## Implementation Details to Complete in QRY Labs

### QR Code Generation
**Target URL:** `https://labs.qry.zone`

**QR Code Requirements:**
- **Size:** Small enough for corner placement, large enough to scan reliably
- **Error Correction:** High (30%) - accounts for potential damage/wear
- **Format:** SVG for scalability, PNG backup for printing
- **Color:** Black on white for maximum contrast

**Generation Tools:**
1. **qr-code-generator.com** - free, immediate, customizable
2. **Python qrcode library:** 
   ```python
   import qrcode
   qr = qrcode.QRCode(version=1, error_correction=qrcode.constants.ERROR_CORRECT_H, box_size=10, border=4)
   qr.add_data('https://labs.qry.zone')
   qr.make(fit=True)
   img = qr.make_image(fill_color="black", back_color="white")
   ```
3. **API approach** - programmable generation if needed

### Sticker Design Specifications

**Physical Requirements:**
- **Size:** 3"x3" or 4"x4" (visible from distance, fits bulletin boards)
- **Material:** Weather-resistant vinyl
- **Finish:** Matte (reduces glare)
- **Adhesive:** Removable (respectful)

**Print Specifications:**
- **Resolution:** 300 DPI minimum
- **Color Mode:** CMYK for printing
- **Bleed:** 0.125" around edges
- **File Formats:** PDF (print-ready), PNG (backup)

**Design Layout:**
```
┌─────────────────────────────────────┐
│  ██  ██████  ████                   │
│  ██  ██  ██  ██  ██                 │ QRY Labs Logo
│  ██  ██████  ████                   │ (looks like QR code)
│                                     │
│           (wanna play?)             │ Text (subtle)
│                                     │
│                               ┌───┐ │
│                               │QR │ │ Actual QR Code
│                               │   │ │ (functional)
│                               └───┘ │
└─────────────────────────────────────┘
```

**Design Tools:**
- **Figma** (free, browser-based, collaborative)
- **Canva** (templates available)
- **Inkscape** (free, vector-based)
- **Adobe Illustrator** (if available)

**Testing Requirements:**
- **Distance testing:** Logo looks like QR code from 10+ feet
- **Scan testing:** QR code works reliably at arm's length
- **Readability:** "(wanna play?)" readable at 2-3 feet
- **Print testing:** Actual size mockup before bulk printing

**Typography for "(wanna play?)":**
- **Font:** Clean, readable (Arial, Helvetica, or similar)
- **Size:** Large enough to read at 2-3 feet, small enough to be subtle
- **Color:** Black on white background
- **Position:** Centered vertically and horizontally

### Printing & Distribution

**Print Options:**
1. **Local print shop** - higher quality, immediate pickup
2. **Campus print services** - potentially free/cheap
3. **Online services** (Sticker Mule) - bulk pricing, mail delivery

**Distribution Strategy:**
- **Bulletin boards only** (respectful placement)
- **High-traffic areas:** Library, student union, academic buildings, cafeteria
- **Finals week timing** - stressed students want distraction
- **Early morning placement** - fresh visibility
- **Document engagement** - photos, analytics, feedback

**Backup Plans:**
- **Paper flyers** if stickers restricted
- **Different sizes** for various board types
- **Digital campaign** if physical placement limited
- **Social media** amplification of physical campaign

### Square Business Card Design

**Concept:** Unconventional square format that immediately signals "I think differently" - perfect for professional networking while maintaining QRY Labs aesthetic.

**Physical Specifications:**
- **Size:** 2.5"x2.5" or 3"x3" (square format)
- **Material Options:**
  - Standard cardstock (cost-effective)
  - Premium matte finish
  - Holographic/prismatic effects (premium option)
  - Pen plotter compatible paper (handmade variations)
- **Thickness:** 14pt minimum for durability

**Design Layout (Square Format):**
```
┌───────────────────────────────┐
│  ██  ██████  ████             │
│  ██  ██  ██  ██  ██           │ QRY Labs Logo
│  ██  ██████  ████             │ (QR illusion)
│                               │
│        Your Name              │ 
│   Software Developer          │ Contact Info
│   QRY Labs                    │
│                               │
│    labs.qry.zone         ┌──┐ │
│                          │QR│ │ Functional QR
│                          └──┘ │
└───────────────────────────────┘
```

**Pen Plotter Possibilities:**
- **Logo Variations:** Different geometric patterns that maintain QR-like appearance
- **Generative Designs:** Algorithm-created unique patterns for each card
- **Personal Touch:** Hand-plotted elements show craftsmanship
- **Limited Editions:** Special patterns for specific events/contexts
- **Interactive Elements:** QR codes that change based on when/where plotted

**Professional Context Advantages:**
- **Memorable:** Square format stands out in wallet/card holder
- **Conversation Starter:** "Interesting card" opens dialogue about thinking differently
- **Brand Consistency:** Same visual language as guerrilla marketing campaign
- **Quality Signal:** Shows attention to detail, willingness to invest in unique approach
- **Tech-Forward:** QR code integration shows comfort with modern tools

**Production Options:**
1. **Print Shop:** Bulk production, professional finish
2. **Online Printing:** Moo.com, Vistaprint (custom sizing available)
3. **Pen Plotter:** AxiDraw, personal touch, conversation piece
4. **Hybrid Approach:** Printed base + pen plotted accents

**Special Effects Considerations:**
- **Holographic:** Makes QR illusion even more striking, premium feel
- **Spot UV:** Selective glossy elements, subtle luxury
- **Embossing:** Tactile QR pattern, accessibility bonus
- **Foil Stamping:** Metallic accents, high-end presentation

**Pen Plotter Birthday Gift Strategy:**
- **Research Models:** AxiDraw series, pricing, capabilities
- **Software Ecosystem:** Compatible with Inkscape, custom scripts
- **Paper Options:** Various weights, textures, colors
- **Batch Production:** Create 50-100 unique variations
- **Documentation:** Process videos for social media content

**Usage Scenarios:**
- **Job Interviews:** Shows creativity, technical awareness
- **Networking Events:** Memorable, generates follow-up conversations
- **Conference Handouts:** Professional but distinctive
- **Client Meetings:** Demonstrates attention to detail, modern approach
- **Portfolio Presentations:** Physical artifact that reinforces digital presence

### Square Video Content Strategy

**Concept:** Maintain consistent square aesthetic across all media - business cards, stickers, and video content for unified brand experience.

**Square Video Advantages:**
- **Platform Agnostic:** Works equally well on Instagram, Twitter, LinkedIn, TikTok, YouTube Shorts
- **No Orientation Issues:** Portrait/landscape irrelevant - always looks intentional
- **Brand Consistency:** Same visual language as physical materials
- **Mobile Optimized:** Efficient screen real estate on phones
- **Attention Grabbing:** Unusual format stands out in feeds

**Content Types for Square Format:**
- **Code Walkthroughs:** Screen recordings with code centered in square frame
- **Hardware Demos:** Arduino, Flipper Zero projects with focused framing
- **Game Development:** Quantum Dice progress, mechanics explanations
- **Tool Showcases:** Uroboro, Examinator demonstrations
- **Educational Content:** Programming concepts, systematic thinking approaches
- **Behind-the-Scenes:** QRY Labs development process

**Technical Specifications:**
- **Resolution:** 1080x1080 (Instagram optimal) or 1200x1200
- **Frame Rate:** 30fps for smooth playback
- **Duration:** 15-60 seconds for maximum engagement
- **Export Formats:** MP4 (universal), WebM (web optimized)

**Production Workflow:**
1. **Record in 16:9** - capture full context
2. **Edit to 1:1** - creative cropping, zooming, repositioning
3. **Add QRY Labs branding** - subtle logo/watermark placement
4. **Consistent color palette** - match business card/sticker aesthetic
5. **Cross-platform distribution** - single edit, multiple deployments

**Content Framework:**
- **Hook (0-3s):** QR-like pattern transition or logo reveal
- **Content (3-45s):** Core educational/demo material
- **Call-to-Action (45-60s):** QR code appearance, labs.qry.zone reference
- **Consistent Outro:** Same ending pattern across all videos

**Platform-Specific Considerations:**
- **Instagram:** Stories, Reels, Feed posts
- **Twitter:** Native video, easy retweeting
- **LinkedIn:** Professional context, thought leadership
- **TikTok:** Educational/tech content audience
- **YouTube Shorts:** Discoverability, longer-form potential

**Brand Integration Opportunities:**
- **Logo Animations:** QR pattern morphing into actual logo
- **Transition Effects:** Square geometric patterns between scenes
- **Watermark Placement:** Corner QR code (like business cards)
- **Color Consistency:** Black/white primary, accent colors sparingly
- **Typography:** Same fonts as business cards/stickers

**Content Series Ideas:**
- **"Systematic Solutions"** - problem-solving approaches
- **"Hardware Hacks"** - Arduino/embedded projects
- **"Game Dev Diary"** - Quantum Dice development
- **"Tool Time"** - QRY Labs software demonstrations
- **"Educational Gaming"** - learning through play concepts

### Brand Philosophy: "Square Peg, Round Hole"

**Core Concept:** The square format isn't just design - it's identity. You ARE the square peg that doesn't fit conventional round holes, so you create your own square spaces.

**The Fundamental Challenge Question: "How do I fit in?"**

This is the essential tension that makes ANY challenge engaging - academic, personal, technical, recreational. When faced with a square peg and round hole, you have options:

1. **Try to fit?** (conformity - compromise your shape)
2. **Increase the hole?** (change the system - costly, resistance)  
3. **Downsize yourself?** (cut corners, literally - lose what makes you unique)
4. **Break through?** (force it - potentially destructive)
5. **Give up?** (acceptance/defeat - unsatisfying)
6. **Create a square hole?** (build new systems - the QRY Labs approach)

**Why This Resonates in Games:**
- Portal: How do I navigate impossible spaces? (Create new pathways)
- Zachtronics: How do I solve with these constraints? (Work within/around limitations)
- Tetris: How do I make this piece fit? (Strategic placement, line clearing)

**Your Professional Pattern:**
Instead of trying to fit existing molds, you consistently create better systems:
- **Startup context:** Built enterprise-grade solutions solo
- **Institutional trauma:** Transformed into systematic improvement tools
- **Career path:** Non-traditional route that leverages unique intersections
- **Technical approach:** Systematic solutions vs ad-hoc fixes

**Brand Power:**
Every square element becomes a conversation starter about this fundamental question. People immediately understand they're dealing with someone who doesn't just accept "that's how things are done."

**Metaphor Applications:**
- **Career Path:** Non-traditional route (call center → psychology → game design → programming)
- **Problem Solving:** Systematic approaches where others use ad-hoc solutions  
- **Design Choices:** Square formats in a world of rectangles and circles
- **Professional Identity:** Software developer who builds systematic solutions, not just code

**Tagline Variations:**
- **"QRY Labs: Square Peg, Round Hole"** (primary)
- **"Different Shape, Better Fit"**
- **"Why fit in when you can stand out?"**
- **"How do YOU fit in?"** (interactive/questioning)

**Visual Storytelling:**
- Square business cards in round card holders
- Square videos in rectangular feeds (but perfectly centered)
- Square stickers on round bulletin boards
- QR-like logo that looks like it should scan but doesn't (until you find the real QR code)

**Professional Narrative:**
Instead of apologizing for not fitting conventional molds, celebrate creating better solutions. The square format becomes a visual reminder that different approaches often work better - you just need the confidence to try them.

**Educational Game Design Connection:**
This tension - "How do I fit in?" - is exactly what makes learning games engaging. QRY Labs builds educational experiences around this fundamental challenge structure, helping others discover their own creative solutions to seemingly impossible constraints.

**Brand Consistency Message:**
Every square element reinforces the same idea: "I think differently, and that's exactly why you want to work with me." The format becomes the message. 