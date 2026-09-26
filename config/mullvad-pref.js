// Give the Mullvad Browser UI (toolbar, menus, tab bar) Firefox's built-in
// dark theme, to match the rest of the desktop. This only changes the
// browser's own chrome - not web page content - so it doesn't add anything
// a website's JavaScript can detect.
user_pref("extensions.activeThemeID", "firefox-compact-dark@mozilla.org");
