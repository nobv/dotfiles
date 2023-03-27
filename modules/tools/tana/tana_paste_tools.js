javascript: (async function () {
  const now = new Date();
  const formattedHours = String(now.getHours()).padStart(2, "0");
  const formattedMinutes = String(now.getMinutes()).padStart(2, "0");

  const time = `${formattedHours}:${formattedMinutes}`;

  const tana_paste = `
%%tana%%\n
- ${time}\n
  - [ ] ${document.title} #tools\n
    - Title:: ${document.title}\n
    - URL:: ${location.href}\n`;

  try {
    await navigator.permissions.query({name: "clipboard-write"});
    await navigator.clipboard.writeText(tana_paste);
    console.log("copy to clipboard success.");
  } catch (err) {
    console.error("copy to clipboard error:", err);
  }
})();

