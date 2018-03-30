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
//= require mission_user_roles.js
//= require landing.js
//= require missions.js
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

function platform_timestamp (dt) {
  // console.log(dt);
  if (dt !== 'undefined' ) {

    var jsdatetime = new Date( dt );
    var jsnow = new Date();
    if( isNaN(jsdatetime) )
    {
      return "";
    }

    if (jsdatetime.getFullYear() != jsnow.getFullYear() ) {
      return moment(dt).format("MMM Do YYYY");
    }
    var jsdatetime = jsdatetime.getTime();
    var jsnow = jsnow.getTime();

    var delta = Math.abs(jsnow - jsdatetime) / 1000;

    if (jsdatetime > jsnow) {
      var delta = Math.abs(jsdatetime - jsnow) / 1000;
    }
    // get total seconds between the times

    // calculate (and subtract) whole days
    var days = Math.floor(delta / 86400);
    delta -= days * 86400;

    // calculate (and subtract) whole hours
    var hours = Math.floor(delta / 3600) % 24;
    delta -= hours * 3600;

    // calculate (and subtract) whole minutes
    var minutes = Math.floor(delta / 60) % 60;
    delta -= minutes * 60;

    if ( days > 7 ) {
      return moment(dt).format("MMM Do");
    }
    if ( days > 0 ) {
      if ( days == 1 ) {
        return "1 day ago";
      }
      return days + " days ago"
    }
    if ( hours > 0 ) {
      if ( hours == 1 ) {
        return "1 hour ago";
      }
      return hours + " hours ago"
    }
    if ( minutes >= 0 ) {
      if ( minutes == 0 ) {
        return "Just now";
      }
      if ( minutes == 1 ) {
        return "1 minute ago";
      }
      return minutes + " minutes ago"
    }
  }
}

function updatePlatformTimestamps() {
  $(".platform_timestamp").each(function() {
    var updated_timestamp = platform_timestamp($(this).attr("data-time-stamp"));
    $(this).html(updated_timestamp);
    // console.log(updated_timestam;
  });
}

$(function(){

  if ( $(window).height() < $("#platform_main_layout_content").height() ) {
    $(".bottom-platform-cover-container").css("position", "relative").css("z-index","1");
  }
  setInterval(function(){updatePlatformTimestamps();},45000);
  $(".flashages-container .close").click(function() {
    $(this).closest(".flashages-container").remove();
  });

});

$(document).on('click', '.dropdown-menu li a', function(e) {
  $(this).closest('.dropdown.open').removeClass('open');
})
