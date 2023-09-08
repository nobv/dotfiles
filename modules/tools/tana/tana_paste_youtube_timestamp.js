javascript: (async function () {
  const player = document.getElementById("ytd-player");
  player.pause();

  const video = document.getElementsByTagName("video")[0];
  const current_time = parseInt(video.currentTime);
  const current_time_str = document.getElementsByClassName("ytp-time-current")[0].innerText;

  const videoId = document.querySelector("ytd-watch-flexy").getAttribute("video-id");

  const tana_paste = `
%%tana%%\n
- [${current_time_str}](https://youtu.be/${videoId}?t=${current_time})\n
  - Screenshot:: \n
  - Memo:: \n`;

  try {
    await navigator.permissions.query({name: "clipboard-write"});
    await navigator.clipboard.writeText(tana_paste);
    console.log("copy to clipboard success.");
  } catch (err) {
    console.error("copy to clipboard error:", err);
  }
})();

