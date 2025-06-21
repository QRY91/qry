#!/usr/bin/env python3
"""
QRY Logo + QR Code Integration Generator

This script generates the complete QRY logo with QR codes embedded in the 2x2 square.
The QR code replaces positions [5][5], [5][6], [6][5], [6][6] in the 8x8 logo matrix.

Usage:
    python logo_qr_integration.py "https://qry.zone"
    python logo_qr_integration.py "https://qry.zone" --sizes 640,320,160
    python logo_qr_integration.py "https://qry.zone" --output-dir logos
"""

import argparse
import sys
import os
from pathlib import Path
import numpy as np

try:
    import qrcode
    from PIL import Image, ImageDraw
except ImportError as e:
    print(f"Error: Required packages not installed. Run:")
    print(f"pip install qrcode[pil] Pillow numpy")
    print(f"Missing: {e}")
    sys.exit(1)

# QRY Logo 8x8 matrix (from the provided files)
# 0 = black, 1 = white
QRY_LOGO_MATRIX = [
    [0,0,0,0,0,0,0,0],  # Row 0
    [0,1,1,1,1,1,1,0],  # Row 1
    [0,1,0,0,0,0,1,0],  # Row 2
    [0,1,0,0,0,0,1,0],  # Row 3
    [0,1,0,0,0,0,0,0],  # Row 4
    [0,1,0,0,0,1,1,0],  # Row 5 - positions [5] and [6] are the target square
    [0,1,1,1,0,1,1,0],  # Row 6 - positions [5] and [6] are the target square
    [0,0,0,0,0,0,0,0]   # Row 7
]

# Target positions for QR code integration (2x2 square)
QR_TARGET_POSITIONS = [(5, 5), (5, 6), (6, 5), (6, 6)]

# Default logo sizes (width x height in pixels)
DEFAULT_SIZES = [640, 320, 160, 80, 40]

class LogoQRGenerator:
    """Generator for QRY logos with integrated QR codes"""

    def __init__(self):
        self.logo_matrix = np.array(QRY_LOGO_MATRIX)
        self.base_size = 8  # 8x8 base logo

    def generate_qr_matrix(self, data, target_size):
        """Generate a QR code matrix scaled to fit target size"""
        # Create QR code with maximum error correction for reliability
        qr = qrcode.QRCode(
            version=1,  # Start small and auto-size
            error_correction=qrcode.constants.ERROR_CORRECT_H,  # High error correction
            border=0,   # No border - we'll handle positioning
        )

        qr.add_data(data)
        qr.make(fit=True)

        # Get the QR matrix
        qr_matrix = qr.get_matrix()
        qr_array = np.array(qr_matrix, dtype=int)

        # Resize QR code to target size using nearest neighbor
        if qr_array.shape[0] != target_size:
            # Calculate scaling factor
            scale_factor = target_size / qr_array.shape[0]

            # Create new array with target size
            scaled_qr = np.zeros((target_size, target_size), dtype=int)

            for i in range(target_size):
                for j in range(target_size):
                    # Map back to original coordinates
                    orig_i = int(i / scale_factor)
                    orig_j = int(j / scale_factor)

                    # Clamp to valid range
                    orig_i = min(orig_i, qr_array.shape[0] - 1)
                    orig_j = min(orig_j, qr_array.shape[1] - 1)

                    scaled_qr[i, j] = qr_array[orig_i, orig_j]

            qr_array = scaled_qr

        return qr_array

    def integrate_qr_into_logo(self, qr_data, final_size):
        """Create logo with QR code integrated into the 2x2 square"""
        # Calculate pixels per logo matrix cell
        pixels_per_cell = final_size // self.base_size

        # Calculate QR code size (2x2 logo cells = 2 * pixels_per_cell)
        qr_size = 2 * pixels_per_cell

        # Generate QR code matrix
        qr_matrix = self.generate_qr_matrix(qr_data, qr_size)

        # Create the full-size logo image
        logo_image = np.zeros((final_size, final_size), dtype=int)

        # Fill in the base logo pattern
        for row in range(self.base_size):
            for col in range(self.base_size):
                # Calculate pixel boundaries for this logo cell
                start_row = row * pixels_per_cell
                end_row = (row + 1) * pixels_per_cell
                start_col = col * pixels_per_cell
                end_col = (col + 1) * pixels_per_cell

                # Check if this is one of the QR target positions
                if (row, col) in QR_TARGET_POSITIONS:
                    # This cell will be replaced by QR code
                    # Calculate which part of the QR matrix to use
                    if (row, col) == (5, 5):  # Top-left of QR
                        qr_start_row, qr_end_row = 0, pixels_per_cell
                        qr_start_col, qr_end_col = 0, pixels_per_cell
                    elif (row, col) == (5, 6):  # Top-right of QR
                        qr_start_row, qr_end_row = 0, pixels_per_cell
                        qr_start_col, qr_end_col = pixels_per_cell, 2 * pixels_per_cell
                    elif (row, col) == (6, 5):  # Bottom-left of QR
                        qr_start_row, qr_end_row = pixels_per_cell, 2 * pixels_per_cell
                        qr_start_col, qr_end_col = 0, pixels_per_cell
                    elif (row, col) == (6, 6):  # Bottom-right of QR
                        qr_start_row, qr_end_row = pixels_per_cell, 2 * pixels_per_cell
                        qr_start_col, qr_end_col = pixels_per_cell, 2 * pixels_per_cell

                    # Extract the relevant QR section and place it
                    qr_section = qr_matrix[qr_start_row:qr_end_row, qr_start_col:qr_end_col]
                    logo_image[start_row:end_row, start_col:end_col] = qr_section
                else:
                    # Use the original logo pixel value
                    logo_pixel_value = self.logo_matrix[row, col]
                    logo_image[start_row:end_row, start_col:end_col] = logo_pixel_value

        return logo_image

    def matrix_to_pil_image(self, matrix, invert=False):
        """Convert numpy matrix to PIL Image"""
        if invert:
            # Invert the matrix first (0->1, 1->0)
            matrix = 1 - matrix

        # Convert to 0-255 range (0=black, 255=white)
        image_array = (matrix * 255).astype(np.uint8)

        # Convert to PIL Image
        image = Image.fromarray(image_array, mode='L')

        return image

    def generate_logo_set(self, qr_data, sizes=None, output_dir=".", prefix="qry_logo_qr"):
        """Generate a complete set of logos with integrated QR codes"""
        if sizes is None:
            sizes = DEFAULT_SIZES

        generated_files = []

        print(f"Generating QRY logos with QR code for: {qr_data}")
        print(f"Target sizes: {sizes}")
        print(f"QR code will replace the 2x2 white square in the logo")
        print(f"Generating both normal and inverted versions for color flexibility")
        print()

        for size in sizes:
            print(f"Generating {size}x{size} logos...")

            # Generate integrated logo matrix
            logo_matrix = self.integrate_qr_into_logo(qr_data, size)

            # Generate normal version
            normal_image = self.matrix_to_pil_image(logo_matrix, invert=False)
            normal_filename = f"{prefix}_{size}x{size}_normal.png"
            normal_filepath = os.path.join(output_dir, normal_filename)
            normal_image.save(normal_filepath, "PNG")
            generated_files.append(normal_filepath)
            print(f"  ✓ Normal: {normal_filepath}")

            # Generate inverted version
            inverted_image = self.matrix_to_pil_image(logo_matrix, invert=True)
            inverted_filename = f"{prefix}_{size}x{size}_inverted.png"
            inverted_filepath = os.path.join(output_dir, inverted_filename)
            inverted_image.save(inverted_filepath, "PNG")
            generated_files.append(inverted_filepath)
            print(f"  ✓ Inverted: {inverted_filepath}")

            # Print some stats
            qr_pixels = 2 * (size // 8)  # 2x2 cells in an 8x8 grid
            print(f"    Logo size: {size}x{size} pixels")
            print(f"    QR code area: {qr_pixels}x{qr_pixels} pixels")
            print(f"    Pixels per logo cell: {size // 8}")
            print()

        return generated_files

def print_usage_guide():
    """Print usage guide and viral marketing tips"""
    guide = """
QRY LOGO + QR CODE INTEGRATION GUIDE
===================================

WHAT THIS SCRIPT DOES:
• Takes your 8x8 QRY logo matrix
• Generates QR codes for your URLs
• Replaces the 2x2 white square with the QR code
• Outputs complete logos at multiple sizes

GENERATED SIZES (both normal and inverted):
• 640x640px - High-res printing, large displays
• 320x320px - Web use, social media profiles
• 160x160px - Business cards, small prints
• 80x80px   - Icons, thumbnails
• 40x40px   - Favicons, tiny displays

COLOR VERSIONS:
• Normal: Black logo on white background (original)
• Inverted: White logo on black background (for dark themes)

QR CODE PLACEMENT:
The QR code replaces positions [5][5], [5][6], [6][5], [6][6]
in your logo matrix - the 2x2 white square in the bottom-right.

VIRAL MARKETING APPLICATIONS:
• Business cards with scannable logos (choose color based on card)
• Poster campaigns with hidden QR codes (normal/inverted for any background)
• Social media profile images that link to campaigns (match platform themes)
• Merchandise with functional branding (works on light or dark materials)
• Event materials with instant engagement (flexible for any design context)

SCALING MATH:
• 640px logo: QR area is 160x160px (25% of logo)
• 320px logo: QR area is 80x80px (25% of logo)
• 160px logo: QR area is 40x40px (25% of logo)
• Perfect for scanning at typical distances

PRINT RECOMMENDATIONS:
• 640px: Print at 2-3 inches for posters/banners
• 320px: Print at 1-1.5 inches for flyers
• 160px: Print at 0.6-0.8 inches for business cards
• Test scan before mass printing!
    """
    print(guide)

def main():
    parser = argparse.ArgumentParser(
        description='Generate QRY logos with integrated QR codes',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s "https://qry.zone"
  %(prog)s "https://qry.zone" --sizes 640,320,160
  %(prog)s "https://qry.zone" --output-dir ./logos --prefix qry_viral
  %(prog)s --guide
        """
    )

    parser.add_argument('url', nargs='?', help='URL to encode in QR code')
    parser.add_argument('--sizes', type=str, default='640,320,160,80,40',
                       help='Comma-separated list of sizes (default: 640,320,160,80,40)')
    parser.add_argument('--output-dir', default='.',
                       help='Output directory (default: current directory)')
    parser.add_argument('--prefix', default='qry_logo_qr',
                       help='Output filename prefix (default: qry_logo_qr)')
    parser.add_argument('--guide', action='store_true',
                       help='Show usage guide and viral marketing tips')

    args = parser.parse_args()

    if args.guide:
        print_usage_guide()
        return

    if not args.url:
        parser.print_help()
        print("\nError: URL is required (or use --guide for information)")
        return

    # Validate URL format
    if not (args.url.startswith('http://') or args.url.startswith('https://')):
        print(f"Warning: URL doesn't start with http:// or https://")
        print(f"Adding https:// prefix...")
        args.url = 'https://' + args.url

    # Parse sizes
    try:
        sizes = [int(s.strip()) for s in args.sizes.split(',')]
        # Validate sizes are multiples of 8 for clean scaling
        invalid_sizes = [s for s in sizes if s % 8 != 0]
        if invalid_sizes:
            print(f"Warning: These sizes are not multiples of 8: {invalid_sizes}")
            print("This may result in imperfect pixel scaling.")
    except ValueError:
        print("Error: Invalid sizes format. Use comma-separated integers.")
        return

    # Create output directory
    os.makedirs(args.output_dir, exist_ok=True)

    # Generate logos
    generator = LogoQRGenerator()

    try:
        generated_files = generator.generate_logo_set(
            args.url,
            sizes=sizes,
            output_dir=args.output_dir,
            prefix=args.prefix
        )

        print("=" * 50)
        print("✓ LOGO GENERATION COMPLETE!")
        print("=" * 50)
        print(f"Generated {len(generated_files)} logo files:")
        for file in generated_files:
            print(f"  • {file}")

        print(f"\nQR Code URL: {args.url}")
        print(f"QR Code Location: Bottom-right 2x2 square of logo")
        print(f"Error Correction: High (30% damage resistance)")

        print(f"\nNEXT STEPS:")
        print(f"1. Test scan all generated logos with your phone")
        print(f"2. Choose appropriate sizes for your use cases")
        print(f"3. Deploy in your viral marketing campaign!")

    except Exception as e:
        print(f"Error generating logos: {e}")
        sys.exit(1)

if __name__ == '__main__':
    main()
