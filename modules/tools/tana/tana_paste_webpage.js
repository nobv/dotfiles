javascript: (async function () {
  const now = new Date();
  const formattedHours = String(now.getHours()).padStart(2, "0");
  const formattedMinutes = String(now.getMinutes()).padStart(2, "0");

  let tag;
  let extra = "";
  const host = location.hostname;
  switch (host) {
    case "www.youtube.com":
      tag = `#youtube`;
      extra = `    - Created by:: [[${document.querySelector("#text > a").innerHTML}]]`;
      break;
    default:
      tag = `#[[web page]]`;
  }

  const text = `%%tana%%\n
- ${formattedHours}:${formattedMinutes}\n
  - [ ] ${document.title} ${tag}\n
    - Title:: ${document.title}\n
    - URL:: ${location.href}\n
${extra}`;

  try {
    await navigator.permissions.query({name: "clipboard-write"});
    await navigator.clipboard.writeText(text);
    console.log("copy to clipboard success.");
  } catch (err) {
    console.error("copy to clipboard error:", err);
  }
})();

