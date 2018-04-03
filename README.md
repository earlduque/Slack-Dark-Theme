1) go to your version of `C:\Users\username\AppData\Local\slack\app-3.1.0\resources\app.asar.unpacked\src\static`
2) locate and open the file `ssb-interop.js` in notepad
3) add this code to the end of that file and save:
```document.addEventListener('DOMContentLoaded', function () {
    $.ajax({
        url: 'https://raw.githubusercontent.com/earlduque/Slack-Dark-Theme/master/dark.css',
        success: function (css) {
            $("<style></style>").appendTo('head').html(css);
        }
    });
});```
4) close and reopen slack
