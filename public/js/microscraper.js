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
    $('form.ajax').each(function() {
	var method = $(this).attr('method');
	$(this).ajaxForm({
	    type : method,
	    success : function() {
		location.reload();
	    },
	    error : function(response, responseText) {
		$.error( responseText );
	    }
	});
    });
    
    /* Testing. Intercept test form submission and give it to the applet. */
    $('form.test').microscraper_applet({
	code : data.applet_class,
	archive : data.applet_jar,
	codebase : data.applet_dir
    });

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
			console.log(labels);
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
