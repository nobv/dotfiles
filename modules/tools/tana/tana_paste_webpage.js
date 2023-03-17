javascript: (async function () {
  const now = new Date();
  const formattedHours = String(now.getHours()).padStart(2, "0");
  const formattedMinutes = String(now.getMinutes()).padStart(2, "0");

  const time = `${formattedHours}:${formattedMinutes}`;

  let tana_paste = "%%tana%%\n";
  switch (location.hostname) {

    case "www.youtube.com":
      tana_paste += `
- ${time}\n
  - [ ] ${document.title} #youtube\n
    - Title:: ${document.title}\n
    - URL:: ${location.href}\n
    - Created by:: [[${document.querySelector("#text > a").innerHTML}]]`;
      break;

    case "github.com":
      tana_paste += `
- ${time}\n
  - [ ] ${document.querySelector("#readme > div.Box-body.px-5.pb-5 > article > h1").innerText} #github\n
    - Title:: ${document.title}\n
    - URL:: ${location.href}\n
    - Repository Owner:: [[${document.querySelector("#repository-container-header > div.d-flex.flex-wrap.flex-justify-end.mb-3.px-3.px-md-4.px-lg-5 > div > div > span.author.flex-self-stretch > a").innerText}]]`;
      break;

    case "ja.wikipedia.org":
    case "en.wikipedia.org":
      tana_paste += `
- ${time}\n
  - [ ] ${document.querySelector("#firstHeading > span").innerText} #wiki\n
    - Title:: ${document.title}\n
    - URL:: ${location.href}\n`;
      break;

    default:
      tana_paste += `
- ${time}\n
  - [ ] ${document.title} #[[web page]]\n
    - Title:: ${document.title}\n
    - URL:: ${location.href}\n`;
      break;
  }

  try {
    await navigator.permissions.query({name: "clipboard-write"});
    await navigator.clipboard.writeText(tana_paste);
    console.log("copy to clipboard success.");
  } catch (err) {
    console.error("copy to clipboard error:", err);
  }
})();

