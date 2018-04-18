(function ($) {
  $.fn.fetchMediumPosts = function(options) {
    var $container = $(this);
    var defaults = {
      rss_url: 'https://blog.space.coop/feed',
      title: 'Medium Posts',
      titleClass: 'section-title',
      done: null, // callback function
    };
    var data = Object.assign(defaults,  options);
    var apiRss2jsonEnpoint = 'https://api.rss2json.com/v1/api.json';

    $.get(apiRss2jsonEnpoint, data, function (response) {
      if (response.status == 'ok') {
        var output = '';
        output += '<h2 class="' + data.titleClass + ' text-center">' + data.title + '</h2>';
        output += '<div class="row">';

        $.each(response.items, function (k, item) {
          var visibleSm;

          if(k < 6){
            visibleSm = '';
          } else {
            visibleSm = ' visible-sm';
          }

          output += '<div class="col-sm-6 col-md-4 tilter tilter--3' + visibleSm + '">';
          output += '<div class="blog-post tilter__figure mb-30"><header>';

          var tagIndex = item.description.indexOf('<img'); // Find where the img tag starts
          var srcIndex = item.description.substring(tagIndex).indexOf('src=') + tagIndex; // Find where the src attribute starts
          var srcStart = srcIndex + 5; // Find where the actual image URL starts; 5 for the length of 'src="'
          var srcEnd = item.description.substring(srcStart).indexOf('"') + srcStart; // Find where the URL ends
          var src = item.description.substring(srcStart, srcEnd); // Extract just the URL

          output += '<div class="blog-element" style="background-image: url(' + src + '); background-position: 50% 50%; height: 150px; background-size: 100%;"></div></header>';
          output += '<div class="blog-content"><h4 class="ellipsis-box"><a href="'+ item.link + '">' + item.title + '</a></h4>';
          output += '<div class="blog-body ellipsis-box"><div class="post-meta"><span class="author">By ' + item.author + '&nbsp;&#183;&nbsp;<span class="date platform_timestamp" data-time-stamp= ' +  item.pubDate  + ' /></span></div>';

          var yourString = item.description.replace(/<img[^>]*>/g,"");
          var maxLength = 120 // maximum number of characters to extract
          //trim the string to the maximum length
          var trimmedString = yourString.substr(0, maxLength);
          //re-trim if we are in the middle of a word
          trimmedString = trimmedString.substr(0, Math.min(trimmedString.length, trimmedString.lastIndexOf(" ")))

          output += '<p>' + trimmedString + '...</p>';
          output += '</div></div></div></div>';
          return k < 6;
        });

        output += '</div>';
        $container.html(output);
        data.done(true);
        updatePlatformTimestamps();
      }
    });
  }
}( jQuery ));
