javascript: (async function () {
  const video = document.getElementsByTagName("video");
  const current_time = parseInt(video[0].currentTime);
  const current_time_str = document.getElementsByClassName("ytp-time-current")[0].innerText;

  const short_link_url = document.querySelectorAll('[rel="shortlinkUrl"]')[0].href;

  const tana_paste = `
%%tana%%\n
- [ ] [${current_time_str}](${short_link_url}?t=${current_time})\n
  - Memo:: \n`;

  try {
    await navigator.permissions.query({name: "clipboard-write"});
    await navigator.clipboard.writeText(tana_paste);
    console.log("copy to clipboard success.");
  } catch (err) {
    console.error("copy to clipboard error:", err);
  }
})();

