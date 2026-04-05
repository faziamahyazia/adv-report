# Testing & Debugging Guide - Photo Display Issue

**Date:** April 2, 2026 10:20 UTC  
**Issue:** Photos display in Table view but NOT in Card view  
**Status:** Debug version deployed with console logging

---

## 🔍 Current Status

### ✅ What's Working:
- Photos display in **Table View** ✅
- Data exists in MySQL database (4 harvest results, 8 photos) ✅
- Backend API correctly constructs photo URLs ✅

### ❌ What's NOT Working:
- Photos NOT displaying in **Card View** ❌
- User only sees placeholder icons, not actual images ❌

### ⚠️ Partially Fixed:
- Mobile zone labels - improved but user reports "kurang optimal"

---

## 🧪 **DEBUG STEPS - PLEASE FOLLOW**

### Step 1: Open Browser Console

1. **Buka https://202.10.40.89**
2. **Login** ke aplikasi
3. **Press F12** (atau klik kanan → Inspect)
4. **Click "Console" tab**

### Step 2: Navigate to Product Knowledge

1. Go to **Product Knowledge → Hasil Panen**
2. Make sure you're in **Card View** (not Table View)
3. **Look at Console** - you should see debug messages like:

```
[DEBUG] Photo URLs for item 4 : ["/uploads/harvest_...jpg", ...]
[DEBUG] Using first URL: /uploads/harvest_...jpg
```

### Step 3: Check What's Being Logged

**If you see:**
```
[DEBUG] Photo URLs for item 4 : []
[DEBUG] No photo URLs found for item 4
```
→ **Problem:** API not sending photo_urls array

**If you see:**
```
[DEBUG] Photo URLs for item 4 : ["/uploads/harvest_...jpg"]
[DEBUG] Using first URL: /uploads/harvest_...jpg
```
→ **Problem:** URL is correct but image not loading (network issue)

### Step 4: Check Network Tab

1. In DevTools, click **"Network"** tab
2. Filter by: **Img** (image requests)
3. Look for requests to: `/uploads/harvest_*.jpg`

**Check for:**
- ❌ **404 Not Found** → File doesn't exist on server
- ❌ **403 Forbidden** → Permission issue
- ✅ **200 OK** → File loads successfully

### Step 5: Take Screenshots

Please take screenshots of:
1. **Console tab** showing debug logs
2. **Network tab** showing image requests (if any fail, highlight them)
3. **Card view** showing the issue (no photos)
4. **Table view** showing photos working

---

## 📸 Testing Mobile Label Optimization

### New Approach (Deployed):

**Previous (had issues):**
- Desktop: "Lowland" / "Middleland" / "Highland"
- Mobile: "Low" / "Mid" / "High"
- Problem: Still cut off on very small screens

**New (current):**
- **All devices:** Full label ("Lowland", "Middleland", "Highland")
- **Responsive sizing:**
  - Desktop (>768px): 11px font, 140px max-width
  - Tablet (480-768px): 10px font, 110px max-width
  - Mobile (<480px): 9px font, 85px max-width
- **Ellipsis:** Text truncates with "..." if still too long
- **Tooltip:** Hover/long-press shows full text + altitude

### Test on Different Screen Sizes:

**Desktop (>768px):**
- Font should be 11px
- Full text visible
- No truncation unless >140px

**Tablet (480-768px):**
- Font should be 10px
- May show ellipsis for long text
- Max width 110px

**Mobile (<480px):**
- Font should be 9px
- Tighter padding (2px/6px)
- Max width 85px
- Ellipsis for overflow

### How to Test Mobile:

1. **F12 → Toggle Device Toolbar**
2. **Set to iPhone 12** (390px width)
3. **Check zone tags:**
   - Should be smaller font
   - May have ellipsis (...)
   - Hover shows full text in tooltip

---

## 🔧 Quick Fixes to Try (If Debug Shows Data)

### Fix 1: Hard Reload Browser

```
Ctrl + Shift + R (Windows/Linux)
Cmd + Shift + R (Mac)
```

**Why:** Old cached build files may still be loaded

### Fix 2: Clear Application Cache

1. F12 → Application tab
2. Clear Storage → Clear site data
3. Reload page

### Fix 3: Check Service Worker

1. F12 → Application → Service Workers
2. Click "Unregister" for any active service workers
3. Reload page

---

## 🐛 Common Issues & Solutions

### Issue 1: Photos in Table but not Card

**Possible Cause:** CSS issue hiding images in card view

**Debug:**
```javascript
// In console, check if image elements exist:
document.querySelectorAll('.harvest-thumb-wrap img').length
// Should return number > 0 if images rendered
```

**Solution:**
Check if `v-if="getPhotoUrl(item)"` evaluates to false for cards

### Issue 2: Console Shows URLs but Images Don't Load

**Possible Cause:** Path mismatch or file permission

**Debug:**
```bash
# On server, check files exist:
ssh root@202.10.40.89
ls -lh /var/www/adv/public/uploads/harvest_*
```

**Solution:**
```bash
# Fix permissions:
chmod 644 /var/www/adv/public/uploads/harvest_*
chown www-data:www-data /var/www/adv/public/uploads/harvest_*
```

### Issue 3: Mobile Labels Still Cut Off

**Current Settings:**
- Mobile (<480px): 9px font, 85px max-width
- Ellipsis enabled for overflow

**If still cut off, user can:**
- Tap/hover to see full text in tooltip
- Switch to Table view for more space

**Or we can:**
- Make font even smaller (8px)
- Use abbreviations ("L", "M", "H")
- Vertical stacking instead of horizontal

---

## 📊 Expected Console Output (Normal)

```
[DEBUG] Photo URLs for item 4 : [
  "/uploads/harvest_1775056430_0_69cd362e5f44d.jpg",
  "/uploads/harvest_1775056430_1_69cd362ec4558.jpg",
  "/uploads/harvest_1775085759_0_69cda8bf140a9.jpg"
]
[DEBUG] Using first URL: /uploads/harvest_1775056430_0_69cd362e5f44d.jpg

[DEBUG] Photo URLs for item 3 : ["/uploads/harvest_1775056174_0_69cd352e345e0.jpg"]
[DEBUG] Using first URL: /uploads/harvest_1775056174_0_69cd352e345e0.jpg

[DEBUG] Photo URLs for item 2 : ["/uploads/harvest_1775055632_0_69cd3310d23b8.jpg"]
[DEBUG] Using first URL: /uploads/harvest_1775055632_0_69cd3310d23b8.jpg

[DEBUG] Photo URLs for item 1 : [
  "/uploads/harvest_1775035992_69cce65870850.jpg",
  "/uploads/harvest_1775037309_0_69cceb7d11647.jpg",
  "/uploads/harvest_1775037309_1_69cceb7d8c615.jpg",
  "/uploads/harvest_1775037803_0_69cced6b917b9.jpg"
]
[DEBUG] Using first URL: /uploads/harvest_1775035992_69cce65870850.jpg
```

---

## 📤 What to Send Back

Please provide:

1. **Console Log Screenshot** (full debug output)
2. **Network Tab Screenshot** (showing image requests)
3. **Card View Screenshot** (showing issue)
4. **Table View Screenshot** (showing it works)
5. **Mobile View Screenshot** (showing label truncation)

**Copy console text:**
```javascript
// Run in console:
copy(console.log)
// Then paste in message
```

---

## 🚀 Next Steps Based on Results

### If Console Shows Empty Arrays `[]`:
→ **Backend API issue** - need to fix ProductKnowledgeController

### If Console Shows URLs but Network Shows 404:
→ **File path issue** - need to verify uploads folder structure

### If Console Shows URLs and Network Shows 200 OK:
→ **CSS/rendering issue** - need to check CSS rules for card view

### If Mobile Labels Still Cut Off:
→ **Further optimization needed** - can use shorter labels or icon-based tags

---

**Deployment Info:**
- Build: `app-CXoLc5VM.js` (April 2, 2026 10:20 UTC)
- Debug logging: ENABLED
- Mobile optimization: IMPROVED (responsive font sizes)

**Ready for testing!** 🧪
