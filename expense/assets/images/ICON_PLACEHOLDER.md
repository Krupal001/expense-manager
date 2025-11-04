# 📱 App Icon Placeholder

## 🎨 Icon Files Needed

Place the following files in this directory:

### 1. app_icon.png
- **Size**: 1024x1024 pixels
- **Format**: PNG with transparency
- **Purpose**: Main app icon for all platforms

### 2. app_icon_foreground.png
- **Size**: 1024x1024 pixels
- **Format**: PNG with transparency
- **Purpose**: Foreground layer for Android adaptive icons

---

## 🎯 Quick Icon Creation

### Option 1: Use Online Tool
1. Go to https://www.canva.com
2. Create 1024x1024 design
3. Add rupee symbol (₹)
4. Apply purple (#7C3AED) to pink (#EC4899) gradient
5. Export as PNG
6. Save as `app_icon.png`

### Option 2: Use AI
Prompt for ChatGPT/DALL-E:
```
Create a modern app icon for an expense tracker app.
- 1024x1024 pixels
- Indian Rupee symbol (₹) in the center
- Purple (#7C3AED) to pink (#EC4899) gradient background
- Clean, minimalist design
- Rounded square shape
- Professional look
```

### Option 3: Use Figma Template
1. Search "app icon template" on Figma Community
2. Customize with:
   - Rupee symbol (₹)
   - Purple-pink gradient
   - Modern style
3. Export as PNG 1024x1024

---

## 🚀 After Adding Icons

Run these commands:
```bash
flutter pub get
flutter pub run flutter_launcher_icons
flutter clean
flutter run
```

Your app icon will be generated for all platforms!

---

## 💡 Design Tips

### Colors to Use:
- Primary: #7C3AED (Purple)
- Secondary: #EC4899 (Pink)
- Accent: #10B981 (Green)
- Background: White or gradient

### Elements to Include:
- ₹ (Rupee symbol) - Main element
- 📊 (Chart) - Optional
- 💰 (Money) - Optional
- ↗️ (Trending) - Optional

### Style Guidelines:
- ✅ Simple and recognizable
- ✅ Works at small sizes
- ✅ High contrast
- ✅ No text
- ✅ Unique design
- ✅ Matches app theme

---

## 📐 Icon Dimensions

### Main Icon (app_icon.png):
```
┌─────────────────────┐
│                     │
│                     │
│        ₹            │  1024x1024
│    [Gradient]       │
│                     │
│                     │
└─────────────────────┘
```

### Foreground Icon (app_icon_foreground.png):
```
┌─────────────────────┐
│   [Transparent]     │
│                     │
│        ₹            │  1024x1024
│    [Icon Only]      │
│                     │
│   [Transparent]     │
└─────────────────────┘
```

---

## ✨ Example Design

### Simple Rupee Icon:
```
Background: Purple-Pink gradient
Foreground: White ₹ symbol
Style: Bold, modern
Shadow: Subtle drop shadow
```

### With Badge:
```
Background: Purple-Pink gradient
Main: White ₹ symbol (large)
Badge: Small green ↗️ in corner
Style: Modern, clean
```

### Minimalist:
```
Background: Solid purple (#7C3AED)
Foreground: Pink ₹ symbol (#EC4899)
Style: Flat, simple
Border: Rounded corners
```

---

Once you add the icon files here, run the icon generator command!
