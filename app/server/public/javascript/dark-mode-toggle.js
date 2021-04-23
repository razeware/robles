window.addEventListener('DOMContentLoaded', (event) => {
  const moonButton = document.getElementById('moon-button');
  const sunButton = document.getElementById('sun-button');

  if(!moonButton || !sunButton) { return; }

  const enableDarkMode = () => {
    moonButton.classList.add('u-hide');
    sunButton.classList.remove('u-hide');
    document.body.classList.add('l-prefers-color-scheme--dark');
    setDarkModeCookie(true);
  };

  const disableDarkMode = () => {
    moonButton.classList.remove('u-hide');
    sunButton.classList.add('u-hide');
    document.body.classList.remove('l-prefers-color-scheme--dark');
    setDarkModeCookie(false);
  };

  if(getDarkModeCookie()) {
    enableDarkMode();
  } else {
    disableDarkMode();
  }

  moonButton.addEventListener('click', enableDarkMode);
  sunButton.addEventListener('click', disableDarkMode);
});

const darkModeCookieName = 'robles-dark-mode';

const getDarkModeCookie = () => {
  const cookie = document.cookie
    .split('; ')
    .find(row => row.startsWith(`${darkModeCookieName}=`));

  if (!cookie) { return false; }

  const value = cookie.split('=')[1];
  return value === 'true';
};

const setDarkModeCookie = (enabled) => {
  if(enabled) {
    document.cookie = `${darkModeCookieName}=true`;
  } else {
    document.cookie = `${darkModeCookieName}=; expires=Thu, 01 Jan 1970 00:00:00 GMT`;
  }
};

