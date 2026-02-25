# Test Image URLs for Category Management

Use these URLs to test the category management system. They are publicly accessible images that work with `Image.network()`.

## Public Test Images (Free to Use)

### Medical/Health Related

```
https://images.unsplash.com/photo-1576091160550-2173dba999ef?w=400
https://images.unsplash.com/photo-1576091160499-112ba8d7d1aa?w=400
https://images.unsplash.com/photo-1587663712051-36468e3b3842?w=400
https://images.unsplash.com/photo-1631217314998-ab67467b5b41?w=400
https://images.unsplash.com/photo-1530026405186-256c9c6d2b41?w=400
```

### Emergency/First Aid

```
https://images.unsplash.com/photo-1631217314998-ab67467b5b41?w=400
https://images.unsplash.com/photo-1576091160550-2173dba999ef?w=400
https://images.unsplash.com/photo-1551076805-84cdf56b2a91?w=400
```

### General Icons/Symbols

```
https://via.placeholder.com/200x200/FF6B6B/FFFFFF?text=Medical
https://via.placeholder.com/200x200/4ECDC4/FFFFFF?text=Health
https://via.placeholder.com/200x200/95E1D3/FFFFFF?text=Care
https://via.placeholder.com/200x200/F38181/FFFFFF?text=Help
```

## How to Test

### Step 1: Quick Test

1. Go to Category Management
2. Click **+** to add new category
3. Enter a name: `Test Category`
4. In **Picture URLs**, paste ONE of the URLs above
5. Click **Add**

### Step 2: Verify Image Loads

1. Find your test category in the grid
2. Check if image appears in the card
3. Expand **"Images (1)"** section
4. Click the **✓** checkmark to validate URL
5. Should see "Image URL is valid" in green message

### Step 3: Test Edit

1. Click **Edit** on your test category
2. Add another image URL from the list above
3. Click **Update**
4. Verify both images are now listed under "Images (2)"

### Step 4: Test Delete

1. Click **Delete** on your test category
2. Confirm deletion
3. Category should disappear from grid

## Firebase Storage URLs (Recommended)

If you upload images to Firebase Storage, URLs will look like:

```
https://storage.googleapis.com/your-bucket-name/images/category-name.jpg
https://storage.googleapis.com/your-bucket-name/image-file.png
```

## Cloudinary URLs (Alternative)

Example Cloudinary URLs:

```
https://res.cloudinary.com/demo/image/upload/w_400/v1234567/sample.jpg
```

## Image Hosting Services That Work Well

| Service              | Free             | Direct URLs | Notes                      |
| -------------------- | ---------------- | ----------- | -------------------------- |
| **Unsplash**         | ✅               | ✅          | Great for testing          |
| **Firebase Storage** | ✅ (with quotas) | ✅          | Recommended for production |
| **Cloudinary**       | ✅ (limited)     | ✅          | Good CDN performance       |
| **ImgBB**            | ✅               | ✅          | Simple image hosting       |
| **Postimages**       | ✅               | ✅          | No account needed          |
| **imgur**            | ✅               | ⚠️          | Requires direct link       |

## Common Issues & Solutions

### "Image failed to load"

- Copy the URL to browser to test it directly
- Check if domain is blocked by CORS
- Try a different image hosting service

### "Images (0)" shown but URL was entered

- Make sure URL starts with `http://` or `https://`
- Check for extra whitespace (should be auto-trimmed)
- Ensure URL is complete and valid

### Validation button shows red error

- URL is either invalid or inaccessible
- Try replacing with a URL from the test list above
- Check if server/domain is online

## Example Complete Data

To quickly test, use this data:

**Category Name:** First Aid Basics
**Description:** Essential first aid information and emergency response techniques
**Display Order:** 1
**Aliases:** emergency, help, aid, medical
**Picture URLs:**

```
https://images.unsplash.com/photo-1576091160550-2173dba999ef?w=400
https://images.unsplash.com/photo-1631217314998-ab67467b5b41?w=400
```

**Video URL:** https://www.youtube.com/watch?v=dQw4w9WgXcQ

Then click **Add** and verify:

1. Both images appear in the card
2. Expand "Images (2)" and validate both URLs
3. Edit the category and change the order to 2
4. Images still load correctly

## Production Recommendations

1. **Use Firebase Storage** for all images
2. **Set up proper CORS** rules
3. **Optimize image sizes** (max 500KB per image)
4. **Use WebP format** for better compression
5. **Add CDN caching** for faster loading
6. **Test URLs** before setting them in production

## Debugging

If an image won't load:

1. **Open browser console** and check for errors
2. **Test URL directly** in browser address bar
3. **Check network tab** to see if request succeeds
4. **Verify CORS headers** (should allow your domain)
5. **Check Firebase Security Rules** (if using Firebase Storage)

---

**Quick URL Validation:**

- ✅ Starts with `https://` or `http://`
- ✅ Can be opened in browser
- ✅ Returns an image (not HTML error page)
- ✅ Not blocked by CORS
- ✅ Server is online and accessible
