#!/usr/bin/env python3
"""
QR Code Generator Script

This script generates QR codes for URLs with customizable size and format options.
Perfect for integrating into logos or marketing materials.

Usage:
    python qr_generator.py "https://example.com" --size 300 --format png
    python qr_generator.py "https://example.com" --size 500 --border 2 --error-correction H
"""

import argparse
import sys
import os
from pathlib import Path

try:
    import qrcode
    from qrcode.image.styledpil import StyledPilImage
    from qrcode.image.styles.moduledrawers import RoundedModuleDrawer, SquareModuleDrawer, CircleModuleDrawer
    from PIL import Image, ImageDraw
except ImportError as e:
    print(f"Error: Required package not installed. Run: pip install qrcode[pil] Pillow")
    print(f"Missing: {e}")
    sys.exit(1)

class QRGenerator:
    """QR Code generator with customizable options"""

    # Error correction levels (affects data capacity vs damage resistance)
    ERROR_CORRECTION_LEVELS = {
        'L': qrcode.constants.ERROR_CORRECT_L,  # ~7% correction
        'M': qrcode.constants.ERROR_CORRECT_M,  # ~15% correction
        'Q': qrcode.constants.ERROR_CORRECT_Q,  # ~25% correction
        'H': qrcode.constants.ERROR_CORRECT_H   # ~30% correction
    }

    def __init__(self):
        self.qr = None

    def create_qr_code(self, data, error_correction='M', border=4, box_size=10):
        """
        Create QR code object with specified parameters

        Args:
            data (str): The data to encode (URL, text, etc.)
            error_correction (str): Error correction level ('L', 'M', 'Q', 'H')
            border (int): Size of the border (quiet zone) in boxes
            box_size (int): Size of each box in pixels
        """
        self.qr = qrcode.QRCode(
            version=1,  # Auto-size based on data
            error_correction=self.ERROR_CORRECTION_LEVELS[error_correction],
            border=border,
            box_size=box_size,
        )

        self.qr.add_data(data)
        self.qr.make(fit=True)

        return self.qr

    def generate_basic_qr(self, data, size=300, **kwargs):
        """Generate a basic black and white QR code"""
        # Calculate box_size to achieve target size
        self.create_qr_code(data, **kwargs)

        # Calculate optimal box size for target dimensions
        modules = self.qr.modules_count + (2 * self.qr.border)
        box_size = max(1, size // modules)

        # Recreate with calculated box size
        self.create_qr_code(data, box_size=box_size, **kwargs)

        img = self.qr.make_image(fill_color="black", back_color="white")

        # Resize to exact target size if needed
        if img.size[0] != size:
            img = img.resize((size, size), Image.Resampling.NEAREST)

        return img

    def generate_styled_qr(self, data, size=300, style='square', **kwargs):
        """Generate a styled QR code with different module shapes"""
        self.create_qr_code(data, **kwargs)

        # Calculate box size
        modules = self.qr.modules_count + (2 * self.qr.border)
        box_size = max(1, size // modules)

        # Recreate with calculated box size
        self.create_qr_code(data, box_size=box_size, **kwargs)

        # Choose module drawer style
        drawer_map = {
            'square': SquareModuleDrawer(),
            'rounded': RoundedModuleDrawer(),
            'circle': CircleModuleDrawer()
        }

        module_drawer = drawer_map.get(style, SquareModuleDrawer())

        img = self.qr.make_image(
            image_factory=StyledPilImage,
            module_drawer=module_drawer,
            fill_color="black",
            back_color="white"
        )

        # Resize to exact target size if needed
        if img.size[0] != size:
            img = img.resize((size, size), Image.Resampling.NEAREST)

        return img

    def save_image(self, img, output_path, format='PNG'):
        """Save the QR code image"""
        img.save(output_path, format=format.upper())
        print(f"QR code saved to: {output_path}")
        print(f"Image size: {img.size[0]}x{img.size[1]} pixels")

    def get_qr_info(self):
        """Get information about the generated QR code"""
        if not self.qr:
            return "No QR code generated yet"

        info = {
            'version': self.qr.version,
            'error_correction': self.qr.error_correction,
            'border': self.qr.border,
            'box_size': self.qr.box_size,
            'modules_count': self.qr.modules_count,
            'data_capacity': self.qr.data_cache
        }
        return info

def print_size_guide():
    """Print information about QR code sizes and scannability"""
    guide = """
QR CODE SIZE GUIDE FOR OPTIMAL SCANNABILITY
==========================================

MINIMUM SIZES (for reliable scanning):
- Business cards: 0.8" x 0.8" (20mm x 20mm)
- Flyers/posters: 1" x 1" (25mm x 25mm)
- Digital displays: 150px x 150px minimum

RECOMMENDED SIZES:
- Print materials: 1-2 inches (25-50mm)
- Digital use: 200-400px
- Large format (posters): 2-4 inches (50-100mm)

SCANNING DISTANCE FORMULA:
QR code size should be at least 1/10th of the scanning distance
- Scan from 10 inches away → QR code should be 1" minimum
- Scan from 3 feet away → QR code should be 3.6" minimum

ERROR CORRECTION LEVELS:
- L (Low): ~7% - Use for clean environments, larger data capacity
- M (Medium): ~15% - Default, good balance
- Q (Quartile): ~25% - Better for printed materials
- H (High): ~30% - Best for damaged/dirty environments, logos

LOGO INTEGRATION TIPS:
- Use error correction level H when overlaying logos
- Logo should cover no more than 30% of QR code area
- Place logo in center for best results
- Test thoroughly after logo integration
- Consider using white border around logo for better contrast

FACTORS AFFECTING SCANNABILITY:
✓ Sufficient contrast (black on white is best)
✓ Adequate quiet zone (white border around QR code)
✓ Proper lighting when scanning
✓ Stable camera/phone position
✓ Clean, undamaged QR code
✗ Too small for scanning distance
✗ Poor contrast or color choices
✗ Damaged or obscured areas
✗ Insufficient quiet zone
    """
    print(guide)

def main():
    parser = argparse.ArgumentParser(
        description='Generate QR codes for URLs with customizable options',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s "https://example.com"
  %(prog)s "https://example.com" --size 400 --format PNG
  %(prog)s "https://example.com" --size 300 --error-correction H --border 2
  %(prog)s "https://example.com" --style rounded --output my_qr.png
  %(prog)s --size-guide
        """
    )

    parser.add_argument('url', nargs='?', help='URL to encode in QR code')
    parser.add_argument('--size', type=int, default=300,
                       help='Output image size in pixels (default: 300)')
    parser.add_argument('--format', choices=['PNG', 'JPEG', 'SVG'], default='PNG',
                       help='Output format (default: PNG)')
    parser.add_argument('--error-correction', choices=['L', 'M', 'Q', 'H'], default='M',
                       help='Error correction level (default: M)')
    parser.add_argument('--border', type=int, default=4,
                       help='Border size in modules (default: 4)')
    parser.add_argument('--style', choices=['square', 'rounded', 'circle'], default='square',
                       help='QR code module style (default: square)')
    parser.add_argument('--output', '-o', help='Output filename (auto-generated if not specified)')
    parser.add_argument('--size-guide', action='store_true',
                       help='Show size guide and scannability information')
    parser.add_argument('--info', action='store_true',
                       help='Show QR code technical information')

    args = parser.parse_args()

    if args.size_guide:
        print_size_guide()
        return

    if not args.url:
        parser.print_help()
        print("\nError: URL is required (or use --size-guide for information)")
        return

    # Validate URL format
    if not (args.url.startswith('http://') or args.url.startswith('https://')):
        print(f"Warning: URL doesn't start with http:// or https://")
        print(f"Adding https:// prefix...")
        args.url = 'https://' + args.url

    # Generate output filename if not specified
    if not args.output:
        safe_url = args.url.replace('://', '_').replace('/', '_').replace('?', '_').replace('&', '_')[:50]
        args.output = f"qr_{safe_url}_{args.size}px.{args.format.lower()}"

    # Create QR generator
    generator = QRGenerator()

    try:
        print(f"Generating QR code for: {args.url}")
        print(f"Size: {args.size}x{args.size} pixels")
        print(f"Error correction: {args.error_correction}")
        print(f"Style: {args.style}")

        # Generate QR code
        if args.style == 'square':
            img = generator.generate_basic_qr(
                args.url,
                size=args.size,
                error_correction=args.error_correction,
                border=args.border
            )
        else:
            img = generator.generate_styled_qr(
                args.url,
                size=args.size,
                style=args.style,
                error_correction=args.error_correction,
                border=args.border
            )

        # Save the image
        generator.save_image(img, args.output, args.format)

        # Show technical info if requested
        if args.info:
            info = generator.get_qr_info()
            print("\nQR Code Information:")
            for key, value in info.items():
                print(f"  {key}: {value}")

        print(f"\n✓ QR code generated successfully!")
        print(f"Test it by scanning with your phone's camera app.")

    except Exception as e:
        print(f"Error generating QR code: {e}")
        sys.exit(1)

if __name__ == '__main__':
    main()
