javascript: (async function () {

  const video = document.getElementsByTagName('video')[0];
  const canvas = document.createElement('canvas');
  canvas.width = video.videoWidth;
  canvas.height = video.videoHeight;
  const ctx = canvas.getContext('2d');
  ctx.drawImage(video, 0, 0, canvas.width, canvas.height);
  const imageDataURL = canvas.toDataURL('image/png');

  try {
    const response = await fetch(imageDataURL);
    const blob = await response.blob();
    const item = [new ClipboardItem({[blob.type]: blob})];
    await navigator.clipboard.write(item);
    console.log("copy to clipboard success.");
  } catch (error) {
    console.error("copy to clipboard error:", err);
  }
})();

