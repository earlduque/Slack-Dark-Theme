document.addEventListener('DOMContentLoaded', function () {
    $.ajax({
        url: 'https://raw.githubusercontent.com/earlduque/Slack-Dark-Theme/master/dark.css',
        success: function (css) {
            $("<style></style>").appendTo('head').html(css);
        }
    });
});