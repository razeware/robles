window.addEventListener('DOMContentLoaded', (event) => {
  const elements = document.querySelectorAll('span[data-video-timestamp]');
  [...elements].forEach((element) => {
    element.classList.add('o-badge', 'o-badge-product--highlight', 'video-timestamp');
    element.innerHTML = element.dataset.videoTimestamp;
  });
});
