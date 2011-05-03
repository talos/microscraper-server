/**
*
* JavaScript for MicroScraper.
*
**/
$(document).ready(function() {
    // TODO: initialize this from mustache.
    var data = {
	'applet_dir'   : '/applets/', //'{{applet_dir}}',
	'applet_class' : 'net.microscraper.client.applet.MicroScraperApplet.class', //'{{applet_class}}',
	'applet_jar'   : 'MicroScraperApplet.jar',  //'{{applet_jar}}',
	'img_dir'      : '/img', //'{{img_dir}}',
	'spinner_img'  : '/imag/spinner.gif' //'{{spinner_img}}'
    };
    
    /* Allows for PUT and DELETE from forms, reloads upon success. */
    /* Also displays errors. */
    $('form.ajax').each(function() {
	var method = $(this).attr('method'),
	$form = $(this),
	$errorText = $('<span />'),
	$errorClose = $('<span />')
	    .addClass('ui-icon ui-icon-close')
	    .css({ float : 'right' , cursor : 'pointer' }),
	$error = $('<div />').addClass('ui-state-error')
	    .append($('<span />')
		    .addClass('ui-icon ui-icon-alert')
		    .css({ float : 'left' }))
	    .append($errorText)
	    .append($errorClose)
	    .hide();
	$errorClose.click(function() { $error.hide(); } );
	$form.append($error);
	$form.ajaxForm({
	    type : method,
	    success : function(response) {
		$error.hide();
		if(response) {
		    window.location = response;
		} else {
		    $(location).get(0).reload();
		}
	    },
	    error : function(response) {
		$errorText.text(response.responseText);
		$error.show();
	    }
	});
    });
    
    /* Testing. Intercept test form submission and give it to the applet. */
    $('form.test').microscraper_applet({
	code : data.applet_class,
	archive : data.applet_jar,
	codebase : data.applet_dir
    });

    /* Disabler. Give certain elements disable/enable functionality. */
    $('form.test textarea').disabler();

    /* Autofill 'add' inputs, which are used for tagging & resource creation. */
    $('input.add').each(function() {
	var $input = $(this);
	$input.autocomplete({
	    minLength : 1,
	    /* Replace 'term' with the input's name, plus wildcard. */
	    source : function ( request, response ) {
		var term = $input.attr('name'),
		data = {};
		data[term] = '%' + request.term + '%';
		$.ajax({
		    url : $input.attr('title'),
		    dataType : 'json',
		    data : data,
		    success : function ( labels ) {
			response ( labels );
		    },
		    error : function ( response, responseText ) {
			$.error( responseText );
		    }
		});
	    }
	});
    });
    /* Accordion. No longer used.  TODO: remove from UI library. */
    //$('.accordion').accordion({autoHeight: false});
    /* Button. */
    $('button').button();
    /* Tabs. */
    $('.tabs').tabs({
	cookie : {}
    });
});
