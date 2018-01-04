function initTilter(options) {
  var settings = Object.assign({
    selectors: '.tilter',
  }, options);

  var idx = 0;
  $(settings.selectors).each(function(pos) {
    idx = pos % 2 === 0 ? idx + 1 : idx;
    new TiltFx(this, settings[idx-1]);
  });
}
