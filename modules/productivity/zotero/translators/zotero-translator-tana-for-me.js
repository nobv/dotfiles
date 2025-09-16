{
  "translatorID": "2dc0d36f-b2b5-467f-8593-4f71015253fe",
  "translatorType": 2,
  "label": "Tana Metadata Export for me",
  "creator": "nobv",
  "target": "md",
  "minVersion": "5.0",
  "maxVersion": "",
  "priority": 100,
  "inRepository": false,
  "lastUpdated": "2023-03-09 16:52:35"
}


function doExport() {
  Zotero.write("%%tana%%\n");
  var item;
  while (item = Zotero.nextItem()) {
    switch (item.itemType) {
      case "videoRecording":
        video(item)
        break;
      case "book":
      case "journalArticle":
        book(item)
        break;
      case "webpage":
        webage(item)
        break;
    }
    // zotero link
    var item_key = item.uri.split("/items/")[1]
    var itemLink = `zotero://select/library/items/${item_key}`;

    Zotero.write('  - Zotero link:: ')
    Zotero.write('[Zotero Link](' + itemLink + ')\n')
  }
}

function book(item) {
  // ref
  Zotero.write(`- ${item.title} #books\n`);

  // title
  Zotero.write(`  - Title:: ${item.title}\n`);

  // author
  Zotero.write('  - Authored by:: \n');
  // write authors as indented nodes
  for (author in item.creators) {
    Zotero.write(`    - [[${item.creators[author].firstName || ''} ${item.creators[author].lastName || ''}]]\n`);
  }
  Zotero.write('\n');
}

function video(item) {
  // ref
  let tag = "#videos";
  if (item.libraryCatalog == "Youtube") tag = "#youtube";
  Zotero.write(`- ${item.title} ${tag}\n`);

  // title
  Zotero.write(`  - Title:: ${item.title}\n`);

  // author
  Zotero.write('  - Created by:: \n');
  // write authors as indented nodes
  for (author in item.creators) {
    Zotero.write(`    - [[${item.creators[author].firstName || ''} ${item.creators[author].lastName || ''}]]\n`);
  }
  Zotero.write('\n');

  // url with citation
  Zotero.write(`  - URL:: ${item.url || ''}\n`)
}

function webage(item) {
  // ref
  Zotero.write('- ' + item.title + ' #articles\n');

  // title
  Zotero.write(`  - Title:: ${item.title}\n`);

  // author
  Zotero.write('  - Authored by:: \n');
  // write authors as indented nodes
  for (author in item.creators) {
    Zotero.write(`    - [[${item.creators[author].firstName || ''} ${item.creators[author].lastName || ''}]]\n`);
  }
  Zotero.write('\n');

  // url with citation
  Zotero.write(`  - URL:: ${item.url || ''}\n`)
}
