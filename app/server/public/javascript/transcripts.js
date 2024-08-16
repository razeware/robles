window.addEventListener('DOMContentLoaded', (event) => {
  const parseTimestamp = (tsString) => {
    const parsed = tsString.split(':').map((t) => Number(t)).reverse();
    return {
      hours: parsed[2] || 0,
      minutes: parsed[1] || 0,
      seconds: parsed[0] || 0,
    };
  };

  const displayTime = (tsString) => {
    const time = parseTimestamp(tsString);
    const mins = `${time.hours * 60 + time.minutes}`.padStart(2, '0');
    const secs = time.seconds.toFixed(0).toString().padStart(2, '0');
    return `${mins}:${secs}`;
  };

  const elements = document.querySelectorAll('span[data-video-timestamp]');
  [...elements].forEach((element) => {
    element.classList.add('video-timestamp');
    element.innerHTML = displayTime(element.dataset.videoTimestamp);
  });

  // Remove all headers(titles) in DOM
  const transcriptContainer = document.querySelector('.transcript-segment');
  const headers = transcriptContainer.querySelectorAll('h1, h2, h3, h4, h5, h6');
  [...headers].forEach((hd) => {
    if (!hd.classList.contains('segment-header')) {
      hd.remove();
    }
  });
});
