#!/bin/bash

# Script to fix Firefox white flash on page load
# This creates userChrome.css and userContent.css files with dark backgrounds

echo "Firefox Dark Background Fix"
echo "============================"
echo ""

# Find Firefox profile directory
FIREFOX_PROFILES_DIR="$HOME/.mozilla/firefox"

if [ ! -d "$FIREFOX_PROFILES_DIR" ]; then
    echo "Error: Firefox profile directory not found at $FIREFOX_PROFILES_DIR"
    exit 1
fi

# Find all profiles
profiles=($(ls -d "$FIREFOX_PROFILES_DIR"/*.default* "$FIREFOX_PROFILES_DIR"/*-release 2>/dev/null))

if [ ${#profiles[@]} -eq 0 ]; then
    echo "Error: No Firefox profiles found"
    exit 1
fi

echo "Found ${#profiles[@]} Firefox profile(s). Applying fix to all..."
echo ""

# Apply fix to all profiles
for PROFILE_DIR in "${profiles[@]}"; do
    echo "Applying fix to: $(basename "$PROFILE_DIR")"
    
    # Create chrome directory if it doesn't exist
    CHROME_DIR="$PROFILE_DIR/chrome"
    mkdir -p "$CHROME_DIR"

    # Backup existing files if they exist
    if [ -f "$CHROME_DIR/userChrome.css" ]; then
        cp "$CHROME_DIR/userChrome.css" "$CHROME_DIR/userChrome.css.backup.$(date +%s)"
    fi
    if [ -f "$CHROME_DIR/userContent.css" ]; then
        cp "$CHROME_DIR/userContent.css" "$CHROME_DIR/userContent.css.backup.$(date +%s)"
    fi

    # Create userChrome.css
    cat > "$CHROME_DIR/userChrome.css" << 'EOF'
/* Fix white flash on new tab and page load */
@-moz-document url(about:blank), url(about:newtab), url(about:home) {
    html, body {
        background-color: #89380f !important;
    }
}

/* Dark browser chrome */
browser {
    background-color: #89380f !important;
}

#main-window,
#browser,
#appcontent,
#tabbrowser-tabpanels,
.browserContainer {
    background-color: #89380f !important;
}
EOF

    # Create userContent.css
    cat > "$CHROME_DIR/userContent.css" << 'EOF'
/* Set dark background for all pages before they load */
@-moz-document url-prefix(http://), url-prefix(https://), url(about:blank) {
    html, body {
        background-color: #89380f !important;
    }
}

/* Dark background for about: pages */
@-moz-document url-prefix(about:) {
    html, body {
        background-color: #89380f !important;
    }
}
EOF
    
    echo "  ✓ Fixed: $(basename "$PROFILE_DIR")"
done

echo ""
echo "============================================"
echo "✓ All profiles updated successfully!"
echo "============================================"
echo "============================================"
echo ""
echo "IMPORTANT: To enable these changes, you need to:"
echo "1. Open Firefox and type 'about:config' in the address bar"
echo "2. Search for 'toolkit.legacyUserProfileCustomizations.stylesheets'"
echo "3. Set it to 'true' (double-click to toggle)"
echo "4. Restart Firefox"
echo ""
echo "Note: The background color used is #89380f."
echo "You can edit the CSS files to use a different color if you prefer."
echo "Old files backed up with .backup timestamp extension."
