function sidenotes($body) {
  $('note').replaceWith(function () {
    return $('<div class="notes" />').append($(this).contents());
  });
}

function convert() {
  console.log('converting')
  $body = $(document.body);
  sidenotes($body);
}

window.convert = convert;
