(function($, viewport){

  var highlightBoxes = function() {
    if(!viewport.is('xs')) {
      $('.filter-title, .close-filter-toolbar').hide();
      $('.forum-banner, .post-list, .js-toolbar-link, .js-filter-button, #js_load_more').show();
      $('.forum-filter-button').removeClass('mra');
      $('.post-filter .forum-sidebar').show();
      $('.post-filter').removeClass('js-on-mobile p-0');
      $('.post-container').removeClass('p-0');
    } else {
      $('.js-open-filter-button').show();
      $('.post-filter .forum-sidebar').hide();
      $('.post-filter').addClass('js-on-mobile p-0');
      $('.post-container').addClass('p-0');
    }
  }

  var originalWidth = $( window ).width();
  // Executes once whole document has been loaded
  $(document).ready(function() {
    highlightBoxes();
  });

  $(window).resize(
    viewport.changed(function(){
      if (originalWidth !== $(window).width()) {
        highlightBoxes();
      }
    })
  );

})(jQuery, ResponsiveBootstrapToolkit);

$(document).on('click', '.filter-toolbar .close-filter-toolbar', function() {
  $('.filter-title, .close-filter-toolbar').hide();
  $('.forum-sidebar').slideUp('300').hide();
  $('.forum-banner, .post-list, .js-toolbar-link, .js-open-filter-button, #js_load_more').show();
  $('.search-on-mobile').addClass('visible-xs');
  $('.forum-filter-button').removeClass('mra');
});

$(document).on('click', '.js-open-filter-button', function(event) {
  $('.filter-title, .close-filter-toolbar').show();
  $('.forum-sidebar').show();
  $('.forum-banner, .post-list, .js-toolbar-link, .js-open-filter-button, #js_load_more').hide();
  $('.forum-filter-button').addClass('mra');
  $('.search-on-mobile').removeClass('visible-xs');
});

$(document).on('change', 'form.filter-form', function(e, where) {
  $(this).submit();

  if (where !== 'from_search_box' && $('.post-filter').hasClass('js-on-mobile')) {
    $('.filter-toolbar .close-filter-toolbar').trigger('click');
  }
});

var searchForumDebouceFn = debounce(function(value) {
  $("form.filter-form #filter_keyword").val(value);
  $('form.filter-form').trigger('change', ['from_search_box']);
}, 700);

$(document).on('keyup', '.js-search-forum-input', function(e) {
  var value = e.target.value;
  if (value.length >= 1) {
    $(".search-box .js-clear-search-filter").show();
    $(".search-box .js-search-icon").hide();
  } else {
    $(".search-box .js-clear-search-filter").hide();
    $(".search-box .js-search-icon").show();
  }

  searchForumDebouceFn(value);
});

$(document).on('click', '.search-box .js-clear-search-filter', function(e) {
  e.preventDefault();
  $('.js-search-forum-input').val('');
  $("form.filter-form #filter_keyword").val('');

  $(".search-box .js-clear-search-filter").hide();
  $(".search-box .js-search-icon").show();

  $('form.filter-form').trigger('change', ['from_search_box']);
});

$(document).on('click', '.js-filter-box .clear-filter', function(e) {
  e.preventDefault();
  $(this).closest('.js-filter-box').find('.filter-item input[type="checkbox"]').prop('checked', false);
  $(this).closest('form.filter-form').trigger('change');
});

$(document).on('change', '.mission-filters .filter-item input[type="checkbox"]', function() {
  var children = $(this).closest('.filter-item')
                        .find('.filter-children .filter-item input[type="checkbox"]');
  if (children.length <= 0) return;

  if ($(this).is(":checked")) {
    children.prop('checked', true);
  } else {
    children.prop('checked', false);
  }
});

$(document).on('shown.bs.modal', '#post_form_modal', function() {
  var textarea = $(this).find("textarea#post_content");
  var cm = $(textarea).closest('form').find(".CodeMirror")[0];
  var content = $(textarea).val();
  cm.CodeMirror.setValue(content);
  cm.CodeMirror.refresh();
});

// Override confirm rails action
$.rails.allowAction = function(link) {
  link.closest('.dropdown').removeClass('open');
  if (link.data('confirm-target') == undefined) {
    return true;
  }

  triggerCustomConfirmDialog(link);
  return false;
}

function triggerCustomConfirmDialog(link) {
  $modal = $(link.data('confirm-target'));
  var modalActionBtn = $modal.find('.js-btn-modal-action');

  modalActionBtn.attr('href', link.attr('href'));
  modalActionBtn.data('remote', link.data('remote'));
  modalActionBtn.data('method', link.data('method'));

  $modal.modal('show');

  $(document).on('ajax:complete', $.rails.allowAction, function() {
    $modal.modal('hide');
  });
}

$(document).on('click', '.reply-link', function(e) {
  e.preventDefault();
  $('.reply-container').hide();

  var replyId = $(this).data('id');
  reply_container = $("#reply-container-" + replyId);
  reply_container.show();
  var top = reply_container.offset().top;
  $('html, body').animate({scrollTop: top }, 1000);

  var textarea = reply_container.find('textarea#reply_content' + replyId)[0];
  getOrInitSCEditor(textarea);
});

function getOrInitSCEditor(selector) {
  var $selector = $(selector);
  var cmDom = $selector.closest('form').find(".CodeMirror")[0];
  $selector.closest('.reply-form').show();

  $selector.val('');
  if (cmDom) {
    var cm = cmDom.CodeMirror;
    cm.setValue('');
    cm.focus();
    return;
  }

  initSCEditor($selector);
}

$(document).on('click', '.response_box', function(e){
  e.preventDefault();
  $(this).hide();
  var responseForm = $('.response_box_form .reply-form');
  responseForm.show();
  var top = responseForm.offset().top;
  $('html, body').animate({scrollTop: top }, 1000);
  getOrInitSCEditor(responseForm.find('textarea'));
});

$(document).on('click', '.cancel-btn', function(event) {
  event.preventDefault();
  $(this).closest('.reply-form').hide(100);
  $(this).closest('.edit-reply-form').hide(100);
  $('.reply-content').show();
  $('.response_box').show();
});

$(document).on('click', '.js-show-more-tags', function(e) {
  e.preventDefault();
  var $moreTags = $(this).closest('.list-tags').find('.more-tags')

  $(this).find('.more-icon').toggleClass('hidden');
  $(this).find('.less-icon').toggleClass('hidden');
  if ($moreTags.hasClass('hidden')) {
    $moreTags.removeClass('hidden')
    $(this).find('.btn-text').html('show less');
  } else {
    $moreTags.addClass('hidden')
    $(this).find('.btn-text').html('show more');
  }
  $(this).blur();
});

$(document).on('click', '.js-trigger-response-box', function(e) {
  e.preventDefault();
  $(this).closest('.list-forum-cards').find('.response_box').click();
});

$(document).on('click', '.miz-icon-image', function(e) {
  e.preventDefault();
  $(this).parent().parent().find('.upload-box input').click();
});

$(document).on('click', '#etiquette_modal_btn', function() {
  $('#etiquette_modal').modal({ backdrop: 'static' });
});

function initPostForm() {
  $.each($('.chips input, .sleek_form .form-group input.form-control, .sleek_form .form-group select.form-control, .sleek_form .form-group textarea.form-control'), function(index, input){
    $(input).parents('.form-group').toggleClass('hasValue', (input.value.length > 0));
  });

  $(document).on('focus blur', '.chips input, .sleek_form .form-group input.form-control, .sleek_form .form-group select.form-control, .sleek_form .form-group textarea.form-control', function (e) {
    $(this).parents('.form-group').toggleClass('focused', (e.type === 'focusin'));
    $(this).parents('.form-group').toggleClass('hasValue', (this.value.length > 0 || $(this).parents('.form-group').find('.chip').length > 0));
  }).trigger('blur');

  $('.forum-post-form').submit(function(e){
    tag_ids = $.map($('.tags.chips-autocomplete').material_chip('data'), function( element, i ) {
      return [element.id || element.label];
    });
    $("#post_tag_field").val(tag_ids.toString());
  });

	var postTags = $('.tags.chips-autocomplete').data('chip');
  if (postTags && postTags.length > 0){
    $('.tags.chips').parents('.form-group').addClass('hasValue')
  }

  $('.tags.chips-autocomplete').material_chip({
    placeholder: 'Type your tag...',
    data: postTags,
    addOnBlur: true,
    autocompleteOptions: {
      classes:{
        "ui-autocomplete":"chip-input-autocomplete"
      },
      position: { my: "left top+50", at: "left top"},
      source: function( request, response ) {
        $.ajax( {
          url: "/tags",
          dataType: "json",
          data: {
            term: request.term
          },
          success: function( data ) {
            response( data );
          }
        } );
      }
    }
  });
}

$(document).ready( function() {
  initPostForm();

  $(window).on('resize', function(event) {
    /* Act on the event */
    if ( $(this).width() >= 990 ){
      $('.hidden-md-down').show();
    }else{
      $('.hidden-md-down').hide();
    }
    $('.post-list').show();
  });
});

function initSCEditor(selector, options) {
  options = options || {}
  var domSelector = $(selector)[0];
  var defaults = {
    asyncUploadOptions: {
      url: '/attachments/upload.json',
      type: 'POST',
      dataType: 'json',
      singleFileUploads: true,
      add: function(e, data) {
        var file = data.files[0];
        if (!(/\.(gif|jpg|jpeg|tiff|png)$/i).test(file.name)) {
          alert('You must select an image file only');
          return;
        }
        if (file.size > 5000000) { // 5mb
          alert('Please upload a smaller image, max size is 5 MB');
          return;
        }
        data.submit();
      }
    },
    element: domSelector,
    toolbar: [
      {name: 'bold', action: Editor.toggleBold},
      {name: 'italic', action: Editor.toggleItalic},
      '|',

      {name: 'quote', action: Editor.toggleBlockquote},
      {name: 'unordered-list', action: Editor.toggleUnOrderedList},
      {name: 'ordered-list', action: Editor.toggleOrderedList},
      '|',

      {name: 'link', action: Editor.drawLink},
      {name: 'image', action: ''},
    ],
    status:true,
  };

  var options = Object.assign({}, defaults, options);
  var scEditor = new SCEditor(options);
  var $form = $(domSelector).closest('form');
  var inputFile = $form.find('.upload-box input[type=file]');

  $(".toggle-markdown-preview").click(function(e){
    e.preventDefault();
    $form.find(".toggle-markdown-preview").removeClass('active');
    $(this).addClass('active');
    scEditor.togglePreview(this);
  });

  scEditor.uploadFile(inputFile, options.asyncUploadOptions)

  // set line wrapping for editor
  if (scEditor.codemirror && scEditor.codemirror.options) {
    scEditor.codemirror.options['lineWrapping'] = true;
  }

  return scEditor;
}

function uploadFile(editor, selector, options) {
  var $selector = $(selector);
  $selector.attr('data-url', options.url);
  $selector.fileupload(options);

  $selector.bind('fileuploaddone', function(e, data) {
    var result = data.result;
    if (result.error) {
      alert(result.error);
      return;
    }
    editor.drawImageUri(result.path, result.title);
  });
  $selector.bind('fileuploadfail', function(e, data) {
    if (data.result) {
      alert(data.result.error);
      return;
    }
    alert('Oops! Server could not handle your request at the moment. Please try again later.')
  });
};

function drawImageUri(editor, uri, title) {
  var cm = editor.codemirror;
  var stat = getState(cm);
  _replaceSelection(cm, stat.image, '![' + title, '](' + uri + ')');
}

function _replaceSelection(cm, active, start, end) {
  var text;
  var startPoint = cm.getCursor('start');
  var endPoint = cm.getCursor('end');
  if (active) {
    text = cm.getLine(startPoint.line);
    start = text.slice(0, startPoint.ch);
    end = text.slice(startPoint.ch);
    cm.setLine(startPoint.line, start + end);
  } else {
    text = cm.getSelection();
    cm.replaceSelection(start + text + end);

    startPoint.ch += start.length;
    endPoint.ch += start.length;
  }
  cm.setSelection(startPoint, endPoint);
  cm.focus();
}

function getState(cm, pos) {
  pos = pos || cm.getCursor('start');
  var stat = cm.getTokenAt(pos);
  if (!stat.type) return {};

  var types = stat.type.split(' ');

  var ret = {}, data, text;
  for (var i = 0; i < types.length; i++) {
    data = types[i];
    if (data === 'strong') {
      ret.bold = true;
    } else if (data === 'variable-2') {
      text = cm.getLine(pos.line);
      if (/^\s*\d+\.\s/.test(text)) {
        ret['ordered-list'] = true;
      } else {
        ret['unordered-list'] = true;
      }
    } else if (data === 'atom') {
      ret.quote = true;
    } else if (data === 'em') {
      ret.italic = true;
    }
  }
  return ret;
}

function SCEditor(options) {
  Editor.call(this, options);
}

// inherit Person
SCEditor.prototype = Object.create(Editor.prototype);

SCEditor.prototype.drawImageUri = function(path, title) {
  drawImageUri(this, path, title);
};

SCEditor.prototype.uploadFile = function(selector, options) {
  uploadFile(this, selector, options);
}

SCEditor.prototype.createToolbar = function(items) {
  toolbar_wrapper = document.createElement('div');
  toolbar_wrapper.className = "forum-editor-toolbar clearfix";

  right_bar=document.createElement('div');
  right_bar.className = "pull-right";
  right_bar.appendChild(Editor.prototype.createToolbar.call(this,items));

  var uploadInput = document.createElement('div');
  uploadInput.className = 'upload-box hidden';
  uploadInput.innerHTML = "<input type='file' class='editor-upload-file' />";
  right_bar.appendChild(uploadInput);

  left_bar=document.createElement('div');
  left_bar.className='pull-left';
  left_bar.innerHTML="<a href='javascript:void(0)' id='markdown-write' class='toggle-markdown-preview active'>Write</a>" +
    "<a href='javascript:void(0)' id='markdown-preview' class='toggle-markdown-preview'>Preview</a>"
  toolbar_wrapper.appendChild(left_bar);
  toolbar_wrapper.appendChild(right_bar);

  var cmWrapper = this.codemirror.getWrapperElement();
  cmWrapper.parentNode.insertBefore(toolbar_wrapper, cmWrapper);
  return toolbar_wrapper;
}

SCEditor.prototype.togglePreview = function(sender){
  var parse = this.constructor.markdown;
  var cm = this.codemirror;
  var wrapper = cm.getWrapperElement();
  var preview = wrapper.lastChild;
  if (!/editor-preview/.test(preview.className)) {
    preview = document.createElement('div');
    preview.className = 'editor-preview';
    wrapper.appendChild(preview);
  }

  if(sender.id == "markdown-write"){
    preview.className = preview.className.replace(
      /\s*editor-preview-active\s*/g, ''
    );
    $("#markdown-write").addClass("active");
    $("#markdown-preview").removeClass("active");
  } else {

    setTimeout(function() {preview.className += ' editor-preview-active'}, 1);

    $("#markdown-write").removeClass("active");
    $("#markdown-preview").addClass("active");

  }
  var text = cm.getValue();
  preview.innerHTML = parse(text);
  $(preview).find("a").attr('target', '_blank');
}
