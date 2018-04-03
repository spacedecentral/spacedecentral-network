$(function() {
  $(window).on('load', function() {
    $('#medium_posts').fetchMediumPosts({
      title: 'Latest News',
      done: function(isDone) {
        if (isDone) {
          initTilter({
            selectors: '#medium_posts .tilter',
          });
        }
      }
    });

    $('#newsletter').load(function(){
      var hashTag = window.location.hash;
      if (hashTag && /\#newsletter/.test(hashTag)) {
        $('#newsletter input').focus();
        $('html, body').animate({
          scrollTop: $(hashTag).offset().top + 300
        }, 1000);
      }
    });

    initTilter({
      selectors: '#list_programs .tilter, #trending_posts .tilter',
    });
  });
});
