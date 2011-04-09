/**
*
* JavaScript for MicroScraper.
*
**/

$(document).ready(function() {
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
    $('form.test').submit(function(event) {
	var $form = $(this),
	json_location = $form.attr('action'),
	data = $('body').data('microscraper');
	
	$form.spinner( { img : data.spinner_img } );
	
	var defaults = $form.serializeArray();
	    
	try {
	    /* Create the applet if this is the user's first click to test. */
	    if(!data.applet) {
		var $applet = $('<applet>').attr({
		    code : data.applet_class,
		    archive : data.applet_jar,
		    codebase : data.applet_dir,
		    width : "0",
		    height : "0"
		});
		$form.append($applet);
		data.applet = $form.children('applet').get(0);
	    }
	    
	    /* The applet will throw TypeErrors until it's ready. */
	    var tryScraper = function() {
		try {
		    data.applet.scrape(json_location, defaults);
		    $form.spinner('remove');
		} catch(error) {
		    if(error instanceof TypeError) {
			setTimeout(tryScraper, 100);
		    } else {
			$form.spinner('remove');
			// $.error(error);
			throw error;
		    }
		}
	    }
	    tryScraper();
	    
	    return false;
	} catch(error) {
	    $form.spinner('remove');
	    event.preventDefault();
	    $.error(error);
	}
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
