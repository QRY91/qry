#!/usr/bin/env python3
"""
QR Code Generator Demo Script

This script demonstrates various QR code generation examples,
perfect for understanding how to integrate QR codes into your logo/branding.
"""

import os
import sys
from pathlib import Path

# Add the scripts directory to path so we can import our QR generator
script_dir = Path(__file__).parent
sys.path.insert(0, str(script_dir))

try:
    from qr_generator import QRGenerator, print_size_guide
except ImportError:
    print("Error: Could not import QR generator. Make sure qr_generator.py is in the same directory.")
    sys.exit(1)

def demo_basic_qr_codes():
    """Generate basic QR codes in different sizes"""
    print("=" * 50)
    print("DEMO 1: Basic QR Codes in Different Sizes")
    print("=" * 50)

    generator = QRGenerator()
    demo_url = "https://your-website.com"

    sizes = [150, 200, 300, 400, 500]

    for size in sizes:
        print(f"\nGenerating {size}x{size}px QR code...")
        img = generator.generate_basic_qr(demo_url, size=size)
        filename = f"demo_basic_{size}px.png"
        generator.save_image(img, filename)

        # Print technical info
        info = generator.get_qr_info()
        print(f"  Version: {info['version']}, Modules: {info['modules_count']}")

def demo_error_correction_levels():
    """Show different error correction levels"""
    print("\n" + "=" * 50)
    print("DEMO 2: Error Correction Levels (for Logo Integration)")
    print("=" * 50)

    generator = QRGenerator()
    demo_url = "https://your-logo-website.com"

    levels = ['L', 'M', 'Q', 'H']
    descriptions = {
        'L': 'Low (~7%) - Clean environments',
        'M': 'Medium (~15%) - Default balance',
        'Q': 'Quartile (~25%) - Print materials',
        'H': 'High (~30%) - Best for logo overlay'
    }

    for level in levels:
        print(f"\nGenerating QR with error correction {level}: {descriptions[level]}")
        img = generator.generate_basic_qr(
            demo_url,
            size=300,
            error_correction=level
        )
        filename = f"demo_error_correction_{level}.png"
        generator.save_image(img, filename)

def demo_styled_qr_codes():
    """Generate styled QR codes"""
    print("\n" + "=" * 50)
    print("DEMO 3: Styled QR Codes")
    print("=" * 50)

    generator = QRGenerator()
    demo_url = "https://stylish-brand.com"

    styles = ['square', 'rounded', 'circle']

    for style in styles:
        print(f"\nGenerating {style} style QR code...")
        img = generator.generate_styled_qr(
            demo_url,
            size=300,
            style=style,
            error_correction='H'  # High error correction for better logo integration
        )
        filename = f"demo_style_{style}.png"
        generator.save_image(img, filename)

def demo_logo_ready_qr():
    """Generate QR codes optimized for logo integration"""
    print("\n" + "=" * 50)
    print("DEMO 4: Logo-Ready QR Codes")
    print("=" * 50)

    generator = QRGenerator()
    demo_url = "https://viral-marketing.com"

    # Create QR codes specifically optimized for logo integration
    configs = [
        {'size': 200, 'name': 'small_logo'},
        {'size': 300, 'name': 'medium_logo'},
        {'size': 400, 'name': 'large_logo'},
        {'size': 500, 'name': 'poster_logo'}
    ]

    for config in configs:
        print(f"\nGenerating logo-ready QR ({config['size']}px)...")
        img = generator.generate_styled_qr(
            demo_url,
            size=config['size'],
            style='rounded',  # Rounded looks good with logos
            error_correction='H',  # Maximum error correction for logo overlay
            border=6  # Extra border for better logo integration
        )
        filename = f"demo_{config['name']}_ready.png"
        generator.save_image(img, filename)

        print(f"  💡 This QR code can have up to 30% covered by your logo")
        print(f"  💡 Recommended logo size: {int(config['size'] * 0.3)}px square")

def print_viral_marketing_tips():
    """Print tips for viral marketing with QR codes"""
    tips = """
🚀 VIRAL MARKETING TIPS WITH QR CODES IN LOGOS
==============================================

INTEGRATION STRATEGIES:
✓ Place QR code in a natural square element of your logo
✓ Use high error correction (H level) to allow logo overlay
✓ Maintain good contrast - black QR on white background works best
✓ Test scanning from various distances and lighting conditions

DYNAMIC CONTENT IDEAS:
• Link to different content based on campaigns
• Seasonal promotions or limited-time offers
• Behind-the-scenes content or exclusive access
• Social media profiles or hashtag campaigns
• Product launches or event announcements
• Customer feedback or survey forms

SIZE RECOMMENDATIONS BY USE CASE:
• Business cards: 200-300px (print at 0.8-1 inch)
• Flyers/brochures: 300-400px (print at 1-1.5 inches)
• Posters/banners: 400-600px (print at 2-3 inches)
• Digital displays: 300-500px
• Social media posts: 400-600px

TESTING CHECKLIST:
□ Test with multiple phone types (iPhone, Android)
□ Test in different lighting conditions
□ Test from various scanning distances (6 inches to 3 feet)
□ Verify URL redirect works correctly
□ Check analytics/tracking is working
□ Test printed versions match digital versions

BRANDING CONSISTENCY:
• Keep your brand colors in the logo portion
• Use QR code as a functional design element
• Consider animated versions for digital use
• Create templates for different campaign types
• Maintain the same QR placement across materials
    """
    print(tips)

def main():
    """Run all QR code demos"""
    print("QR CODE GENERATOR DEMO")
    print("Perfect for Logo Integration & Viral Marketing")
    print("=" * 50)

    # Create output directory for demos
    os.makedirs("qr_demos", exist_ok=True)
    os.chdir("qr_demos")

    try:
        # Run all demos
        demo_basic_qr_codes()
        demo_error_correction_levels()
        demo_styled_qr_codes()
        demo_logo_ready_qr()

        print("\n" + "=" * 50)
        print("ALL DEMOS COMPLETED!")
        print("=" * 50)
        print(f"Generated QR codes saved in: {os.getcwd()}")
        print("\nNext steps:")
        print("1. Test scan all generated QR codes with your phone")
        print("2. Choose the best size/style for your logo")
        print("3. Use image editing software to overlay your logo")
        print("4. Test the final design thoroughly")

        # Print marketing tips
        print_viral_marketing_tips()

        # Show size guide
        print("\n" + "=" * 50)
        print_size_guide()

    except Exception as e:
        print(f"Demo error: {e}")
        return 1

    return 0

if __name__ == '__main__':
    sys.exit(main())
