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
      let repository_name = document.querySelector("#readme h1");
      if (location.pathname.includes("issues")) {
        repository_name = document.querySelector("bdi");
      }
      if (repository_name === null || repository_name === undefined) {
        repository_name = document.querySelector("#repository-container-header > div.d-flex.flex-wrap.flex-justify-end.mb-3.px-3.px-md-4.px-lg-5 > div > div > strong > a");
      }

      tana_paste += `
- ${time}\n
  - [ ] ${repository_name.innerText} #github\n
    - Title:: ${document.title}\n
    - URL:: ${location.href}\n
    - Repository Owner:: [[${document.querySelector("#repository-container-header > div.d-flex.flex-wrap.flex-justify-end.mb-3.px-3.px-md-4.px-lg-5 > div > div > span.author.flex-self-stretch > a").innerText}]]`;
      break;

    case "gist.github.com":
      tana_paste += `
- ${time}\n
  - [ ] ${document.querySelector("#gist-pjax-container > div.container-lg.px-3 > div > div > div:nth-child(1)").innerText} #github\n
    - Title:: ${document.title}\n
    - URL:: ${location.href}\n
    - Repository Owner:: [[${document.querySelector("#gist-pjax-container > div.gisthead.pagehead.pb-0.pt-3.mb-4 > div > div.mb-3.d-flex.px-3.px-md-3.px-lg-5 > div > div > div.d-flex.flex-column.width-full > div.d-flex.flex-row.width-full > h1 > span.author > a").innerText}]]`;
      break;

    case "ja.wikipedia.org":
    case "en.wikipedia.org":
      tana_paste += `
- ${time}\n
  - [ ] ${document.querySelector("#firstHeading > span").innerText} #wiki\n
    - Title:: ${document.title}\n
    - URL:: ${location.href}\n`;
      break;

    case "developer.mozilla.org":
      tana_paste += `
 - ${time}\n
  - [ ] ${document.querySelector("h1").innerText} #[[Web APIs]]\n
    - Title:: ${document.title}\n
    - Description:: ${document.querySelector("#content > article > div.section-content > p").innerText}\n
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


Keeping your Home Manager home.nix in ~/.config/nixpkgs is deprecated, please move it to ~/.config/home-manager
