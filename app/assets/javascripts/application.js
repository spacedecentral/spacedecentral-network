//= require jquery
//= require jquery-ui
//= require bootstrap-sprockets
//= require jquery_ujs
//= require jquery.remotipart
//= require jquery-fileupload/basic
//= require moment
//= require mark_it_zero
//= require cocoon
//= require debounce
//= require bootstrap-toolkit
//= require truncate
//= require webfontloader

//= require cable.js.erb
//= require chips.js
//= require cover_editor.js
//= require dropzone.js
//= require forums.js
//= require gdrive.js
//= require landing.js
//= require program_user_roles.js
//= require landing.js
//= require programs.js
//= require tag_references.js
//= require user_careers.js
//= require user_educations.js
//= require user_publications.js
//= require users.js
//= require medium-posts-fetcher
//= require modal
//= require_tree ./tilter
//= require jquery.slick
//= require message

function platform_timestamp(dt) {
    const momentDate = moment(dt, "YYYY-MM-DD HH:mm Z");
    const date = momentDate.utc(new Date(momentDate));
    const now = moment();

    let result = date.fromNow();

    if (date.year != now.year) {
        result = date.format("MMM Do YYY")
    } else if (now.diff(date) > 86400 * 1000 * 7) {
        result = date.format("MMM Do")
    }
    return result;
}

function updatePlatformTimestamps() {
    const timestampElements = $(".platform_timestamp");
    for (let e of timestampElements) {
        const date = $(e).attr("data-time-stamp");
        $(e).html(platform_timestamp(date));
    };
}

$(function(){

  if ( $(window).height() < $("#platform_main_layout_content").height() ) {
    $(".bottom-platform-cover-container").css("position", "relative").css("z-index","1");
  }
  setInterval(updatePlatformTimestamps,15000);
  $(".flashages-container .close").click(function() {
    $(this).closest(".flashages-container").remove();
  });

  updatePlatformTimestamps();
});

$(document).on('click', '.dropdown-menu li a', function(e) {
  $(this).closest('.dropdown.open').removeClass('open');
})
