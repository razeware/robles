// Switches the module preview between light and dark, using the same body
// class as kodeco.com. Clicking a [data-toggle-night-mode] button flips it and
// remembers the choice; until someone makes one, the preview follows the OS.
//
// Load this as the first thing in <body>, so the class is set before anything
// is drawn and the page doesn't flash light on every live reload.
(() => {
  const STORAGE_KEY = 'robles-night-mode';
  const NIGHT_MODE_CLASS = 'prefers-color-scheme--dark';
  const osPrefersDark = window.matchMedia('(prefers-color-scheme: dark)');

  // localStorage can throw when storage is blocked, so treat that as no choice
  const storedPreference = () => {
    try {
      return localStorage.getItem(STORAGE_KEY);
    } catch {
      return null;
    }
  };

  const isNightMode = () => {
    const preference = storedPreference();
    return preference ? preference === 'dark' : osPrefersDark.matches;
  };

  const applyNightMode = () => {
    document.body.classList.toggle(NIGHT_MODE_CLASS, isNightMode());
  };

  applyNightMode();
  osPrefersDark.addEventListener('change', applyNightMode);

  document.addEventListener('DOMContentLoaded', () => {
    document.querySelectorAll('[data-toggle-night-mode]').forEach((button) => {
      button.addEventListener('click', () => {
        try {
          localStorage.setItem(STORAGE_KEY, isNightMode() ? 'light' : 'dark');
        } catch {
          // Storage is blocked, so the switch won't survive a reload
          document.body.classList.toggle(NIGHT_MODE_CLASS);
          return;
        }
        applyNightMode();
      });
    });
  });
})();
